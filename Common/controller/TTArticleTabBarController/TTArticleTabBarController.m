//
//  TTTabBarController.m
//  TestUniversaliOS6
//
//  Created by Nick Yu on 3/3/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "TTArticleTabBarController.h"
#import "TTApplicationHeader.h"
#import "UITabBarController+TabbarConfig.h"
#import "TTThemeManager.h"

#import "TTNavigationController.h"

#import "ArticleBadgeManager.h"
#import "TTSettingMineTabManager.h"
#import "TTSettingMineTabGroup.h"
#import "TTSettingMineTabEntry.h"
#import <TTAccountBusiness.h>
#import "ArticleFetchSettingsManager.h"

#import "ExploreMovieView.h"
#import "UIViewController+Track.h"
#import "NewsBaseDelegate.h"

#import "TTVideoTip.h"
#import "ArticleCategoryManagerView.h"
#import "SSWebViewController.h"

#import "TTInstallIDManager.h"
#import "TTUISettingHelper.h"
#import "TTTabbar+Private.h"
#import "TTTabBarManager.h"
#import <KVOController/KVOController.h>
#import "TTDeviceHelper.h"

#import "TTMovieFullscreenViewController.h"

#import "ArticleTabbarStyleNewsListViewController.h"
#import "TTVideoTabViewController.h"
#import "TTVHomeViewController.h"
#import "TTVVideoTabViewController.h"
//#import "TTFollowWebViewController.h"
//#import "TTWeitoutiaoViewController.h"
#import "TTProfileViewController.h"
#import "TTAccountBindingMobileViewController.h"
#import "TTHTSTabViewController.h"
#import <Crashlytics/Crashlytics.h>

//#import "TTUGCPermissionService.h"
//#import "TTPostUGCEntrance.h"
#import <TTIndicatorView.h>
#import "PGCAccountManager.h"
#import "TTAdSplashMediator.h"
//#import "TTPLManager.h"
#import "TTBadgeTrackerHelper.h"
#import "TTCustomAnimationDelegate.h"
#import "TTCategoryBadgeNumberManager.h"
#import "TTStartupTasksTracker.h"
#import "TTInterfaceTipManager.h"
#import "TTVFullscreenViewController.h"
#import "TTBubbleViewManager.h"
#import "TTFreeFlowTipManager.h"
//#import "TTForumPostThreadStatusViewModel.h"
//#import "TTContactsAddFriendsViewController.h"
//#import "TTCommonwealManager.h"
#import "TTTopBar.h"
#import <TTBubbleView.h>
#import "TTBubbleViewHeader.h"
#import "TTGuideDispatchManager.h"
#import "TTVSettingsConfiguration.h"
#import "TTSettingsManager.h"
#import "TSVStartupTabManager.h"
#import "TTShortVideoHelper.h"
#import "TSVTabViewController.h"
#import "TSVTabTipManager.h"
#import "TTTabBarProvider.h"
#import "TSVTabManager.h"
#import "TTTabBarManager.h"
//#import "TSVPublishManager.h"
#import "TTTabBarProvider.h"
#import "TSVTabManager.h"
#import "TTTabBarCustomMiddleModel.h"
//#import "TTFantasyTimeCountDownManager.h"
//#import "TTFantasyWindowManager.h"
#import "AKActivityTabManager.h"
#import "TTMessageNotificationTipsManager.h"
//爱看
#import "AKImageAlertManager.h"
#import "AKActivityTabManager.h"
#import "AKProfileBenefitManager.h"
#import "AKLoginTrafficViewController.h"
//#import "Bubble-Swift.h"
#import <FHEnvContext.h>
#import <BDABTestSDK/BDABTestManager.h>
#import <HMDTTMonitor.h>

extern NSString *const kFRConcernCareActionHadDone;
extern NSString *const kFRHadShowFirstConcernCareTips;
extern NSString *const kFRHadShowFirstForumLikeTips;
extern NSString *const TTLaunchTimerTaskLaunchTimeIntervalKey;

NSString * const TTArticleTabBarControllerChangeSelectedIndexNotification = @"TTArticleTabBarControllerChangeSelectedIndexNotification";

typedef NS_ENUM(NSUInteger,TTTabbarTipViewType){
    TTTabbarTipViewTypeDefault  = 0,//针对的是关注tip和视频tip
    TTTabbarTipViewTypeRefresh,     //针对的是新用户刷新引导的tip
};

//@interface QuickLoginDelegate () <QuickLoginVCDelegate>
//
//@property (nonatomic, copy) void (^DidSelectItem)();
//
//@end
//
//
//@implementation QuickLoginDelegate
//
//- (void)loginSuccessed {
//    if (_DidSelectItem != nil) {
//        _DidSelectItem();
//    }
//}
//
//@end

@interface TTArticleTabBarController () <UITabBarControllerDelegate, UINavigationControllerDelegate, TTUIViewControllerTrackProtocol, TTAccountMulticastProtocol,TTInterfaceTabBarControllerProtocol>
{
    NSArray * storyboardNames;
    NSArray<NSString *>* viewControllerNames;
    NSArray * tabBarItemImageKeys;
    NSArray * tabBarItemNameKeys;
}

@property (nonatomic, strong) TTBubbleView *tabbarTipView;
@property (nonatomic, strong) ArticleCategoryManagerView *categoryManagerView;
//@property (nonatomic, strong) TTContactsAddFriendsViewController *addFriendsViewController;
@property (nonatomic, assign) BOOL isInvisble;//当前视图是否已经push或者Present到别的页面
@property (nonatomic, assign) BOOL isBackground;//当前视图是否已经被挂起到后台
@property (nonatomic, assign) BOOL needShowSurfaceTip;
@property (nonatomic, assign) BOOL autoEnterShortVideoTab;
@property (nonatomic, assign) BOOL autoEnterTab;
@property (nonatomic, strong) NSString *lastSelectedTabTag;

@property (nonatomic, strong) LOTAnimationView *animationView1;

@property (nonatomic, assign) BOOL isClickTab;

@end

@implementation TTArticleTabBarController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (void)setupEssentialInitialization {
    [self registerNotification];
    
    if ([SSCommonLogic isNewLaunchOptimizeEnabled]) {
        self.tabbarHeight = [TTDeviceHelper isIPhoneXDevice] ? ([TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom + 49.f) : 49.f;
        self.ttTabBarStyle = @"White";
        self.ttHideNavigationBar = YES;
    }
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adShowFinish:) name:kTTAdSplashShowFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadgeNumber:) name:kChangeExploreTabBarBadgeNumberNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBadgeMangerChangedNotification:) name:kArticleBadgeManagerRefreshedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayCategoryManagerView:) name:kDisplayCategoryManagerViewNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCategoryManagerView:) name:kCloseCategoryManagerViewNotification object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAddFriendsView:) name:kPresentAddFriendsViewNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAddFriendsView:) name:kDismissAddFriendsViewNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTheme)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    
    [TTAccount addMulticastDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabbarTip) name:@"kTabbarShowTipNotification" object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationStatusBarDidRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(postUGCPermissionUpdate:)
//                                                 name:kTTPostUGCPermissionUpdateNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTabbarIndex:) name:TTArticleTabBarControllerChangeSelectedIndexNotification object:nil];
    //消息通知优化重要的人消息未读提示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageNotificationTips:) name:kTTMessageNotificationTipsChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(baiwanyingxiong:) name:@"kFantasyTimeCountDown" object:nil];
}

- (void)baiwanyingxiong:(NSNotification *)notification
{
    if (![SSCommonLogic fantasyCountDownEnable] || self.viewControllers.count >= 5) {
        return;
    }
    
    UIView *customView = [TTTabBarManager sharedTTTabBarManager].customMiddleButton;
    if (!customView || ![[TTTabBarManager sharedTTTabBarManager].middleModel.originalIdentifier isEqualToString:kTTTabActivityTabKey]) {
        return;
    }
    
    if (!_animationView1) {
        NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json" inDirectory:@"FantasyAnimation.bundle"];
        _animationView1 = [LOTAnimationView animationWithFilePath:filePath1];
        _animationView1.contentMode = UIViewContentModeScaleToFill;
        _animationView1.frame = CGRectMake(50, 170, 50, 44);
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFantasyWindow)];
        [_animationView1 addGestureRecognizer:tapGestureRecognizer];
    }
    
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        _animationView1.alpha = 0.5;
    } else {
        _animationView1.alpha = 1.0;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    CGFloat progress = 0;
    if (userInfo[@"progress"]) {
        progress = [userInfo[@"progress"] floatValue];
    }
    
    [TTTrackerWrapper eventV3:@"fantasy_window_countdown_start" params:@{@"progress":@(progress)}];
    
    ((TTTabbar *)(self.tabBar)).middleCustomItemView = _animationView1;
    _animationView1.hidden = NO;
    _animationView1.animationProgress = 0;
    [TTTabBarManager sharedTTTabBarManager].customMiddleButton.hidden = YES;
    [_animationView1 playFromProgress:progress toProgress:1 withCompletion:^(BOOL animationFinished) {
        if (animationFinished) {
            UIView *customView = [TTTabBarManager sharedTTTabBarManager].customMiddleButton;
            ((TTTabbar *)(self.tabBar)).middleCustomItemView = customView;
        } else {
            _animationView1.hidden = YES;
            UIView *customView = [TTTabBarManager sharedTTTabBarManager].customMiddleButton;
            ((TTTabbar *)(self.tabBar)).middleCustomItemView = customView;
            
        }
        [TTTabBarManager sharedTTTabBarManager].customMiddleButton.hidden = NO;
    }];
}

- (void)openFantasyWindow
{
    if ([SSCommonLogic fantasyWindowResizeable]) {
        [TTTrackerWrapper eventV3:@"launch_fantasy_window_from_countdown" params:@{@"resizeable":@"1"}];
        
        if ([[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:[TTTabBarManager sharedTTTabBarManager].middleModel.schema]]) {
            [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:[TTTabBarManager sharedTTTabBarManager].middleModel.schema] userInfo:nil];
        }
    } else {
        [TTTrackerWrapper eventV3:@"launch_fantasy_window_from_countdown" params:@{@"resizeable":@"0"}];
        
        if ([[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:[TTTabBarManager sharedTTTabBarManager].middleModel.schema]]) {
            [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:[TTTabBarManager sharedTTTabBarManager].middleModel.schema] userInfo:nil];
        }
    }
}

