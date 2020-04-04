//
//  GPUImageViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/24.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "GPUBaseViewController.h"


@interface GPUBaseViewController ()<UIGestureRecognizerDelegate>
- (UIImageView *)ImageView;
- (GPUImageView *)GPUImageView;
- (GPUImageVideoCamera *)GPUVideoCameraBack:(BOOL)isBack;

- (GPUImageFilter *)GPUFilterSepia;

@end

@implementation GPUBaseViewController

- (void)runGPUFunction
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self autoresizingMaskView:self.view];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    if (self.videoCamera) {
        self.videoCamera.outputImageOrientation = orientation;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.videoCamera) {
        [self.videoCamera stopCameraCapture];
    }
    _imageView = nil;
    _imageViewGPU= nil;
    _videoCamera = nil;
    _movieWriter = nil;
}

- (void)autoresizingMaskView:(UIView *)view
{
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark -- create Module

- (UIImageView *)ImageView
{
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = self.view.bounds;
    [self autoresizingMaskView:imageView];
    return imageView;
}

- (GPUImageView *)GPUImageView
{
    GPUImageView *imv = [[GPUImageView alloc]init];
    imv.fillMode = kGPUImageFillModePreserveAspectRatio;//kGPUImageFillModePreserveAspectRatioAndFill;
    imv.frame = self.view.bounds;
    [self autoresizingMaskView:imv];
    return imv;
}

- (GPUImageVideoCamera *)GPUVideoCameraBack:(BOOL)isBack
{
    AVCaptureDevicePosition position = isBack ? AVCaptureDevicePositionBack: AVCaptureDevicePositionFront;
   GPUImageVideoCamera *mGPUVideoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:position];
    mGPUVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

    return mGPUVideoCamera;
}

- (GPUImageFilter *)GPUFilterSepia
{
    GPUImageFilter *filter = [[GPUImageSepiaFilter alloc]init];
    return filter;
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
