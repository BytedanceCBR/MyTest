//
//  SSWebViewController.m
//  Article
//
//  Created by Zhang Leonardo on 13-8-21.
//
//


#import "SSWebViewController.h"
#import "SSActivityView.h"
#import "TTTrackerWrapper.h"
#import "SSCommonLogic.h"
#import "TTActivityShareManager.h"
//#import "TTRealnameAuthServiceForWebManager.h"

#import <TTUIWidget/TTNavigationController.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <TTRoute/TTRoute.h>
#import <TTBaseLib/JSONAdditions.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/NSStringAdditions.h>
#import <TTBaseLib/NSString+URLEncoding.h>
#import <TTUIWidget/TTViewWrapper.h>
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <BDWebImage/SDWebImageAdapter.h>
#import <TTServiceKit/TTServiceCenter.h>
#import <TTTracker/TTTrackerProxy.h>
#import "TTAdManagerProtocol.h"
#import <AKWDPlugin/WDParseHelper.h>

NSString *const  SSViewControllerBaseConditionADIDKey = @"SSViewControllerBaseConditionADIDKey";

@interface SSWebViewController ()<YSWebViewDelegate>
{
    NSDate *_startDate;
    BOOL _statusBarHidden;
    
    NSString *_gd_label;
    NSString *_extJson;
    
    // 控制导航栏隐藏（保留返回和关闭按钮），1为隐藏，非1或者不传则显示；（5.2版本起支持）
    BOOL _shouldHideNavigationBar;
    // 控制状态栏隐藏（保留返回和关闭按钮），1为隐藏（WAP页面以屏幕顶部作为顶部），非1或者不传则显示；（页面从屏幕顶部往下20pt开始作为顶部
    // style_canvas = 1 时是沉浸式样式 隐藏 NavigationBar StatusBar
    BOOL _shouldhideStatusBar;
    BOOL _webViewBounceEnable;
    BOOL _shouldHideBackButton;             //是否隐藏左上角返回键
    
    // 下面这个名字起得不好
    BOOL _shouldHideBackButtonView;         //是否用 backButton 替代 SSWebViewBackButtonView
}
@property(nonatomic, strong)SSWebViewControllerView * ssWebView;
@property(nonatomic, strong)NSURL * requestURL;
@property(nonatomic, assign)SSWebViewDismissType dismissType;
@property(nonatomic, assign)SSWebViewBackButtonImageType backButtonImageType;
@property(nonatomic, assign)SSWebViewBackButtonPositionType backButtonPositionType;
@property(nonatomic, assign)SSWebViewBackButtonColorType backButtonColorType;
@property(nonatomic, strong)TTAlphaThemedButton *backButton;
@property(nonatomic, assign)BOOL hideMore;
@property(nonatomic, assign)BOOL showShareBtn;
@property(nonatomic, copy)NSDictionary *wapHeaders;
@property(nonatomic, assign, readwrite) BOOL supportLandscapeOnly;
@property(nonatomic, assign)BOOL shouldDisableHistory;
@property(nonatomic, assign)BOOL wapViewStartFromTop;
@property(nonatomic, assign)BOOL isStatusBarWhite;
@property(nonatomic, assign, readwrite)BOOL iphoneSupportRotate;
@property(nonatomic, strong) NSDictionary *baseCondition;
@property(nonatomic, strong) UIView *customeNavigationBar;
@property(nonatomic, assign) NSInteger colorKey;
@property(nonatomic, assign) NSInteger closeStackCount;
@property(nonatomic, assign) BOOL nightModeDisable;

@property (nonatomic, assign) BOOL shouldDisableHash;
@property (nonatomic, strong)   NSDictionary       *fhJSParams;

@end

@implementation SSWebViewController

+ (void)load {
    RegisterRouteObjWithEntryName(@"novel");
}

