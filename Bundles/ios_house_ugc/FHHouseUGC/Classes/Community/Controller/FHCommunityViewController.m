//
//  FHCommunityViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import "FHCommunityViewController.h"
#import "TTDeviceHelper.h"
#import "FHCommunityViewModel.h"
#import "FHCommunityDiscoveryViewModel.h"
#import "UIButton+TTAdditions.h"
#import "FHTopicDetailViewController.h"
#import "FHCommunityDetailViewController.h"
#import "FHPostDetailViewController.h"
#import "FHWDAnswerPictureTextViewController.h"
#import "FHEnvContext.h"
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
#import "UIViewController+Track.h"
#import <FHHouseBase/FHPermissionAlertViewController.h>
#import <FHPopupViewCenter/FHPopupViewManager.h>
#import "FHUGCPostMenuView.h"
#import "FHCommonDefines.h"
#import "TTAccountManager.h"
#import "FHHouseUGCHeader.h"
#import "FHUGCCategoryManager.h"
#import "FHLoginTipView.h"
#import "UIDevice+BTDAdditions.h"

@interface FHCommunityViewController ()<FHUGCPostMenuViewDelegate>

@property(nonatomic, strong) FHCommunityBaseViewModel *viewModel;
@property(nonatomic, strong) UIView *bottomLineView;
@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UIButton *searchBtn;
@property(nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property(nonatomic, strong) FHLoginTipView * loginTipview;
@property(nonatomic, assign) BOOL hasShowDots;
@property(nonatomic, assign) BOOL alreadyShowGuide;
@property(nonatomic, assign) BOOL isFirstLoad;
@property(nonatomic, strong) FHUGCPostMenuView *publishMenuView;
@property(nonatomic, assign) BOOL isShowLoginTip;
@end

@implementation FHCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    //test
    self.hasShowDots = NO;
    self.isUgcOpen = [FHEnvContext isUGCOpen];
    
    if(self.isInHomePage){
        self.categorys = @[[FHUGCCategoryManager sharedManager].recommendCategory];
    }else{
        self.categorys = [[FHUGCCategoryManager sharedManager].allCategories copy];
    }
    
    self.alreadyShowGuide = NO;
    self.ttTrackStayEnable = YES;
    self.isShowLoginTip = NO;
    [self initView];
    [self initViewModel];
    if(!self.isInHomePage){
        [self setupDiscoverySetmentedControl];
    }
    [self initConstraints];

    if(!self.isInHomePage){
        [self onFocusHaveNewContents];
    }

    self.isFirstLoad = YES;
    //切换开关
    if(!self.isInHomePage){
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
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFocusHaveNewContents) name:kFHUGCFocusTabHasNewNotification object:nil];
    
    //tabbar双击的通知
    if(self.isInHomePage){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kExploreMixedListRefreshTypeNotification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kFindTabbarKeepClickedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTab) name:kFHUGCForumPostThreadFinish object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSegmentView) name:kUGCCategoryGotFinishedNotification object:nil];
    }
    
    [TTForumPostThreadStatusViewModel sharedInstance_tt];
    self.isFirstLoad = NO;
}

   

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onFocusHaveNewContents {
    BOOL hasNew = [FHUGCConfig sharedInstance].ugcFocusHasNew;
    NSInteger index = [[FHUGCCategoryManager sharedManager] getCategoryIndex:@"f_news_recommend"];
    if(self.viewModel.currentTabIndex != index && hasNew && index >= 0 && !self.isInHomePage){
        NSMutableArray *redPoints = [NSMutableArray array];
        for (NSInteger i = 0; i <= index; i++) {
            if(i == index){
                redPoints[i] = @1;
            }else{
                redPoints[i] = @0;
            }
        }
        _segmentControl.sectionRedPoints = redPoints;
        self.hasFocusTips = YES;
    }
}

