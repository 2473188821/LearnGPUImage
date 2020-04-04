//
//  CoreMediaViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/30.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "CoreMediaViewController.h"
#import "SimpleEditor.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CoreMediaViewController ()
@property(nonatomic,strong)SimpleEditor *editor;
@property(nonatomic,strong)GPUImageMovieComposition *movieComposition;

@property(nonatomic,strong)NSMutableArray *clips;
@property(nonatomic,strong)NSMutableArray *clipTimeRanges;

@property(nonatomic)dispatch_group_t dis_group;

@end

@implementation CoreMediaViewController
{
    GPUImageOutput<GPUImageInput> *filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}


- (void)runGPUFunction
{
    GPUImageView *imageVGPU = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self autoresizingMaskView:imageVGPU];
    self.imageViewGPU =imageVGPU;
    [self.view addSubview:imageVGPU];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 260, 50)];
    label.textColor = [UIColor redColor];
    self.label = label;
    [self.view addSubview:label];
    
    filter = (GPUImageOutput<GPUImageInput>*)imageVGPU;
    
    self.clips = [NSMutableArray arrayWithCapacity:5];
    self.clipTimeRanges = [NSMutableArray arrayWithCapacity:5];
    self.editor = [[SimpleEditor alloc]init];
    
    [self setupEditingAndPlayBack];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLabelText)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [link setPaused:NO];
}

#pragma mark - Simple Editor
- (void)setupEditingAndPlayBack
{
    NSString *pathV1 = [[NSBundle mainBundle]pathForResource:@"mzd" ofType:@"mp4"];
    NSURL *urlV1 = [NSURL fileURLWithPath:pathV1];
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:urlV1];
    
    NSString *pathV2 = [[NSBundle mainBundle]pathForResource:@"my" ofType:@"mp4"];
    NSURL *urlV2 = [NSURL fileURLWithPath:pathV2];
    AVURLAsset *asset2 = [AVURLAsset assetWithURL:urlV2];
    
    dispatch_group_t group = dispatch_group_create();
    _dis_group = group;
    NSArray *assetKeysToLoadAndTest = @[@"tracks", @"duration", @"composable"];
    
    //加载视频
    [self loadAsset:asset1 keys:assetKeysToLoadAndTest dispatchGroup:group];
    [self loadAsset:asset2 keys:assetKeysToLoadAndTest dispatchGroup:group];
    
    //等待就绪
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self synchronizeWithEditor];
    });
}

//加载视频
- (void)loadAsset:(AVURLAsset *)asset keys:(NSArray *)keys dispatchGroup:(dispatch_group_t)group
{
    dispatch_group_enter(group);
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        // 测试是否成功加载
        BOOL bSuccess = YES;
        for (NSString *key in keys) {
            NSError *error = nil;
            if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                NSLog(@"Key value loading failed for key:%@ with error: %@", key, error);
                bSuccess = NO;
                break;
            }
        }
        if (![asset isComposable]) {
            NSLog(@"Asset is not composable");
            bSuccess = NO;
        }
        
        if (bSuccess && CMTimeGetSeconds(asset.duration) > 5.0) {
            [self.clips addObject:asset];
            NSValue *value = [NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1), CMTimeMakeWithSeconds(5, 1))];
            [self.clipTimeRanges addObject:value];
        }
        else {
            NSLog(@"error happened!");
        }
        
        dispatch_group_leave(group);
    }];
}

- (void)synchronizeWithEditor
{
    //1、synchronizeEditorClipsWithOurClips
    NSMutableArray *validClips = [NSMutableArray array];
    for (AVURLAsset *asset in self.clips) {
        if (![asset isKindOfClass:[NSNull class]]) {
            [validClips addObject:asset];
        }
    }
    self.editor.clips = validClips;
    
    //2、synchronizeEditorClipTimeRangesWithOurClipTimeRanges
    NSMutableArray *validClipTimeRanges = [NSMutableArray array];
    for (NSValue *timeRange in self.clipTimeRanges) {
        if (! [timeRange isKindOfClass:[NSNull class]]) {
            [validClipTimeRanges addObject:timeRange];
        }
    }
    self.editor.clipTimeRanges = validClipTimeRanges;
    
    self.editor.transitionDuration = CMTimeMakeWithSeconds(1, 600);
    [self.editor buildCompositionObjectsForPlayback];
    [self synchronizePlayerWithEditor];
}

/**  开始播放 */
- (void)synchronizePlayerWithEditor
{
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

    GPUImageMovieWriter *movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:movieURL size:CGSizeMake(640, 480)];
    self.movieWriter = movieWriter;
    
    GPUImageMovieComposition *movieComposition = [[GPUImageMovieComposition alloc]initWithComposition:self.editor.composition andVideoComposition:self.editor.videoComposition andAudioMix:self.editor.audioMix];
    self.movieComposition = movieComposition;
    
    movieComposition.runBenchmark = YES;
//    movieComposition.playAtActualSpeed = YES;
    
    [movieComposition addTarget:movieWriter];
    [movieComposition addTarget:filter];
    
    [movieComposition enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    movieComposition.audioEncodingTarget = movieWriter;
    
    [movieWriter startRecording];
    [movieComposition startProcessing];
    
    WS(weakSelf);
    [movieWriter setCompletionBlock:^{        
        [weakSelf.movieWriter finishRecording];
        [weakSelf.movieComposition endProcessing];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie))
        {
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (error) {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
                                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     } else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     }
                 });
             }];
        }
        else {
            NSLog(@"error mssg)");
        }
    }];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)updateLabelText
{
    self.label.text = [[NSDate dateWithTimeIntervalSinceNow:0]description];
}
@end