//这是我见过写的最乱的代码.
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.requestURL = nil;
    self.ssWebView = nil;
    if (self.adID.longLongValue > 0) {
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        [adManagerInstance preloadWebRes_stopCaptureAdWebResRequest];
        [self tt_sendDomCompleteEventTrack];
    }
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params addEntriesFromDictionary:paramObj.allParams];
    params[@"use_wk"] = @"1";  // 添加默认支持使用WKWebView
    if (![params valueForKey:@"bounce_disable"]) {
        params[@"bounce_disable"] = @"1"; // 添加支持bounce_disable设置
    }
    NSString * urlStr = nil;
    if ([params.allKeys containsObject:@"url"]) {
        urlStr = [params objectForKey:@"url"];
        if ([params.allKeys containsObject:@"ttencoding"]) {
            if ([[params objectForKey:@"ttencoding"] isEqualToString:@"base64"]) {
                urlStr = [TTStringHelper decodeStringFromBase64Str:urlStr];
            }
        }
    }
    
    BOOL supportIphoneRotate = [params tt_boolValueForKey:@"supportRotate"];
    
    self = [self initWithSupportIPhoneRotate:supportIphoneRotate paramObj:paramObj];
    if (self) {
        self.navigationItem.title = isEmptyString([params tt_stringValueForKey:@"title"])? @"网页浏览": [params tt_stringValueForKey:@"title"];
        self.titleImageName = [params tt_stringValueForKey:@"titleImageName"]; //显示为logo
        self.requestURL = [TTStringHelper URLWithURLString:urlStr];
        if ([params valueForKey:SSViewControllerBaseConditionADIDKey]) {
            self.adID = [params valueForKey:SSViewControllerBaseConditionADIDKey];
        } else if ([params valueForKey:@"ad_id"]) {
            self.adID = [params valueForKey:@"ad_id"];
        }
        
        self.logExtra = [params valueForKey:@"log_extra"];
        self.webViewTrackKey = [params valueForKey:@"webview_track_key"];
        
        // 问答用字段，原因是没法继承，沉库以后记得转移一下
        self.gdExtJsonDict = [WDParseHelper gdExtJsonFromBaseCondition:params];
        
        //wap_enter事件
        _gd_label = [params stringValueForKey:@"gd_label" defaultValue:nil];
        
        if (!isEmptyString(_gd_label)) {
            NSMutableDictionary * extraDic = [NSMutableDictionary dictionaryWithCapacity:3];
            [extraDic setValue:self.logExtra forKey:@"log_extra"];
            [extraDic setValue:self.adID forKey:@"ext_value"];
            if ([_gd_label isEqualToString:@"enter_click_novel_card"] && [TTTrackerWrapper isOnlyV3SendingEnable]) {
            } else {
                [TTTrackerWrapper category:@"wap_stat" event:@"wap_enter" label:_gd_label dict:extraDic json:_extJson];
            }
        }
        
//        self.hideMore = [params tt_boolValueForKey:@"hide_more"];
        self.hideMore = [params tt_boolValueForKey:@"hide_more"];
        self.showShareBtn = [params tt_boolValueForKey:@"share_enable"];
        
        _shouldHideNavigationBar = NO;
        if ([params valueForKey:@"hide_bar"]) {
            _shouldHideNavigationBar = [[NSString stringWithFormat:@"%@", params[@"hide_bar"]] isEqualToString:@"1"];
        }
        
        if ([params valueForKey:@"hide_nav_bar"]) {//hide_nav_bar 与 hide_bar 功能一致 王伟老师说要换个名字，但是老版本要兼容
            _shouldHideNavigationBar = [[NSString stringWithFormat:@"%@", params[@"hide_nav_bar"]] isEqualToString:@"1"];
        }
        
        _shouldHideBackButton = NO;
        if ([params valueForKey:@"hide_back_button"]) {
            _shouldHideBackButton = [[NSString stringWithFormat:@"%@", params[@"hide_back_button"]] isEqualToString:@"1"];
        }
        
        _webViewBounceEnable = YES;
        if ([params valueForKey:@"bounce_disable"]) {
            _webViewBounceEnable = ![[NSString stringWithFormat:@"%@", params[@"bounce_disable"]] isEqualToString:@"1"];
        }
        
        if ([params valueForKey:@"background_colorkey"]) {
            self.colorKey = [params tt_intValueForKey:@"background_colorkey"];
        }
        
        if ([params valueForKey:@"nightbackground_disable"]) {
            self.nightModeDisable = [params tt_boolValueForKey:@"nightbackground_disable"];
        }

        _shouldHideBackButtonView = NO;
        if (![TTDeviceHelper isPadDevice]) {
            if ([[params allKeys] containsObject:@"back_button_position"]) {
                _shouldHideBackButtonView = YES;
                NSString *position = [params stringValueForKey:@"back_button_position" defaultValue:nil];
                if ([position isEqualToString:@"top_right"]){
                    _backButtonPositionType = SSWebViewBackButtonPositionTypeTopRight;
                    self.hideMore = NO;
                }
                else if ([position isEqualToString:@"bottom_left"]){
                    _backButtonPositionType = SSWebViewBackButtonPositionTypeBottomLeft;
                }
                else if ([position isEqualToString:@"bottom_right"]){
                    _backButtonPositionType = SSWebViewBackButtonPositionTypeBottomRight;
                }
            }
            
            if ([[params allKeys] containsObject:@"back_button_icon"]) {
                _shouldHideBackButtonView = YES;
                NSString *image = [params stringValueForKey:@"back_button_icon" defaultValue:nil];
                if ([image isEqualToString:@"down_arrow"]){
                    _backButtonImageType = SSWebViewBackButtonImageTypeDownArrow;
                }
                else if ([image isEqualToString:@"close"]){
                    _backButtonImageType = SSWebViewBackButtonImageTypeClose;
                }
            }
            
            if ([[params allKeys] containsObject:@"back_button_color"]) {
                NSString *color = [params stringValueForKey:@"back_button_color" defaultValue:nil];
                if ([color isEqualToString:@"white"]) {
                    _backButtonColorType = SSWebViewBackButtonColorTypeLightContent;
                }
            }
            
            if (_backButtonImageType == SSWebViewBackButtonImageTypeLeftArrow && _backButtonPositionType == SSWebViewBackButtonPositionTypeTopLeft) {
                _shouldHideBackButtonView = NO;//如果是向左的箭头且位置在左上的话，不需要用backbutton替代backbuttonview
            }
            //sswebView中的backView
            if ([[params allKeys] containsObject:@"hide_back_buttonView"]) {
                _shouldHideBackButtonView = [params tt_boolValueForKey:@"hide_back_buttonView"];
            }
            
            if ([[params allKeys] containsObject:@"hide_back_button"]) {
                _shouldHideBackButtonView = [params tt_boolValueForKey:@"hide_back_button"];
            }
        }
        
        _shouldDisableHistory = [params tt_boolValueForKey:@"disableHistory"];
        _wapViewStartFromTop = [params tt_boolValueForKey:@"hide_status_bar"];  // 控制布局开始origin.Y
        _useSystemNavigationbarHeight = [params tt_boolValueForKey:@"use_system_navigationbarheight"];
        
        _isStatusBarWhite = NO;
        if ([[params allKeys] containsObject:@"status_bar_color"]) {
            _isStatusBarWhite = [[params stringValueForKey:@"status_bar_color" defaultValue:@"black"] isEqualToString:@"white"];
        }
        
        // 组合控制样式
        if ([params tt_boolValueForKey:@"style_canvas"]) {
            _shouldhideStatusBar = YES;
            _shouldHideNavigationBar = YES;
            _wapViewStartFromTop = YES;
            _shouldHideBackButton = YES;
            _shouldHideBackButtonView = YES;
        }

        // wap_headers
        if ([params.allKeys containsObject:@"wap_headers"]) {
            NSString *json = [params stringValueForKey:@"wap_headers" defaultValue:nil];
            if (!isEmptyString(json)) {
                NSDictionary *wapHeaders = nil;
                json = [json stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSDictionary *dict = [NSString tt_objectWithJSONString:json error:&error];
                
                if (!error && [dict isKindOfClass:[NSDictionary class]]) {
                    wapHeaders = dict;
                }
                else {
                    dict = nil;
                    json = [json stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                    error = nil;
                    dict = [NSString tt_objectWithJSONString:json error:&error];
                    if (!error && [dict isKindOfClass:[NSDictionary class]]) {
                        wapHeaders = dict;
                    }
                }
                
                if (wapHeaders) {
                    self.wapHeaders = wapHeaders;
                }
            }
        }
        //disable_hash
        if ([[params allKeys] containsObject:@"disable_hash"]) {
            self.shouldDisableHash = [[NSString stringWithFormat:@"%@", [params objectForKey:@"disable_hash"]] isEqualToString:@"1"];
        } else {
            self.shouldDisableHash = NO;
        }
        //透传给下一级
        self.baseCondition = params;
        if ([[params allKeys] containsObject:@"fhJSParams"]) {
            self.fhJSParams = [params objectForKey:@"fhJSParams"];
        }
    }
    return self;
}

- (void)setUpBackBtnControl:(NSNumber *)isControl
{
    if (isControl) {
        self.backButton.userInteractionEnabled = NO;
    }
}

- (void)setupAdInfo
{
    if (self.adID.longLongValue > 0) {
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        [adManagerInstance preloadWebRes_startCaptureAdWebResRequest];
    }
}

+ (void)openWebViewForNSURL:(NSURL *)requestURL title:(NSString *)title navigationController:(UINavigationController *)navigationController supportRotate:(BOOL)supportRotate conditions:(NSDictionary *)parameters {
    NSMutableDictionary *conditions = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [conditions setValue:@(supportRotate) forKey:@"supportRotate"];
    SSWebViewController *controller = [[SSWebViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(conditions)];
    if (title == nil) {
        // [controller setTitleText:NSLocalizedString(@"网页浏览", nil)];
    }
    else {
        [controller setTitleText:title];
    }
    
    // [controller showAddressBar:YES];
    [controller requestWithURL:requestURL];
    [navigationController pushViewController:controller animated:YES];
}

+ (void)openWebViewForNSURL:(NSURL *)requestURL title:(NSString *)title navigationController:(UINavigationController *)navigationController supportRotate:(BOOL)supportRotate
{
    return [self openWebViewForNSURL:requestURL title:title navigationController:navigationController supportRotate:supportRotate conditions:nil];
}

- (instancetype)init
{
    self = [self initWithSupportIPhoneRotate:NO];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (instancetype)initWithSupportIPhoneRotate:(BOOL)supportIPhone
{
    return [self initWithSupportIPhoneRotate:supportIPhone paramObj:nil];
}

- (instancetype)initWithSupportIPhoneRotate:(BOOL)supportIPhone paramObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        self.hidesBottomBarWhenPushed = YES;
        _iphoneSupportRotate = supportIPhone;
        _dismissType = SSWebViewDismissTypePop;
        _backButtonPositionType = SSWebViewBackButtonPositionTypeTopLeft;
        _backButtonImageType = SSWebViewBackButtonImageTypeLeftArrow;
        _backButtonColorType = SSWebViewBackButtonColorTypeDefault;
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        self.ttNavBarStyle = @"White";
    }
    return self;
}

- (void)showShareButtonAcition
{
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.ssWebView.navigationBar.rightBarView];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//
//    _statusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
//    if ([TTDeviceHelper OSVersionNumber] >= 7.f && _statusBarHidden) {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SSThemedView * baseView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    baseView.backgroundColorThemeKey = kColorBackground4;//@"BackgroundColor1";
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:baseView];
    
    self.ssWebView = [[SSWebViewControllerView alloc] initWithFrame:[self frameForWebView] baseCondition:self.baseCondition];
    self.ssWebView.rightButtonDisplayed = !self.hideMore;
    self.ssWebView.ssWebContainer.ssWebView.scrollView.bounces = _webViewBounceEnable;
    self.ssWebView.shouldDisableHistory = self.shouldDisableHistory;
    _ssWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _ssWebView.ssWebContainer.adID = self.adID;
    _ssWebView.ssWebContainer.logExtra = self.logExtra;
    _ssWebView.ssWebContainer.webViewTrackKey = self.webViewTrackKey;
    self.ssWebView.ssWebContainer.ssWebView.colorKey = self.colorKey;
    self.ssWebView.ssWebContainer.gdExtJsonDict = self.gdExtJsonDict;
    self.ssWebView.shouldDisableHash = self.shouldDisableHash;
    self.ssWebView.ssWebContainer.ssWebView.disableNightBackground = self.nightModeDisable;
    if (self.adID.longLongValue > 0) {
        _ssWebView.ssWebContainer.ssWebView.shouldInterceptUrls = [SSCommonLogic shouldInterceptAdJump];
    }
    
    TTAlphaThemedButton * backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 68, 44);
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.backButton = backButton;
    [self refreshStatusBarStyle];
    
    if ([TTDeviceHelper isPadDevice]) {
        TTViewWrapper *wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        [wrapperView addSubview:_ssWebView];
        wrapperView.targetView = _ssWebView;
        [self.view addSubview:wrapperView];
    }
    else {
        [self.view addSubview:_ssWebView];
    }
    
    //外部调用setDismissType的时候,_ssWebView还没有初始化.
    [self setDismissType:_dismissType];

    if (_requestURL) {
        if (self.wapHeaders) {
            [_ssWebView loadWithURL:_requestURL requestHeaders:self.wapHeaders];
        } else {
            [_ssWebView loadWithURL:_requestURL];
        }
    }
    
    [self registerObserver];
    
    if (self.backButtonColorType == SSWebViewBackButtonColorTypeLightContent) {
        [self.ssWebView.backButtonView setStyle:SSWebViewBackButtonStyleLightContent];
    }
    
    if (!_shouldHideNavigationBar) {
        if (!isEmptyString(self.titleImageName)) {
            SSThemedImageView *imageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
            imageView.imageName = self.titleImageName;
            [imageView sizeToFit];
            self.navigationItem.titleView = imageView;
        }
        if (_shouldHideBackButtonView && _backButtonPositionType == SSWebViewBackButtonPositionTypeTopLeft) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
        }
        else{
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.ssWebView.navigationBar.leftBarView];
        }
        
        if (_shouldHideBackButtonView && _backButtonPositionType == SSWebViewBackButtonPositionTypeTopRight) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
        }
        else{
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.ssWebView.navigationBar.rightBarView];
        }
    } else {
        
        self.ttHideNavigationBar = YES;
        
        [self registerJSBridgeForHideNavigationBar];
        
        if (!_shouldHideBackButtonView) {
            UIView *backButtonView = self.ssWebView.navigationBar.leftBarView;
            _customeNavigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(backButtonView.frame), 44)];
            [self.view addSubview:_customeNavigationBar];
            [_customeNavigationBar addSubview:backButtonView];
            // customeNavigationBar.backgroundColor = [UIColor yellowColor];
            backButtonView.left = 8;
        }
    }
    
    [self registerJSBridge];
    
    [self refreshBackButton];
    
    // F项目JS注册
    [self registerFHJSBridge];
    
    //注册基础服务
