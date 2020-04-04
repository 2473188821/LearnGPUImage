//
//  SingleImageViewViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/31.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "SingleImageViewViewController.h"
#import "LYMultiTextureFilter.h"

#define MaxRow (2)
#define MaxColumn (3)

@interface SingleImageViewViewController ()
@property (nonatomic, strong) NSMutableArray<GPUImageMovie *> *gpuImageMovieArray;

@property (nonatomic, strong) CADisplayLink *mDisplayLink;

@property (nonatomic, strong) LYMultiTextureFilter *lyMultiTextureFilter;

@end

@implementation SingleImageViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    self.gpuImageMovieArray = [[NSMutableArray<GPUImageMovie *> alloc] init];
    NSArray *fileNamesArray = @[@"mzd", @"my", @"mzd", @"my", @"mzd", @"my"];

    self.lyMultiTextureFilter = [[LYMultiTextureFilter alloc] initWithMaxFilter:MaxRow * MaxColumn];
    for (int indexRow = 0; indexRow < MaxRow; ++indexRow) {
        for (int indexColumn = 0; indexColumn < MaxColumn; ++indexColumn) {
            CGRect frame = CGRectMake(indexColumn * 1.0 / MaxColumn,
                                      indexRow * 1.0 / MaxRow,
                                      1.0 / MaxColumn,
                                      1.0 / MaxRow);
            GPUImageMovie *movie = [self getGPUImageMovieWithFileName:fileNamesArray[indexRow * MaxColumn + indexColumn]];
            [self buildGPUImageViewWithFrame:frame imageMovie:movie];
            [self.gpuImageMovieArray addObject:movie];
        }
    }
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) / MaxColumn * MaxRow)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.fillMode = kGPUImageFillModeStretch;
    [self.lyMultiTextureFilter addTarget:imageView];
    [self.view addSubview:imageView];
}

- (GPUImageMovie *)getGPUImageMovieWithFileName:(NSString *)fileName {
    NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp4"];
    
    GPUImageMovie *imageMovie = [[GPUImageMovie alloc] initWithURL:videoUrl];
    return imageMovie;
}

- (void)buildGPUImageViewWithFrame:(CGRect)frame imageMovie:(GPUImageMovie *)imageMovie {
    // 1080 1920，这里已知视频的尺寸。如果不清楚视频的尺寸，可以先读取视频帧CVPixelBuffer，再用CVPixelBufferGetHeight/Width
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((1920 - 1080) / 2 / 1920, 0, 1080.0 / 1920, 1)];
    
    GPUImageTransformFilter *transformFilter = [[GPUImageTransformFilter alloc] init];
//    transformFilter.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
    
    GPUImageOutput *tmpFilter;
    
    tmpFilter = imageMovie;
    
    [tmpFilter addTarget:cropFilter];
    tmpFilter = cropFilter;
    
    [tmpFilter addTarget:transformFilter];
    tmpFilter = transformFilter;
//    [imageView setInputRotation:kGPUImageRotateRight atIndex:0];
    
    NSInteger index = [self.lyMultiTextureFilter nextAvailableTextureIndex];
    [tmpFilter addTarget:self.lyMultiTextureFilter atTextureLocation:index];
    [self.lyMultiTextureFilter setDrawRect:frame atIndex:index];
    
    imageMovie.playAtActualSpeed = YES;
    imageMovie.shouldRepeat = YES;
    
    [imageMovie startProcessing];
    
    return ;
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
