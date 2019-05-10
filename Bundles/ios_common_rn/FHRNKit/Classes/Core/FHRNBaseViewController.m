//
//  FHRNBaseViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/25.
//

#import "FHRNBaseViewController.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import "TTRNKitHelper.h"
#import "TTRNKit.h"
#import "TTRNKitMacro.h"
#import <FHEnvContext.h>
#import <FHIESGeckoManager.h>
#import <TTInstallIDManager.h>
#import "FHRNDebugViewController.h"
#import "FHRNKitMacro.h"
#import <TTRNKitViewWrapper.h>
#import <TTRNKitViewWrapper+Private.h>
#import <UIViewAdditions.h>
#import <TTUIResponderHelper.h>
#import <UIViewController+Refresh_ErrorHandler.h>
#import "RCTRootView.h"
#import <RCTDevLoadingView.h>
#import <UIView+BridgeModule.h>
#import <TTRNBridgeEngine.h>
#import "FHRNHelper.h"
#import "RCTDevLoadingView.h"
#import <HMDTTMonitor.h>
#import <TTReachability.h>
#import <FHEnvContext.h>

@interface FHRNBaseViewController ()<TTRNKitProtocol,FHRNDebugViewControllerProtocol>

@property (nonatomic, assign) BOOL hideBar;
@property (nonatomic, assign) BOOL hideStatusBar;
@property (nonatomic, strong) TTRNKitViewWrapper *viewWrapper;
@property (nonatomic, assign) BOOL originHideStatusBar;
@property (nonatomic, assign) BOOL originHideNavigationBar;
@property (nonatomic, strong) NSString *shemeUrlStr;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) NSString *channelStr;
@property (nonatomic, strong) NSString *moduleNameStr;
@property (nonatomic, strong) NSString *bundleNameStr;
@property (nonatomic, assign) BOOL isDebug;
@property (nonatomic, assign) BOOL canPreLoad;
@property (nonatomic, assign) BOOL statusBarHighLight;
@property (nonatomic, strong) TTRouteParamObj *paramCurrentObj;
@property (nonatomic, strong) TTRNKit *ttRNKit;
@property (nonatomic, strong) UIView *container;

@end

@implementation FHRNBaseViewController
@synthesize manager = _manager;

- (TTRNKit *)extracted {
    NSString *stringVersion = [FHEnvContext getToutiaoVersionCode];
    
    NSDictionary *rnInitKitParams = @{TTRNKitUserId:@"user",                                  //gecko的userID，无实用意义
                                  TTRNKitScheme:@"sslocal://",                           //js与oc交互时使用的scheme
                                  TTRNKitAppName:@"f100",
                                  TTRNKitInnerAppName:@"Inner_Example",
                                  //       TTRNKitCommonBundlePath:commonBundlePath,
                                  //       TTRNKitCommonBundleMetaPath:commonBundleMetaPath,
                                  //TTRNKitGeckoDomain:@"gecko-sg.byteoversea.com"        //如果是海外资源，或者有自定义域名，请添加此行参数，
                                  };
    
    NSMutableDictionary *rnKitParams = [NSMutableDictionary dictionaryWithDictionary:rnInitKitParams];
    
    [rnKitParams setValue:stringVersion forKey:TTRNKitGeckoAppVersion];
    [rnKitParams setValue:_channelStr forKey:TTRNKitGeckoChannel];//一个ttrnkit实例只对应一个channel
    [rnKitParams setValue:[FHIESGeckoManager getGeckoKey] forKey:TTRNKitGeckoKey];
    [rnKitParams setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:TTRNKitDeviceId];
    
    NSMutableDictionary *defaultBundlePath = [NSMutableDictionary new];
    if (_channelStr) {
        [defaultBundlePath setValue:_bundleNameStr forKey:_channelStr];
    }
    [rnKitParams setValue:defaultBundlePath forKey:TTRNKitDefaultBundlePath];
    
    [rnKitParams setValue:_bundleNameStr forKey:TTRNKitBundleName];
    
    NSDictionary *rnAinimateParams = @{TTRNKitLoadingViewClass : @"loading",
                                       TTRNKitLoadingViewSize : [NSValue valueWithCGSize:CGSizeMake(100, 100)]
                                       };
    [RCTDevLoadingView setEnabled:NO];
    return [[TTRNKit alloc] initWithGeckoParams:rnKitParams
                                animationParams:rnAinimateParams];
}

- (instancetype)initWithParams:(NSDictionary *)params viewWrapper:(TTRNKitViewWrapper *)viewWrapper {
    if (self = [super init]) {
        if ([params isKindOfClass:[NSDictionary class]]) {
            [self processParams:params];
        }
        _viewWrapper = viewWrapper;
        
        if (_canPreLoad) {
            [self processPreloadAction];
        }
    }
    return self;
}