- (void)initTabbarBadge
{
    [self reloadTheme];
    for (TTTabBarItem * item in ((TTTabbar *)self.tabBar).tabItems) {
        if ([item isEqual:[((TTTabbar *)self.tabBar).tabItems firstObject]]) {
            item.ttBadgeView.badgeViewStyle = TTBadgeNumberViewStyleDefaultWithBorder;
            item.ttBadgeView.lastBadgeViewStyle = TTBadgeNumberViewStyleDefault;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([SSCommonLogic isNewLaunchOptimizeEnabled]) {
        [self setValue:[[TTTabbar alloc] init] forKey:@"tabBar"];
    }
    [self setupEssentialInitialization];
    [self constructTabItems];
    
    [UITabBar appearance].clipsToBounds = YES;
    //添加自定义线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    lineView.backgroundColor = [UIColor clearColor];
    [[UITabBar appearance] addSubview:lineView];

//    [self addKVO];
    [[TSVTabTipManager sharedManager] setupShortVideoTabRedDotWhenStartupIfNeeded];
    
    [self addClientABTestLog];
}

// add by zjing 测试客户端AB分流清空
- (void)addClientABTestLog
{
    id res1 = [BDABTestManager getExperimentValueForKey:@"show_house" withExposure:YES];
    [[HMDTTMonitor defaultManager]hmdTrackService:@"abtest_show_house" status:[res1 integerValue] extra:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isInvisble = YES;
    TTNavigationController *naviVC = self.viewControllers[self.lastSelectedIndex];
    //退出应用时viewDidDisappear和trackEndedByAppWillEnterBackground回调方法都会执行到，用一个标记为标示一下防止重复发送stay_tab事件
    if (naviVC.viewControllers.count == 1 && !self.isBackground) {
        [self sendLogForTabStayWithIndex:self.lastSelectedIndex delayResetStayTime:YES];
    }
}

-(void)constructTabItems{
    [self setViewControllers:[TTTabBarManager sharedTTTabBarManager].viewControllers];
    [self updateTabBarControllerWithAutoJump:NO];
    
    UIView *customView = [TTTabBarManager sharedTTTabBarManager].customMiddleButton;
    ((TTTabbar *)(self.tabBar)).middleCustomItemView = customView;
    if (customView && [[TTTabBarManager sharedTTTabBarManager].middleModel.originalIdentifier isEqualToString:kTTTabActivityTabKey]) {
        [TTTrackerWrapper eventV3:@"show_million_pound" params:@{@"enter_from":@"click_bottom"}];
    }
    
    // 统计 - 启动时进入首页
    NSInteger htsTabStatus = 0;
    if ([[TSVTabManager sharedManager] indexOfShortVideoTab] == self.viewControllers.count - 1){
        htsTabStatus = 4;
        [TTTrackerWrapper eventV3:@"launch_fourth_tab" params:@{@"tab_name":kTTUGCVideoCategoryID}];
    } else {
        [TTTrackerWrapper eventV3:@"launch_fourth_tab" params:@{@"tab_name":@"mine"}];
    }
    
    if ([[TSVTabManager sharedManager] indexOfShortVideoTab] == self.viewControllers.count - 2) {
        htsTabStatus = 3;
        [TTTrackerWrapper eventV3:@"launch_third_tab" params:@{@"tab_name":kTTUGCVideoCategoryID}];
    } else {
        [TTTrackerWrapper eventV3:@"launch_third_tab" params:@{@"tab_name":@"weitoutiao"}];
    }
    
    [[TTMonitor shareManager] trackService:@"short_video_tab_index" status:htsTabStatus extra:nil];
    
    wrapperTrackEvent(@"navbar", @"enter_home_launch");
    [self initTabbarBadge];
    [self refreshBadge];
    
    self.ttTrackStayEnable = YES;
    
    [[TTStartupTasksTracker sharedTracker] cacheInitializeDevLog:@"construct_tabs" params:@{
                                                                                   @"weitoutiao" : @([TTTabBarProvider isWeitoutiaoOnTabBar]),
                                                                                   @"huoshan" : @([TTTabBarProvider isHTSTabOnTabBar])}];
}

- (void)updateTabBarControllerWithAutoJump:(BOOL)autoJump
{
    NSMutableArray *updateItems = [NSMutableArray array];
    NSMutableArray *tabTags = [NSMutableArray array];
    NSMutableArray *vcs = [NSMutableArray array];
    NSMutableArray *freezedItems = [NSMutableArray array];
    NSMutableArray *items = [[TTTabBarManager sharedTTTabBarManager].tabItems mutableCopy];
    TTTabBarItem *lastSelectItem = nil;
    for (TTTabBarItem * item in items) {
        if (!item.freezed) {
            [vcs addObject:item.viewController];
            [updateItems addObject:item];
            [tabTags addObject:item.identifier];
        } else {
            [freezedItems addObject:item];
        }
        
        if ([item.identifier isEqualToString:self.lastSelectedTabTag]) {
            lastSelectItem = item;
        }
    }
    
    // 如果当前tab没有被freeze，则不自动跳转
    BOOL shouldJump = NO;
    for (TTTabBarItem * freezedItem in freezedItems) {
        if ([freezedItem.viewController isKindOfClass:[UINavigationController class]]) {
            [((UINavigationController *)freezedItem.viewController) popToRootViewControllerAnimated:NO];
        }
        
        if ([freezedItem.identifier isEqualToString:[self currentTabIdentifier]]) {
            shouldJump = YES;
        }
    }
    
    autoJump = autoJump && shouldJump;
    
//    // 更新tabbar的item和viewControllers，以及标记位
//    [self setViewControllers:[vcs copy]];
//    ((TTTabbar *)self.tabBar).tabItems = [updateItems copy];
//    [[TTTabBarManager sharedTTTabBarManager] updateTabTags:tabTags];
    
    [updateItems enumerateObjectsUsingBlock:^(TTTabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item.identifier isEqualToString:lastSelectItem.identifier]) {
            self.lastSelectedTabTag = item.identifier;
            self.lastSelectedIndex = idx;
        }
    }];
    
    // 默认切换到第一个tab
    if ([TTTabBarManager sharedTTTabBarManager].tabItems.count > 0 && autoJump) {
        NSString *firstTabItemIdentifier = [[TTTabBarManager sharedTTTabBarManager].tabItems firstObject].identifier;
        [[NSNotificationCenter defaultCenter] postNotificationName:TTArticleTabBarControllerChangeSelectedIndexNotification object:nil userInfo:({
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:firstTabItemIdentifier forKey:@"tag"];
            [userInfo copy];
        })];
    }
    
    // 更新tabbar的item和viewControllers，以及标记位
    [self setViewControllers:[vcs copy]];
    ((TTTabbar *)self.tabBar).tabItems = [updateItems copy];
    [[TTTabBarManager sharedTTTabBarManager] updateTabTags:tabTags];
}

