//
//  ViewController.m
//  LearnGPUImage
//
//  Created by Chenfy on 2020/3/24.
//  Copyright © 2020 Chenfy. All rights reserved.
//

#import "ViewController.h"
#pragma mark -- loying
#import "FilterImageViewController.h"
#import "FilterCameraViewController.h"
#import "MovieWriterViewController.h"
#import "FilterTiltShiftImageViewController.h"
#import "FilterVideoMixViewController.h"
#import "WaterMarkVideoViewController.h"
#import "MovieMixViewController.h"
#import "RawDataRenderViewController.h"
#import "CoreMediaViewController.h"
#import "SobelEdgeViewController.h"
#import "FaceRecognitionViewController.h"
#import "VideoBackImageReplaceViewController.h"
#import "MutiImageViewViewController.h"
#import "SingleImageViewViewController.h"
#import "SingleLessDrawViewController.h"
#import "SingleImageTestViewController.h"
#import "TestCIImageViewController.h"
#pragma mark -- GPUImage
#import "CubeViewController.h"
#import "FilterListViewController.h"
#import "MultiViewViewController.h"
#import "PhotoViewController.h"

//SCREEN_SIZE 屏幕尺寸
#define KSCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define KSCREEN_HEIGTH  ([UIScreen mainScreen].bounds.size.height)

#pragma mark -- step 001 -- add enum value
typedef NS_ENUM(NSInteger,GPUActionType) {
    GPUActionType_filterImage,
    GPUActionType_filterCamera,
    GPUActionType_movieWriter,
    GPUActionType_tiltShiftImage,
    GPUActionType_filterVideoMix,
    GPUActionType_watermarkVideo,
    GPUActionType_movieMix,
    GPUActionType_rawDataRender,
    GPUActionType_coreMedia,
    GPUActionType_sobelEdge,
    GPUActionType_faceRecognition,
    GPUActionType_videoBackImageReplace,
    GPUActionType_mutiPlay,
    GPUActionType_singleImageView,
    GPUActionType_singleLessDraw,
    GPUActionType_singleImageTest,
    GPUActionType_testCIImage,
    
    GPUActionType_cubeVideo,
    GPUActionType_filterList,
    GPUActionType_mutiView,
    GPUActionType_photoView,


};

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *dataSource;

@end

@implementation ViewController

#pragma mark -- step 002  -- add content value
- (NSArray *)dataSource
{
    return @[@"Filter Image",
             @"Filter Camera",
             @"Movie Writer",
             @"TiltShift Image",
             @"Filter Video Mix",
             @"WaterMark Video",
             @"Movie Mix",
             @"RawData Render",
             @"Core Media",
             @"Sobel Edge",
             @"Face recognition",
             @"Video Backimage replace",
             @"Muti ImageView play",
             @"Single ImageView play",
             @"Single Less Draw",
             @"Single Image Test",
             @"Test CIImage",
    
             @"Cube Video",
             @"Filter List Show",
             @"Muti View",
             @"Photo View",];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GPUImage Test";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

#pragma mark --
#pragma mark -- tableView
- (UITableView *)tableView
{
    if (!_tableView)
    {
        CGRect fm = CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGTH);
        _tableView = [[UITableView alloc]initWithFrame:fm style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    NSString *content = self.dataSource[indexPath.row];
    NSString *showMessage = [NSString stringWithFormat:@"%ld、%@",(long)indexPath.row + 1,content];
    cell.textLabel.text = showMessage;
    
    return cell;
}

#pragma mark -- step 003 -- add selected event
-  (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GPUBaseViewController *controller = nil;
    switch (indexPath.row) {
        case GPUActionType_filterImage:
                controller = [FilterImageViewController new];
            break;
            
        case GPUActionType_filterCamera:
                controller = [FilterCameraViewController new];
            break;

        case GPUActionType_movieWriter:
                controller = [MovieWriterViewController new];
            break;
            
        case GPUActionType_tiltShiftImage:
                controller = [FilterTiltShiftImageViewController new];
            break;
            
        case GPUActionType_filterVideoMix:
                controller = [FilterVideoMixViewController new];
            break;
            
        case GPUActionType_watermarkVideo:
                controller = [WaterMarkVideoViewController new];
            break;
            
        case GPUActionType_movieMix:
                controller = [MovieMixViewController new];
            break;

        case GPUActionType_rawDataRender:
            controller = [RawDataRenderViewController new];
            break;
            
        case GPUActionType_coreMedia:
            controller = [CoreMediaViewController new];
            break;

        case GPUActionType_sobelEdge:
            controller = [SobelEdgeViewController new];
            break;
           
        case GPUActionType_faceRecognition:
            controller = [FaceRecognitionViewController new];
            break;
        
        case GPUActionType_videoBackImageReplace:
            controller = [VideoBackImageReplaceViewController new];
            break;
        
        case GPUActionType_mutiPlay:
            controller = [MutiImageViewViewController new];
            break;
        
        case GPUActionType_singleImageView:
            controller = [SingleImageViewViewController new];
            break;
        
        case GPUActionType_singleLessDraw:
            controller = [SingleLessDrawViewController new];
            break;
        
        case GPUActionType_singleImageTest:
            controller = [SingleImageTestViewController new];
            break;
            
        case GPUActionType_testCIImage:
            controller = [TestCIImageViewController new];
            break;
            
         case GPUActionType_cubeVideo:
            controller = [CubeViewController new];
            break;
            
        case GPUActionType_filterList:
            controller = [FilterListViewController new];
            break;
        
        case GPUActionType_mutiView:
            controller = [MultiViewViewController new];
            break;
            
        case GPUActionType_photoView:
            controller = [PhotoViewController new];
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:controller animated:YES];
}


@end