- (void)hideRedPoint {
    if(!self.isInHomePage){
        NSInteger index = [[FHUGCCategoryManager sharedManager] getCategoryIndex:@"f_news_recommend"];
        if(self.viewModel.currentTabIndex == index && self.hasFocusTips){
            self.hasFocusTips = NO;
            [FHUGCConfig sharedInstance].ugcFocusHasNew = NO;
            [[FHUGCConfig sharedInstance] recordHideRedPointTime];
            self.segmentControl.sectionRedPoints = @[@0];
            [self.viewModel refreshCell:YES isClick:NO];
        }
    }
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];

    self.topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];

    self.bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor themeGray6];
    _bottomLineView.hidden = YES;
    [self.topView addSubview:_bottomLineView];

    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    
    if(!self.isInHomePage){
        [self initPublishBtn];
    }
}
//- (void)initLoginTipView {
//    if (!self.isShowLoginTip) {
//        self.loginTipview =  [FHLoginTipView showLoginTipViewInView:self.view navbarHeight:0 withTracerDic:self.tracerDict];
//        self.isShowLoginTip = YES;
//        self.loginTipview.type = FHLoginTipViewtTypeNeighborhood;
//    }else {
//        if (self.loginTipview) {
//            if ([TTAccount sharedAccount].isLogin) {
//                [self.loginTipview removeFromSuperview];
//            }else {
//                [self.loginTipview startTimer];
//            }
//        }
//    }
//
//}

- (void)initPublishBtn {
    self.publishBtn = [[UIButton alloc] init];
    [_publishBtn setImage:[UIImage imageNamed:@"fh_ugc_publish"] forState:UIControlStateNormal];
    [_publishBtn addTarget:self action:@selector(goToPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(![FHEnvContext sharedInstance].isShowingHomeHouseFind || !self.isInHomePage){
        [self.viewModel viewWillDisappear];
    }
    
    if (self.loginTipview) {
         [self.loginTipview pauseTimer];
    }
    if(!self.isInHomePage){
        [self addStayCategoryLog:self.stayTime];
    }else{
//        if (![FHEnvContext sharedInstance].isShowingHomeHouseFind) {
//            [self viewDisAppearForEnterType:1 needReportSubCategory:NO];
//        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(![FHEnvContext sharedInstance].isShowingHomeHouseFind || !self.isInHomePage){
        [self.viewModel viewWillAppear];
    }
    
//    [self initLoginTipView];
    self.stayTime = [[NSDate date] timeIntervalSince1970];

    //去掉邻里tab的红点
    [FHEnvContext hideFindTabRedDots];
    if(!self.isInHomePage){
        NSInteger index = [[FHUGCCategoryManager sharedManager] getCategoryIndex:@"f_news_recommend"];
        //去掉圈子红点的同时刷新tab
        if(self.viewModel.currentTabIndex == index && [FHUGCConfig sharedInstance].ugcFocusHasNew){
            self.hasFocusTips = NO;
            [FHUGCConfig sharedInstance].ugcFocusHasNew = NO;
            [[FHUGCConfig sharedInstance] recordHideRedPointTime];
            self.segmentControl.sectionRedPoints = @[@0];
            [self.viewModel refreshCell:YES isClick:NO];
        }
    }
    
//    if(self.isInHomePage){
//        if (![FHEnvContext sharedInstance].isShowingHomeHouseFind) {
//            [self viewAppearForEnterType:1 needReportSubCategory:NO];
//        }
//    }
    
    //视频tab，隐藏发布按钮
    if(!self.isInHomePage){
        if(self.viewModel.currentTabIndex == 0){
            self.publishBtn.hidden = YES;
        }else{
            self.publishBtn.hidden = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[FHPopupViewManager shared] triggerPopupView];
    [[FHPopupViewManager shared] triggerPendant];
}

- (BOOL)prefersStatusBarHidden {
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
    tracerDict[@"enter_channel"] = [FHEnvContext sharedInstance].enterChannel;

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
    if(_segmentControl){
        [_segmentControl removeFromSuperview];
        _segmentControl = nil;
    }
    
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
        [weakSelf.viewModel refreshCell:NO isClick:YES];
    };
    
    CGFloat segmentContentWidth = [self.segmentControl totalSegmentedControlWidth];
    [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.topView);
        make.width.mas_equalTo(segmentContentWidth);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.topView).offset(-8);
    }];
}

- (void)setupDiscoverySetmentedControl {
    if(_segmentControl){
        [_segmentControl removeFromSuperview];
        _segmentControl = nil;
    }
    
    _segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:[self getSegmentTitles]];
    
    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
            NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.titleTextAttributes = titleTextAttributes;

    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontMedium:18],
            NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.firstLeftMargain = 8;
    _segmentControl.lastRightMargin = 10;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(9, 20, 0, 8);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 20.0f;
    _segmentControl.selectionIndicatorHeight = 4.0f;
    _segmentControl.selectionIndicatorCornerRadius = 2.0f;
    _segmentControl.shouldFixedSelectPosition = YES;
    _segmentControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
    _segmentControl.bounces = NO;
    
    [self.topView addSubview:_segmentControl];

    __weak typeof(self) weakSelf = self;
    _segmentControl.indexChangeBlock = ^(NSInteger index) {
        [weakSelf.viewModel segmentViewIndexChanged:index];
    };
    
    _segmentControl.indexRepeatBlock = ^(NSInteger index) {
        [weakSelf.viewModel refreshCell:NO isClick:YES];
    };
    
    [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.topView);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.topView).offset(-8);
    }];
}