- (SSThemedButton *)generatePublishButton {
    TTTabBarItem *item = [[TTTabBarManager sharedTTTabBarManager].tabItems lastObject];
    
    SSThemedButton * postUGCEntranceButton = [[SSThemedButton alloc] init];
    postUGCEntranceButton.adjustsImageWhenHighlighted = NO;
    [postUGCEntranceButton setImageName:@"ugc_publish_tabbar"];
    [postUGCEntranceButton setTitle:@"发布" forState:UIControlStateNormal];
    [postUGCEntranceButton setTitleColor:item.normalTitleColor forState:UIControlStateNormal];
    [postUGCEntranceButton.titleLabel setFont:item.titleFont];
    [postUGCEntranceButton sizeToFit];
    
    NSUInteger count = [TTTabBarManager sharedTTTabBarManager].tabItems.count + 1;
    
    postUGCEntranceButton.size = CGSizeMake(self.tabBar.width/count, 44);
    
    CGSize imageSize = postUGCEntranceButton.imageView.frame.size;
    CGSize titleSize = postUGCEntranceButton.titleLabel.frame.size;
    NSUInteger totalHeight = imageSize.height + titleSize.height;
    postUGCEntranceButton.imageEdgeInsets = UIEdgeInsetsMake( - (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    postUGCEntranceButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0, - imageSize.width, - (totalHeight - titleSize.height) + 8, 0.0);
    
    [postUGCEntranceButton addTarget:self
                              action:@selector(showPostUGCEntrance:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    return postUGCEntranceButton;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    [super setViewControllers:viewControllers];
    
    for (UIViewController *vc in viewControllers) {
        if ([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi =  (UINavigationController *)vc;
            if (!navi.delegate) {
                [navi setDelegate:self];
            }
        }
    }

    ((TTTabbar *)self.tabBar).tabItems = [TTTabBarManager sharedTTTabBarManager].tabItems;

    WeakSelf;
    [((TTTabbar *)self.tabBar) setItemSelectedBlock:^(NSUInteger index){
        __strong typeof(wself) self = wself;
        
        void (^DidSelectItem)() = ^() {
            
            if (self.viewControllers.count > self.lastSelectedIndex && self.lastSelectedIndex >= 0) {
                TTNavigationController *lastNav = self.viewControllers[self.lastSelectedIndex];
                lastNav.shouldIgnorePushingViewControllers = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    lastNav.shouldIgnorePushingViewControllers = NO;
                });
            }
            
            self.selectedIndex = index;
            if(![[self currentTabIdentifier] isEqualToString:[self lastTabIdentifier]]) {
                [(((TTTabbar *)self.tabBar).tabItems[self.lastSelectedIndex]) setState:TTTabBarItemStateNormal];
                [(((TTTabbar *)self.tabBar).tabItems[self.selectedIndex]) setState:TTTabBarItemStateHighlighted];
            }
            // add by zjing
            if (![[self currentTabIdentifier] isEqualToString: kTTTabHomeTabKey]) {
                TTTabBarItem *item = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kTTTabHomeTabKey];
                [[TTTabBarManager sharedTTTabBarManager]reloadIconAndTitleForItem:item];
            }

            [self tabBarController:self didSelectViewController:self.viewControllers[index]];
            
        };
        

        
        BOOL canItemSelected = YES;
        //去掉消息tab强登录设定
//        NSString *toTabTag = ((TTTabbar *)self.tabBar).tabItems[index].identifier;
//        if (!tta_IsLogin() && [toTabTag isEqualToString:kFHouseMessageTabKey]) {
//            canItemSelected = NO;
//            QuickLoginDelegate* delegate = [[QuickLoginDelegate alloc] init];
//            delegate.DidSelectItem = DidSelectItem;
//            TTRouteUserInfo* obj = [[TTRouteUserInfo alloc] initWithInfo:@{@"delegate": delegate}];
//            if ([TTDeviceHelper isIPhoneXDevice]) {
//                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString: @"fschema://flogin"] userInfo:obj];
//            } else {
//                [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString: @"fschema://flogin"] userInfo: obj];
//            }
//            [self trackBadgeWithTabBarTag:kFHouseMessageTabKey enter_type:@"click_tab"];
//
//
//        }
        if (canItemSelected) {
            DidSelectItem();
        }
    }];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //默认第一个Tab被选中（只有第一次生效）
//        NSUInteger defaultIndex = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabHomeTabKey];
//        [[TTTabBarManager sharedTTTabBarManager].tabItems[defaultIndex] setState:TTTabBarItemStateHighlighted];
        NSInteger type = [SSCommonLogic firstTabStyle];
        NSString *tabKey = kTTTabHomeTabKey;
        if (type == 1) {
            tabKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"kLastSelectTab"];
            if (!tabKey) {
                tabKey = kTTTabHomeTabKey;
            }
        }
        if (type == 2) {
            tabKey = [SSCommonLogic feedStartTab];
            if (!tabKey) {
                tabKey = kTTTabHomeTabKey;
            }
        }
        
        NSString *tabInfo = @"stream";
        if ([tabKey isEqualToString:kTTTabHomeTabKey]) {
            tabInfo = @"stream";
        } else if ([tabKey isEqualToString:kTTTabVideoTabKey]) {
            tabInfo = @"video";
        } else if ([tabKey isEqualToString:kTTTabWeitoutiaoTabKey]) {
            tabInfo = @"weitoutiao";
        } else if ([tabKey isEqualToString:kTTTabHTSTabKey]) {
            tabInfo = kTTUGCVideoCategoryID;
        } else if ([tabKey isEqualToString:kTTTabMineTabKey]) {
            tabInfo = @"mine";
        } else if ([tabKey isEqualToString:kTTTabFollowTabKey]) {
            tabInfo = @"follow";
        }
        NSString *startCategory = nil;
        if (type == 1) {
            startCategory = [[NSUserDefaults standardUserDefaults] valueForKey:@"kLastSelectCategory"];
            if (!startCategory) {
                startCategory = @"__all__";
            }
        }
        if (type == 2) {
            startCategory = [SSCommonLogic feedStartCategory];
            if (!startCategory) {
                startCategory = @"__all__";
            }
        }
        if (!startCategory) {
            startCategory = @"__all__";
        }
        NSInteger categoryType = [SSCommonLogic firstCategoryStyle];
        [TTTrackerWrapper eventV3:@"launch_position" params:@{@"tab_name":tabInfo, @"launch_type":@(categoryType), @"category_name":startCategory}];
        
        // add by zjing 首次默认tabBar 选中
        [self trackBadgeWithTabBarTag:kTTTabHomeTabKey enter_type:@"default"];
        
        if ([tabKey isEqualToString:kTTTabHomeTabKey]) {
            NSUInteger defaultIndex = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabHomeTabKey];
            [[TTTabBarManager sharedTTTabBarManager].tabItems[defaultIndex] setState:TTTabBarItemStateHighlighted];
        } else {
            NSUInteger defaultIndex = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:tabKey];
            if (defaultIndex == NSNotFound) {
                defaultIndex = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabHomeTabKey];
            }
            self.selectedIndex = defaultIndex;
            if(![[self currentTabIdentifier] isEqualToString:[self lastTabIdentifier]]) {
                [(((TTTabbar *)self.tabBar).tabItems[self.lastSelectedIndex]) setState:TTTabBarItemStateNormal];
                [(((TTTabbar *)self.tabBar).tabItems[self.selectedIndex]) setState:TTTabBarItemStateHighlighted];
                //[((TTTabbar *)self.tabBar) setItemLoading:NO forIndex:defaultIndex];
                ((TTTabbar *)self.tabBar).selectedIndex = defaultIndex;
            }
            [[TTTabBarManager sharedTTTabBarManager].tabItems[defaultIndex] setState:TTTabBarItemStateHighlighted];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self tabBarController:self didSelectViewController:self.viewControllers[defaultIndex]];
            });
            //[self tabBarController:self didSelectViewController:self.viewControllers[defaultIndex]];
        }
    });
    
//    if ([TTTabBarProvider isPublishButtonOnTabBar]) {
//
//        SSThemedButton * postUGCEntranceButton = [self generatePublishButton];
//        ((TTTabbar *)self.tabBar).middleCustomItemView = postUGCEntranceButton;
//        if (bTrackMainPublisherLog) {
//            [TTTrackerWrapper eventV3:@"navbar_show_publisher" params:nil];
//            bTrackMainPublisherLog = NO;
//        }
//    }
}

//// 动态替换某个 Tab 的视图，不支持追加和插入
//- (void)replaceViewController:(UIViewController *)viewController
//                      atIndex:(NSUInteger)index {
//
//    NSMutableArray * array = [NSMutableArray arrayWithArray:self.viewControllers];
//    // index 超限
//    if (index >= array.count)
//        return;
//
//    [array replaceObjectAtIndex:index withObject:viewController];
//    [super setViewControllers:array animated:YES];
//
//    NSArray * tabItems = ((TTTabbar *)self.tabBar).tabItems;
//    [[TTTabBarManager sharedTTTabBarManager] reloadIconAndTitleForItem:tabItems[index] index:index];
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([SSCommonLogic shouldUseOptimisedLaunch]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationMainViewDidShowNotification object:nil];
    }
    self.isInvisble = NO;
    
    //在这缓存tabbar label的尺寸，此时都已经布局好
    if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [TTTabBarItem syncAllCachedBounds];
            });
        });
    }
    
    [self openShortVideoTabWhenStartupIfNeeded];
}

- (BOOL)isShowingConcernOrForumTab
{
    return [[self lastTabIdentifier] isEqualToString:kTTTabFollowTabKey];
}

- (void)reloadTheme
{
    [[TTTabBarManager sharedTTTabBarManager] reloadThemeForTabbar:(TTTabbar *)self.tabBar style:self.ttTabBarStyle];
    TTTabBarItem *item = [[TTTabBarManager sharedTTTabBarManager].tabItems lastObject];
    UIView * middleCustomItemView = ((TTTabbar *)self.tabBar).middleCustomItemView;
    if ([middleCustomItemView isKindOfClass:[SSThemedButton class]]) {
        SSThemedButton *button = (SSThemedButton *)middleCustomItemView;
        [button setTitleColor:item.normalTitleColor forState:UIControlStateNormal];
    }else if ([middleCustomItemView.subviews.firstObject isKindOfClass:[SSThemedButton class]]) {
        SSThemedButton *button = (SSThemedButton *)middleCustomItemView.subviews.firstObject;
        [button setTitleColor:item.normalTitleColor forState:UIControlStateNormal];
    }
//    NSUInteger index = 0;
//    for (UIViewController * vc in self.viewControllers) {
//        vc.tabBarItem.image = [[UIImage themedImageNamed:tabBarItemImageKeys[index]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        vc.tabBarItem.selectedImage = [[UIImage themedImageNamed:[NSString stringWithFormat:@"%@_press",tabBarItemImageKeys[index]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        index++;
//    }
    
    if (_animationView1.isAnimationPlaying) {
        [_animationView1 pause];
        CGFloat progress = _animationView1.animationProgress;
        
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            _animationView1.alpha = 0.5;
        } else {
            _animationView1.alpha = 1.0;
        }
        
        //_animationView1.animationProgress = 0;
        
        ((TTTabbar *)(self.tabBar)).middleCustomItemView = _animationView1;
        _animationView1.hidden = NO;
        [TTTabBarManager sharedTTTabBarManager].customMiddleButton.hidden = YES;
        [_animationView1 playFromProgress:progress toProgress:1 withCompletion:^(BOOL animationFinished) {
            //            if (animationFinished) {
            //                UIView *customView = [TTTabBarManager sharedTTTabBarManager].customMiddleButton;
            //                ((TTTabbar *)(self.tabBar)).middleCustomItemView = customView;
            //            }
            
            if (animationFinished) {
                UIView *customView = [TTTabBarManager sharedTTTabBarManager].customMiddleButton;
                ((TTTabbar *)(self.tabBar)).middleCustomItemView = customView;
            } else {
                _animationView1.hidden = YES;
                UIView *customView = [TTTabBarManager sharedTTTabBarManager].customMiddleButton;
                ((TTTabbar *)(self.tabBar)).middleCustomItemView = customView;
                
            }
            [TTTabBarManager sharedTTTabBarManager].customMiddleButton.hidden = NO;
            
            
        }];
    }
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    if (![TTTabBarProvider isMineTabOnTabBar]) {
        return;
    }
    
    TTTabBarItem *item = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kTTTabMineTabKey];
    
    [[TTTabBarManager sharedTTTabBarManager] reloadIconAndTitleForItem:item];
}

- (void)onAccountLogin
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [ArticleFetchSettingsManager startFetchDefaultInfoIfNeed];
    });
}

- (void)onAccountLogout
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [ArticleFetchSettingsManager startFetchDefaultInfoIfNeed];
    });
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([TTDeviceHelper isPadDevice]) {
        return UIInterfaceOrientationMaskAll;
    }
    
    UIViewController *topmostViewController = self;
    while (topmostViewController.presentedViewController) {
        topmostViewController = topmostViewController.presentedViewController;
    }
    if ([topmostViewController isKindOfClass:[TTMovieFullscreenViewController class]] || [topmostViewController isKindOfClass:[TTVFullscreenViewController class]]) {
        if (!topmostViewController.isBeingDismissed && !topmostViewController.isBeingPresented) {
            //如果当前正在播放全屏视频，则允许转屏
            return [topmostViewController supportedInterfaceOrientations];
        }
    }
    
    return [self.selectedViewController supportedInterfaceOrientations];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.count > 1) {
        if (navigationController.viewControllers.count == 2) {
            [self sendLogForTabStayWithIndex:self.lastSelectedIndex delayResetStayTime:YES];
        }
        WeakSelf;
        [_tabbarTipView hideTipWithAnimation:YES forceHide:YES completionHandle:^{
            //Todo
            StrongSelf;
            if(self.tabbarTipView.type == TTBubbleViewTypeVideoTip){
                wrapperTrackEvent(@"video", @"video_tip_leave");
            }
        }];
        //跳转后隐藏消息通知
        [[TTMessageNotificationTipsManager sharedManager] forceRemoveTipsView];
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreTopVCChangeNotification object:self];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (navigationController.viewControllers.count == 1 && NO == [TTAdSplashMediator shareInstance].isAdShowing) {
        //回到tabbar controller某个导航控制器的栈底，并且没有开屏广告
        [self showTipViewIfNeeded];
        [self showMessageNotificationTips:nil];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    return [[TTCustomAnimationManager sharedManager] customAnimationForOperation:operation fromViewController:fromVC toViewController:toVC];
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return [[TTCustomAnimationManager sharedManager] percentDrivenTransitionForAnimationController:animationController];
}

