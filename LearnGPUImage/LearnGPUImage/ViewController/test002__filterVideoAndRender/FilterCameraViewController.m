//
//  FilterVideoViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/24.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "FilterCameraViewController.h"

@interface FilterCameraViewController ()

@end

@implementation FilterCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    CGRect frm = CGRectMake(100, 100, 200, 200);
    frm = self.view.bounds;
    self.imageViewGPU = [[GPUImageView alloc]initWithFrame:frm];
    [self autoresizingMaskView:self.imageViewGPU];
    [self.view addSubview:self.imageViewGPU];
    
    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc]init];
    
    self.videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    //一、添加滤镜
    [self.videoCamera addTarget:filter];
    [filter addTarget:self.imageViewGPU];
    //二、元数据展示
//    [self.videoCamera addTarget:self.imageViewGPU];

    [self.videoCamera startCameraCapture];
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
