//
//  VideoTestViewController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/11.
//

#import "VideoTestViewController.h"
#import "FHMultiMediaScrollView.h"
#import "FHMultiMediaModel.h"

@interface VideoTestViewController ()

@property(nonatomic, strong) FHMultiMediaScrollView *mediaView;
@property(nonatomic, strong) FHMultiMediaModel *model;

@end

@implementation VideoTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self generateModel];
    
    self.mediaView = [[FHMultiMediaScrollView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    [self.view addSubview:_mediaView];
    
    [_mediaView updateWithModel:self.model];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)generateModel {
    
    self.model = [[FHMultiMediaModel alloc] init];
    
    NSMutableArray *itemArray = [NSMutableArray array];
    
//    FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
//    itemModel.mediaType = FHMultiMediaTypeVideo;
//    itemModel.videoUrl = @"https://aweme.snssdk.com/aweme/v1/play/?video_id=v03033c20000bbvd7nlehji8cghrbb20&line=0&ratio=default&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0";
//    itemModel.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9th6BUofQQc";
//    itemModel.groupType = @"视频";
//    [itemArray addObject:itemModel];
    
    FHMultiMediaItemModel *itemModel2 = [[FHMultiMediaItemModel alloc] init];
    itemModel2.mediaType = FHMultiMediaTypePicture;
    itemModel2.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9th6BUofQQc";
    itemModel2.groupType = @"图片";
    [itemArray addObject:itemModel2];
    
    FHMultiMediaItemModel *itemModel3 = [[FHMultiMediaItemModel alloc] init];
    itemModel3.mediaType = FHMultiMediaTypePicture;
    itemModel3.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9thgq2vC0ycF";
    itemModel3.groupType = @"图片";
    [itemArray addObject:itemModel3];
    
    FHMultiMediaItemModel *itemModel4 = [[FHMultiMediaItemModel alloc] init];
    itemModel4.mediaType = FHMultiMediaTypePicture;
    itemModel4.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9thfQ36dAgvc";
    itemModel4.groupType = @"户型";
    [itemArray addObject:itemModel4];
    
    FHMultiMediaItemModel *itemModel5 = [[FHMultiMediaItemModel alloc] init];
    itemModel5.mediaType = FHMultiMediaTypePicture;
    itemModel5.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9thgLATrEhGe";
    itemModel5.groupType = @"户型";
    [itemArray addObject:itemModel5];
    
    self.model.medias = itemArray;
}

@end