- (void)showTipViewIfNeeded
{
    if (![self tipsCouldShow]) {
        return;
    }

    NSString *displayIdentifier;
    NSString *tipText = nil;
    NSString *imageName = nil;
    TTBubbleViewArrowDirection lineDirection = TTBubbleViewArrowUp;
    TTBubbleViewType viewType = TTBubbleViewTypeDefault;
    
    if (isEmptyString(tipText) && [[TSVTabTipManager sharedManager] shouldShowBubbleTip]) {
        displayIdentifier = kTTTabHTSTabKey;
        tipText = [[TSVTabTipManager sharedManager] textForBubbleTip];
        imageName = @"detail_close_icon";
        lineDirection = TTBubbleViewArrowDown;
        viewType = TTBubbleViewTypeShortVideoTabTip;
    }
    
    if (isEmptyString(tipText)) {
        BOOL shouldShowVideoTip = [TTVideoTip shouldShowVideoTip];
        if (shouldShowVideoTip && ![[self lastTabIdentifier] isEqualToString:kTTTabVideoTabKey]) {
            displayIdentifier = kTTTabVideoTabKey;
            tipText = NSLocalizedString(@"精彩视频在这里", nil);
            imageName = @"detail_close_icon";
            lineDirection = TTBubbleViewArrowDown;
            viewType = TTBubbleViewTypeVideoTip;
        }
    }
    
    CGFloat delayDuration = 0.1;//ugly code:推迟调用。否则tip在首次会漂移。
    CGFloat autoDismissInterval = 0;
    if (isEmptyString(tipText)) {
        if(![TTBubbleViewManager shareManager].isValid){
            return;
        }
        NSTimeInterval launchTime = [[NSUserDefaults standardUserDefaults] doubleForKey:TTLaunchTimerTaskLaunchTimeIntervalKey];
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        CGFloat displayInterval = [TTBubbleViewManager shareManager].displayInterval;
        if (currentTime > launchTime && currentTime - launchTime < displayInterval) {
            delayDuration = displayInterval - (currentTime - launchTime);
        }
        autoDismissInterval = [TTBubbleViewManager shareManager].autoDismissInterval;
        tipText = [TTBubbleViewManager shareManager].text;
        imageName = @"detail_close_icon";
        lineDirection = TTBubbleViewArrowDown;
        viewType = [TTBubbleViewManager shareManager].viewType;
        displayIdentifier = [[TTBubbleViewManager shareManager] tabbarIdentifier];
    }
    
    if (isEmptyString(tipText)) {
        return;
    }
    
    CGPoint anchorPoint = CGPointZero;
    
    if (viewType == TTBubbleViewTypePostUGCTip || viewType == TTBubbleViewTypeTimerPostUGCTip) {
        //发布器上出tip
        anchorPoint = CGPointMake(self.view.size.width - 24, 40);
        anchorPoint.y += self.view.tt_safeAreaInsets.top;
    } else if ([self isTipsMineTopEntranceForViewType:viewType]) {
        //左上角”我的“头像上出tip
        lineDirection = TTBubbleViewArrowUp;
        anchorPoint = CGPointMake(kMineIconLeft + kMineIconW / 2, 40);
        anchorPoint.y += self.view.tt_safeAreaInsets.top;
    } else {
        //底tab出tip
        if (![[TTTabBarManager sharedTTTabBarManager].tabTags containsObject:displayIdentifier]) {
            return;
        }
        
        NSUInteger properIndex = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:displayIdentifier];
        
        if (properIndex >= ((TTTabbar *)self.tabBar).tabItems.count) {
            return;
        }
        
        UIView *tabbarItemView = ((TTTabbar *)self.tabBar).tabItems[properIndex];
        CGFloat centerX = tabbarItemView.frame.origin.x + tabbarItemView.frame.size.width / 2;
        anchorPoint = CGPointMake(centerX, self.tabBar.origin.y - 3);
    }

    self.tabbarTipView = [[TTBubbleView alloc] initWithAnchorPoint:anchorPoint imageName:imageName tipText:tipText attributedText:nil arrowDirection:lineDirection lineHeight:0 viewType:viewType screenMargin:15];
    [self.view addSubview:self.tabbarTipView];
    
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StrongSelf;
        [self showTipWithAnimation];
    });
}

- (void)showPublishTipsIfNeeded {
    if (![self tipsCouldShow]) {
        return;
    }

    NSString *tipText = nil;
    NSString *imageName = nil;
    TTBubbleViewArrowDirection lineDirection = TTBubbleViewArrowUp;
    TTBubbleViewType viewType = TTBubbleViewTypeDefault;
    
//    if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) isNeedShowPostUGCTipsView] && [TTTabBarProvider isPublishButtonOnTopBar] && [[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey]) {
//        [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) setHadShowPostUGCTipsView];
//        tipText = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCTips];
//        imageName = @"detail_close_icon";
//        lineDirection = TTBubbleViewArrowUp;
//        viewType = TTBubbleViewTypePostUGCTip;
//    }
    
    if(isEmptyString(tipText)) {
        return;
    }
    
    //发布器上出tip
    CGPoint anchorPoint = CGPointMake(self.view.size.width - 24, 40);
    anchorPoint.y += self.view.tt_safeAreaInsets.top;
    
    self.tabbarTipView = [[TTBubbleView alloc] initWithAnchorPoint:anchorPoint imageName:imageName tipText:tipText attributedText:nil arrowDirection:lineDirection lineHeight:0 viewType:viewType screenMargin:15];
    [self.view addSubview:self.tabbarTipView];
    
    CGFloat delayDuration = 0.1f;
    
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StrongSelf;
        [self showTipWithAnimation];
    });
}

- (void)showTipWithAnimation
{
    if (![self tipsCouldShow]) {
        return;
    }

    NSTimeInterval autoHideInterval = 5;
    
    if ([[TTBubbleViewManager class] isViewTypeTimer:self.tabbarTipView.type]) {
        [[TTBubbleViewManager shareManager] setTipHasShow];
        [[TTBubbleViewManager shareManager] sendTrackForTipsShow];
        autoHideInterval = [TTBubbleViewManager shareManager].autoDismissInterval;
    } else if (self.tabbarTipView.type == TTBubbleViewTypeVideoTip) {
        [TTVideoTip saveVideoTipShowDate];
        //视频tip统计
        wrapperTrackEvent(@"video",@"video_tip_show");
        [TTVideoTip setHasShownVideoTip:YES];
    } else if (self.tabbarTipView.type == TTBubbleViewTypeMineTopEntranceTip){
        [SSCommonLogic setHTSTabMineIconTipsHasShow:YES];
    }
    else if (self.tabbarTipView.type == TTBubbleViewTypeShortVideoTabTip) {
        [[TSVTabTipManager sharedManager] updateBubbleTipShownStatus];
        [self trackTabBubbleTipShowEventWithIndex:[[TSVTabTipManager sharedManager] indexForBubbleTip]];
    }
    [[TSVTabTipManager sharedManager] setShouldNotShowBubbleTip];
    
    self.tabbarTipView.willShow = YES;
    
    NSDate *startDate = [[NSDate alloc] init];
    self.tabbarTipView.willShow = NO;
    WeakSelf;
    [self.tabbarTipView showTipWithAnimation:YES automaticHide:YES autoHideInterval:autoHideInterval animationCompleteHandle:nil autoHideHandle:^{
        //Todo
        StrongSelf;
        if ([[TTBubbleViewManager class] isViewTypeTimer:self.tabbarTipView.type]) {
            [[TTBubbleViewManager shareManager] sendTrackForTipsAutoClose];
        } else if(self.tabbarTipView.type == TTBubbleViewTypeVideoTip){
            wrapperTrackEvent(@"video", @"video_tip_close");
        } else if (self.tabbarTipView.type == TTBubbleViewTypeNightShiftMode){
            NSDate *currentDate = [[NSDate alloc] init];
            NSInteger timeInterval = [currentDate timeIntervalSinceDate:startDate];
            [TTTrackerWrapper eventV3:@"eye_care_tips_close" params:@{@"stay_time":@(timeInterval)}];
        } else if (self.tabbarTipView.type == TTBubbleViewTypeResurfaceTip){
                NSDate *currentDate = [[NSDate alloc] init];
                NSInteger timeInterval = [currentDate timeIntervalSinceDate:startDate] * 1000;
                [TTTrackerWrapper eventV3:@"surface_tips_close" params:@{@"stay_time":@(timeInterval)}];
        }
    } tapHandle:nil closeHandle:^{
        if ([[TTBubbleViewManager class] isViewTypeTimer:self.tabbarTipView.type]) {
            [[TTBubbleViewManager shareManager] sendTrackForTipsActiveClose];
            [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES];
        } else {
            switch (self.tabbarTipView.type) {
                case TTBubbleViewTypeVideoTip:{
                    //视频tip统计
                    wrapperTrackEvent(@"video",@"click_video_tip");
                    [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES];
                }
                    break;
                case TTBubbleViewTypeConcernTip:
                case TTBubbleViewTypePostUGCTip:
                case TTBubbleViewTypeMyFollowTip:
                case TTBubbleViewTypePostUGCEntranceChangeTip:
                case TTBubbleViewTypePrivateLetterTip:
                case TTBubbleViewTypeMineTopEntranceTip:
                {
                    [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES];
                }
                    break;
                case TTBubbleViewTypeNightShiftMode:
                {
                    [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES];
                    NSDate *currentDate = [[NSDate alloc] init];
                    NSInteger timeInterval = [currentDate timeIntervalSinceDate:startDate] * 1000;
                    [TTTrackerWrapper eventV3:@"eye_care_tips_close" params:@{@"stay_time":@(timeInterval)}];
                }
                    break;
                case TTBubbleViewTypeResurfaceTip:
                {
                    NSDate *currentDate = [[NSDate alloc] init];
                    NSInteger timeInterval = [currentDate timeIntervalSinceDate:startDate] * 1000;
                    [TTTrackerWrapper eventV3:@"surface_tips_close" params:@{@"stay_time":@(timeInterval)}];
                    [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES];
                }
                    break;
                case TTBubbleViewTypeCommonwealTip:
                {
                    [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES];
                }
                    break;
                case TTBubbleViewTypeShortVideoTabTip:
                {
                    [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES];
                }
                    break;
                default:
                    break;
            }
        }
    } shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
        StrongSelf;
        return [self tipsCouldShow];
    }];
}

