//
//  SingleImageTestViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/31.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "SingleImageTestViewController.h"
#import "LYTestMultiTextureFilter.h"
#import "LYAssetReader.h"

#define MaxRow (2)
#define MaxColumn (3)

@interface SingleImageTestViewController ()
@property (nonatomic, strong) NSMutableArray<GPUImageView *> *gpuImageViewArray;
@property (nonatomic, strong) NSMutableArray<GPUImageMovie *> *gpuImageMovieArray;

@property (nonatomic, strong) NSMutableArray<LYAssetReader *> *lyReaderArray;


@property (nonatomic, strong) CADisplayLink *mDisplayLink;

@property (nonatomic, strong) LYTestMultiTextureFilter *lyMultiTextureFilter;

@end

@implementation SingleImageTestViewController

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
    self.lyReaderArray = [[NSMutableArray<LYAssetReader *> alloc] init];
    NSArray *fileNamesArray = @[@"mzd", @"my", @"mzd", @"my", @"mzd", @"my"];

    self.lyMultiTextureFilter = [[LYTestMultiTextureFilter alloc] initWithMaxFilter:MaxRow * MaxColumn];
    for (int indexRow = 0; indexRow < MaxRow; ++indexRow) {
        for (int indexColumn = 0; indexColumn < MaxColumn; ++indexColumn) {
            CGRect frame = CGRectMake(indexColumn * 1.0 / MaxColumn,
                                      indexRow * 1.0 / MaxRow,
                                      1.0 / MaxColumn,
                                      1.0 / MaxRow);
            NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:fileNamesArray[indexRow * MaxColumn + indexColumn] withExtension:@"mp4"];
            GPUImageMovie *movie = [[GPUImageMovie alloc] initWithURL:videoUrl];
            [self buildGPUImageViewWithFrame:frame imageMovie:movie];
            [self.gpuImageMovieArray addObject:movie];
            
            LYAssetReader *reader = [[LYAssetReader alloc] initWithUrl:videoUrl];
            [self.lyReaderArray addObject:reader];
        }
    }
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) / MaxColumn * MaxRow)];
    imageView.fillMode = kGPUImageFillModeStretch;
    
    [self.lyMultiTextureFilter addTarget:imageView];
    [self.view addSubview:imageView];
    
    UIButton *btn = [self createButton:@"DisPlay" frame:CGRectMake(50, 50, 100, 50)];
    [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}


- (void)onClick:(UIButton *)sender {
    if (!self.mDisplayLink) {
        self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displaylink:)];
        self.mDisplayLink.frameInterval = 2;
        [self.mDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}


- (void)buildGPUImageViewWithFrame:(CGRect)frame imageMovie:(GPUImageMovie *)imageMovie {
    // 1080 1920，这里已知视频的尺寸。如果不清楚视频的尺寸，可以先读取视频帧CVPixelBuffer，再用CVPixelBufferGetHeight/Width
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((1920 - 1080) / 2 / 1920, 0, 1080.0 / 1920, 1)];
    
    GPUImageTransformFilter *transformFilter = [[GPUImageTransformFilter alloc] init];
    transformFilter.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
    
    GPUImageOutput *tmpFilter;
    
    tmpFilter = imageMovie;
    
    [tmpFilter addTarget:cropFilter];
    tmpFilter = cropFilter;
    
    [tmpFilter addTarget:transformFilter];
    tmpFilter = transformFilter;
    
    NSInteger index = [self.lyMultiTextureFilter nextAvailableTextureIndex];
    [tmpFilter addTarget:self.lyMultiTextureFilter atTextureLocation:index];
    [self.lyMultiTextureFilter setDrawRect:frame atIndex:index];
    
    return ;
}

- (void)displaylink:(CADisplayLink *)displaylink {
    for (int index = 0; index < MaxRow * MaxColumn; ++index) {
        GPUImageMovie *imageMovie = self.gpuImageMovieArray[index];
        LYAssetReader *reader = self.lyReaderArray[index];
        
        static BOOL lyTest = NO;
        if (index == 3 && lyTest) {
            static BOOL hadRefresh = NO;
            if (!hadRefresh) {
                hadRefresh = YES;
                [self.lyMultiTextureFilter clearDrawRect:[self getFrameByIndex:index rowNum:MaxRow columnNum:MaxColumn]];
            }
            continue;
        }
        
        CMSampleBufferRef sampleBufferRef = [reader readBuffer];
        if (sampleBufferRef)
        {
            runSynchronouslyOnVideoProcessingQueue(^{
                [imageMovie processMovieFrame:sampleBufferRef];
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            });
        }
    }
}




- (CGRect)getFrameByIndex:(int)index rowNum:(int)rowNum columnNum:(int)columnNum {
    NSAssert(index < rowNum * columnNum, @"getFrameByIndex error");
    int row = (index + 1) / columnNum;
    int column = index % columnNum;
    CGRect frame = CGRectMake(column * 1.0 / columnNum,
                              row * 1.0 / rowNum,
                              1.0 / columnNum,
                              1.0 / rowNum);
    return frame;
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -- Button Create
- (UIButton *)createButton:(NSString *)title frame:(CGRect)frame
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor orangeColor];
    return btn;
}

@end
