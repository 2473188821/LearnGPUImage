//
//  MutiPlayViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/31.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "MutiImageViewViewController.h"

@interface MutiImageViewViewController ()
@property (nonatomic, strong) NSMutableArray<GPUImageView *> *gpuImageViewArray;
@property (nonatomic, strong) NSMutableArray<GPUImageMovie *> *gpuImageMovieArray;

@end

@implementation MutiImageViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    self.gpuImageViewArray = [[NSMutableArray<GPUImageView *> alloc] init];
    self.gpuImageMovieArray = [[NSMutableArray<GPUImageMovie *> alloc] init];
    
    NSArray *fileNamesArray = @[@"mzd", @"my", @"mzd", @"my", @"mzd", @"my"];
    
    for (int indexRow = 0; indexRow < 2; ++indexRow) {
        for (int indexColumn = 0; indexColumn < 3; ++indexColumn) {
            CGRect frame = CGRectMake(CGRectGetWidth(self.view.bounds) / 3 * indexColumn,
                                      100 + CGRectGetWidth(self.view.bounds) / 3 * indexRow,
                                      CGRectGetWidth(self.view.bounds) / 3,
                                      CGRectGetWidth(self.view.bounds) / 3);
            GPUImageMovie *movie = [self getGPUImageMovieWithFileName:fileNamesArray[indexRow * 3 + indexColumn]];
            GPUImageView *view = [self buildGPUImageViewWithFrame:frame imageMovie:movie];
            [self.gpuImageViewArray addObject:view];
            [self.gpuImageMovieArray addObject:movie];
        }
    }
}

- (GPUImageMovie *)getGPUImageMovieWithFileName:(NSString *)fileName
{
    NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp4"];
    
    GPUImageMovie *imageMovie = [[GPUImageMovie alloc] initWithURL:videoUrl];
    return imageMovie;
}

- (GPUImageView *)buildGPUImageViewWithFrame:(CGRect)frame imageMovie:(GPUImageMovie *)imageMovie {
    
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:frame];
    [self.view addSubview:imageView];
    
    // 1080 1920，这里已知视频的尺寸。如果不清楚视频的尺寸，可以先读取视频帧CVPixelBuffer，再用CVPixelBufferGetHeight/Width
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((1920 - 1080) / 2 / 1920, 0, 1080.0 / 1920, 1)];
    
    GPUImageTransformFilter *transformFilter = [[GPUImageTransformFilter alloc] init];
    //    transformFilter.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
    
    //响应链
    [imageMovie addTarget:cropFilter];
    [cropFilter addTarget:transformFilter];
    [transformFilter addTarget:imageView];
    
    imageMovie.playAtActualSpeed = YES;
    imageMovie.shouldRepeat = YES;
    
    [imageMovie startProcessing];
    
    return imageView;
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
