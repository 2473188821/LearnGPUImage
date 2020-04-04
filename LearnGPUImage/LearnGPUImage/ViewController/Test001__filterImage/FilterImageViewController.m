//
//  FilterImageViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/24.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "FilterImageViewController.h"

@interface FilterImageViewController ()

@end

@implementation FilterImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    UIImage *image = [UIImage imageNamed:@"man"];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self autoresizingMaskView:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    self.imageView = imageView;
    [self.view addSubview:self.imageView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showFilterImage:image];
    });
    // Do any additional setup after loading the view.
}

- (void)showFilterImage:(UIImage *)image
{
    GPUImageFilter *filter = [[GPUImageSepiaFilter alloc]init];

    UIImage *newImage = [filter imageByFilteringImage:image];
    self.imageView.image = newImage;
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