- (BOOL)isTipsMineTopEntranceForViewType:(TTBubbleViewType)viewType
{
    BOOL result = ![TTTabBarProvider isMineTabOnTabBar] &&
    (viewType == TTBubbleViewTypeMineTopEntranceTip ||
     viewType == TTBubbleViewTypeTimerMineTopEntranceTip ||
     viewType == TTBubbleViewTypeNightShiftMode ||
     viewType == TTBubbleViewTypeResurfaceTip ||
     viewType == TTBubbleViewTypeCommonwealTip);
    
    return result;
}

- (BOOL)isTipsShowing
{
    if (self.tabbarTipView.isAnimating || self.tabbarTipView.isShowing || self.tabbarTipView.willShow ||
        [TTMessageNotificationTipsManager sharedManager].isShowingTips) {
        return YES;
    }
    return NO;
}

- (BOOL)tipsCouldShow
{
    if (self.tabbarTipView.isAnimating || self.tabbarTipView.isShowing || self.tabbarTipView.willShow ||
        [TTMessageNotificationTipsManager sharedManager].isShowingTips || ![[TTGuideDispatchManager sharedInstance_tt] isQueueEmpty]) {
        //tip view动画消失或者已经展示
        return NO;
    }

    // 修复线上发现的闪退问题
    if ([self.viewControllers count] > self.lastSelectedIndex) {
        UIViewController *lastVC = self.viewControllers[self.lastSelectedIndex];
        if ([lastVC isKindOfClass:[UINavigationController class]] && ((UINavigationController *)lastVC).viewControllers.count > 1) {//进详情页
            return NO;
        }
    }
    
    if (_categoryManagerView.isShowing){//频道管理
        return NO;
    }
    
//    if (self.addFriendsViewController.isVisible) {//添加好友
//        return NO;
//    }
    
//    if ([TTPostUGCEntrance isShowing]) {//发布器弹出时
//        return NO;
//    }
    
    if ([self isTipsMineTopEntranceForViewType:self.tabbarTipView.type]) {//在左上角弹tips时
        if (![SSCommonLogic threeTopBarEnable] && ![[self lastTabIdentifier] isEqualToString:kTTTabHomeTabKey]) {
            //顶部只有一个topbar且当前不在第一个tab
            return NO;
        }
        if ([SSCommonLogic threeTopBarEnable] && [[self lastTabIdentifier] isEqualToString:kTTTabMineTabKey]) {
            //顶部有三个topbar且当前在第四个tab
            return NO;
        }
    }
    
    return YES;
}

- (void)showMessageNotificationTips:(NSNotification *)notification
{
    if (self.tabbarTipView.isAnimating || self.tabbarTipView.isShowing || self.tabbarTipView.willShow) {
        //tip view动画消失或者已经展示
        return;
    }
    
    UIViewController *lastVC = self.viewControllers[self.lastSelectedIndex];
    if ([lastVC isKindOfClass:[UINavigationController class]] && ((UINavigationController *)lastVC).viewControllers.count > 1) {
        if([((UINavigationController *)lastVC).topViewController isKindOfClass:[TTProfileViewController class]]){
            [[TTMessageNotificationTipsManager sharedManager] saveLastImportantMessageID];
        }
        return;
    }
    
    if (_categoryManagerView.isShowing){
        return;
    }
    
    if ([[self currentTabIdentifier] isEqualToString:kTTTabMineTabKey] && [TTTabBarProvider isMineTabOnTabBar]) { // 在我的Tab页不显示浮窗，并且标记这条消息已读
        [[TTMessageNotificationTipsManager sharedManager] saveLastImportantMessageID];
        return;
    }
    
    CGFloat tabCenterX = 0;
    if ([TTTabBarProvider isMineTabOnTabBar]) {
        NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabMineTabKey];
        if (index < ((TTTabbar *)self.tabBar).tabItems.count) {
            UIView *tabbarItemView = ((TTTabbar *)self.tabBar).tabItems[index];
            tabCenterX = tabbarItemView.frame.origin.x + tabbarItemView.frame.size.width / 2;
        }
    }
    [[TTMessageNotificationTipsManager sharedManager] showTipsInView:self.view tabCenterX:tabCenterX callback:nil];
}

- (void)topBarMineIconTap:(NSNotification *)notification
{
    WeakSelf;
    [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES completionHandle:^{
        StrongSelf;
        if(self.tabbarTipView.type == TTBubbleViewTypeTimerMineTopEntranceTip){
            //顶部我的出tip，隐藏时需要统计
            [[TTBubbleViewManager shareManager] sendTrackForTipsEnterClick];
        }
    }];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)vc
{
    int64_t startTime = [NSObject currentUnixTime];
    
    //切换tab停止所有视频
    [ExploreMovieView removeAllExploreMovieView];
    
    if ([[self currentTabIdentifier] isEqualToString:kTTTabVideoTabKey]) {
        [TTVideoTip setHasShownVideoTip:YES];
        
        NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabVideoTabKey];
        TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
        if (badgeView.badgeValue) {
            wrapperTrackEvent(@"video_redspot", @"click");
        }
        [SSCommonLogic showedVideoTabSpot];
        [badgeView setBadgeNumber:TTBadgeNumberHidden];
    }
    else if ([[self currentTabIdentifier] isEqualToString:kTTTabHomeTabKey]) {
        [self trackBadgeWithLabel:@"click" tabBarTag:kTTTabHomeTabKey];
        [[TTFreeFlowTipManager sharedInstance] showHomeFlowAlert]; //流量统计弹窗
        
        [self trackBadgeWithTabBarTag:kTTTabHomeTabKey enter_type:@"click_tab"];

    }
    else if ([[self currentTabIdentifier] isEqualToString:kTTTabFollowTabKey]) {
        [self trackBadgeWithLabel:@"click" tabBarTag:kTTTabFollowTabKey];
    }
    else if ([[self currentTabIdentifier] isEqualToString:kTTTabMineTabKey]) {
        [self trackBadgeWithLabel:@"click" tabBarTag:kTTTabMineTabKey];
        //切换到我的tab后隐藏气泡
        [[TTMessageNotificationTipsManager sharedManager] forceRemoveTipsView];
        // 标记能够展示绑定手机号逻辑
//        [TTAccountBindingMobileViewController setShowBindingMobileEnabled:YES];
        //检查一下是否需要弹窗
        if (![[self currentTabIdentifier] isEqualToString:self.lastSelectedTabTag]) {
            [AKImageAlertManager checkProfileImageAlertShowIfNeed];
        }
    }
    else if ([[self currentTabIdentifier] isEqualToString:kAKTabActivityTabKey]) {
//        // 单击刷新。首次切到tab不刷
//        static BOOL firstLoad = YES;
//        if (!firstLoad) {
//            [[AKActivityTabManager sharedManager] reloadActivityTabViewController];
//        } else {
//            firstLoad = NO;
//        }
        [self trackBadgeWithLabel:@"click" tabBarTag:kAKTabActivityTabKey];
        
    }else if ([[self currentTabIdentifier] isEqualToString:kFHouseFindTabKey]) {
        
        [self trackBadgeWithTabBarTag:kFHouseFindTabKey enter_type:@"click_tab"];
        
    }else if ([[self currentTabIdentifier] isEqualToString:kFHouseMessageTabKey]) {
        
        [self trackBadgeWithTabBarTag:kFHouseMessageTabKey enter_type:@"click_tab"];
        
    }else if ([[self currentTabIdentifier] isEqualToString:kFHouseMineTabKey]) {
        
        [self trackBadgeWithTabBarTag:kFHouseMineTabKey enter_type:@"click_tab"];
        
    }
    TLS_LOG(@"didSelectViewController=%ld", self.selectedIndex);
    

    //点两次后刷新 或者消去红点
    if ([[self lastTabIdentifier] isEqualToString:[self currentTabIdentifier]]) {
        NSString * eventName=nil;
        if ([[self currentTabIdentifier] isEqualToString:kTTTabHomeTabKey]) {
            NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabHomeTabKey];
            TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
            
            NSDictionary * userInfo = @{kMainTabbarClickedNotificationUserInfoHasTipKey:@(!badgeView.hidden)};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixedListRefreshTypeNotification object:self userInfo:@{@"refresh_reason" : @(ExploreMixedListRefreshTypeClickHome)}];
            
