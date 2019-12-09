//
//  FHPersonalHomePageController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHPersonalHomePageController.h"
#import "FHExploreDetailToolbarView.h"
#import "SSCommonLogic.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "FHCommentViewController.h"
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"
#import "FHBaseTableView.h"
#import "FHPersonalHomePageViewModel.h"
#import "TTReachability.h"
#import "FHUGCCellManager.h"
#import "FHUGCCellHelper.h"
#import "FHPersonalHomePageHeaderView.h"
#import "FHUGCTopicRefreshHeader.h"
#import "FHRefreshCustomFooter.h"
#import "UILabel+House.h"
#import "FHEnvContext.h"
#import "FHUserTracker.h"
#import <UIScrollView+Refresh.h>
#import "FHFeedOperationView.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "SSImpressionManager.h"
#import "FHUserTracker.h"
#import "UIViewController+Track.h"
#import "TTAccountManager.h"

@interface FHPersonalHomePageController ()<UIScrollViewDelegate,TTUIViewControllerTrackProtocol,SSImpressionProtocol>

@property (nonatomic, strong)   FHPersonalHomePageHeaderView        *topHeaderView;
@property (nonatomic, assign)   CGFloat       minSubScrollViewHeight;
@property (nonatomic, assign)   CGFloat       maxSubScrollViewHeight;
@property (nonatomic, assign)   CGFloat       criticalPointHeight;// 临界点长度
@property (nonatomic, assign)   CGFloat       topHeightOffset;
@property (nonatomic, assign)   CGFloat       navOffset;
@property (nonatomic, strong)   FHPersonalHomePageViewModel       *viewModel;
@property (nonatomic, assign)   BOOL       isViewAppear;
@property (nonatomic, strong)   UILabel *titleLabel;
@property (nonatomic, strong)   UILabel *subTitleLabel;
@property (nonatomic, strong)   UIView *titleContainer;

@property (nonatomic, assign)   BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign)   BOOL isTopIsCanNotMoveTabViewPre;
@property (nonatomic, assign)   BOOL canScroll;
@property (nonatomic, assign)   CGFloat       defaultTopHeight;
@property (nonatomic, strong)   NSString *userId;//用户id
@property (nonatomic, copy)     NSString       *enter_from;  // 从哪进入的当前页面

@end

@implementation FHPersonalHomePageController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 话题
        NSDictionary *params = paramObj.allParams;
        self.userId = [params objectForKey:@"uid"];
        // 埋点
        self.tracerDict[@"page_type"] = @"personal_homepage_detail";
        // 取链接中的埋点数据
        NSString *enter_from = params[@"from_page"];
        if (enter_from.length > 0) {
            self.tracerDict[@"enter_from"] = enter_from;
        }else{
            self.tracerDict[@"enter_from"] = @"default";
        }
        
        self.tracerDict[@"enter_type"] = @"click";
        // 取url中的埋点数据结束
        self.enter_from = self.tracerDict[@"enter_from"];
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    self.isViewAppear = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCLeaveTop" object:@"homePage"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToSubScrollView:) name:@"kScrollToSubScrollView" object:@"homePage"];
    [[SSImpressionManager shareInstance] addRegist:self];
    __weak typeof(self) weakSelf = self;
    self.panBeginAction = ^{
        weakSelf.mainScrollView.scrollEnabled = NO;
    };
    self.panRestoreAction = ^{
        weakSelf.mainScrollView.scrollEnabled = YES;
    };
}

- (void)scrollToSubScrollView:(NSNotification *)notification {
    [self.mainScrollView setContentOffset:self.subScrollView.frame.origin animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewAppear = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayPageLog];
    self.isViewAppear = NO;
    [self.viewModel viewWillDisappear];
}

