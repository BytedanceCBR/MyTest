//
//  TTFollowWebViewController.m
//  Article
//
//  Created by 王双华 on 16/5/4.
//
//

#import "TTFollowWebViewController.h"
#import "SSThemed.h"
#import "UIButton+TTAdditions.h"
#import "ArticleBadgeManager.h"
#import "SSWebViewContainer.h"
//#import "FRConcernGuideViewController.h"
#import "ArticleURLSetting.h"
#import "UIViewController+Track.h"
#import "TTTabBarManager.h"
#import "SSCommonLogic.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "TTThemeManager.h"
#import "TTFollowWebViewModel.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTFollowNotifyServer.h"
#import "FRAPPDelegateHelper.h"
#import "ArticleMessageManager.h"
#import <Crashlytics/Crashlytics.h>
#import <SSNavigationBar.h>
#import <TTAlphaThemedButton.h>
#import <TTAccountBusiness.h>
#import <TTBaseLib/JSONAdditions.h>

static NSString * const kFollowTipCanShowKey = @"kFollowTipCanShowKey";
static NSString * const kPreloadEnableKey = @"kPreloadEnableKey";

@interface TTFollowWebViewController ()
<
YSWebViewDelegate,
UIViewControllerErrorHandler,
TTAccountMulticastProtocol
>

@property(nonatomic, strong)TTAlphaThemedButton * searchButton;
@property(nonatomic, strong)SSWebViewContainer * webViewContainer;
@property(nonatomic, strong)TTFollowWebViewModel * viewModel;
@property(nonatomic, copy)NSString * currentHTML;
@property(nonatomic, assign)BOOL isFirstPolling;
@property(nonatomic, assign)BOOL isFirstAppear;

@property(nonatomic, assign)NSTimeInterval startInterval;
@property(nonatomic, assign)BOOL isRecording;

@end

@implementation TTFollowWebViewController

#pragma mark - Public

+ (void)setCanShowFollowTip:(BOOL)canShow
{
    if ([self canShowFollowTip] == canShow) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:canShow forKey:kFollowTipCanShowKey];
    [defaults synchronize];
}

+ (BOOL)canShowFollowTip
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kFollowTipCanShowKey];
}

+ (void)setCanPreload:(BOOL)canPreload
{
    if ([self canPreload] == canPreload) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:canPreload forKey:kPreloadEnableKey];
    [defaults synchronize];
}

+ (BOOL)canPreload
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kPreloadEnableKey];
}

#pragma mark - Life circle

- (void)dealloc{
    _searchButton = nil;
    [_webViewContainer removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        if ([SSCommonLogic shouldUseOptimisedLaunch]) {
            [self commonSetup];
        }
    }
    return self;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    self.hidesBottomBarWhenPushed = NO;
    
    [[self class] setCanShowFollowTip:[SSCommonLogic isFollowTabTipsEnable]];
    [[self class] setCanPreload:[SSCommonLogic isPreloadFollowEnable]];
    
    [[TTFollowNotifyServer sharedServer] addObserver:self selector:@selector(followActionNotify:)];
    
    __weak typeof(self) wSelf = self;
    self.viewModel = [[TTFollowWebViewModel alloc] initWithRefreshBlock:^(NSString * _Nullable html, TTFollowNotify * _Nullable followNotify) {
        [wSelf refreshHand:html followNotify:followNotify];
    } willEnterForeground:^{
        [wSelf willEnterForeground];
    } didEnterBackground:^{
        [wSelf didEnterBackground];
    }];
    self.isFirstPolling = YES;
    self.isFirstAppear = YES;
    
    if ([[self class] canPreload]) {
        NSUInteger delayInSeconds = 5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [self firstRequest];
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttTrackStayEnable = YES;
    self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //title
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:!isEmptyString([[TTTabBarManager sharedTTTabBarManager] followHeaderText]) ? [[TTTabBarManager sharedTTTabBarManager] followHeaderText] : NSLocalizedString(@"我关注的", nil)];
    [(UILabel *)self.navigationItem.titleView setFont:[UIFont systemFontOfSize:17]];
    
    //search button
    self.searchButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    _searchButton.frame = CGRectMake(0, 0, 44, 44);
    _searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _searchButton.imageName = @"add_channel_titlbar_follow";
    if ([TTDeviceHelper is736Screen]) {
        _searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -12);
    }else {
        _searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -8);
    }
    [_searchButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_searchButton];
    
    //web view
    [self.view addSubview:self.webViewContainer];
    
    if (![[self class] canPreload]) {
        [self firstRequest];
    }
    
    [self addNotification];
    //UI
    [self reloadThemeUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[self class] canPreload] && self.isFirstAppear && isEmptyString(self.currentHTML)) {
        //预加载失败，重试
        [self firstRequest];
    }
    self.isFirstAppear = NO;
    
    [[ArticleBadgeManager shareManger] clearFollowNumber];
    
    if (self.isRecording == NO) {
        self.isRecording = YES;
        [self startRecordStayTime];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (![FRAPPDelegateHelper isConcernTabbar] && self.isRecording) {
        [self endRecordStayTime];
        self.isRecording = NO;
    }
}

- (SSWebViewContainer *)webViewContainer
{
    if (!_webViewContainer) {
        _webViewContainer = [[SSWebViewContainer alloc] initWithFrame:CGRectMake(0, 64, SSWidth(self.view), SSHeight(self.view) - 64 - 44)];
        _webViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webViewContainer.backgroundColorThemeName = kColorBackground3;
        [_webViewContainer hiddenProgressView:YES];
        [_webViewContainer.ssWebView addDelegate:self];
    }
    return _webViewContainer;
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return !isEmptyString(self.currentHTML);
}

