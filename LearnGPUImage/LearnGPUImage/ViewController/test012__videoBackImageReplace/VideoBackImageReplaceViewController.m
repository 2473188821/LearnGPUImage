//
//  VideoBackImageReplaceViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/31.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "VideoBackImageReplaceViewController.h"

@interface VideoBackImageReplaceViewController ()
@property (nonatomic, strong) GPUImageMovie *movieGreen;
@property (nonatomic, strong) GPUImageMovie *movieNormal;
@end

@implementation VideoBackImageReplaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    NSString *pathGreen = [[NSBundle mainBundle]pathForResource:@"greenscreen" ofType:@"mp4"];
//    NSString *pathGreen = [[NSBundle mainBundle]pathForResource:@"car" ofType:@"mp4"];
    NSURL *urlGreen = [NSURL fileURLWithPath:pathGreen];

    NSString *pathNormal = [[NSBundle mainBundle]pathForResource:@"mzd" ofType:@"mp4"];
    NSURL *urlVNormal = [NSURL fileURLWithPath:pathNormal];

    GPUImageMovie *movieGreen = [[GPUImageMovie alloc]initWithURL:urlGreen];
    movieGreen.playAtActualSpeed = YES;
    movieGreen.shouldRepeat = YES;
    self.movieGreen = movieGreen;
    
    GPUImageMovie *movieNormal = [[GPUImageMovie alloc]initWithURL:urlVNormal];
    movieNormal.playAtActualSpeed = YES;
    movieNormal.shouldRepeat = YES;
    
    GPUImageView *imageVGPU = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self autoresizingMaskView:imageVGPU];
    [self.view addSubview:imageVGPU];
    self.imageViewGPU = imageVGPU;
    
    GPUImageChromaKeyBlendFilter *filter = [[GPUImageChromaKeyBlendFilter alloc]init];
    
    [movieGreen addTarget:filter];
    [movieNormal addTarget:filter];

    [filter addTarget:imageVGPU];
    
    [movieGreen startProcessing];
    [movieNormal startProcessing];
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