- (void)initRNKit
{
    self.ttRNKit = [self extracted];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
        
        if ([paramObj.sourceURL respondsToSelector:@selector(absoluteString)]) {
            _shemeUrlStr = [paramObj.sourceURL absoluteString];
        }
        _paramCurrentObj = paramObj;
        _isLoadFinish = NO;
        
        if ([paramObj.allParams isKindOfClass:[NSDictionary class]]) {
            [self processParams:paramObj.allParams];
        }
        
        if (!_isDebug) {
            [self initRNKit];
        }
        
        [[FHRNHelper sharedInstance] addObjectCountforChannel:_channelStr];
        
        if (_canPreLoad) {
            [self processPreloadAction];
        }
    }
    return self;
}

#pragma mark - network changed
-(void)connectionChanged:(NSNotification *)notification
{
    NSInteger netStatusV = 0;
    if (![FHEnvContext isNetworkConnected]) {
        netStatusV = 1;
    }else
    {
        netStatusV = 0;
    }
    
    [self sendEventName:@"net_status" andParams:@{@"available":[NSString stringWithFormat:@"%ld",netStatusV]}];
}

- (void)processParams:(NSDictionary *)params
{
    _titleStr = [params tt_stringValueForKey:@"title"];
    _channelStr = [params tt_stringValueForKey:@"channelName"];
    _originHideStatusBar = [UIApplication sharedApplication].statusBarHidden;
    _originHideNavigationBar = self.navigationController.navigationBarHidden;
    _hideBar = [params tt_intValueForKey:FHRN_BUNDLE_NATIVE_BAR] == 1;
    _hideStatusBar = [params tt_intValueForKey:FHRN_HIDE_STATUS_BAR] == 1;
    self.title = [params tt_stringValueForKey:RNTitle];
    _isDebug = [params tt_boolValueForKey:FHRN_DEBUG];
    _moduleNameStr = [params tt_stringValueForKey:FHRN_BUNDLE_MODULE_NAME];
    _canPreLoad = [params tt_boolValueForKey:FHRN_CAN_PRE_LOAD];
    _bundleNameStr = [params tt_stringValueForKey:FHRN_BUNDLE_NAME];
    _statusBarHighLight = [params tt_intValueForKey:FHRN_BUNDLE_STATUS_BAR_LIGHTR] == 1;
}

- (void)processPreloadAction
{
    if (!_isDebug) {
        // Do any additional setup after loading the view.
        NSString *url = [NSString stringWithFormat:@"%@",_shemeUrlStr];
        
        self.ttRNKit.delegate = self;
        [self.ttRNKit handleUrl:url];
    }else
    {
        [self loadJSbundleAndShowWithIp:nil port:nil moduleName:nil];
        [((RCTRootView *)_viewWrapper.rnView).bridge moduleForClass:[RCTDevLoadingView class]];
    }
}

- (void)updateLoadFinish
{
    self.isLoadFinish = YES;
    if (!_canPreLoad) {
        [self sendEventName:@"host_resume" andParams:nil];
    }
}

- (void)setupUI
{
    [self setupDefaultNavBar:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setupUI];
    
    self.customNavBarView.title.text = _titleStr;

    _container = [[UIView alloc] init];
    [self.view addSubview:_container];
    
    if (_hideBar) {
        self.customNavBarView.hidden = YES;
        [_container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }else
    {
        [_container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            if (@available(iOS 11.0 , *)) {
                make.top.mas_equalTo(44.f + self.view.tt_safeAreaInsets.top);
            } else {
                make.top.mas_equalTo(65);
            }
        }];
    }
    
    [self.view layoutIfNeeded];
    
    if (!_canPreLoad) {
        [self processPreloadAction];
    }
    
    [self tt_startUpdate];
    
    [self registerObserver];
    
    _container.hidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [[HMDTTMonitor defaultManager] hmdTrackService:@"rn_monitor_error" status:0 extra:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [[UIApplication sharedApplication] setStatusBarHidden:_hideStatusBar];
    
    if (_statusBarHighLight) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _container.hidden = NO;
        if (_viewWrapper && _canPreLoad && _isLoadFinish) {
            [self tt_endUpdataData];
        }
    });
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_viewWrapper) {
        [self addViewWrapper:_viewWrapper];
    }
    
    [self sendEventName:@"host_resume" andParams:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self sendEventName:@"host_pause" andParams:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.originHideStatusBar];
}

- (void)sendEventName:(NSString *)stringName andParams:(NSDictionary *)params
{
    if (((RCTRootView *)_viewWrapper.rnView).bridge.tt_engine) {
        TTRNBridgeEngine *bridgeEngine = ((RCTRootView *)_viewWrapper.rnView).bridge.tt_engine;
        if (![bridgeEngine.events containsObject:stringName]) {
            if (stringName) {
                [bridgeEngine.events addObject:stringName];
                [bridgeEngine addListener:stringName];
            }
        }
        [bridgeEngine sendEventWithName:stringName body:params];
    }
}