//            [self startRefreshWithIndex:self.selectedIndex];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMainTabbarKeepClickedNotification object:self userInfo:userInfo];
            
            // 统计 - 当前在首页点首页刷新
            if (badgeView.hidden) {
                // 无提醒点首页
                wrapperTrackEvent(@"navbar", @"click_home");
            } else {
                // 有提醒点首页
                wrapperTrackEvent(@"navbar", @"click_home_tip");
            }
            eventName = @"click_bottom_home";
        }
        else if ([[self currentTabIdentifier] isEqualToString:kTTTabFollowTabKey]) {
            NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabFollowTabKey];
            TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMomentTabbarKeepClickedNotification object:self userInfo:nil];
            if (badgeView.hidden) {
                wrapperTrackEvent(@"navbar", @"click_follow");
            } else {
                wrapperTrackEvent(@"navbar", @"click_follow_tip");
            }
        }
        else if([[self currentTabIdentifier] isEqualToString:kTTTabWeitoutiaoTabKey]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMomentTabbarKeepClickedNotification object:self userInfo:nil];
            [TTTrackerWrapper event:@"navbar" label:@"click_weitoutiao" value:nil extValue:nil extValue2:nil dict:nil];
        }
        else if ([[self currentTabIdentifier] isEqualToString:kTTTabHTSTabKey]) {
            [self keepTapShortVideoTab];
        }
        else if ([[self currentTabIdentifier] isEqualToString:kTTTabVideoTabKey]) {
            wrapperTrackEvent(@"navbar", @"click_video");
            eventName = @"click_bottom_video";
            
            NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabVideoTabKey];
            TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
            NSDictionary * userInfo = @{kMainTabbarClickedNotificationUserInfoHasTipKey:@(!badgeView.hidden)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kVideoTabbarKeepClickedNotification object:self userInfo:userInfo];
        }
        else if ([[self currentTabIdentifier] isEqualToString:kTTTabMineTabKey]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMineTabbarKeepClickedNotification object:self userInfo:nil];
        }
        else if([[self currentTabIdentifier] isEqualToString:kTTTabHTSTabKey]) {
            [self keepTapShortVideoTab];
        }
        else if ([[self currentTabIdentifier] isEqualToString:kAKTabActivityTabKey]) {
            [[AKActivityTabManager sharedManager] reloadActivityTabViewController];
        }
    } else {
        if (self.tabbarTipView) {
            [self.tabbarTipView removeFromSuperview];
            self.tabbarTipView = nil;
        }
        
        //如果第一个tab是刷新状态则停止
        [((TTTabbar *)self.tabBar) setItemLoading:NO forIndex:self.lastSelectedIndex];
        
        NSString * eventName = nil;
       
        //tab停留时间打点
        [self sendLogForTabStayWithIndex:self.lastSelectedIndex delayResetStayTime:NO];
        //统计打点
        TTBadgeNumberView *badgeView;
        if (((TTTabbar *)self.tabBar).tabItems.count > self.selectedIndex) {
            badgeView = [[((TTTabbar *)self.tabBar).tabItems objectAtIndex:self.selectedIndex] ttBadgeView];
        }
        
        // enter_tab埋点
//        NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:1];
//        NSString *selectedTabName = [[self class] tabStayStringForIndex:self.selectedIndex];
//        [logv3Dic setValue:selectedTabName forKey:@"tab_name"];
//        if ([selectedTabName isEqualToString:@"f_hotsoon_video"]) {//小视频tab 该埋点必须发
//            [logv3Dic setValue:self.autoEnterShortVideoTab ? @1 : @0 forKey:@"is_auto"];
//            [logv3Dic setValue:[[TSVTabTipManager sharedManager] isShowingRedDot] ? @1 : @0 forKey:@"with_tips"];
//            self.autoEnterShortVideoTab = NO;
//            [TTTrackerWrapper eventV3:@"enter_tab" params:logv3Dic];
//        } else {
//            [logv3Dic setValue:badgeView.hidden?@0:@1 forKey:@"with_tips"];
//            [logv3Dic setValue:self.autoEnterTab?@1:@0 forKey:@"is_auto"];
//            self.autoEnterTab = NO;
//            [TTTrackerWrapper eventV3:@"enter_tab" params:logv3Dic];
//        }
        
        if ([[self currentTabIdentifier] isEqualToString:kTTTabHomeTabKey]) {
            eventName = @"click_bottom_home";
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//                if ([TTForumPostThreadStatusViewModel sharedInstance_tt].isEnterHomeTabFromPostNotification) {
//
//                    wrapperTrackEventWithCustomKeys(@"navbar", @"enter_home_click", nil, nil, @{@"enter_type":@"after_post_auto"});
//                }
//                else{
                    wrapperTrackEvent(@"navbar", @"enter_home_click");
//                }
            }
            

        }

        else if ([[self currentTabIdentifier] isEqualToString:kTTTabFollowTabKey]) {
            NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabFollowTabKey];
            TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
            if ([TTAccountManager isLogin]) {
                if (badgeView.hidden) {
                    wrapperTrackEvent(@"navbar", @"enter_follow");
                }
                else{
                    wrapperTrackEvent(@"navbar", @"enter_follow_tip");
                }
            }
            else {
                if (badgeView.hidden) {
                    wrapperTrackEvent(@"navbar", @"enter_follow");
                }
                else{
                    wrapperTrackEvent(@"navbar", @"enter_follow_tip");
                }
            }
        }
        else if ([[self currentTabIdentifier] isEqualToString:kTTTabWeitoutiaoTabKey]) {
            NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabWeitoutiaoTabKey];
            TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
            [[NSNotificationCenter defaultCenter] postNotificationName:kWeitoutiaoTabbarClickedNotification object:self userInfo:nil];
            if (!badgeView.hidden) {
                if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                    [TTTrackerWrapper event:@"navbar" label:@"enter_weitoutiao_tips" value:nil extValue:nil extValue2:nil dict:nil];
                }
                [TTTrackerWrapper eventV3:@"navbar_enter_weitoutiao"
                                   params:@{
                                            @"with_red_dot" : @1,
                                            }
                          isDoubleSending:YES];
            }
            else {
                if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                    [TTTrackerWrapper event:@"navbar" label:@"enter_weitoutiao" value:nil extValue:nil extValue2:nil dict:nil];
                }
                [TTTrackerWrapper eventV3:@"navbar_enter_weitoutiao"
                                   params:@{
                                            @"with_red_dot" : @0,
                                            }
                          isDoubleSending:YES];
            }
        }
        else if ([[self currentTabIdentifier] isEqualToString:kTTTabVideoTabKey]) {
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                wrapperTrackEvent(@"navbar", @"enter_video_click");
            }
            eventName = @"click_bottom_video";
        }
        else if ([[self currentTabIdentifier] isEqualToString:kTTTabMineTabKey]) {
            //eventName = @"click_bottom_mine";
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                wrapperTrackEvent(@"navbar", @"enter_mine_click");
            }
        }
        else if([[self currentTabIdentifier] isEqualToString:kTTTabHTSTabKey]) {
            [self enterShortVideoTab];
        }
    }
    if ([[TTBubbleViewManager class] isViewTypeTimer:self.tabbarTipView.type]) {//定时出时，点任意tab需要隐藏tip
        WeakSelf;
        [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES completionHandle:^{
            StrongSelf;
            if ([[self currentTabIdentifier] isEqualToString:[TTBubbleViewManager shareManager].tabbarIdentifier] && self.tabbarTipView.type != TTBubbleViewTypeTimerMineTopEntranceTip) {
                //点击出tip的tab时，隐藏tip时，发埋点
                [[TTBubbleViewManager shareManager] sendTrackForTipsEnterClick];
            }
        }];
    }
    else if(_tabbarTipView.type == TTBubbleViewTypeVideoTip){
        //切换频道后，底部的视频tipview不显示
        if(![[self lastTabIdentifier] isEqualToString:[self currentTabIdentifier]]){
            [_tabbarTipView hideTipWithAnimation:YES forceHide:YES completionHandle:^{
                wrapperTrackEvent(@"video", @"video_tip_leave");
            }];
        }
    }
    else if(_tabbarTipView.type == TTBubbleViewTypeConcernTip || _tabbarTipView.type == TTBubbleViewTypePostUGCEntranceChangeTip){
        if([[self currentTabIdentifier] isEqualToString:kTTTabFollowTabKey]){
            [_tabbarTipView hideTipWithAnimation:YES forceHide:YES];
        }
    }
    else if (![[self currentTabIdentifier] isEqualToString:kTTTabHomeTabKey] &&
              (_tabbarTipView.type == TTBubbleViewTypeMineTopEntranceTip ||
              _tabbarTipView.type == TTBubbleViewTypeResurfaceTip ||
               _tabbarTipView.type == TTBubbleViewTypeNightShiftMode)){
              [_tabbarTipView hideTipWithAnimation:YES forceHide:YES];
    } else if (self.tabbarTipView.type == TTBubbleViewTypeShortVideoTabTip && self.selectedIndex == [[TSVTabTipManager sharedManager] indexForBubbleTip]) {
        [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES];
    }
    
    uint64_t endTime = [NSObject currentUnixTime];
    double duration = [NSObject machTimeToSecs:(endTime - startTime)];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@(duration) forKey:@"duration"];
    [params setValue:@(self.lastSelectedIndex) forKey:@"last_index"];
    [params setValue:@(self.selectedIndex) forKey:@"index"];
    [TTDebugRealMonitorManager cacheDevLogWithEventName:@"tab_switch" params:params];
    NSMutableDictionary *tabDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [tabDict setValue:@(self.lastSelectedIndex) forKey:@"lastIndex"];
    [tabDict setValue:@(self.selectedIndex) forKey:@"currentIndex"];
    [tabDict setValue:[self rootViewControllerForTabViewController:self.viewControllers[self.lastSelectedIndex]] forKey:@"lastViewController"];
    [tabDict setValue:[self rootViewControllerForTabViewController:self.viewControllers[self.selectedIndex]] forKey:@"currentViewController"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreTabBarClickNotification object:self userInfo:tabDict];
    [super tabBarController:tabBarController didSelectViewController:vc];
    
    //只能放到最后
    if(![self.lastSelectedTabTag isEqualToString:[self currentTabIdentifier]]) {
        self.lastSelectedTabTag = [self currentTabIdentifier];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:[self currentTabIdentifier] forKey:@"kLastSelectTab"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)enterShortVideoTab
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHTSTabbarClickedNotification object:nil];
}

- (void)keepTapShortVideoTab
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTSVTabbarContinuousClickNotification object:self userInfo:nil];
}

#pragma mark notification related

- (void)adShowFinish:(NSNotification *)notification {
    UINavigationController * nav = [self.viewControllers objectAtIndex:self.selectedIndex];
    if ([nav isKindOfClass:[UINavigationController class]]
        && nav.viewControllers.count == 1) {
        [self showTipViewIfNeeded];
    }
}

- (void)changeBadgeNumber:(NSNotification*)notification
{
    if([[notification userInfo] objectForKey:kExploreTabBarItemIndentifierKey])
    {
        NSString *tag = [[notification userInfo] objectForKey:kExploreTabBarItemIndentifierKey];
        int number = [[[notification userInfo] objectForKey:kExploreTabBarBadgeNumberKey] intValue];
        BOOL displayRedPoint = [[[notification userInfo] objectForKeyedSubscript:kExploreTabBarDisplayRedPointKey] boolValue];
        
        NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:tag];
        TTBadgeNumberView *badgeView  = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
        
        BOOL isTrackForShow = YES;
        //展示红点且ui上没有变化时，不发show事件
        if (badgeView.badgeNumber == TTBadgeNumberPoint && displayRedPoint) {
            //之前是红点，现在还是要展示红点
            isTrackForShow = NO;
        }
        if ([badgeView.badgeValue isEqualToString:TTBadgeValueStringFromInteger(number)]) {
            //之前是多少，现在还是多少
            isTrackForShow = NO;
        }
        if (index == 0) {
            // 首页不显示红点 数字
            [badgeView setBadgeNumber:TTBadgeNumberHidden];
        } else {
            if(displayRedPoint)
            {
                [badgeView setBadgeNumber:TTBadgeNumberPoint];
            }
            else
            {
                [badgeView setBadgeNumber:number];
            }
        }
        
        if (isTrackForShow) {
            if ([tag isEqualToString:kTTTabHomeTabKey]) {
                [self trackBadgeWithLabel:@"show" tabBarTag:kTTTabHomeTabKey];
            }
            else if([tag isEqualToString:kTTTabFollowTabKey]) {
                [self trackBadgeWithLabel:@"show" tabBarTag:kTTTabFollowTabKey];
            }
            
            if (displayRedPoint || number > 0) {
                [self trackTabBarTipShowEventWithTag:tag];
            }
        }
    }
}

