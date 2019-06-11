//
//  FHMyJoinViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHMyJoinViewController.h"
#import "FHCommunityFeedListController.h"

@interface FHMyJoinViewController ()

@end

@implementation FHMyJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initConstraints];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    FHCommunityFeedListController *vc =[[FHCommunityFeedListController alloc] init];
    vc.listType = FHCommunityFeedListTypeMyJoin;
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

- (void)initConstraints {
    
}

@end
