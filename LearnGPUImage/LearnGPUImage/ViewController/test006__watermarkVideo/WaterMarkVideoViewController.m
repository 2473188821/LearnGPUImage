//
//  WaterMarkVideoViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/25.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "WaterMarkVideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface WaterMarkVideoViewController ()
@property(nonatomic,strong)GPUImageDissolveBlendFilter *filter;

@property (nonatomic , strong) UILabel  *mLabel;
@end

@implementation WaterMarkVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    
    // Do any additional setup after loading the view.
}

- (void)updateProgress
{
    self.mLabel.text = [NSString stringWithFormat:@"Progress:%d%%", (int)(self.movieFile.progress * 100)];
    [self.mLabel sizeToFit];
}

- (void)runGPUFunction
{
    self.imageViewGPU = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self autoresizingMaskView:self.imageViewGPU];
    [self.view addSubview:self.imageViewGPU];
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 50)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    //播放
    NSURL *sampleURL = [[NSBundle mainBundle]URLForResource:@"desk" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:sampleURL];
    GPUImageMovie *movieFile = [[GPUImageMovie alloc]initWithAsset:asset];
    //    GPUImageMovie *movieFile = [[GPUImageMovie alloc]initWithURL:sampleURL];
    movieFile.runBenchmark = NO;
    movieFile.playAtActualSpeed = YES;
    self.movieFile = movieFile;
    
    //水印
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, 100, 100, 50)];
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:30];
    label.text = @"我是水印！";
    
    UIImage *image = [UIImage imageNamed:@"watermark"];
    UIImageView *imageV = [[UIImageView alloc]initWithImage:image];
    UIView *backView = [[UIView alloc]initWithFrame:self.view.bounds];
    backView.backgroundColor = [UIColor clearColor];
    imageV.center = backView.center;
    
    [backView addSubview:label];
    [backView addSubview:imageV];
    
    //滤镜
    GPUImageDissolveBlendFilter *filterDissolve = [[GPUImageDissolveBlendFilter alloc]init];
    [filterDissolve setMix:0.5];
    _filter = filterDissolve;
    
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc]initWithView:backView];
    
    // movie writer
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    GPUImageMovieWriter *movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:movieURL size:CGSizeMake(640, 480)];
    self.movieWriter = movieWriter;
    
    //GPUImageTransformFilter 动画的filter
    GPUImageFilter *progressFilter = [[GPUImageFilter alloc] init];
    [movieFile addTarget:progressFilter];
    
    [progressFilter addTarget:filterDissolve];
    [uielement addTarget:filterDissolve];
    
    movieWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    // 显示到界面
    [filterDissolve addTarget:self.imageViewGPU];
    [filterDissolve addTarget:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    WS(weakSelf);
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        CGRect frame = imageV.frame;
        frame.origin.x += 1;
        frame.origin.y += 1;
        imageV.frame = frame;
        [uielement updateWithTimestamp:time];
    }];
    
    [movieWriter setCompletionBlock:^{
        [weakSelf.filter removeTarget:weakSelf.movieWriter];
        [weakSelf.movieWriter finishRecording];
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

@end
