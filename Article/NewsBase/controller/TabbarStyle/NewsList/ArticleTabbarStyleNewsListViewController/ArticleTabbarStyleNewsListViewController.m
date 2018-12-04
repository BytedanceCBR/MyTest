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

@interface ArticleTabBarStyleNewsListViewController ()<TTInteractExitProtocol>

@end

@implementation ArticleTabBarStyleNewsListViewController

- (id)init
{
    self = [super init];
    if (self) {
        if ([SSCommonLogic shouldUseOptimisedLaunch]) {
            self.hidesBottomBarWhenPushed = NO;
            self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
            self.ttStatusBarStyle = UIStatusBarStyleLightContent;
            self.ttNavBarStyle = @"White";
            self.ttHideNavigationBar = YES;
            self.ttTrackStayEnable = YES;
        }
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
        if (mediator.adWillShow && [SSCommonLogic shouldUseOptimisedLaunch]) {
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

    if (![TTAdSplashMediator shareInstance].adWillShow && [SSCommonLogic shouldUseOptimisedLaunch]) {
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
