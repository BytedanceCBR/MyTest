//
//  FHNearbyViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHNearbyViewController.h"
#import "FHHotTopicView.h"
#import "FHInterestCommunityView.h"
#import "UIColor+Theme.h"
#import "FHCommunityFeedListController.h"

@interface FHNearbyViewController ()

@property(nonatomic ,strong) FHCommunityFeedListController *feedVC;

@end

@implementation FHNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.feedVC viewWillAppear];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];

    self.feedVC =[[FHCommunityFeedListController alloc] init];
    _feedVC.listType = FHCommunityFeedListTypeNearby;
    _feedVC.view.frame = self.view.bounds;
    [self addChildViewController:_feedVC];
    [self.view addSubview:_feedVC.view];
}

@end
