//
//  MovieMixViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/26.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "MovieMixViewController.h"
#import "THImageMovieWriter.h"
#import "THImageMovie.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface MovieMixViewController ()
@property (nonatomic , strong) UILabel  *mLabel;
@property (nonatomic, strong) THImageMovieWriter *movieWriterIM;
@property(nonatomic) dispatch_group_t recordSyncingDispatchGroup;

@end

@implementation MovieMixViewController
{
    THImageMovie *movieFile;
    THImageMovie *movieFile2;
    GPUImageOutput<GPUImageInput> *filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
#pragma mark -- HDS_MARK___MODIFY---TODO study
//        [self setupAudioAssetReader__TEST];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self autoresizingMaskView:filterView];
    [self.view addSubview:filterView];
    self.imageViewGPU = filterView;
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    filter = [[GPUImageDissolveBlendFilter alloc] init];
    [(GPUImageDissolveBlendFilter *)filter setMix:0.5];
    
    // 播放
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"desk" withExtension:@"mp4"];
    movieFile = [[THImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    
    NSURL *sampleURL2 = [[NSBundle mainBundle] URLForResource:@"qwe" withExtension:@"mp4"];
    movieFile2 = [[THImageMovie alloc] initWithURL:sampleURL2];
    movieFile2.runBenchmark = YES;
    movieFile2.playAtActualSpeed = YES;
    
    //movies
    NSArray *thMovies = @[movieFile, movieFile2];

    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriterIM = [[THImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640, 480) movies:thMovies];
    
    // 响应链
    [movieFile addTarget:filter];
    [movieFile2 addTarget:filter];
    
    // 显示到界面
    [filter addTarget:filterView];
    [filter addTarget:_movieWriterIM];
    
    [movieFile2 startProcessing];
    [movieFile startProcessing];
    [_movieWriterIM startRecording];
    
    CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
    
    __weak typeof(self) weakSelf = self;
    [_movieWriterIM setCompletionBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->filter removeTarget:strongSelf->_movieWriterIM];
        [strongSelf->movieFile endProcessing];
        [strongSelf->movieFile2 endProcessing];
        [strongSelf->_movieWriterIM finishRecording];
        
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

- (void)updateProgress
{
    self.mLabel.text = [NSString stringWithFormat:@"Progress:%d%%", (int)(movieFile.progress * 100)];
    [self.mLabel sizeToFit];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)printDuration:(NSURL *)url{
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:url options:inputOptions];
    
    [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler: ^{
        NSLog(@"movie: %@ duration: %.2f", url.lastPathComponent, CMTimeGetSeconds(inputAsset.duration));
    }];
}

- (void)setupAudioAssetReader__TEST
{
    NSString *pathURL_MY = [[NSBundle mainBundle]pathForResource:@"my" ofType:@"mp4"];
    NSURL *videoURL_MY = [NSURL fileURLWithPath:pathURL_MY];
    AVAsset *asset_MY = [AVAsset assetWithURL:videoURL_MY];
    
    NSString *pathURL_MZD = [[NSBundle mainBundle]pathForResource:@"my" ofType:@"mp4"];
    NSURL *videoURL_MZD = [NSURL fileURLWithPath:pathURL_MZD];
    AVAsset *asset_MZD = [AVAsset assetWithURL:videoURL_MZD];

    movieFile = [[THImageMovie alloc]initWithAsset:asset_MY];
    movieFile2 = [[THImageMovie alloc]initWithAsset:asset_MZD];
    
    NSMutableArray *audioTracks = [NSMutableArray array];
    
    for(GPUImageMovie *movie in @[movieFile, movieFile2]){
        AVAsset *asset = movie.asset;
        if(asset){
            NSArray *_audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
            if(_audioTracks.count > 0){
                [audioTracks addObject:_audioTracks.firstObject];
            }
        }
    }
    
    NSLog(@"audioTracks: %@", audioTracks);
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    for(AVAssetTrack *track in audioTracks){
        if(![track isKindOfClass:[NSNull class]]){
            NSLog(@"track url: %@ duration: %.2f", track.asset, CMTimeGetSeconds(track.asset.duration));
            AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio                                   preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, track.asset.duration)
                                                ofTrack:track
                                                 atTime:kCMTimeZero error:nil];
        }
    }
    
    //    AVMutableComposition* videoComposition = [AVMutableComposition composition];
    NSMutableArray *videoTracks = [NSMutableArray array];
    
    for(GPUImageMovie *movie in @[movieFile, movieFile2]){
        AVAsset *asset = movie.asset;
        if(asset){
            NSArray *_videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if(_videoTracks.count > 0){
                [videoTracks addObject:_videoTracks.firstObject];
            }
        }
    }
    
    NSLog(@"videoTracks: %@", videoTracks);
    
    for(AVAssetTrack *track in videoTracks){
        if(![track isKindOfClass:[NSNull class]]){
            NSLog(@"track url: %@ duration: %.2f", track.asset, CMTimeGetSeconds(track.asset.duration));
            AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo                                   preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, track.asset.duration)
                                                ofTrack:track
                                                 atTime:kCMTimeZero error:nil];
        }
    }
    
    //    NSMutableArray *trackMixArray = [NSMutableArray array];
    //
    //    // Add AudioMix to fade in the volume ramps
    //    AVMutableAudioMixInputParameters *trackMix1 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTracks[0]];
    //
    //    [trackMix1 setVolumeRampFromStartVolume:1.0 toEndVolume:0.0 timeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(1, 1), CMTimeMakeWithSeconds(5, 1))];
    //
    //    [trackMixArray addObject:trackMix1];
    //
    //    AVMutableAudioMixInputParameters *trackMix2 = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTracks[1]];
    //
    //    [trackMix2 setVolumeRampFromStartVolume:0.0 toEndVolume:1.0 timeRange:transitionTimeRanges[0]];
    //    [trackMix2 setVolumeRampFromStartVolume:1.0 toEndVolume:1.0 timeRange:passThroughTimeRanges[1]];
    //
    //    [trackMixArray addObject:trackMix2];
    
    
    AVAudioMix *audioMix = [AVMutableAudioMix audioMix];
    
    
    //    movieCompostion = [[GPUImageMovieComposition alloc] initWithComposition:mixComposition andVideoComposition:nil andAudioMix:audioMix];
}


@end