- (void)setupUI {
    self.navOffset = 65;
    CGFloat navOffset = 65;
    if (@available(iOS 11.0 , *)) {
        navOffset = 44.f + self.view.tt_safeAreaInsets.top;
    } else {
        navOffset = 65;
    }
    self.navOffset = navOffset;
    self.canScroll = NO;
    self.isTopIsCanNotMoveTabView = NO;
    self.isTopIsCanNotMoveTabViewPre = NO;
    
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = [[TTAccountManager userID] isEqualToString:self.userId] ? @"我的主页" : @"TA的主页";
     
    self.defaultTopHeight = 100;
    
    // _mainScrollView
    _mainScrollView = [[FHPersonalHomePageScrollView alloc] init];
    [self.view addSubview:_mainScrollView];
    if (@available(iOS 11.0 , *)) {
         _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _mainScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _mainScrollView.delegate = self;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.scrollsToTop = YES;
    _mainScrollView.bounces = NO;
    
    [_mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    // _topHeaderView
    _topHeaderView = [[FHPersonalHomePageHeaderView alloc] init];
    _topHeaderView.frame = CGRectMake(0, self.navOffset, SCREEN_WIDTH, self.defaultTopHeight);
    [self.mainScrollView addSubview:_topHeaderView];
    _topHeaderView.hidden = YES;
    
    self.mainScrollView.backgroundColor = [UIColor whiteColor];
    self.topHeightOffset = CGRectGetMaxY(self.topHeaderView.frame) + 5;
    
    // 计算subScrollView的高度
    self.minSubScrollViewHeight = SCREEN_HEIGHT - self.topHeightOffset;// 暂时不用，数据较少时也可在下面展示空页面
    self.maxSubScrollViewHeight = SCREEN_HEIGHT - navOffset;
    self.criticalPointHeight = self.maxSubScrollViewHeight - self.minSubScrollViewHeight;
    
    // subScrollView
    _subScrollView = [[UIScrollView alloc] init];
    if (@available(iOS 11.0 , *)) {
         _subScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _subScrollView.frame = CGRectMake(0, self.topHeightOffset, SCREEN_WIDTH, self.maxSubScrollViewHeight);
    _subScrollView.delegate = self;
    _subScrollView.scrollsToTop = NO;
    
    _subScrollView.backgroundColor = [UIColor whiteColor];
    [self.mainScrollView addSubview:self.subScrollView];
    self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.maxSubScrollViewHeight + self.topHeightOffset);
    
    // 空态页
    [self addDefaultEmptyViewFullScreen];
    
    //覆盖在下方的空态页
    [self addTableErrorView];
    
    // viewModel
    _viewModel = [[FHPersonalHomePageViewModel alloc] initWithController:self];
    _viewModel.currentSelectIndex = 0;
//     self.cid = 1643560283994120;//1643171844947979;//1642474912698382;
    _viewModel.userId = self.userId;
    _viewModel.enter_from = self.enter_from;
    
    // self.mainScrollView.hidden = YES;
    
    // 初始化tableViews，后续可能网络返回结果
    NSArray *indexStrs = @[@"全部"];
    [self setupSubTableViews:indexStrs];
    
    // 加载数据
    self.isViewAppear = YES;
    [self startLoadData];
    
    // goDetail
//    [self addGoDetailLog];
}

- (void)addTableErrorView {
    self.tableErrorView = [[FHErrorView alloc] init];
    _tableErrorView.hidden = YES;
    [self.view addSubview:_tableErrorView];
    [_tableErrorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(self.topHeightOffset);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)setupSubTableViews:(NSArray *)tabIndexStrs {
    if ([tabIndexStrs isKindOfClass:[NSArray class]] && tabIndexStrs.count > 0) {
        [self.emptyView hideEmptyView];
        self.mainScrollView.hidden = NO;
        NSInteger tabCount = tabIndexStrs.count;
        _subScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * tabCount, self.maxSubScrollViewHeight);
        _subScrollView.pagingEnabled = YES;
        _subScrollView.bounces = NO;
        _subScrollView.showsVerticalScrollIndicator = NO;
        _subScrollView.showsHorizontalScrollIndicator = NO;
        for (NSInteger i = 0; i < tabCount; i++) {
            UITableView *tempView = [self createTableView];
            tempView.frame = CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, self.maxSubScrollViewHeight);
            tempView.tag = i;
            [self.viewModel.ugcCellManager registerAllCell:tempView];
            tempView.delegate = self.viewModel;
            tempView.dataSource = self.viewModel;
            tempView.scrollEnabled = YES;
            tempView.scrollsToTop = NO;
            [self.viewModel.hashTable addObject:tempView];
            [_subScrollView addSubview:tempView];
        }
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
        self.mainScrollView.hidden = YES;
    }
}

- (UITableView *)createTableView {
    UITableView *_tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    if ([TTDeviceHelper isIPhoneXSeries]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    // 上拉加载更多
    __weak typeof(self) weakSelf = self;
    FHRefreshCustomFooter *refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [weakSelf loadMore];
    }];
    _tableView.mj_footer = refreshFooter;
    
    refreshFooter.hidden = YES;
    return _tableView;
}