- (NSArray *)getSegmentTitles {
    return [self.viewModel getSegmentTitles];
}

- (void)initConstraints {

    CGFloat bottom = 49;
    if (@available(iOS 11.0, *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }

    CGFloat top = 0;
    CGFloat safeTop = 0;
    if (@available(iOS 13.0 , *)) {
        safeTop = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    } else if (@available(iOS 11.0, *)) {
        safeTop = self.view.tt_safeAreaInsets.top;
    }
    if (safeTop > 0) {
        top += safeTop;
    } else {
        if([[UIApplication sharedApplication] statusBarFrame].size.height > 0){
            top += [[UIApplication sharedApplication] statusBarFrame].size.height;
        }else{
            if([UIDevice btd_isIPhoneXSeries]){
                top += 44;
            }else{
                top += 20;
            }
        }
    }
    
    if(self.isInHomePage){
        top = 0;
        bottom = 0;
    }else{
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(top);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(44);
        }];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.topView);
            make.height.mas_equalTo([UIDevice btd_onePixel]);
        }];
    }
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(self.isInHomePage){
            make.top.mas_equalTo(self.view).offset(top);
        }else{
            make.top.mas_equalTo(self.topView.mas_bottom);
        }
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
    
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-bottom);
        make.right.mas_equalTo(self.view).offset(-12);
        make.width.height.mas_equalTo(64);
    }];
}

- (void)initViewModel {
    [self setupCollectionView];
    self.viewModel = [[FHCommunityDiscoveryViewModel alloc] initWithCollectionView:self.collectionView controller:self];
}



- (void)updateSegmentView {
    [self initViewModel];
    self.segmentControl.selectedSegmentIndex = self.viewModel.currentTabIndex;
    self.segmentControl.sectionTitles = [self getSegmentTitles];
}

- (void)refreshData {
    if(!self.isInHomePage || ![FHEnvContext sharedInstance].isShowingHomeHouseFind){
        [self.viewModel refreshCell:NO isClick:YES];
    }
}

- (void)changeTab {
    NSString *tabIdentifier = [FHEnvContext getCurrentTabIdentifier];
    if(!self.isInHomePage && [tabIdentifier isEqualToString:@"tab_f_find"]){
        if (self.navigationController.viewControllers.count <= 1) {
            NSInteger index = [[FHUGCCategoryManager sharedManager] getCategoryIndex:@"f_news_recommend"];
            [self.viewModel changeTab:index];
        }
    }
}

#pragma mark - 发布器

- (void)goToPublish {
    
    [self showPublishMenu];
}

- (FHUGCPostMenuView *)publishMenuView {
    
    if(!_publishMenuView) {
        _publishMenuView = [[FHUGCPostMenuView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _publishMenuView.delegate = self;
    }
    return _publishMenuView;
}

- (void)showPublishMenu {
    [self.publishMenuView showForButton:self.publishBtn];
}

#pragma mark - FHUGCPostMenuViewDelegate

- (void)gotoPostPublish {
    [self gotoPostThreadVC];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM] ?: @"be_null";
    params[UT_ELEMENT_TYPE] = @"feed_icon";
    params[UT_PAGE_TYPE] = [self.viewModel pageType];
    TRACK_EVENT(@"click_options", params);
}

- (void)gotoVotePublish {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM] ?: @"be_null";
    params[UT_ELEMENT_TYPE] = @"vote_icon";
    params[UT_PAGE_TYPE] = [self.viewModel pageType];
    TRACK_EVENT(@"click_options", params);
    
    if ([TTAccountManager isLogin]) {
        [self gotoVoteVC];
    } else {
        [self gotoLogin:FHUGCLoginFrom_VOTE];
    }
}

- (void)gotoWendaPublish {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM] ?: @"be_null";
    params[UT_ELEMENT_TYPE] = @"question_icon";
    params[UT_PAGE_TYPE] = [self.viewModel pageType];
    TRACK_EVENT(@"click_options", params);
    
    if ([TTAccountManager isLogin]) {
        [self gotoWendaVC];
    } else {
        [self gotoLogin:FHUGCLoginFrom_WENDA];
    }
}

