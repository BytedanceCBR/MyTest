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

@end
