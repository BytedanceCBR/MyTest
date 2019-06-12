//
//  FHCommunityDetailViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHCommunityDetailViewController.h"
#import "FHCommunityDetailViewModel.h"
#import "FHCommunityFeedListController.h"
#import "FHCommunityDetailHeaderView.h"
#import "UIViewAdditions.h"
#import "TTAccountLoginPCHHeader.h"


@interface FHCommunityDetailViewController ()
@property(nonatomic, copy) NSString *communityId;
@property(nonatomic, strong) FHCommunityDetailViewModel *viewModel;
@property(nonatomic, strong) FHCommunityFeedListController *feedListController;
@property(nonatomic, strong) FHCommunityDetailHeaderView *headerView;
@property(nonatomic, strong) UIButton *rightBtn;
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
    [self.customNavBarView setNaviBarTransparent:YES];

    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_white"] forState:UIControlStateNormal];
    [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_white"] forState:UIControlStateHighlighted];
    [_rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:_rightBtn];

    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.bottom.mas_equalTo(-10);
        make.right.equalTo(self.customNavBarView).offset(-20);
    }];

    self.feedListController = [[FHCommunityFeedListController alloc] init];
    self.feedListController.listType = FHCommunityFeedListTypeMyJoin;
    [self addChildViewController:self.feedListController];
    [self.feedListController didMoveToParentViewController:self];
    CGFloat topOffset = (@available(iOS 11.0, *)) ? self.view.tt_safeAreaInsets.top : 0;
    self.feedListController.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + topOffset, self.view.bounds.size.width, self.view.bounds.size.height - topOffset);

//    self.feedListController.view.frame = self.view.bounds;
    [self.view addSubview:self.feedListController.view];

    self.headerView = [[FHCommunityDetailHeaderView alloc] initWithFrame:CGRectZero];
    self.feedListController.tableHeaderView = self.headerView;

    [self addDefaultEmptyViewFullScreen];
}


- (void)setNavBar:(BOOL)error {
    if (error) {
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        [self.rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_black"] forState:UIControlStateNormal];
        [self.rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_black"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:NO];
    } else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        [self.rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_white"] forState:UIControlStateNormal];
        [self.rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_white"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}

- (void)initViewModel {
    [self.viewModel requestData];
}

- (void)retryLoadData {
    [self loadData];
}

- (void)loadData {
    [self.viewModel requestData];
}

@end