//    [TTRealnameAuthServiceForWebManager supportNativeServiceForWebView:self.ssWebView.ssWebContainer.ssWebView];
    [self setupAdInfo];
    
    [self.ssWebView setupFShareBtn:self.showShareBtn];
    
    [self showShareButtonAcition];
}

// 注册全局通知监听器
- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

// F项目JS注册，route参数中要传递：fhJSParams:{} url: title:
-(void)registerFHJSBridge
{
    __weak typeof(self) wSelf = self;
    [self.fhJSParams enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull methodName, NSDictionary*  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([methodName length] > 0) {
            NSMutableDictionary *callBackData = [NSMutableDictionary dictionaryWithDictionary:obj];
            [wSelf.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin  registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse callback) {
                [callBackData setObject:@(1) forKey:@"code"];
                if ([params isKindOfClass:[NSDictionary class]]) {
                    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull temObj, BOOL * _Nonnull stop) {
                        [callBackData setObject:temObj forKey:key];
                    }];
                }
                callback(TTRJSBMsgSuccess, callBackData);
            } forMethodName:methodName];
        }
    }];
}

// 注册JSBridge
- (void)registerJSBridge {
    __weak typeof(self) wSelf = self;
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        wSelf.shouldDisableHistory = [result tt_boolValueForKey:@"disableHistory"];
        wSelf.ssWebView.shouldDisableHistory = wSelf.shouldDisableHistory;
    } forMethodName:@"disableHistory"];
    
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSArray *data = [result arrayValueForKey:@"data" defaultValue:nil];
        if([data count] > 0){
            for (NSDictionary *dict in data) {
                if ([dict objectForKey:@"key"] && [dict objectForKey:@"visible"]) {
                    NSString *actionString = [dict stringValueForKey:@"key" defaultValue:nil];
                    BOOL actionVisible = [dict tt_boolValueForKey:@"visible"];
                    if ([actionString isEqualToString:@"refresh"]){
                        wSelf.ssWebView.shouldShowRefreshAction = actionVisible;
                    }
                    else if ([actionString isEqualToString:@"copyLink"]){
                        wSelf.ssWebView.shouldShowCopyAction = actionVisible;
                    }
                    else if ([actionString isEqualToString:@"openWithBrowser"]){
                        wSelf.ssWebView.shouldShowSafariAction = actionVisible;
                    }
                    else if ([actionString isEqualToString:@"share"]){
                        wSelf.ssWebView.shouldShowShareAction = actionVisible;
                    }
                }
            }
        }
        [TTTracker eventV3:@"deprecated_feature" params:@{@"name": @"sswebviewvc_setBrowserOpBtnVisible"}];
    } forMethodName:@"setBrowserOpBtnVisible"];
    
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        wSelf.ssWebView.shareTitle = [result stringValueForKey:@"title" defaultValue:nil];
        wSelf.ssWebView.shareDesc = [result stringValueForKey:@"desc" defaultValue:nil];
        NSString *imageUrl = [result stringValueForKey:@"image" defaultValue:nil];
        wSelf.ssWebView.shareImageUrl = imageUrl;
        if (!isEmptyString(imageUrl)){
            [[SDWebImageAdapter sharedAdapter] prefetchURLs:@[imageUrl]];
        }
    } forMethodName:@"shareInfo"];
    
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        wSelf.ssWebView.repostTitle = [result stringValueForKey:@"title" defaultValue:nil];
        wSelf.ssWebView.repostSchema = [result stringValueForKey:@"schema" defaultValue:nil];
        NSString *repostCoverUrl = [result stringValueForKey:@"cover_url" defaultValue:nil];
        wSelf.ssWebView.repostCoverUrl = repostCoverUrl;
        wSelf.ssWebView.repostType = [result integerValueForKey:@"repost_type" defaultValue:215];
        if (!isEmptyString(repostCoverUrl)){
            [[SDWebImageAdapter sharedAdapter] prefetchURLs:@[repostCoverUrl]];
        }
        wSelf.ssWebView.isRepostWeitoutiaoFromWeb = [result tt_boolValueForKey:@"is_repost_weitoutiao"];
        
    } forMethodName:@"repostInfo"];
}

