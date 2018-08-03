 //
//  TTRNViewController.m
//  Article
//
//  Created by Chen Hong on 16/7/14.
//
//

#import "TTRNViewController.h"
#import "RCTRootView.h"
#import "TTRNBundleManager.h"
#import "TTNavigationController.h"
#import "TTRoute.h"
#import "SSWebViewController.h"
#import <TTUserSettingsManager+FontSettings.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTEventDispatcher.h>
#import "TTRNView.h"
#import "TTUIResponderHelper.h"
#import "TTRNBridge+Call.h"

@interface TTRNViewController () <TTRouteInitializeProtocol>

@property (nonatomic, copy) NSString *moduleName;
@property (nonatomic, copy) NSDictionary *initialProperties;
@property (nonatomic, copy) NSString *pageName;
@property (nonatomic, copy) void(^bundleInfoBlock)(TTRNBundleInfoBuilder *builder);
@property (nonatomic) TTRNView *rnView;
@property (nonatomic) SSWebViewController *fallbackWebViewController;
@property (nonatomic) BOOL showFallbackWebView;
@property (nonatomic) TTNavigationBarItemContainerView *backButton;
@property (nonatomic, strong) NSDate* rnStartTime;
@end

@implementation TTRNViewController

#pragma mark - Route

+ (void)load
{
    // @attention: 新业务需求请使用新版本的跳转host----`react`
    RegisterRouteObjWithEntryName(@"rctview"); // to be deprecated
    RegisterRouteObjWithEntryName(@"react");
}

- (void)dealloc
{
    
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        [self preHandleParamObj:paramObj];
    }
    return self;
}

- (void)preHandleParamObj:(TTRouteParamObj *)paramObj
{
    NSString *pageName = paramObj.host;
    NSDictionary *parameters = paramObj.allParams;
    if ([pageName isEqualToString:@"react"]) {
        NSString *moduleName = parameters[@"moduleName"];
        
        NSAssert(!isEmptyString(moduleName), @"module name is empty");
        
        NSString *bundleUrl = parameters[@"bundleUrl"];
        NSString *version = parameters[@"version"];
        NSString *fallbackUrl = parameters[@"fallbackUrl"];
        NSString *rnMinVersion = parameters[@"rnMinVersion"];
        NSString *patchUrl = parameters[@"patchUrl"];
        self.hideBackButton = [parameters[@"hide_back_buttonView"] boolValue];
        if ([parameters[@"back_button_color"] isEqualToString:@"white"]) {
            self.isWhiteBack = YES;
        }
        
        // 透传url中路由逻辑之外的query参数
        NSMutableDictionary *initialProperties = [parameters mutableCopy];
        [initialProperties removeObjectsForKeys:@[
                                                  @"moduleName",
                                                  @"bundleUrl",
                                                  @"version",
                                                  @"fallbackUrl",
                                                  @"rnMinVersion",
                                                  @"hide_back_buttonView",
                                                  @"back_button_color",
                                                  ]];
        
        [self setUpWithModuleName:moduleName
                       bundleInfo:^(TTRNBundleInfoBuilder * _Nonnull builder) {
                           builder.bundleUrl = bundleUrl;
                           builder.version = version;
                           builder.fallbackUrl = fallbackUrl;
                           builder.rnMinVersion = rnMinVersion;
                           builder.patchUrl = patchUrl;
                       }
                initialProperties:initialProperties];
    } else if ([pageName isEqualToString:@"rctview"]) {
        NSString *moduleName = parameters[@"component"];
        NSAssert(!isEmptyString(moduleName), @"module name is empty");
        
        [self setUpWithModuleName:moduleName
                       bundleInfo:nil
                initialProperties:nil];
    }
}

#pragma mark - Initialization

- (instancetype)initWithModuleName:(NSString *)moduleName
                        bundleInfo:(void(^)(TTRNBundleInfoBuilder *builder))block
                 initialProperties:(NSDictionary *)initialProperties
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self setUpWithModuleName:moduleName bundleInfo:block initialProperties:initialProperties];
    }
    return self;
}

- (void)setUpWithModuleName:(NSString *)moduleName
                 bundleInfo:(void(^)(TTRNBundleInfoBuilder *builder))block
          initialProperties:(NSDictionary *)initialProperties
{
    if (isEmptyString(moduleName)) {
        NSAssert(NO, @"module name is empty.");
        return;
    }
    
    self.moduleName = moduleName;
    self.bundleInfoBlock = block;
    self.initialProperties = initialProperties;
    self.pageName = initialProperties[@"tab"];
    NSURL *jsCodeLocation = [[TTRNBundleManager sharedManager] localBundleURLForModuleName:self.moduleName];
    
    if (jsCodeLocation) {
        NSMutableDictionary *props = [[self defaultInitialProperties] mutableCopy];
        [props setValuesForKeysWithDictionary:self.initialProperties];
        _rnView = [[TTRNView alloc] init];
        [_rnView loadModule:moduleName initialProperties:props];
        self.ttHideNavigationBar = YES;
    } else {
        NSString *fallbackUrl = nil;
        TTRNBundleInfoBuilder *builder = [TTRNBundleInfoBuilder new];
        if (self.bundleInfoBlock) {
            self.bundleInfoBlock(builder);
            fallbackUrl = builder.fallbackUrl;
        }
        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:fallbackUrl]];;
        self.fallbackWebViewController = [[SSWebViewController alloc] initWithRouteParamObj:paramObj];
        self.showFallbackWebView = YES;
        self.ttHideNavigationBar = YES;
    }
    
    TTRNBundleUpdateCompletionBlock completionBlock = NULL;