- (void)destroyRNView
{

    [[FHRNHelper sharedInstance] removeCountChannel:_channelStr];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[FHRNHelper sharedInstance] isNeedCleanCacheForChannel:_channelStr]) {
            ((RCTRootView *)_viewWrapper.rnView).delegate = nil;
            [self.ttRNKit clearRNResourceForChannel:_channelStr];
            [((RCTRootView *)_viewWrapper.rnView).bridge invalidate];
        }
        [_container removeFromSuperview];
        self.container = nil;
        [(RCTRootView *)_viewWrapper.rnView removeFromSuperview];
        _viewWrapper.rnView = nil;
        [_viewWrapper removeFromSuperview];
         self.viewWrapper = nil;
    });
}

- (BOOL)prefersStatusBarHidden {
    return _hideStatusBar;
}

- (void)onClose {
    [TTRNKitHelper closeViewController:self];
}

- (void)willMoveToParentViewController:(UIViewController*)parent{
    [super willMoveToParentViewController:parent];
    if(!parent){
    }else
    {
        if (![FHEnvContext isNetworkConnected]) {
            [self sendEventName:@"net_status" andParams:@{@"available":[NSString stringWithFormat:@"%ld",0]}];
        }else
        {
            [self sendEventName:@"net_status" andParams:@{@"available":[NSString stringWithFormat:@"%ld",1]}];
        }
    }
}
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        if(!_canPreLoad)
        {
            [self destroyRNView];
        }else
        {
            [self sendEventName:@"host_destroy" andParams:nil];
        }
    }
}

- (void)goBack
{
    UIViewController *popVC = [self.navigationController popViewControllerAnimated:YES];
    
    if (nil == popVC) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}


// 注册全局通知监听器
- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self sendEventName:@"host_pause" andParams:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self sendEventName:@"host_resume" andParams:nil];
}

#pragma mark

#pragma mark - DebugProtocol
- (void)addViewWrapper:(TTRNKitViewWrapper *)viewWrapper
{
    if (![_container.subviews containsObject:viewWrapper]) {
        [_container addSubview:viewWrapper];
        [viewWrapper setFrame:self.container.bounds];
    }
}

# pragma mark - TTRNKitProtocol
- (UIViewController *)presentor {
    return self;
}

- (BOOL)openUrl:(NSString *)url
{
    return NO;
}

- (void)handleWithWrapper:(TTRNKitViewWrapper *)wrapper
              specialHost:(NSString *)specialHost
                      url:(NSString *)url
            reactCallback:(RCTResponseSenderBlock)reactCallback
              webCallback:(TTRNKitWebViewCallback)webCallBack
            sourceWrapper:(TTRNKitViewWrapper *)sourceWrapper
                  context:(TTRNKit *)context {
    if (wrapper) {
        if (_container && [self.view.subviews containsObject:_container]) {
            [self addViewWrapper:wrapper];
        }
        _viewWrapper = wrapper;
    } else if (specialHost) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:specialHost message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)closeparams:(NSDictionary *)params
      reactCallback:(RCTResponseSenderBlock)reactCallback
        webCallback:(TTRNKitWebViewCallback)webCallback
      sourceWrapper:(TTRNKitViewWrapper *)wrapper {
    
}

- (void)loadJSbundleAndShowWithIp:(NSString *)host
                             port:(NSString *)port
                       moduleName:(NSString *)moduleName {
    NSString *hostFormat = @"http://%@/index.bundle?platform=ios&realtorId=213124234";
    NSURL *jsCodeLocation;
    if (host.length && port.length) {
        jsCodeLocation = [NSURL URLWithString:
                          [NSString stringWithFormat:hostFormat,
                           [NSString stringWithFormat:@"%@:%@", host, port]]];
    } else {
        jsCodeLocation = [NSURL URLWithString:[NSString stringWithFormat:hostFormat, @"127.0.0.1:8081"]];
    }
    NSMutableDictionary *initParams = [NSMutableDictionary dictionaryWithDictionary:_paramCurrentObj.allParams];
    initParams[RNModuleName] = moduleName ?: _moduleNameStr;
    [initParams setValue:self forKey:@"sourcevc"];
    
    TTRNKitViewWrapper *wrapper = [[TTRNKitViewWrapper alloc] init];
    [self.manager registerObserver:wrapper];
    _viewWrapper = wrapper;
    [self createRNView:initParams bundleURL:jsCodeLocation inWrapper:wrapper];
}

- (void)createRNView:(NSDictionary *)initParams bundleURL:(NSURL *)jsCodeLocation inWrapper:(TTRNKitViewWrapper *)wrapper {
    [wrapper reloadDataForDebugWith:initParams
                          bundleURL:jsCodeLocation
                         moduleName:initParams[RNModuleName] ?: @""];
}

/**
 接入方处理channel上发生fallback的行为；
 */
- (void)fallBackForChannel:(NSString *)channel jsContextIsValid:(BOOL)valid
{
    if (!valid) {
        [[HMDTTMonitor defaultManager] hmdTrackService:@"rn_monitor_error" status:1 extra:nil];
    }
}

- (void)callPhone:(void (^)(NSDictionary * _Nonnull))excute
{
//    if (excute) {
//        excute()
//    }
}

#pragma mark TTBridgeEngine

- (UIViewController *)sourceController {
    return self;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