// 注册JSBridge（_shouldHideNavigationBar为true时才执行）
- (void)registerJSBridgeForHideNavigationBar {
    __weak typeof(self) wSelf = self;
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        
        wSelf.iphoneSupportRotate = YES;
        
        BOOL isLandscape = [[result valueForKey:@"orientation"] boolValue];
        wSelf.supportLandscapeOnly = isLandscape;
        if (isLandscape) {
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait)
                                        forKey:@"orientation"];
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight)
                                        forKey:@"orientation"];
        } else {
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight)
                                        forKey:@"orientation"];
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait)
                                        forKey:@"orientation"];
        }
        [TTTracker eventV3:@"deprecated_feature" params:@{@"name": @"sswebviewvc_requestChangeOrientation"}];
    } forMethodName:@"requestChangeOrientation"];
    
    // 控制页面顶部状态条风格和返回按钮颜色
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *color = [result stringValueForKey:@"color" defaultValue:nil];
        if ([color isEqualToString:@"white"]) {
            [wSelf.ssWebView.backButtonView setStyle:SSWebViewBackButtonStyleLightContent];
            wSelf.backButtonColorType = SSWebViewBackButtonColorTypeLightContent;
        }
        else if ([color isEqualToString:@"black"]) {
            [wSelf.ssWebView.backButtonView setStyle:SSWebViewBackButtonStyleDefault];
            wSelf.backButtonColorType = SSWebViewBackButtonColorTypeDefault;
        }
        if (![TTDeviceHelper isPadDevice]) {
            [wSelf refreshBackButtonImage];
        }
    } forMethodName:@"backButton"];
    
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *color = [result stringValueForKey:@"color" defaultValue:@"black"];
        wSelf.isStatusBarWhite = [color isEqualToString:@"white"];
        [wSelf refreshStatusBarStyle];
    } forMethodName:@"statusBar"];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    UIEdgeInsets safeInset = self.view.tt_safeAreaInsets;
    _customeNavigationBar.top = safeInset.top;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.ssWebView.frame = [self frameForWebView];
}