#if INHOUSE && DEBUG
    completionBlock = ^(NSURL *localBundleURL, BOOL update, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"加载失败" message:error.localizedDescription delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if (update) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"加载成功" message:@"bundle数据准备完毕，请退出页面重新进入" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert show];
        }
    };
    
#endif
    [[TTRNBundleManager sharedManager] updateBundleForModuleName:self.moduleName
                                                      bundleInfo:self.bundleInfoBlock
                                                    updatePolicy:TTRNBundleUpdateDefaultPolicy
                                                      completion:completionBlock];
}

- (NSDictionary *)defaultInitialProperties
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    NSString *daymode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? @"day" : @"night";
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    [props setValue:daymode forKey:@"daymode"];
    [props setValue:fontSizeType forKey:@"font"];
    return [props copy];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    // Do any additional setup after loading the view.
    if (self.showFallbackWebView) {
        [self.view addSubview:self.fallbackWebViewController.view];
        [self addChildViewController:self.fallbackWebViewController];
        [self.fallbackWebViewController didMoveToParentViewController:self];
    } else {
        CGFloat topOffset = self.view.tt_safeAreaInsets.top - 20.f;
        _rnView.frame = CGRectMake(0,topOffset, self.view.width, self.view.height - topOffset);
        [self.view addSubview:self.rnView];
        [self monitorRNLoad];
        if (!self.hideBackButton) {
            [self.view addSubview:self.backButton];
            [self updateBackButtonAppearance];
        }
        
        // 左滑返回时取消rctView的事件响应
        WeakSelf;
        self.panBeginAction = ^{
            StrongSelf;
            [self.rnView.rootView cancelTouches];
        };
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat topOffset = MAX(0,self.view.tt_safeAreaInsets.top - 20.f);
    _rnView.frame = CGRectMake(0,topOffset, self.view.width, self.view.height - topOffset);
    self.backButton.top = self.view.tt_safeAreaInsets.top;
}

- (TTNavigationBarItemContainerView *)backButton
{
    if (!_backButton) {
        _backButton = [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(backButtonClicked:)];
        _backButton.frame = CGRectMake(0.0, 20.0, 44.0, 44.0);
    }
    return _backButton;
}

- (void)backButtonClicked:(id)sender
{
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count == 1 && self.navigationController.presentingViewController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

- (void)setHideBackButton:(BOOL)hideBackButton
{
    if (_hideBackButton != hideBackButton) {
        _hideBackButton = hideBackButton;
        [self updateBackButtonAppearance];
    }
}

- (void)setIsWhiteBack:(BOOL)isWhiteBack
{
    if (_isWhiteBack != isWhiteBack) {
        _isWhiteBack = isWhiteBack;
        [self updateBackButtonAppearance];
    }
}

- (void)updateBackButtonAppearance
{
    self.backButton.hidden = self.hideBackButton;
    if (self.isWhiteBack) {
        [self.backButton.button setImage:[UIImage themedImageNamed:@"white_lefterbackicon_titlebar"] forState:UIControlStateNormal];
    } else {
        [self.backButton.button setImage:[UIImage themedImageNamed:@"lefterbackicon_titlebar"] forState:UIControlStateNormal];
    }
}

- (void)sendDeviceEventWithName:(NSString *)name body:(id)body
{
    [self.rnView.rootView.bridge.eventDispatcher sendDeviceEventWithName:name body:body];
}

- (void)monitorRNLoad
{
    self.rnStartTime = [NSDate date];
    NSMutableDictionary* extra = [NSMutableDictionary dictionary];
    [extra setValue:self.moduleName forKey:@"module_name"];
    [extra setValue:self.pageName forKey:@"page_name"];
    [extra setValue:@"native_init_start_bundle" forKey:@"page_status"];
    [[TTMonitor shareManager] trackService:@"native_init_start_bundle" status:1 extra:extra];
    WeakSelf;
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        StrongSelf;
        int time = (int)([[NSDate date] timeIntervalSinceDate:self.rnStartTime] * 1000);
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:result];
        [params setValue:@(time) forKey:@"duration"];
        NSString* seviceName = [result tt_stringValueForKey:@"page_status"];
        if (!isEmptyString(seviceName)) {
            [[TTMonitor shareManager] trackService:seviceName value:params extra:nil];
        }
    } forMethod:@"ReportPageStatus"];
    
}

@end