- (void)receiveBadgeMangerChangedNotification:(NSNotification *)notification
{
    [self refreshBadge];
}

- (void)receivedTopBarPublishButtonTapNotification:(NSNotification *)notification
{
    if(self.tabbarTipView && (self.tabbarTipView.type == TTBubbleViewTypePostUGCTip || self.tabbarTipView.type == TTBubbleViewTypeTimerPostUGCTip)) {
        WeakSelf;
        [self.tabbarTipView hideTipWithAnimation:YES forceHide:YES completionHandle:^{
            StrongSelf;
            self.tabbarTipView = nil;
        }];
    }
}

- (void)refreshBadge
{
    [self refreshForumTabBadgeView];
    [self refreshMyTabBadgeView];
}

- (void)refreshForumTabBadgeView
{
    if (![TTTabBarProvider isFollowTabOnTabBar]) {
        return;
    }
    NSInteger followNumber = [[ArticleBadgeManager shareManger].followNumber integerValue];
    
    NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabFollowTabKey];
    TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
    
    if(followNumber > 0){
        [badgeView setBadgeNumber:followNumber];
    }
    else if(followNumber == - 1000){
        
        [badgeView setBadgeNumber:TTBadgeNumberPoint];
    }
    else{
        [badgeView setBadgeNumber:TTBadgeNumberHidden];
    }
}

- (void)refreshMyTabBadgeView
{
    if (![TTTabBarProvider isMineTabOnTabBar]) {
        return;
    }
    __block NSInteger number = 0;

    __block BOOL shouldDisplayRedBadge = NO;
    __block BOOL isTrackForMineTabShow = NO;
    TTSettingGeneralEntry * messageEntry = [[TTSettingMineTabManager sharedInstance_tt] getEntryForType:TTSettingMineTabEntyTypeMessage];
    NSArray<TTSettingMineTabGroup *> *sections = [TTSettingMineTabManager sharedInstance_tt].visibleSections;
    [sections enumerateObjectsUsingBlock:^(TTSettingMineTabGroup*  _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop1) {
        [group.items enumerateObjectsUsingBlock:^(TTSettingGeneralEntry * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop2) {
            //如果entry是message entry，并且message hint count需要显示到关注频道，则过滤
            if (entry != messageEntry || ![[TTCategoryBadgeNumberManager sharedManager] isFollowCategoryNeedShowMessageBadgeNumber]) {
                if(entry.hintStyle == TTSettingHintStyleNumber)
                {
                    number += entry.hintCount;
                }
                if(entry.hintStyle == TTSettingHintStyleRedPoint || entry.hintStyle == TTSettingHintStyleNewFlag)
                {
                    shouldDisplayRedBadge = YES;
                    if (entry.isTrackForMineTabShow) {
                        isTrackForMineTabShow = YES;
                        entry.isTrackForMineTabShow = NO;
                    }
                }
            }
        }];
    }];

    if ([[AKProfileBenefitManager shareInstance] needShowBadge]) {
        shouldDisplayRedBadge = YES;
    }
    
    if (number > 0) {
        shouldDisplayRedBadge = YES;
    }
    
    TTTabBarItem *mineTabItem = nil;
    for (TTTabBarItem * item in [TTTabBarManager sharedTTTabBarManager].tabItems) {
        if ([item.identifier isEqualToString:kTTTabMineTabKey]) {
            mineTabItem = item;
        }
    }
//    NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:kTTTabMineTabKey];
//    TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
    TTBadgeNumberView *badgeView = [mineTabItem ttBadgeView];
    
    if(number > 0) // 有数字显示数字
    {
        [badgeView setBadgeNumber:number];

    }
    else if(shouldDisplayRedBadge)
    {
        [badgeView setBadgeNumber:TTBadgeNumberPoint];
    }
    else
    {
        [badgeView setBadgeNumber:TTBadgeNumberHidden];
    }
    if (isTrackForMineTabShow) {
        [self trackBadgeWithLabel:@"show" tabBarTag:kTTTabMineTabKey];
    }
}

- (void)displayCategoryManagerView:(NSNotification*)notification
{
    WeakSelf;
    [_tabbarTipView hideTipWithAnimation:YES forceHide:YES completionHandle:^{
        //Todo
        StrongSelf;
        if(self.tabbarTipView.type == TTBubbleViewTypeVideoTip){
            wrapperTrackEvent(@"video", @"video_tip_leave");
        }
    }];
 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.categoryManagerView reloadData];
    });
    
    [self.categoryManagerView showInView:self.view];
}

- (void)closeCategoryManagerView:(NSNotification*)notification
{
    [self.categoryManagerView closeIfNeeded];
}

- (ArticleCategoryManagerView *)categoryManagerView
{
    if (!_categoryManagerView) {
        CGFloat y = 0;//[SSCommonLogic useNewCategoryManageViewStyle] ? 20 : 0;
        _categoryManagerView = [[ArticleCategoryManagerView alloc] initWithFrame:CGRectMake(0, y, [TTUIResponderHelper screenSize].width, [TTUIResponderHelper screenSize].height - y)];
        [_categoryManagerView reloadData];
        WeakSelf;
        [_categoryManagerView didShow:^{
            StrongSelf;
            [self sendLogForTabStayWithIndex:0 delayResetStayTime:YES];
            //点击频道选择列表的时候隐藏气泡
            [[TTMessageNotificationTipsManager sharedManager] forceRemoveTipsView];
        } didDisAppear:^{
            StrongSelf;
            UIViewController * trackVC = self.viewControllers.firstObject;
            if ([trackVC isKindOfClass:[UINavigationController class]]) {
                trackVC = [(UINavigationController*)trackVC viewControllers].firstObject;
            }
            trackVC.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
            [self showMessageNotificationTips:nil];
        }];
    }
    return _categoryManagerView;
}

#pragma mark - AddFriendsView

//- (void)presentAddFriendsView:(NSNotification *)notification {
//    WeakSelf;
//    [_tabbarTipView hideTipWithAnimation:YES forceHide:YES completionHandle:^{
//        //Todo
//        StrongSelf;
//        if(self.tabbarTipView.type == TTBubbleViewTypeVideoTip){
//            wrapperTrackEvent(@"video", @"video_tip_leave");
//        }
//    }];
//
//    NSArray *users = notification.userInfo[@"users"];
//    if (users && users.count > 0 && notification.userInfo[@"from_add_friend_view_controller"] && ![notification.userInfo[@"from_add_friend_view_controller"] boolValue]) {
//        [self.addFriendsViewController showInView:self.view withUsers:users];
//    }
//}
//
//- (void)dismissAddFriendsView:(NSNotification *)notification {
//    [self.addFriendsViewController closeIfNeeded];
//}

//- (TTContactsAddFriendsViewController *)addFriendsViewController {
//    if (!_addFriendsViewController) {
//        _addFriendsViewController = [[TTContactsAddFriendsViewController alloc] init];
//    }
//
//    return _addFriendsViewController;
//}

#pragma mark -- TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    TTNavigationController *naviVC = self.viewControllers[self.lastSelectedIndex];
    //退出应用时viewDidDisappear和trackEndedByAppWillEnterBackground回调方法都会执行到，用一个标记为标示一下防止重复发送stay_tab事件
    if (naviVC.viewControllers.count == 1 && !self.isInvisble && !self.isBackground) {
        [self sendLogForTabStayWithIndex:self.lastSelectedIndex delayResetStayTime:YES];
    }
    self.isBackground = YES;
}

- (void)trackStartedByAppWillEnterForground {
    self.isBackground = NO;
}

#pragma mark -- Statistics Helper
//因为时序问题，一些场景需要延迟重置对应VC的停留时长

#pragma mark stay_tab埋点
- (void)sendLogForTabStayWithIndex:(NSUInteger)index delayResetStayTime:(BOOL)delayReset {
    NSMutableDictionary * valueDict = [NSMutableDictionary dictionary];
    UIViewController * trackVC = [self viewControllers][self.lastSelectedIndex];
    if ([trackVC isKindOfClass:[UINavigationController class]]) {
        trackVC = [(UINavigationController*)trackVC viewControllers].firstObject;
    }
    
    NSTimeInterval stayTime = 0;
    if (!delayReset) {
        stayTime = trackVC.ttTrackStayTime;
        [trackVC tt_resetStayTime];
    } else {
        stayTime = [[NSDate date] timeIntervalSince1970] - trackVC.ttTrackStartTime;
        dispatch_async(dispatch_get_main_queue(), ^{
            [trackVC tt_resetStayTime];
        });
    }
    
    [valueDict setValue:@(((long long)(stayTime * 1000))) forKey:@"value"];
    
//    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//        [TTTrackerWrapper category:@"umeng" event:@"stay_tab" label:[[self class] tabStayStringForIndex:index] dict:valueDict];
//    }
    
    //log3.0 doubleSending
    NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:2];
    [logv3Dic setValue:@(((long long)(stayTime * 1000))) forKey:@"stay_time"];
    NSString *selectedTabName = [[self class] tabStayStringForIndex:index];
    [logv3Dic setValue:selectedTabName forKey:@"tab_name"];
    [logv3Dic setValue:self.isClickTab ? @"click_tab":@"default" forKey:@"enter_type"];

    if (index < self.viewControllers.count) {

        TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
        NSString *with_tips = badgeView.badgeNumber != 0 ? @"1" : @"0";
        [logv3Dic setValue:with_tips forKey:@"with_tips"];

    }
//    [[EnvContext shared].tracer writeEvent:TraceEventName.stay_tab params:logv3Dic];
    self.isClickTab = YES;

//    if ([selectedTabName isEqualToString:@"f_hotsoon_video"]) {//小视频tab 该埋点必须发
//        [TTTrackerWrapper eventV3:@"stay_tab" params:logv3Dic];
//    } else {
//        [TTTrackerWrapper eventV3:@"stay_tab" params:logv3Dic isDoubleSending:YES];
//    }

    
}

+ (NSString *)tabStayStringForIndex:(NSUInteger)index {
    NSArray<TTTabBarItem *> *array = [TTTabBarManager sharedTTTabBarManager].tabItems;
    if (index >= array.count) {
        return nil;
    }
    NSString *tag = [array objectAtIndex:index].identifier;
    
    return [[self tagToLogEventName] objectForKey:tag];
}