- (CGRect)frameForWebView {
    
    CGFloat navHeight = _shouldHideNavigationBar ?
    (_wapViewStartFromTop? 0 : [UIApplication sharedApplication].statusBarFrame.size.height) : 44 + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    if(_useSystemNavigationbarHeight){
        navHeight = 44;
    }
    
    
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        if([TTDeviceHelper OSVersionNumber] < 9){
            padding = 0;
        }
        CGRect rect = self.view.frame;
        rect.origin.y = navHeight;
        rect.size.height -= navHeight;
        return CGRectInset(rect, padding, 0);
    }
    return CGRectMake(0, navHeight, self.view.bounds.size.width, self.view.bounds.size.height - navHeight);
}

- (void)setAdID:(NSString *)adID {
    if ([adID isKindOfClass:[NSString class]]) {
        _adID = [adID copy];
    }
    else if ([adID isKindOfClass:[NSNumber class]])
    {
        _adID = [NSString stringWithFormat:@"%@", adID];
    }
    if (self.isViewLoaded) {
        _ssWebView.ssWebContainer.adID = adID;
        if (_adID.longLongValue > 0) {
            _ssWebView.ssWebContainer.ssWebView.shouldInterceptUrls = [SSCommonLogic shouldInterceptAdJump];
        }
    }
}

