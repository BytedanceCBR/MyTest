//
//  FHCommunityViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import "FHCommunityViewController.h"
#import "TTDeviceHelper.h"
#import "FHCommunityViewModel.h"
#import "UIButton+TTAdditions.h"
#import "FHTopicDetailViewController.h"
#import "FHCommunityDetailViewController.h"
#import "FHPostDetailViewController.h"
#import "FHWDAnswerPictureTextViewController.h"
#import <FHEnvContext.h>
#import "FHUGCGuideHelper.h"
#import "FHUGCGuideView.h"
#import "TTForumPostThreadStatusViewModel.h"
#import "FHEnvContext.h"
#import "FHMessageNotificationTipsManager.h"
#import "FHUnreadMsgModel.h"
#import "FHUGCConfig.h"
#import "ExploreLogicSetting.h"
#import "FHPostUGCViewController.h"
#import "FHUserTracker.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHHouseBase/FHBaseCollectionView.h>
#import <FHMinisdkManager.h>
#import "UIViewController+Track.h"
#import "FHSpringHangView.h"
#import <FHHouseBase/FHPermissionAlertViewController.h>

@interface FHCommunityViewController ()

@property(nonatomic, strong) FHCommunityViewModel *viewModel;
@property(nonatomic, strong) UIView *bottomLineView;
@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UIButton *searchBtn;
@property(nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property(nonatomic, strong) FHUGCGuideView *guideView;
@property(nonatomic, assign) BOOL hasShowDots;
@property(nonatomic, assign) BOOL alreadyShowGuide;
//春节活动运营位
@property (nonatomic, strong) FHSpringHangView *springView;

@end

@implementation FHCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hasShowDots = NO;
    self.isUgcOpen = [FHEnvContext isUGCOpen];
    self.alreadyShowGuide = NO;
    self.ttTrackStayEnable = YES;

    [self initView];
    [self initConstraints];
    [self initViewModel];

    [self onUnreadMessageChange];
    [self onFocusHaveNewContents];

    //切换开关
    WeakSelf;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id _Nullable x) {
        StrongSelf;
        FHConfigDataModel *xConfigDataModel = (FHConfigDataModel *) x;
        if (self.isUgcOpen != xConfigDataModel.ugcCitySwitch) {
            self.isUgcOpen = xConfigDataModel.ugcCitySwitch;
            [self initViewModel];
        }
        self.segmentControl.sectionTitles = [self getSegmentTitles];
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topVCChange:) name:@"kExploreTopVCChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnreadMessageChange) name:kTTMessageNotificationTipsChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnreadMessageChange) name:kFHUGCFollowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFocusHaveNewContents) name:kFHUGCFocusTabHasNewNotification object:nil];
    //tabbar双击的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kFindTabbarKeepClickedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTab) name:kFHUGCForumPostThreadFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnreadMessageChange) name:kFHUGCLoadFollowDataFinishedNotification object:nil];
    [TTForumPostThreadStatusViewModel sharedInstance_tt];
}