- (void)refreshData {
    [self firstRequest];
}

- (void)emptyViewBtnAction {
    [self firstRequest];
}

- (void)sessionExpiredAction {
    [self firstRequest];
}

#pragma mark - Request

- (void)firstRequest {
    if (self.viewModel.isRequesting) {
        return;
    }
    [self tt_startUpdate];
    __weak typeof(self) wSelf = self;
    [self.viewModel refreshWithCompletion:^(NSError * _Nullable error, NSString * _Nullable html) { 
        if (!error) {
            [wSelf loadWebViewWithHTML:html];
        }
        [wSelf tt_endUpdataData:NO error:error];
    }];
}

- (void)refreshHand:(NSString *)html followNotify:(TTFollowNotify *)followNotify {
    if ([FRAPPDelegateHelper isConcernTabbar] && [followNotify.ID isEqualToString:kFollowRefreshID]) {
        //在关注tab，红点轮询接口返回且需要显示红点
        //忽略（不刷新，不出红点）
        return;
    }

    if (!([FRAPPDelegateHelper isConcernTabbar] && followNotify.actionType == TTFollowActionTypeUnfollow)) {
        //不在关注tab下/在关注tab下且是关注动作，则刷新页面
        if (!self.viewModel.isRequesting) {
            if (self.isViewLoaded) {
                [self loadWebViewWithHTML:html];
                [self tt_endUpdataData:NO error:nil];
            }
        }
    }
    
    if ([followNotify.ID isEqualToString:kFollowRefreshID]) {
        //轮询接口返回需要显示红点而触发的刷新，刷新成功后显示红点
        NSInteger followNumber = [followNotify.userInfo tt_integerValueForKey:kGetFollowNumberKey];
        [[ArticleBadgeManager shareManger] refreshWithFollowNumber:followNumber];
    }else {
        //强制请求红点轮询接口
        [[ArticleBadgeManager shareManger] refreshFollowNumber];
    }
}

- (void)loadWebViewWithHTML:(NSString *)html {
    if (!isEmptyString(html)) {
        self.currentHTML = html;
        [_webViewContainer.ssWebView loadHTMLString:html baseURL:self.viewModel.url];
    }
}

#pragma mark - Notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabbarKeepClick:) name:kMomentTabbarKeepClickedNotification object:nil];
    
    [TTAccount addMulticastDelegate:self];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    if (self.isViewLoaded) {
        [self firstRequest];
    }
}

- (void)tabbarKeepClick:(NSNotification *)notification {
    [[ArticleBadgeManager shareManger] clearFollowNumber];
}

- (void)willEnterForeground {
    if ([FRAPPDelegateHelper isConcernTabbar]) {
        self.isRecording = YES;
        [self startRecordStayTime];
    }
}

- (void)didEnterBackground {
    if ([FRAPPDelegateHelper isConcernTabbar] && self.isRecording) {
        [self endRecordStayTime];
        self.isRecording = NO;
    }
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    if (self.isViewLoaded) {
        self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    }
}

#pragma mark - YSWebViewDelegate

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    //调用Web view的loadHTMLString:baseURL:方法，如果baseURL带有锚点，除了第一次，之后的加载会失败并且delegate相关的方法并不会调用。
    //因此去掉了baseURL中日夜间的锚点，在加载成功后手动调用设置日夜间的js。
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    [_webViewContainer.ssWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.TouTiao && TouTiao.setDayMode(%d)", isDayModel]
                                                      completionHandler:nil];
}

#pragma mark - Selectors & Actions

- (void)followActionNotify:(TTFollowNotify *)notify
{
    if ([notify.ID isEqualToString:kFollowRefreshID]) {
        NSInteger followNumber = [notify.userInfo tt_integerValueForKey:kGetFollowNumberKey];
        if (self.isFirstPolling == YES) {
            //第一次轮询，忽略
            self.isFirstPolling = NO;
            [[ArticleBadgeManager shareManger] refreshWithFollowNumber:followNumber];
            return;
        }else if (followNumber == 0) {
            //没有更新，忽略
            return;
        }
    }
    if ([FRAPPDelegateHelper isConcernTabbar] && notify.actionType == TTFollowActionTypeUnfollow) {
        //在关注tab下且取消关注，调用js通知前端删除对应的项
        if (!isEmptyString(notify.ID)) {
            NSString * jsParametersString = [@{@"id":notify.ID} tt_JSONRepresentation];
            [_webViewContainer.ssWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"removeItem(%@)",jsParametersString]
                                                              completionHandler:nil];
        }
    }
    [self.viewModel refreshWithFollowNotify:notify];
}

- (void)buttonClicked:(id)sender
{
//    if (_searchButton == sender) {
//        TLS_LOG(@"buttonClicked ");
//
//        FRConcernGuideViewController * controller = [[FRConcernGuideViewController alloc] init];
//        [self.navigationController pushViewController:controller animated:YES];
//        
//    }
}

#pragma mark - Stay time

- (void)startRecordStayTime
{
    self.startInterval = [[NSDate date] timeIntervalSince1970];
}

- (void)endRecordStayTime
{
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - self.startInterval;
    self.startInterval = 0;
    [TTTrackerWrapper category:@"umeng" event:@"stay_tab_total" label:@"follow" dict:@{@"value":@((long long)(duration*1000))}];
}

@end
