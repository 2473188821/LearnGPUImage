#import <UIKit/UIKit.h>
#import "GPUBaseViewController.h"

@interface PhotoViewController : GPUBaseViewController
{
    GPUImageStillCamera *stillCamera;
    GPUImageOutput<GPUImageInput> *filter, *secondFilter, *terminalFilter;
    UISlider *filterSettingsSlider;
    UIButton *photoCaptureButton;
    
    GPUImagePicture *memoryPressurePicture1, *memoryPressurePicture2;
}

- (IBAction)updateSliderValue:(id)sender;
- (IBAction)takePhoto:(id)sender;

@end
