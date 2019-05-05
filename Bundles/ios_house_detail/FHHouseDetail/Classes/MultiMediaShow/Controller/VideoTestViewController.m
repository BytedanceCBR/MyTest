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
@property(nonatomic, strong) FHVideoViewController *videoVC;

@end

@implementation VideoTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self generateModel];
//    
//    self.mediaView = [[FHMultiMediaScrollView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 300)];
//    [self.view addSubview:_mediaView];
//    
//    [_mediaView updateWithModel:self.model];
    
    [self initVideoVC];
}

- (void)initVideoVC {
    self.videoVC = [[FHVideoViewController alloc] init];
    _videoVC.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_videoVC.view];
    _videoVC.view.frame = CGRectMake(0, 300, [UIScreen mainScreen].bounds.size.width, 300);
    
    FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
    itemModel.mediaType = FHMultiMediaTypeVideo;
    itemModel.videoID = @"v03004b60000bh57qrtlt63p5lgd20d0";
    itemModel.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9th6BUofQQc";
    itemModel.groupType = @"视频";

    [self updateVideo:itemModel];
}

- (void)updateVideo:(FHMultiMediaItemModel *)model {

    FHVideoModel *videoModel = [[FHVideoModel alloc] init];
    videoModel.videoID = model.videoID;
    videoModel.coverImageUrl = model.imageUrl;
    videoModel.muted = NO;
    videoModel.repeated = NO;
    videoModel.isShowControl = YES;

    [self.videoVC updateData:videoModel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)generateModel {
    
    self.model = [[FHMultiMediaModel alloc] init];
    
    NSMutableArray *itemArray = [NSMutableArray array];
    
    FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
    itemModel.mediaType = FHMultiMediaTypeVideo;
    itemModel.videoID = @"v03004b60000bh57qrtlt63p5lgd20d0";
    itemModel.imageUrl = @"https://p3.pstatp.com/origin/f100-image/RM9th6BUofQQc";
    itemModel.groupType = @"视频";
    [itemArray addObject:itemModel];
    
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
