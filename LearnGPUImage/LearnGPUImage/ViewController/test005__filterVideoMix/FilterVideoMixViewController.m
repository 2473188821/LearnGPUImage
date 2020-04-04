//
//  FilterVideoMixViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/25.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "FilterVideoMixViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FilterVideoMixViewController ()
@property(nonatomic,strong)GPUImageDissolveBlendFilter *filter;

@end

@implementation FilterVideoMixViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    self.imageViewGPU = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self autoresizingMaskView:self.imageViewGPU];
    [self.view addSubview:self.imageViewGPU];
    
    //滤镜
    GPUImageDissolveBlendFilter *filter = [[GPUImageDissolveBlendFilter alloc]init];
    [filter setMix:0.5];
    _filter = filter;
    
    //camera
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera = videoCamera;
    [videoCamera startCameraCapture];
        
    //movie file
    NSURL *sampleURL = [[NSBundle mainBundle]URLForResource:@"desk" withExtension:@"mp4"];
    GPUImageMovie *movieFile = [[GPUImageMovie alloc]initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    GPUImageMovieWriter *movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:movieURL size:CGSizeMake(640, 480)];
    BOOL audioFromFile = NO;
    
    if (audioFromFile) {
        [movieFile addTarget:filter];
        [videoCamera addTarget:filter];
        movieWriter.shouldPassthroughAudio = YES;
        movieFile.audioEncodingTarget = movieWriter;
        [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    }
    else
    {
        [videoCamera addTarget:filter];
        [movieFile addTarget:filter];
        movieWriter.shouldPassthroughAudio = NO;
        videoCamera.audioEncodingTarget = movieWriter;
        movieWriter.encodingLiveVideo = NO;
    }
    //渲染到界面
    [filter addTarget:self.imageViewGPU];
    [filter addTarget:movieWriter];
    
    [videoCamera startCameraCapture];
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    WS(weakSelf);
    [movieWriter setCompletionBlock:^{
        [weakSelf.filter removeTarget:weakSelf.movieWriter];
        [weakSelf.movieWriter finishRecording];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie)) {
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
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