- (void)addSpringView {
    if(!_springView){
        self.springView = [[FHSpringHangView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_springView];
        _springView.hidden = YES;
        
        CGFloat bottom = 49;
        if (@available(iOS 11.0 , *)) {
            bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
        }
        
        [_springView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(-bottom - 85);
            make.width.mas_equalTo(82);
            make.height.mas_equalTo(82);
            make.right.mas_equalTo(self.view).offset(-11);
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addUgcGuide {
    if ([FHUGCGuideHelper shouldShowSearchGuide] && self.isUgcOpen && !self.alreadyShowGuide) {
        [self.guideView show:self.view dismissDelayTime:5.0f completion:^{
            [FHUGCGuideHelper hideSearchGuide];
        }];
        self.alreadyShowGuide = YES;
    }
}

- (void)hideGuideView {
    if(_guideView){
        [_guideView hide];
        [FHUGCGuideHelper hideSearchGuide];
    }
}

- (FHUGCGuideView *)guideView {
    [self.view layoutIfNeeded];
    if (!_guideView) {
        _guideView = [[FHUGCGuideView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 186, CGRectGetMaxY(self.topView.frame) - 7, 176, 42) andType:FHUGCGuideViewTypeSearch];
    }
    return _guideView;
}

- (void)topVCChange:(NSNotification *)notification {
    if (self.isUgcOpen) {
        [self hideGuideView];
    }
}

- (void)onUnreadMessageChange {
    BOOL hasSocialGroups = [FHUGCConfig sharedInstance].followList.count > 0;
    FHUnreadMsgDataUnreadModel *model = [FHMessageNotificationTipsManager sharedManager].tipsModel;
    if (model && [model.unread integerValue] > 0 && hasSocialGroups) {
        NSInteger count = [model.unread integerValue];
        _segmentControl.sectionMessageTips = @[@(count)];
    } else {
        _segmentControl.sectionMessageTips = @[@(0)];
    }
}

- (void)onFocusHaveNewContents {
    BOOL hasSocialGroups = [FHUGCConfig sharedInstance].followList.count > 0;
    BOOL hasNew = [FHUGCConfig sharedInstance].ugcFocusHasNew;
    if(self.viewModel.currentTabIndex != 0 && hasSocialGroups && hasNew){
        _segmentControl.sectionRedPoints = @[@1];
        self.hasFocusTips = YES;
    }
}

- (void)hideRedPoint {
    if(self.viewModel.currentTabIndex == 0 && self.hasFocusTips){
        self.hasFocusTips = NO;
        [FHUGCConfig sharedInstance].ugcFocusHasNew = NO;
        [[FHUGCConfig sharedInstance] recordHideRedPointTime];
        self.segmentControl.sectionRedPoints = @[@0];
        [self.viewModel refreshCell:YES];
    }
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];

    self.topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];

    self.bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor themeGray6];
    [self.topView addSubview:_bottomLineView];

    self.searchBtn = [[UIButton alloc] init];
    [_searchBtn setImage: ICON_FONT_IMG(24, @"\U0000e675", [UIColor blackColor]) forState:UIControlStateNormal];//fh_ugc_search
    _searchBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_searchBtn addTarget:self action:@selector(goToSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:_searchBtn];

    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];

    [self setupSetmentedControl];
    
    if([FHEnvContext isSpringHangOpen]){
        [self addSpringView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear];
    [self addStayCategoryLog:self.stayTime];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
    self.stayTime = [[NSDate date] timeIntervalSince1970];
    [self addUgcGuide];

    if(self.isUgcOpen){
        //去掉邻里tab的红点
        [FHEnvContext hideFindTabRedDots];
        //去掉关注红点的同时刷新tab
        if(self.viewModel.currentTabIndex == 0 && [FHUGCConfig sharedInstance].ugcFocusHasNew){
            self.hasFocusTips = NO;
            [FHUGCConfig sharedInstance].ugcFocusHasNew = NO;
            [self.viewModel refreshCell:YES];
        }
    }else{
        if (!self.hasShowDots) {
            [FHEnvContext hideFindTabRedDotsLimitCount];
            self.hasShowDots = YES;
        }
    }
    
    if ([[FHEnvContext sharedInstance] hasConfirmPermssionProtocol]) {
        //春节活动
        [[FHMinisdkManager sharedInstance] goSpring];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //春节活动运营位
    if([FHEnvContext isSpringHangOpen]){
        [self.springView show:[FHEnvContext enterTabLogName]];
    }
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}


- (void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    NSTimeInterval duration = ([[NSDate date] timeIntervalSince1970] - self.stayTime) * 1000.0;
    if (self.isUgcOpen) {
        [tracerDict setValue:@"neighborhood_tab" forKey:@"tab_name"];
    } else {
        [tracerDict setValue:@"discover_tab" forKey:@"tab_name"];
    }
    [tracerDict setValue:@(0) forKey:@"with_tips"];
    [tracerDict setValue:@"click_tab" forKey:@"enter_type"];
    tracerDict[@"stay_time"] = @((int) duration);

    if (((int) duration) > 0) {
        [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_tab"];
    }
}


- (void)setupCollectionView {
    if (self.collectionView) {
        [self.collectionView removeFromSuperview];
        self.collectionView = nil;
    }

    self.automaticallyAdjustsScrollViewInsets = NO;
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;

    //2.初始化collectionView
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.allowsSelection = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_collectionView];

    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}

- (void)setupSetmentedControl {
    _segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:[self getSegmentTitles]];

    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
            NSForegroundColorAttributeName: [UIColor themeGray3]};
    _segmentControl.titleTextAttributes = titleTextAttributes;

    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontSemibold:18],
            NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(9, 10, 0, 10);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 20.0f;
    _segmentControl.selectionIndicatorHeight = 4.0f;
    _segmentControl.selectionIndicatorCornerRadius = 2.0f;
