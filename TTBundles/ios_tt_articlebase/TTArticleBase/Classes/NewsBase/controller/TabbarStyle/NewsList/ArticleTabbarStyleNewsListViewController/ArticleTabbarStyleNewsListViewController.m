//
//  ArticleTabBarStyleNewsListViewController.m
//  Article
//
//  Created by Dianwei on 14-9-2.
//
//

#import "ArticleTabbarStyleNewsListViewController.h"
#import "TTTrackInitTime.h"
#import "TTTabbar.h"
#import "TTTopBarManager.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTMonitor+AppLog.h"
#import "NewsBaseDelegate.h"
#import "SSCommonLogic.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIViewController+Track.h"
#import <Crashlytics/Crashlytics.h>
#import "TTInteractExitHelper.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import <TTInteractExitHelper.h>
#import "TTInterfaceTipHeader.h"
#import "TTTopBar.h"
#import "TTCustomAnimationDelegate.h"
#import "TTAdSplashMediator.h"
#import <Masonry/Masonry.h>
#import "Log.h"
#import <FHEnvContext.h>

@interface ArticleTabBarStyleNewsListViewController ()<TTInteractExitProtocol>

@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@property (nonatomic, strong) NSMutableDictionary *traceEnterTopTabache;

@end

@implementation ArticleTabBarStyleNewsListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
        self.isShowTopSearchPanel = YES;
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
        self.ttNavBarStyle = @"White";
        self.ttHideNavigationBar = YES;
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[TTCustomAnimationManager sharedManager] registerFromVCClass:[self class] toVCClass:NSClassFromString(@"AWEVideoDetailViewController") animationClass:[TSVShortVideoEnterDetailAnimation class]];
    
//    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.view.backgroundColor = [UIColor whiteColor];

    //必须设置，否则scrollView会异常
    self.automaticallyAdjustsScrollViewInsets = NO;
//延迟createMainVC会造成gif类型的开屏广告卡顿，这个优化先下线
    TTAdSplashMediator *mediator = [TTAdSplashMediator shareInstance];
    if (mediator.resouceType == TTAdSplashResouceType_Gif) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createMainVC];
        });
    }
    else{
        if (mediator.adWillShow) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self createMainVC];
            });
        }else{
            [self createMainVC];
            
        }
    }
    
}

-(void)createMainVC{
    [self addChildViewController:self.mainVC];
    [self.view addSubview:self.mainVC.view];
    
    [self.mainVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    NSString * systemVersionStr = [NSString stringWithFormat:@"%.0f",[[[UIDevice currentDevice] systemVersion] floatValue]];
    [[TTMonitor shareManager] trackAppLogWithTag:@"launch" label:systemVersionStr];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    TLS_LOG(@"didReceiveMemoryWarning");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SharedAppDelegate trackCurrentIntervalInMainThreadWithTag:@"MainList ViewAppear"];
    
    static BOOL firstAppear = YES;
    if (firstAppear) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:[NSObject currentUnixTime]] forKey:@"kTrackTime_mainList_viewAppear"];
        TTAdSplashMediator *mediator = [TTAdSplashMediator shareInstance];
        if (!mediator.adWillShow) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:[NSObject currentUnixTime]] forKey:@"kTrackTime_noad_mainList_viewAppear"];
        }else{
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithLongLong:0] forKey:@"kTrackTime_noad_mainList_viewAppear"];
        }
    }
    firstAppear = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    SharedAppDelegate.mainViewDidShow = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainList_ViewAppear" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![TTAdSplashMediator shareInstance].adWillShow) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    UIStatusBarStyle style = UIStatusBarStyleDefault;
    //TODO:Jason
//    if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
//        if (![TTTopBarManager sharedInstance_tt].isStatusBarLight) {
//            style = UIStatusBarStyleDefault;
//        } else {
//            style = UIStatusBarStyleLightContent;
//        }
//    }
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
    self.ttStatusBarStyle = style;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    if ([self isViewLoaded]) {
//        self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        self.view.backgroundColor = [UIColor whiteColor];

    }
}

- (void)viewAppearForEnterType:(FHHomeMainTraceEnterType)enterType
{
    self.stayTime = [self getCurrentTime];
    self.traceEnterTopTabache = [NSMutableDictionary new];
    
    if (enterType == FHHomeMainTraceEnterTypeClick) {
        [self.traceEnterTopTabache setValue:@"click" forKey:@"enter_type"];
    }else
    {
        [self.traceEnterTopTabache setValue:@"flip" forKey:@"enter_type"];
    }
    
    self.stayTime = [self getCurrentTime];
    
    [self.traceEnterTopTabache setValue:@"maintab" forKey:@"enter_from"];
    [self.traceEnterTopTabache setValue:@"discover_stream" forKey:@"category_name"];
    [FHEnvContext recordEvent:self.traceEnterTopTabache andEventKey:@"enter_category"];
    
    NSMutableDictionary *feedCategoryDict = [NSMutableDictionary new];
    if (self.traceEnterTopTabache) {
        [feedCategoryDict addEntriesFromDictionary:self.traceEnterTopTabache];
    }
    [feedCategoryDict setValue:self.mainVC.categorySelectorView.currentSelectedCategory.categoryID
                        forKey:@"category_name"];
    [FHEnvContext recordEvent:feedCategoryDict andEventKey:@"enter_category"];
}

- (void)viewDisAppearForEnterType:(FHHomeMainTraceEnterType)enterType
{
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    if (self.traceEnterTopTabache) {
        [tracerDict addEntriesFromDictionary:self.traceEnterTopTabache];
    }
    
    NSTimeInterval duration = ([self getCurrentTime] - self.stayTime) * 1000.0;
    if (duration) {
        [tracerDict setValue:@((int)duration) forKey:@"stay_time"];
    }
    [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_category"];
    
    
    NSMutableDictionary *feedCategoryDict = [NSMutableDictionary new];
    if (tracerDict) {
        [feedCategoryDict addEntriesFromDictionary:tracerDict];
    }
    [feedCategoryDict setValue:self.mainVC.categorySelectorView.currentSelectedCategory.categoryID
                        forKey:@"category_name"];
    [FHEnvContext recordEvent:feedCategoryDict andEventKey:@"stay_category"];
}

- (NSTimeInterval)getCurrentTime
{
    return  [[NSDate date] timeIntervalSince1970];
}

#pragma mark -
#pragma mark setters and getters

- (TTExploreMainViewController *)mainVC
{
    if (!_mainVC) {
        _mainVC = [[TTExploreMainViewController alloc] init];
        __weak typeof(self) wself = self;
        _mainVC.finishLoadingBlock = ^{
            [((TTTabbar *)wself.tabBarController.tabBar) setItemLoading:NO forIndex:0];
        };
        _mainVC.isShowTopSearchPanel = _isShowTopSearchPanel;
        __weak TTExploreMainViewController *weakMainVC = _mainVC;
        _mainVC.startLoadingBlock = ^{
            if (weakMainVC.isRefreshByClickTabBar) {
                
                // add by zjing 去掉tabbar的loading
//                [((TTTabbar *)wself.tabBarController.tabBar) setItemLoading:YES forIndex:0];
            }
        };
    }
    return _mainVC;
}

#pragma mark -  InteractExitProtocol

- (UIView *)suitableFinishBackView{
    if ([_mainVC conformsToProtocol:@protocol(TTInteractExitProtocol)] && [_mainVC respondsToSelector:NSSelectorFromString(@"suitableFinishBackView")]){
        return (( UIViewController <TTInteractExitProtocol> *)_mainVC).suitableFinishBackView;
    }
    return self.view;
}

@end
