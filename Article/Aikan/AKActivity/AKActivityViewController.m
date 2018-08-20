//
//  AKActivityViewController.m
//  Article
//
//  Created by 冯靖君 on 2018/3/2.
//  活动tab页

#import "AKActivityViewController.h"
#import "AKWebContainerViewController.h"
#import "AKActivityTabManager.h"
#import "AKTaskSettingHelper.h"
#import "AKNetworkManager.h"
#import <UIViewController+Track.h>
#import <UIViewController+NavigationBarStyle.h>
#import <TTRoute.h>
#import <TTAccount.h>

@interface AKActivityViewController () <TTAccountMulticastProtocol, TTUIViewControllerTrackProtocol>

@property (nonatomic, strong) AKWebContainerViewController *webContainerVC;

@end

@implementation AKActivityViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)dealloc
{
    LOGD(@"dealloc called");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self preloadPage];
    [self addObservers];
}

- (void)addObservers
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 监听登录状态变化
    [TTAccount addMulticastDelegate:self];
}

#pragma mark - public

- (void)preloadPage
{
    [self _configUI];
    
    [self _registerActivityBridgeHandlers];
}

- (void)reloadPage
{
    // 刷新页面同时更新tab信息
    [[AKActivityTabManager sharedManager] startUpdateActivityTabState];
    [self.webContainerVC weakReloadWebContainer];
}

#pragma mark - private

- (void)_registerActivityBridgeHandlers
{
    // 打开宝箱
    [self.webContainerVC registerServiceJSBHandler:^(NSDictionary *params, TTRJSBResponse callback) {
        [[AKActivityTabManager sharedManager] startUpdateActivityTabState];
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"openTreasureBox"];
}

- (void)_configUI
{
    self.hidesBottomBarWhenPushed = NO;
    self.statusBarStyle = SSViewControllerStatsBarDayWhiteNightBlackStyle;
    self.ttStatusBarStyle = UIStatusBarStyleDefault;
    self.ttNavBarStyle = @"White";
    self.ttHideNavigationBar = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.webContainerVC = [[AKWebContainerViewController alloc] initWithURL:[CommonURLSetting akActivityMainPageURL] params:({
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@(YES) forKey:@"hide_bar"];
        [params setValue:@(YES) forKey:@"bounce_disable"];
        BOOL useWK = [TTDeviceHelper OSVersionNumber] >= 9.f;
        [params setValue:@(useWK) forKey:@"use_wk"];
        [params setValue:@([AKTaskSettingHelper shareInstance].appIsReviewing) forKey:@"review_flag"];
//        [params setValue:@(YES) forKey:@"report"];
        [params copy];
    })];
    self.webContainerVC.adjustBottomBarInset = YES;
    
    [self.view addSubview:self.webContainerVC.view];
    [self addChildViewController:self.webContainerVC];
    self.webContainerVC.view.frame = CGRectMake(0, 0, self.view.width, self.view.height - 44.f - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom);
}

#pragma mark - account state changed

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName 
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadPage];
    });
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground
{
    [self trySendCurrentPageStayTime];
}

- (void)trackStartedByAppWillEnterForground
{
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)onAppDidBecomeActive
{
    [self reloadPage];
}

- (void)trySendCurrentPageStayTime
{
    if (self.ttTrackStartTime == 0) {
        return;
    }
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    
    [self _sendCurrentPageStayTime:duration];
    
    self.ttTrackStartTime = 0;
    [self tt_resetStayTime];
}

- (void)_sendCurrentPageStayTime:(NSTimeInterval)duration
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(((long long)(duration))) forKey:@"stay_time"];
    [params setValue:@"tab_task" forKey:@"tab_name"];
//    [TTTrackerWrapper eventV3:@"stay_tab" params:params];
}

@end