//    _segmentControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 0, -3, 0);
    _segmentControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
//    _segmentControl.selectionIndicatorImage = [UIImage imageNamed:@"fh_ugc_segment_selected"];

    [self.topView addSubview:_segmentControl];

    __weak typeof(self) weakSelf = self;
    _segmentControl.indexChangeBlock = ^(NSInteger index) {
        [weakSelf.viewModel segmentViewIndexChanged:index];
    };
    
    _segmentControl.indexRepeatBlock = ^(NSInteger index) {
        [weakSelf.viewModel refreshCell:NO];
    };
}

- (NSArray *)getSegmentTitles {
    NSMutableArray *titles = [NSMutableArray array];
    
    NSDictionary *ugcTitles = [FHEnvContext ugcTabName];
    if(ugcTitles[kUGCTitleMyJoinList]){
        NSString *name = ugcTitles[kUGCTitleMyJoinList];
        if(name.length > 2){
            name = [name substringToIndex:2];
        }
        [titles addObject:name];
    }else{
        [titles addObject:@"关注"];
    }
    
    if(ugcTitles[kUGCTitleNearbyList]){
        NSString *name = ugcTitles[kUGCTitleNearbyList];
        if(name.length > 2){
            name = [name substringToIndex:2];
        }
        [titles addObject:name];
    }else{
        [titles addObject:@"附近"];
    }
        
//    [titles addObject:@"发现"];
    
    if(titles.count == 2){
        return titles;
    }
    
    return @[@"关注", @"附近"];
}

- (void)initConstraints {

    CGFloat bottom = 49;
    if (@available(iOS 11.0, *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }

    CGFloat top = 0;
    CGFloat safeTop = 0;
    if (@available(iOS 11.0, *)) {
        safeTop = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].top;
    }
    if (safeTop > 0) {
        top += safeTop;
    } else {
        top += [[UIApplication sharedApplication] statusBarFrame].size.height;
    }

    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(top);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];

    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView).offset(-5);
        make.right.mas_equalTo(self.topView).offset(-20);
        make.width.height.mas_equalTo(24);
    }];

    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.topView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];

    [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.topView);
        make.width.mas_equalTo([self.segmentControl totalSegmentedControlWidth]);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.topView).offset(-8);
    }];

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
}

- (void)initViewModel {
    [self setupCollectionView];
    _viewModel = [[FHCommunityViewModel alloc] initWithCollectionView:self.collectionView controller:self];
    _viewModel.searchBtn = self.searchBtn;
}

- (void)showSegmentControl:(BOOL)isShow {
    self.segmentControl.hidden = !isShow;
    self.bottomLineView.hidden = !isShow;
    self.topView.hidden = !isShow;
    if (isShow) {
        _collectionView.backgroundColor = [UIColor themeGray7];
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
        }];
    } else {
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)refreshData {
    [self.viewModel refreshCell:NO];
}

- (void)changeTab {
    if (self.navigationController.viewControllers.count <= 1) {
        [self.viewModel changeTab:1];
    }
}

//进入搜索页
- (void)goToSearch {
    [self hideGuideView];
    [self addGoToSearchLog];
    NSString *routeUrl = @"sslocal://ugc_search_list";
    NSURL *openUrl = [NSURL URLWithString:routeUrl];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary* searchTracerDict = [NSMutableDictionary dictionary];
    searchTracerDict[@"element_type"] = @"community_search";
    searchTracerDict[@"enter_from"] = @"neighborhood_tab";
    paramDic[@"tracer"] = searchTracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:paramDic];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)addGoToSearchLog {
    NSMutableDictionary *reportParams = [NSMutableDictionary dictionary];
    reportParams[@"page_type"] = @"neighborhood_tab";
    reportParams[@"origin_from"] = @"community_search";
    reportParams[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ?: @"be_null";
    [FHUserTracker writeEvent:@"click_community_search" params:reportParams];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    
}

- (void)trackStartedByAppWillEnterForground {
    //春节活动运营位
    if([FHEnvContext isSpringHangOpen]){
        [self.springView show:[FHEnvContext enterTabLogName]];
    }
}
@end