- (void)setLogExtra:(NSString *)logExtra {
    _logExtra = logExtra;
    if (self.isViewLoaded) {
        _ssWebView.ssWebContainer.logExtra = logExtra;
    }
}

- (void)setWebViewTrackKey:(NSString *)webViewTrackKey {
    _webViewTrackKey = [webViewTrackKey copy];
    if (self.isViewLoaded) {
        _ssWebView.ssWebContainer.webViewTrackKey = webViewTrackKey;
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self _sendStayEventWithTimeInterval];
    [self.ssWebView.ssWebContainer.ssWebView ttr_fireEvent:@"hide" data:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    _startDate = [NSDate date];
    [self.ssWebView.ssWebContainer.ssWebView ttr_fireEvent:@"show" data:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _startDate = [NSDate date];
    if (_shouldhideStatusBar) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:self.ttStatusBarStyle == UIStatusBarStyleDefault ? [[TTThemeManager sharedInstance_tt] statusBarStyle] : self.ttStatusBarStyle animated:YES];
    }
    
    [self.ssWebView.ssWebContainer.ssWebView ttr_fireEvent:@"show" data:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self _sendStayEventWithTimeInterval];
    [self _sendTemailStayEvent]; //wait for hero del
    if (_shouldhideStatusBar) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    [self.ssWebView.ssWebContainer.ssWebView ttr_fireEvent:@"hide" data:nil];
}

- (void)setDismissType:(SSWebViewDismissType)type
{
    _dismissType = type;
}

- (void)refreshStatusBarStyle
{
    if (_isStatusBarWhite) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        self.ttStatusBarStyle = UIStatusBarStyleDefault;
    }
}

- (void)refreshBackButton
{
    if (_shouldHideBackButtonView && ![TTDeviceHelper isPadDevice]) {
        _ssWebView.backButtonView.hidden = YES;
        [self refreshBackButtonImage];
        [self refreshBackButtonPosition];
    }
    if (_shouldHideBackButton && ![TTDeviceHelper isPadDevice]) {
        self.backButton.hidden = YES;
    }
}

- (void)refreshBackButtonImage
{
    BOOL isDefaulfColorType = _backButtonColorType == SSWebViewBackButtonColorTypeDefault;
    switch (_backButtonImageType) {
        case SSWebViewBackButtonImageTypeLeftArrow:
            _backButton.imageName = isDefaulfColorType ? @"lefterbackicon_titlebar" : @"white_lefterbackicon_titlebar";
            break;
        case SSWebViewBackButtonImageTypeDownArrow:
            _backButton.imageName = isDefaulfColorType ? @"black_down_video_details" : @"down_video_details";
            break;
        case SSWebViewBackButtonImageTypeClose:
            _backButton.imageName = isDefaulfColorType ? @"titlebar_close" : @"titlebar_close_white";
            break;
        default:
            break;
    }
}

