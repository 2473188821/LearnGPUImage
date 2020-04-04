//
//  RawDataRenderViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/27.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "RawDataRenderViewController.h"

@interface RawDataRenderViewController ()

@end

@implementation RawDataRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runGPUFunction];
    });
    // Do any additional setup after loading the view.
}

- (void)runGPUFunction
{
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    [self autoresizingMaskView:imageV];
    [self.view addSubview:imageV];
    self.imageView = imageV;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 220, 50)];
    [label sizeToFit];
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
    self.label = label;
    
    GPUImageVideoCamera *camera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    camera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera = camera;

//    GPUImageRawDataOutput *output = [[GPUImageRawDataOutput alloc]initWithImageSize:CGSizeMake(640, 480) resultsInBGRAFormat:YES];
    GPUImageRawDataOutput *output = [[GPUImageRawDataOutput alloc]initWithImageSize:CGSizeMake(640, 480) resultsInBGRAFormat:NO];
    self.rawDataOutput = output;
    
    [camera addTarget:output];
    
    WS(weakSelf);
    [output setNewFrameAvailableBlock:^{
        __strong GPUImageRawDataOutput *strongOutput = weakSelf.rawDataOutput;

        [strongOutput lockFramebufferForReading];
        GLubyte *outputBytes = [strongOutput rawBytesForImage];
        NSInteger bytesPerRow = [strongOutput bytesPerRowInOutput];
        
//        [RawDataRenderViewController convertBGRAtoRGBA:outputBytes withSize:bytesPerRow * 480];
//        NSData* data = [[NSData alloc] initWithBytes:strongOutput.rawBytesForImage length:bytesPerRow * 480];
//        UIImage *image1 = [[UIImage alloc] initWithData:data];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.imageView.image = image1;
//        });
//        return ;
        
        CVPixelBufferRef pixelBuffer= NULL;
        CVReturn ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, 640, 480, kCMPixelFormat_32BGRA, outputBytes, bytesPerRow, nil, nil, nil, &pixelBuffer);
        if (ret != kCVReturnSuccess) {
             NSLog(@"status %d", ret);
        }
        [strongOutput unlockFramebufferAfterReading];
        
        if (pixelBuffer == NULL) {
            return ;
        }
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGDataProviderRef dataProvideRef = CGDataProviderCreateWithData(NULL, outputBytes, bytesPerRow * 480, NULL);
//OK
//        CGImageRef cgimage = CGImageCreate(640, 480, 8, 32, bytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, dataProvideRef, NULL, true, kCGRenderingIntentDefault);
// 异常一
//        CGImageRef cgimage = CGImageCreate(640, 480, 2, 32, bytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, dataProvideRef, NULL, true, kCGRenderingIntentDefault);
// 异常二
//        CGImageRef cgimage = CGImageCreate(480, 640, 8, 32, bytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, dataProvideRef, NULL, true, kCGRenderingIntentDefault);

        CGImageRef cgimage = CGImageCreate(640, 480, 8, 32, bytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, dataProvideRef, NULL, true, kCGRenderingIntentDefault);
        UIImage *image = [UIImage imageWithCGImage:cgimage];
        [weakSelf updateWithImage:image];
        
        CGImageRelease(cgimage);
        CFRelease(pixelBuffer);
    }];
    
    //开始采集
    [camera startCameraCapture];
    
    CADisplayLink *dislink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dislink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dislink setPaused:NO];
}

+ (void)convertBGRAtoRGBA:(unsigned char *)data withSize:(size_t)sizeOfData {
    for (unsigned char *p = data; p < data + sizeOfData; p += 4) {
        unsigned char r = *(p + 2);
        unsigned char b = *p;
        *p = r;
        *(p + 2) = b;
    }
}

- (void)updateWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)updateProgress
{
    NSString *messge = [[NSDate dateWithTimeIntervalSinceNow:0]description];
    self.label.text = messge;
}

@end
