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

@end

@implementation FHNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initConstraints];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];

    FHCommunityFeedListController *vc =[[FHCommunityFeedListController alloc] init];
    vc.listType = FHCommunityFeedListTypeNearby;
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

- (void)initConstraints {

}

@end
