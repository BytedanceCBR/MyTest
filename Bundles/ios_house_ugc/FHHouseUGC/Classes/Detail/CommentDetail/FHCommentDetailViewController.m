//
//  FHCommentDetailViewController.m
//  Pods
//
//  Created by 张元科 on 2019/7/16.
//

#import "FHCommentDetailViewController.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "FHRefreshCustomFooter.h"
#import "FHUserTracker.h"
#import "FHFakeInputNavbar.h"
#import "FHConditionFilterFactory.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIViewController+NavbarItem.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceHelper.h"
#import "FHUGCConfig.h"
#import "FHUGCFollowListCell.h"
#import "UIViewController+Track.h"
#import "TTUIResponderHelper.h"
#import "FHExploreDetailToolbarView.h"
#import "FHCommentDetailViewModel.h"

@interface FHCommentDetailViewController ()

@property (nonatomic, strong)   UITableView       *tableView;
@property (nonatomic, strong)   FHExploreDetailToolbarView       *toolbarView; // 临时toolbar
@property (nonatomic, strong)   FHCommentDetailViewModel      *viewModel;
@property (nonatomic, copy)     NSString       *comment_id;

@end

@implementation FHCommentDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.comment_id = @"6714466747832877060";//  6712727097456623627
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"详情";
    self.comment_id = @"6714466747832877060";
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self configTableView];
    [self.view addSubview:_tableView];
    self.viewModel = [[FHCommentDetailViewModel alloc] initWithController:self tableView:_tableView];
    self.viewModel.comment_id = self.comment_id;
    [self setupToolbarView];
//    _tableView.dataSource = self;
//    _tableView.delegate = self;
//    [_tableView registerClass:[FHUGCFollowListCell class] forCellReuseIdentifier:@"FHUGCFollowListCell"];
//    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(height);
        make.bottom.mas_equalTo(self.toolbarView.mas_top);
    }];
    [self addDefaultEmptyViewFullScreen];
}

- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 0;//
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self startLoading];
        self.isLoadingData = YES;
        [self.viewModel startLoadData];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

// 重新加载
- (void)retryLoadData {
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

- (void)setupToolbarView {
    self.toolbarView = [[FHExploreDetailToolbarView alloc] initWithFrame:[self p_frameForToolBarView]];
    
    self.toolbarView.toolbarType = FHExploreDetailToolbarTypeArticleComment;
    
    [self.view addSubview:self.toolbarView];
    
//    [self.toolbarView.writeButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.toolbarView.digButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toolbarView.frame = [self p_frameForToolBarView];
    self.toolbarView.hidden = NO;
    [self p_refreshToolbarView];
}

- (void)p_refreshToolbarView
{
    
}

- (CGRect)p_frameForToolBarView
{
    self.toolbarView.height = FHExploreDetailGetToolbarHeight() + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    return CGRectMake(0, self.view.height - self.toolbarView.height, self.view.width, self.toolbarView.height);
}

- (void)dismissSelf
{
    if (self.navigationController.viewControllers.count>1) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
