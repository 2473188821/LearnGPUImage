//
//  GPUImageViewController.h
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/24.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImageFramework.h>

NS_ASSUME_NONNULL_BEGIN

//SCREEN_SIZE 屏幕尺寸
#define KSCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define KSCREEN_HEIGTH  ([UIScreen mainScreen].bounds.size.height)

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

typedef void(^MainThreadBlock)(void);

@interface GPUBaseViewController : UIViewController
@property(nonatomic,strong)UILabel       *label;
@property(nonatomic,strong)UIImageView   *imageView;

@property(nonatomic,strong)GPUImageView         *imageViewGPU;
@property(nonatomic,strong)GPUImageMovie        *movieFile;
@property(nonatomic,strong)GPUImageMovieWriter  *movieWriter;
@property(nonatomic,strong)GPUImageVideoCamera  *videoCamera;

@property(nonatomic,strong)GPUImageRawDataInput  *rawDataInput;
@property(nonatomic,strong)GPUImageRawDataOutput *rawDataOutput;


- (void)runGPUFunction;
#pragma mark -- tool func
- (void)autoresizingMaskView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
