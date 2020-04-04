//
//  CubeViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/4/1.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "CubeViewController.h"

@interface CubeViewController ()

@end

@implementation CubeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:primaryView];
    self.imageViewGPU = primaryView;
    
    renderer = [[ES2Renderer alloc] initWithSize:[primaryView sizeInPixels]];
    
    textureInput = [[GPUImageTextureInput alloc] initWithTexture:renderer.outputTexture size:[primaryView sizeInPixels]];
    filter = [[GPUImagePixellateFilter alloc] init];
    [(GPUImagePixellateFilter *)filter setFractionalWidthOfAPixel:0.01];
    
    //    filter = [[GPUImageGaussianBlurFilter alloc] init];
    //    [(GPUImageGaussianBlurFilter *)filter setBlurSize:3.0];
    
    [textureInput addTarget:filter];
    [filter addTarget:primaryView];
    
    [renderer setNewFrameAvailableBlock:^{
        float currentTimeInMilliseconds = [[NSDate date] timeIntervalSinceDate:startTime] * 1000.0;
        
        [textureInput processTextureWithFrameTime:CMTimeMake((int)currentTimeInMilliseconds, 1000)];
    }];
    
    [renderer startCameraCapture];
    
}

#pragma mark -
#pragma mark Touch-handling methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableSet *currentTouches = [[event touchesForView:self.view] mutableCopy];
    [currentTouches minusSet:touches];
    
    // New touches are not yet included in the current touches for the view
    lastMovementPosition = [[touches anyObject] locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    CGPoint currentMovementPosition = [[touches anyObject] locationInView:self.view];
    [renderer renderByRotatingAroundX:(currentMovementPosition.x - lastMovementPosition.x) rotatingAroundY:(lastMovementPosition.y - currentMovementPosition.y)];
    lastMovementPosition = currentMovementPosition;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableSet *remainingTouches = [[event touchesForView:self.view] mutableCopy];
    [remainingTouches minusSet:touches];
    
    lastMovementPosition = [[remainingTouches anyObject] locationInView:self.view];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Handle touches canceled the same as as a touches ended event
    [self touchesEnded:touches withEvent:event];
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