- (void)setupCloseCallBackPreviousVC:(NSDictionary *)params
{
    NSString *jsCodeStr = [NSString stringWithFormat:@"ToutiaoJSBridge.trigger('pageResult',%@);",[params tt_JSONRepresentation]];
    [self.ssWebView.ssWebContainer.ssWebView stringByEvaluatingJavaScriptFromString:jsCodeStr
                                                        completionHandler:nil];
}

- (void)setupOpenPageTagStr:(NSString *)tagStr
{
    self.tagStr = tagStr;
}

- (NSString *)getOpenPageTagStr
{
    return _tagStr;
}


- (void)refreshBackButtonPosition
{
    CGRect frame = self.view.frame;
    switch (_backButtonPositionType) {
        case SSWebViewBackButtonPositionTypeTopLeft:
            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 44)];
            if (_shouldHideNavigationBar) {
                _backButton.left = 12;
                _backButton.top = [UIApplication sharedApplication].statusBarFrame.size.height;
                [self.view addSubview:_backButton];
            }
            break;
        case SSWebViewBackButtonPositionTypeTopRight:
            [TTTracker eventV3:@"deprecated_feature" params:@{@"name": @"sswebviewvc_backbut_tr"}];
            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 44, 0, 0)];
            if (_shouldHideNavigationBar) {
                _backButton.right = frame.size.width - 12;
                _backButton.top = [UIApplication sharedApplication].statusBarFrame.size.height;
                [self.view addSubview:_backButton];
            }
            break;
        case SSWebViewBackButtonPositionTypeBottomLeft:
            [TTTracker eventV3:@"deprecated_feature" params:@{@"name": @"sswebviewvc_backbut_bl"}];
            _backButton.left = 12;
            _backButton.bottom = frame.size.height - 2;
            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 44)];
            [self.view addSubview:_backButton];
            break;
        case SSWebViewBackButtonPositionTypeBottomRight:
            [TTTracker eventV3:@"deprecated_feature" params:@{@"name": @"sswebviewvc_backbut_br"}];
            _backButton.right = frame.size.width - 12;
            _backButton.bottom = frame.size.height - 2;
            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 44, 0, 0)];
            [self.view addSubview:_backButton];
            break;
        default:
            break;
    }
}

- (void)backButtonClicked {

    if ([self.ssWebView.ssWebContainer.ssWebView canGoBack] && !self.shouldDisableHistory && _backButtonImageType == SSWebViewBackButtonImageTypeLeftArrow) {
        [self.ssWebView.ssWebContainer.ssWebView goBack];
    } else {
        if (self.navigationController) {
            if (self.navigationController.viewControllers.count == 1 && self.navigationController.presentingViewController) {
                [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
            } else {
                NSMutableArray *vcStack = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                
                if (self.closeStackCount == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
                
                if (vcStack.count > self.closeStackCount + 1) {
                    NSInteger retainVCs = vcStack.count - self.closeStackCount - 1;
                    if (retainVCs == 0) {
                        self.navigationController.viewControllers = [NSArray arrayWithObjects:vcStack.firstObject,vcStack.lastObject,nil];
                    }else
                    {
                        NSMutableArray *viewControllersArray = [NSMutableArray new];
                        [viewControllersArray addObject:vcStack.firstObject];
                        
                        for (int i = 0; i < retainVCs; i++) {
                            if (vcStack.count > i) {
                                [viewControllersArray addObject:vcStack[i + 1]];
                            }
                        }
                        
                        [viewControllersArray addObject:vcStack.lastObject];
                        
                        self.navigationController.viewControllers = viewControllersArray;
                    }
                }else
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    return;
                }

                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
        }
    }
}

- (void)setTitleText:(NSString *)title
{
    if (!isEmptyString(self.titleImageName)) {
        return;
    }
    
    self.navigationItem.title = title;
}

- (void)requestWithURL:(NSURL *)url
{
    self.requestURL = url;
    if (_requestURL) {
//        if (!_iphoneSupportRotate) {
//            _iphoneSupportRotate = [self URLSupportedAutorotate:_requestURL];
//        }
        NSString *trackKey = [self _webViewTrackKeyFromURL:url];
        self.webViewTrackKey = trackKey;
        NSString *logExtra = [self _webViewLogExtraFromURL:url];
        if (logExtra) {
            _logExtra = logExtra;
        }
        
        if (self.wapHeaders) {
            [_ssWebView loadWithURL:_requestURL requestHeaders:self.wapHeaders];
        } else {
            [_ssWebView loadWithURL:_requestURL];
        }

        _ssWebView.ssWebContainer.webViewTrackKey = trackKey;
        _ssWebView.ssWebContainer.logExtra = logExtra;
    }
}

- (NSString *)_webViewTrackKeyFromURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    NSDictionary *parameters = [TTStringHelper parametersOfURLString:URL.query];
    return parameters[@"webview_track_key"];
}

- (NSString *)_webViewLogExtraFromURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    NSDictionary *parameters = [TTStringHelper parametersOfURLString:URL.query];
    return parameters[@"log_extra"];
}