- (void)refreshHeaderData:(BOOL)refreshAvatar {
    FHPersonalHomePageModel *headerModel = self.viewModel.headerModel;
    if (headerModel) {
        [self hiddenEmptyView];
        self.topHeaderView.hidden = NO;
        [self.topHeaderView updateData:headerModel tracerDic:self.tracerDict refreshAvatar:refreshAvatar];
        // 布局刷新
        self.defaultTopHeight = self.topHeaderView.headerViewheight;
        self.topHeaderView.frame = CGRectMake(0, self.navOffset, SCREEN_WIDTH, self.defaultTopHeight);
        self.topHeightOffset = CGRectGetMaxY(self.topHeaderView.frame) + 5;
        
        // 计算subScrollView的高度
        self.minSubScrollViewHeight = SCREEN_HEIGHT - self.topHeightOffset;// 暂时不用，数据较少时也可在下面展示空页面
        self.maxSubScrollViewHeight = SCREEN_HEIGHT - self.navOffset;
        self.criticalPointHeight = self.maxSubScrollViewHeight - self.minSubScrollViewHeight;
        
        self.subScrollView.frame = CGRectMake(0, self.topHeightOffset, SCREEN_WIDTH, self.maxSubScrollViewHeight);
        self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.maxSubScrollViewHeight + self.topHeightOffset);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self startLoading];
        self.isLoadingData = YES;
        [self.viewModel startLoadData];
    } else {
        [self showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

- (void)showEmptyWithType:(FHEmptyMaskViewType)maskViewType {
    [self.emptyView showEmptyWithType:maskViewType];
    self.mainScrollView.hidden = YES;
}

- (void)hiddenEmptyView {
    [self.emptyView hideEmptyView];
    self.mainScrollView.hidden = NO;
}

// 重新加载
- (void)retryLoadData {
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

// 上拉加载
- (void)loadMore {
    [self.viewModel loadMoreData];
}

- (void)acceptMsg:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

#pragma mark - UIScrollViewDelegate

// 滑动切换tab
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollView) {
   
    } else if (scrollView == _subScrollView) {
        CGFloat offsetX = scrollView.contentOffset.x;
        CGFloat tempIndex = offsetX / SCREEN_WIDTH;
        self.viewModel.currentSelectIndex = (NSInteger)tempIndex;
    }
}

// mainScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollView) {
        CGFloat tabOffsetY;
        CGFloat offsetY = scrollView.contentOffset.y;
        
        _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
        
        tabOffsetY = self.criticalPointHeight;
        
        if (offsetY >= tabOffsetY) {
            scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            _isTopIsCanNotMoveTabView = YES;// 底部列表不能移动
        } else {
            _isTopIsCanNotMoveTabView = NO;// 底部列表能移动
        }
        
        if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
            if (!_isTopIsCanNotMoveTabViewPre) {
                // 滑动到顶端
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHUGCGoTop" object:@"homePage" userInfo:@{@"canScroll":@"1"}];
                _canScroll = NO;
            }
            if(_isTopIsCanNotMoveTabViewPre){
                // 离开顶端
                if (!_canScroll) {
                    scrollView.contentOffset = CGPointMake(0, tabOffsetY);
                }
            }
        }
        
    } if (scrollView == _subScrollView) {
        // 列表父scrollview
    } else {
        // nothing
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self mainScrollToTop];
    return NO;
}

- (void)mainScrollToTop {
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf.mainScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [wSelf.viewModel.currentTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    });
}

#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions {
    [self.viewModel needRerecordImpressions];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayPageLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Tracer

- (void)addGoDetailLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [FHUserTracker writeEvent:@"go_detail_personal" params:tracerDict];
}

- (void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page_personal" params:tracerDict];
    [self tt_resetStayTime];
}

@end

// FHPersonalHomePageScrollView
@implementation FHPersonalHomePageScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
