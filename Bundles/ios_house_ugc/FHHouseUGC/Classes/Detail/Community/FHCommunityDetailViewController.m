//
//  FHCommunityDetailViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHCommunityDetailViewController.h"
#import "FHCommunityDetailViewModel.h"

@interface FHCommunityDetailViewController ()
@property(nonatomic, copy) NSString *communityId;
@property(nonatomic, strong) FHCommunityDetailViewModel *viewModel;
@end

@implementation FHCommunityDetailViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.communityId = paramObj.allParams[@"community_id"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initViewModel];
}

- (void)initView {
    [self setupDefaultNavBar:NO];
    [self setNavBar:NO];
    [self addDefaultEmptyViewFullScreen];
}

- (void)setNavBar:(BOOL)showJoinButton {
    if (showJoinButton) {
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:NO];
    } else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}

- (void)initViewModel {
    self.viewModel = [[FHCommunityDetailViewModel alloc] initWithController:self];
    [self.viewModel requestData];
}

- (void)retryLoadData {
    [self loadData];
}

- (void)loadData {
    [self.viewModel requestData];
}

@end
