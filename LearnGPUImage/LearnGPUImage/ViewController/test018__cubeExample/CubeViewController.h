//
//  CubeViewController.h
//  LearnGPUImage
//
//  Created by Chenfy on 2020/4/1.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "GPUBaseViewController.h"
#import "ES2Renderer.h"

NS_ASSUME_NONNULL_BEGIN

@interface CubeViewController : GPUBaseViewController
{
    CGPoint lastMovementPosition;
@private
    ES2Renderer *renderer;
    GPUImageTextureInput *textureInput;
    GPUImageFilter *filter;
    
    NSDate *startTime;
}

- (void)drawView:(id)sender;

@end

NS_ASSUME_NONNULL_END
