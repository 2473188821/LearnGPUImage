//
//  FilterTiltShiftImageViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/24.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "FilterTiltShiftImageViewController.h"

@interface FilterTiltShiftImageViewController ()
@property(nonatomic,strong)GPUImagePicture          *picture;
@property(nonatomic,strong)GPUImageTiltShiftFilter  *filter;

@end

@implementation FilterTiltShiftImageViewController

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
    
    UIImage *inputImage = [UIImage imageNamed:@"man"];
    GPUImagePicture *sourcePicture = [[GPUImagePicture alloc]initWithImage:inputImage];
    _picture = sourcePicture;
    
    GPUImageTiltShiftFilter *filter = [[GPUImageTiltShiftFilter alloc]init];
    filter.blurRadiusInPixels = 40.0;
    [filter forceProcessingAtSize:self.imageViewGPU.sizeInPixels];
    _filter = filter;
    
    [sourcePicture addTarget:filter];
    [filter addTarget:self.imageViewGPU];
    [_picture processImage];
    
    // GPUImageContext相关的数据显示
    GLint size = [GPUImageContext maximumTextureSizeForThisDevice];
    GLint unit = [GPUImageContext maximumTextureUnitsForThisDevice];
    GLint vector = [GPUImageContext maximumVaryingVectorsForThisDevice];
    NSLog(@"--%s--%d %d %d",__func__, size, unit, vector);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    float rate = point.y / self.view.frame.size.height;
    NSLog(@"Processing---rate---<%f>----",rate);
    int offset = 0.1;
    [self.filter setTopFocusLevel:rate - offset];
    [self.filter setBottomFocusLevel:rate + offset];
    [_picture processImage];
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