// 发布按钮点击
- (void)gotoPostThreadVC {
    if ([TTAccountManager isLogin]) {
        [self gotoPostVC];
    } else {
        [self gotoLogin:FHUGCLoginFrom_POST];
    }
}

- (void)gotoLogin:(FHUGCLoginFrom)from {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *page_type = [self.viewModel pageType];
    [params setObject:page_type forKey:@"enter_from"];
    
    NSString *enter_type = UT_BE_NULL;
    switch (from) {
        case FHUGCLoginFrom_POST:
            enter_type = @"click_publisher_moments";
            break;
        case FHUGCLoginFrom_GROUPCHAT:
            enter_type = @"ugc_member_talk";
            break;
        case FHUGCLoginFrom_VOTE:
            enter_type = @"click_publisher_vote";
            break;
        case FHUGCLoginFrom_WENDA:
            enter_type = @"click_publisher_question";
            break;
        default:
            break;
    }
    [params setObject:enter_type forKey:@"enter_type"];
    
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);

    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    switch (from) {
                        case FHUGCLoginFrom_POST:
                        {
                            [self gotoPostVC];
                        }
                            break;
                        case FHUGCLoginFrom_VOTE:
                        {
                            [self gotoVoteVC];
                        }
                            break;
                        case FHUGCLoginFrom_WENDA:
                        {
                            [self gotoWendaVC];
                        }
                            break;
                        default:
                            break;
                    }
                });
            }
        }
    }];
}

// 跳转到投票发布器
- (void)gotoVoteVC {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"sslocal://ugc_vote_publish"];
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[UT_ENTER_FROM] = [self.viewModel pageType];
    tracerDict[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM] ?: @"be_null";
    dict[TRACER_KEY] = tracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
}

- (void)gotoWendaVC {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"sslocal://ugc_wenda_publish"];
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[UT_ENTER_FROM] = [self.viewModel pageType];
    tracerDict[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM] ?: @"be_null";
    dict[TRACER_KEY] = tracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
}

// 跳转到UGC发布器
- (void)gotoPostVC {

    // 跳转到发布器
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"element_type"] = @"feed_publisher";
    NSString *page_type = [self.viewModel pageType];
    tracerDict[@"page_type"] = page_type;
    [FHUserTracker writeEvent:@"click_publisher" params:tracerDict];
    
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    NSMutableDictionary *dict = @{}.mutableCopy;
    traceParam[@"page_type"] = @"feed_publisher";
    traceParam[@"enter_from"] = page_type;
    traceParam[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM] ?: @"be_null";
    dict[TRACER_KEY] = traceParam;
    dict[VCTITLE_KEY] = @"发帖";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://ugc_post"];
    [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:userInfo];
}

- (void)viewAppearForEnterType:(NSInteger)enterType needReportSubCategory:(BOOL)needReportSubCategory {
    self.stayTime = [[NSDate date] timeIntervalSince1970];
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    if (enterType == 1) {
        tracerDict[@"enter_type"] = @"click";
    }else{
        tracerDict[@"enter_type"] = @"flip";
    }
    tracerDict[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    tracerDict[@"category_name"] = self.tracerDict[@"category_name"] ?: @"be_null";
    [FHEnvContext recordEvent:tracerDict andEventKey:@"enter_category"];
    
    if(needReportSubCategory){
        [self.viewModel viewWillAppear];
    }
}

- (void)viewDisAppearForEnterType:(NSInteger)enterType needReportSubCategory:(BOOL)needReportSubCategory
{
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    NSTimeInterval duration = ([[NSDate date] timeIntervalSince1970] - self.stayTime) * 1000.0;
    if (enterType == 1) {
        tracerDict[@"enter_type"] = @"click";
    }else{
        tracerDict[@"enter_type"] = @"flip";
    }
    tracerDict[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    tracerDict[@"category_name"] = self.tracerDict[@"category_name"] ?: @"be_null";
    tracerDict[@"stay_time"] = @((int) duration);

    if (((int) duration) > 0) {
        [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_category"];
    }
    
    if(needReportSubCategory){
        [self.viewModel viewWillDisappear];
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    if(!self.isInHomePage){
        [self addStayCategoryLog:self.stayTime];
    }
}

- (void)trackStartedByAppWillEnterForground {
    self.stayTime = [[NSDate date] timeIntervalSince1970];
}

- (NSString *)fh_pageType {
    return [self.viewModel pageType];
}

@end