- (void)requestWithURLString:(NSString *)urlString
{
    if (!isEmptyString(urlString)) {
        self.requestURL = [TTStringHelper URLWithURLString:urlString];
        if (self.wapHeaders) {
            [_ssWebView loadWithURL:_requestURL requestHeaders:self.wapHeaders];
        } else {
            [_ssWebView loadWithURL:_requestURL];
        }
    }
}

- (BOOL) URLSupportedAutorotate:(NSURL *) URL {
    if (!URL) {
        return NO;
    }
    NSDictionary *parameters = [TTStringHelper parametersOfURLString:URL.query];
    if ([parameters valueForKey:@"supportRotate"]) {
        return [[parameters valueForKey:@"supportRotate"] boolValue];
    }
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([TTDeviceHelper isPadDevice]) {
        return YES;
    } else {
        if (!_iphoneSupportRotate) {
            return toInterfaceOrientation == UIInterfaceOrientationPortrait;
        }
        else {
            return UIInterfaceOrientationIsLandscape(toInterfaceOrientation) || toInterfaceOrientation == UIInterfaceOrientationPortrait;
        }
    }
}

-(BOOL)shouldAutorotate{
    if ([TTDeviceHelper isPadDevice]) {
        return YES;
    } else {
        return _iphoneSupportRotate;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([TTDeviceHelper isPadDevice]) {
        return UIInterfaceOrientationMaskAll;
    } else {
        if (_iphoneSupportRotate) {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
}

#pragma mark -PrivateMethod
- (void)_sendStayEventWithTimeInterval {
    if (!_startDate) {
        return;
    }
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_startDate];
    _startDate = nil;
    
    NSMutableDictionary * extraDic = [NSMutableDictionary dictionaryWithCapacity:3];
    [extraDic setValue:[NSString stringWithFormat:@"%.0f", timeInterval*1000] forKey:@"value"];
    [extraDic setValue:self.adID forKey:@"ext_value"];
    if (!isEmptyString(_gd_label)) {
        [extraDic setValue:self.logExtra forKey:@"log_extra"];

    }
    else {
        [extraDic setValue:@"" forKey:@"log_extra"];
    }
    [TTTrackerWrapper category:@"wap_stat" event:@"stay_page" label:_gd_label dict:extraDic json:_extJson];
}

- (void)_sendTemailStayEvent {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:_gd_label forKey:@"gd_label"];
}

- (void)tt_sendDomCompleteEventTrack
{
    if (![SSCommonLogic isWebDomCompleteEnable]) {
        return;
    }
    if ([TTDeviceHelper OSVersionNumber] < 9.0) {
        return;
    }
    if (self.adID.longLongValue > 0) {
        NSString* timeStr = nil;
        @try {
            timeStr = [self.ssWebView.ssWebContainer.ssWebView stringByEvaluatingJavaScriptFromString:@"performance.timing.domComplete - performance.timing.navigationStart" completionHandler:nil];
        } @catch (NSException *exception) {
            NSLog(@"performance.timing.domComplete--exception:%@",exception.description);
        } @finally {
            
        }
        if (isEmptyString(timeStr)) {
            timeStr = @"90000";
        }
        NSTimeInterval timeInterval = timeStr.longLongValue;
        if (timeStr.longLongValue < 0 || timeStr.longLongValue >90000) {
            timeInterval = 90000;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"dom_complete_time" forKey:@"tag"];
        [dict setValue:@"ad_wap_stat" forKey:@"label"];
        [dict setValue:self.adID forKey:@"value"];
        [dict setValue:self.logExtra forKey:@"log_extra"];
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
        [dict setValue:@(connectionType) forKey:@"nt"];
        NSMutableDictionary* extraDict = [NSMutableDictionary dictionary];
        [extraDict setValue:@(timeInterval) forKey:@"dom_complete_time"];
        [dict setValue:[extraDict JSONRepresentation] forKey:@"ad_extra_data"];
        [TTTrackerWrapper eventData:dict];
        
    }
}

- (void)setUpBackBtnControlForWeb:(NSNumber *)isWebControl
{
    if ([isWebControl respondsToSelector:@selector(boolValue)]) {
        self.ssWebView.isWebControl = [isWebControl boolValue];
    }
}

- (void)setupCloseStackVCCount:(NSNumber *)count
{
    if ([count respondsToSelector:@selector(integerValue)]) {
        self.closeStackCount = [count integerValue];
    }
}

- (void)setUpCloseBtnControlForWeb:(NSNumber *)isShow
{
    if ([isShow respondsToSelector:@selector(boolValue)]) {
        self.ssWebView.isShowCloseWebBtn = [isShow boolValue];
    }
}

@end
