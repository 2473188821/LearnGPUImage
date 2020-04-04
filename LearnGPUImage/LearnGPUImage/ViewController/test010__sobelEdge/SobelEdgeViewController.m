//
//  SobelEdgeViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/31.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "SobelEdgeViewController.h"

@interface SobelEdgeViewController ()
@property(nonatomic,strong)GPUImageSobelEdgeDetectionFilter *filter;

@end

@implementation SobelEdgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    GPUImageView *imageVGPU = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self autoresizingMaskView:imageVGPU];
    self.imageViewGPU = imageVGPU;
    [self.view addSubview:imageVGPU];
    
    GPUImageSobelEdgeDetectionFilter *filter = [[GPUImageSobelEdgeDetectionFilter alloc]init];
    filter.edgeStrength = 2;
    _filter = filter;
    
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera = videoCamera;
    
    [videoCamera addTarget:filter];
    [filter addTarget:imageVGPU];
    
    [videoCamera startCameraCapture];
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