+ (NSDictionary *)tagToLogEventName {
    return @{
//             kTTTabHomeTabKey:@"stream",
             kTTTabHomeTabKey:@"main",
             kFHouseFindTabKey:@"find",
             kFHouseMineTabKey:@"mine",
             kFHouseMessageTabKey:@"message",

             kTTTabVideoTabKey:@"video",
             kTTTabFollowTabKey:@"follow",
             kTTTabHTSTabKey:kTTUGCVideoCategoryID,
             kTTTabWeitoutiaoTabKey:@"weitoutiao",
             kTTTabMineTabKey:@"mine",
             kAKTabActivityTabKey:@"tab_task"
             };
}

- (void)showTabbarTip{
    [self showTipViewIfNeeded];
}

- (void)didChangeCategory
{
    if(_tabbarTipView.type == TTBubbleViewTypeVideoTip)
    {
        [_tabbarTipView hideTipWithAnimation:YES forceHide:YES completionHandle:^{
            [TTTrackerWrapper event:@"video" label:@"video_tip_leave"];
        }];
    }
}

#pragma mark - 转屏后清除高度缓存

- (void)applicationStatusBarDidRotate
{
    //如果在视频横全屏时，feed刷新完毕，则会导致clearCache，此时重新计算的高度缓存是横屏模式下的。这种情况下，转回竖屏时应清高度缓存。
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kClearCacheHeightNotification object:nil];
    }
}

#pragma mark - UGC发布器

- (void)showPostUGCEntrance:(id)sender {
    if (self.tabBar.hidden || nil == self.view.window) {
        return;
    }
    if ([[TTBubbleViewManager class] isViewTypeTimer:self.tabbarTipView.type]) {//底tab定时出气泡时，点任意tab或发布器按钮需要隐藏起泡
        [_tabbarTipView hideTipWithAnimation:YES forceHide:YES completionHandle:^{
            if ([TTBubbleViewManager shareManager].viewType == TTBubbleViewTypeTimerPostUGCTip) {
                [[TTBubbleViewManager shareManager] sendTrackForTipsEnterClick];
            }
        }];
    }
        
    [TTTrackerWrapper eventV3:@"click_publisher" params:@{@"entrance":@"main"}];
    
//    if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCBan]) {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
//                                  indicatorText:[GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCBanTips]
//                                 indicatorImage:nil
//                                    autoDismiss:YES
//                                 dismissHandler:nil];
//    }else {
//        [TTPostUGCEntrance showMainPostUGCEntrance];
//    }
}

//static BOOL bTrackMainPublisherLog = YES;
//- (void)postUGCPermissionUpdate:(NSNotification *)notification {
//    if ([TTTabBarProvider isPublishButtonOnTabBar]) {
//        if (bTrackMainPublisherLog) {
//            [TTTrackerWrapper eventV3:@"navbar_show_publisher" params:nil];
//            bTrackMainPublisherLog = NO;
//        }
//        [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) setIsNeedShowPostUGCTipsView];
//        SSThemedButton * postUGCEntranceButton = [self generatePublishButton];
//        ((TTTabbar *)self.tabBar).middleCustomItemView = postUGCEntranceButton;
//        UINavigationController * nav = [self.viewControllers objectAtIndex:self.selectedIndex];
//        if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) isNeedShowPostUGCTipsView]
//            && [nav isKindOfClass:[UINavigationController class]]
//            && nav.viewControllers.count == 1
//            && NO == [TTAdSplashMediator shareInstance].isAdShowing) {
//            [self showTipViewIfNeeded];
//        }
//
//    }
//    if([TTTabBarProvider isPublishButtonOnTopBar]) {
//        [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) setIsNeedShowPostUGCTipsView];
//        [self showPublishTipsIfNeeded];
//    }
//}

#pragma mark - 点击埋点

- (void)trackBadgeWithTabBarTag: (NSString *)tag enter_type: (NSString *)enter_type{
    
    NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:tag];
    
    if (index >= self.viewControllers.count) {
        return;
    }
    TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
    NSString *tab_name = @"be_null";
    NSString *with_tips = badgeView.badgeNumber != 0 ? @"1" : @"0";
    
    tab_name = [[self class] tabStayStringForIndex:index] ? : @"be_null";
    
    NSMutableDictionary *params = @{@"with_tips": with_tips, @"enter_type": enter_type, @"tab_name": tab_name}.mutableCopy;
//    FHEnvContext recordEvent:<#(nonnull NSDictionary *)#> andEventKey:<#(nonnull NSString *)#>
//    [[EnvContext shared].tracer writeEvent:TraceEventName.enter_tab params:params];
    
}

#pragma mark - 红点统计

- (void)trackBadgeWithLabel:(NSString *)label tabBarTag:(NSString *)tag
{
    NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:tag];
    
    if (index >= self.viewControllers.count) {
        return;
    }
    
    TTBadgeNumberView *badgeView = [((TTTabbar *)self.tabBar).tabItems[index] ttBadgeView];
    NSString *position = nil;
    NSString *style = nil;
    if ([tag isEqualToString:kTTTabHomeTabKey]) {
        position = @"home_tab";
    }
    else if ([tag isEqualToString:kTTTabWeitoutiaoTabKey]) {
        position = @"weitoutiao_tab";
    }
    else if ([tag isEqualToString:kTTTabMineTabKey]){
        position = @"mine_tab";
    }
    if (badgeView.badgeValue) {
        if (badgeView.badgeNumber == TTBadgeNumberPoint) {
            style = @"red_tips";
        }
        else if (!isEmptyString(badgeView.badgeValue)) {
            style = @"num_tips";
        }
    }
    [[TTBadgeTrackerHelper class] trackTipsWithLabel:label position:position style:style];
}

#pragma mark -
- (void)changeTabbarIndex:(NSNotification *)notification {
    NSString *tag = [notification.userInfo tt_stringValueForKey:@"tag"];
    
    [self updateSelectedViewControllerForTag:tag];
}

- (void)updateSelectedViewControllerForTag:(NSString *)tag {
    if (![[TTTabBarManager sharedTTTabBarManager].tabTags containsObject:tag]) {
        return;
    }
    
    [self setSelectedIndexWithTag:tag];
}

- (void)setSelectedIndexWithTag:(NSString *)tag {
    if (isEmptyString(tag)) return;
    
    self.autoEnterTab = YES;
    NSUInteger index = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:tag];
    
    [((TTTabbar *)self.tabBar) setSelectedIndex:index];
}

#pragma mark -- TTInterfaceTabBarControllerProtocol

- (CGFloat)tabbarVisibleHeight
{
    return self.tabBar.height;
}

- (NSString *)lastTabIdentifier {
    NSArray *tags = [TTTabBarManager sharedTTTabBarManager].tabTags;
    if(self.lastSelectedIndex >= tags.count) {
        return @"unknow";
    }
    return [tags objectAtIndex:self.lastSelectedIndex];
}

- (NSString *)currentTabIdentifier {
    NSArray *tags = [TTTabBarManager sharedTTTabBarManager].tabTags;
    if(self.selectedIndex >= tags.count) {
        return @"unknow";
    }
    return [tags objectAtIndex:self.selectedIndex];
}

- (UIViewController<TTInterfaceBackViewControllerProtocol> *)currentSelectedViewController
{
    UIViewController *VC = self.selectedViewController;
    if ([VC isKindOfClass:[UINavigationController class]]){
        VC = ((UINavigationController *)VC).topViewController;
    }
    return VC;
}

- (UIView *)mineIconView{
    if ([TTTabBarProvider isMineTabOnTabBar]){
        TTTabbar *tmpTabbar = (TTTabbar*)self.tabBar;
        return tmpTabbar.tabItems.lastObject;
    }
    UIViewController *VC = self.selectedViewController;
    if ([VC isKindOfClass:[UINavigationController class]]){
        VC = ((UINavigationController *)VC).topViewController;
    }
    if ([VC respondsToSelector:@selector(mineIconView)]){
        return [VC performSelector:@selector(mineIconView)];
    }
    return nil;
}

#pragma mark -

- (UIViewController *)rootViewControllerForTabViewController:(UIViewController *)viewContoller
{
    if ([viewContoller isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)viewContoller).viewControllers firstObject];
    }
    
    return viewContoller;
}
//- (UIButton *)mineButton{
//    if ([SSCommonLogic isForthTabHTSEnabled]){
//        return nil;
//    }
//    return [self.tabbar.items objectAtIndex:3];
//}

#pragma mark -

- (void)openShortVideoTabWhenStartupIfNeeded
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[TSVStartupTabManager sharedManager] shouldEnterShortVideoTabWhenStartup] && [TTShortVideoHelper canOpenShortVideoTab]) {
            if ([[UIApplication sharedApplication].delegate isKindOfClass:[NewsBaseDelegate class]]) {
                NewsBaseDelegate *delegate = (NewsBaseDelegate *)[UIApplication sharedApplication].delegate;
                
                if (!delegate.isUserLaunchTheAppDirectly) {
                    return;
                }
                
                UIViewController *curVC = self.viewControllers[self.selectedIndex];
                if ([curVC isKindOfClass:[UINavigationController class]] && ((UINavigationController *)curVC).viewControllers.count > 1) {
                    return;
                }
                                                                  
                self.autoEnterShortVideoTab = YES;
                [TTShortVideoHelper openShortVideoTab];
            }
            
        }
    });
}

#pragma mark -
- (void)trackTabBarTipShowEventWithTag:(NSString *)tag
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *tabName = [[[self class] tagToLogEventName] tt_stringValueForKey:tag];
    [params setValue:tabName forKey:@"tab_name"];
    
    [TTTrackerWrapper eventV3:@"tab_tips_show" params:params];
}

- (void)trackTabBubbleTipShowEventWithIndex:(NSInteger)index
{
    NSString *tabString = [[self class] tabStayStringForIndex:index];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:tabString forKey:@"tab_name"];
    
    [TTTrackerWrapper eventV3:@"tab_guide_show" params:params];
}

- (NSUInteger)lastSelectedIndex {
    NSInteger lastIndex = [[TTTabBarManager sharedTTTabBarManager].tabTags indexOfObject:self.lastSelectedTabTag];
    
    if (lastIndex == NSNotFound) {
        lastIndex = 0;
    }
    
    if(lastIndex < 0 || lastIndex >= [TTTabBarManager sharedTTTabBarManager].tabItems.count) {
        return 0;
    }
    
    return (NSUInteger)lastIndex;
}

@end
