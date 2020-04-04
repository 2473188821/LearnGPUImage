//
//  MovieWriterViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/24.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "MovieWriterViewController.h"
#import "GPUImageBeautifyFilter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MovieWriterViewController ()

@end

@implementation MovieWriterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    self.imageViewGPU = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self autoresizingMaskView:self.imageViewGPU];
    [self.view addSubview:self.imageViewGPU];
    
    self.videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:movieURL size:CGSizeMake(640, 480)];
    
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    self.movieWriter.encodingLiveVideo = YES;
        
    GPUImageBeautifyFilter *filter = [[GPUImageBeautifyFilter alloc]init];
    
    [self.videoCamera addTarget:filter];
    [filter addTarget:self.imageViewGPU];
    
    [filter addTarget:self.movieWriter];
    
    [self.videoCamera startCameraCapture];
    [self.movieWriter startRecording];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [filter removeTarget:self.movieWriter];
        [self.movieWriter finishRecording];
        
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
        };
    });
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
