//
//  AKWebContainerViewController.m
//  Article
//
//  Created by 冯靖君 on 2018/3/2.
//  webView容器VC

#import "AKWebContainerViewController.h"
#import <TTFullScreenLoadingView.h>
#import <TTNetworkUtilities.h>
#import <TTURLUtils.h>
#import <TTRouteSelectionServerConfig.h>
#import <UIViewController+NavigationBarStyle.h>
#import <SSWebViewBackButtonView.h>
#import <SDWebImageManager.h>
#import "SSWebViewController.h"
#import "TTFingerprintManager.h"
#import "AKNetworkManager.h"
#import "AKShareManager.h"
#import <TTPostDataHttpRequestSerializer.h>
#import <TTDeviceHelper.h>

NSString * const kAKWebPageCommonPath = @"/score_task/page/";

// 爱看的sslocal://webview？重定向到AKWebContainerViewController容器展示
@interface SSWebViewController (Redirection)

@end

@implementation SSWebViewController (Redirection)

+ (NSURL *)redirectURLWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    NSString *h5URLString = [paramObj.allParams tt_stringValueForKey:@"url"];
    BOOL isAKWebURL = [h5URLString rangeOfString:kAKWebPageCommonPath].location != NSNotFound;
    if (isAKWebURL) {
        NSString *redirectedURLString = [paramObj.sourceURL.absoluteString stringByReplacingOccurrencesOfString:@"://webview?" withString:@"://ak_webview?"];
        return [TTStringHelper URLWithURLString:redirectedURLString];
    } else {
        return paramObj.sourceURL;
    }
}

@end

@interface AKWebContainerViewController () <YSWebViewDelegate>

@property (nonatomic, strong) SSJSBridgeWebView *webContainer;
@property (nonatomic, strong) TTFullScreenLoadingView *loadingView;
@property (nonatomic, strong) SSWebViewBackButtonView *backButtonView;

// 业务VC透传的路由参数
@property (nonatomic, strong) TTRouteParamObj *routeParamObj;
@property (nonatomic, assign) BOOL shouldAppendCommonParams;

@end

@implementation AKWebContainerViewController

+ (void)load
{
    RegisterRouteObjWithEntryName(@"ak_webview");
}

- (void)dealloc
{
    LOGD(@"---%@ instance deallocated---", NSStringFromClass(self.class));
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        if (nil != paramObj) {
            _routeParamObj = paramObj;
            _adjustBottomBarInset = NO;
        }
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)urlString
                     params:(NSDictionary *)params
{
    if ([urlString hasPrefix:TTLocalScheme]) {
        // schema
        TTRouteParamObj *destParamObj = [[TTRouteParamObj alloc] initWithAllParams:({
            NSMutableDictionary *allParams = params.allKeys.count ? [params mutableCopy] : [NSMutableDictionary dictionary];
            TTRouteParamObj *sourceParamObj = [[TTRoute sharedRoute] routeParamObjWithURL:[TTStringHelper URLWithURLString:urlString]];
            [allParams addEntriesFromDictionary:sourceParamObj.allParams];
            [allParams copy];
        })];
        return [self initWithRouteParamObj:destParamObj];
    } else if ([urlString hasPrefix:@"http"]) {
        // http or https
        TTRouteParamObj *destParamObj = [[TTRouteParamObj alloc] initWithAllParams:({
            NSMutableDictionary *allParams = params.allKeys.count ? [params mutableCopy] : [NSMutableDictionary dictionary];
            [allParams setValue:urlString forKey:@"url"];
            [allParams copy];
        })];
        return [self initWithRouteParamObj:destParamObj];
    } else {
        return nil;
    }
}

- (instancetype)init
{
    return [self initWithRouteParamObj:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _configUI];
    
    [self _createWebView];
    
    [self _loadWebViewRequest];
    
//    [self _showLoadingView];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    self.webContainer.scrollView.contentInset = [self _webContainerContentInsets];
}

#pragma mark - private

- (void)_configUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButtonView];
}

- (void)_createWebView
{
    // 初始化webView
    [self _initWebView];
    
    // 根据业务方参数设置webView
    [self _configWebView];
    
    // 注册容器通用JSB handler
    [self _registerJSBridgeHandler];
}

- (void)_initWebView
{
    // 默认走UIWebView，routeParam中的参数只解析native能处理的
    BOOL useWK = [self.routeParamObj.allParams objectForKey:@"use_wk"] ? [self.routeParamObj.allParams tt_boolValueForKey:@"use_wk"] : NO;
    _webContainer = [[SSJSBridgeWebView alloc] initWithFrame:self.view.bounds disableWKWebView:!useWK ignoreGlobalSwitchKey:YES];
    _webContainer.disableThemedMask = YES;
    _webContainer.disableNightBackground = YES;
    _webContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webContainer.scrollView.contentInset = [self _webContainerContentInsets];
    [_webContainer addDelegate:self];
    [self.view addSubview:self.webContainer];
}

- (CGRect)_webContainerFrame
{
    return _webContainer.frame;
}

- (UIEdgeInsets)_webContainerContentInsets
{
//     设置webView的contentInset
    CGFloat topInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top + 44.f;
    if (self.ttHideNavigationBar) {
        topInset = 0;
    }
    if (!self.adjustBottomBarInset) {
        return UIEdgeInsetsMake(topInset, 0, [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom, 0);
    }
    return UIEdgeInsetsMake(topInset, 0, 0, 0);
}

CGFloat const kBackButtonViewLeftPadding = 15.f;
CGFloat const kBackButtonViewTopPadding = 20.f;

- (CGPoint)_backbuttonViewOriginPoint
{
    return CGPointMake([self _webContainerFrame].origin.x + kBackButtonViewLeftPadding, [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top);
}

- (void)_configWebView
{
    // 端上处理schema参数
    BOOL bounceDisable = [self.routeParamObj.allParams objectForKey:@"bounce_disable"] ? [self.routeParamObj.allParams tt_boolValueForKey:@"bounce_disable"] : YES;
    _webContainer.scrollView.bounces = !bounceDisable;
    
    // 设置标题
    self.navigationItem.title = [self.routeParamObj.allParams objectForKey:@"title"] ? [self.routeParamObj.allParams tt_stringValueForKey:@"title"] : nil;

    // 导航栏与webView frame设置
    BOOL barHidden = [self.routeParamObj.allParams objectForKey:@"hide_bar"] ? [self.routeParamObj.allParams tt_boolValueForKey:@"hide_bar"] : NO;
    self.ttHideNavigationBar = barHidden;
    self.webContainer.scrollView.contentInset = [self _webContainerContentInsets];
    if (self.ttHideNavigationBar && self.navigationController.viewControllers.count > 1) {
        // 隐藏native导航栏，h5自绘导航栏。客户端添加返回按钮
        self.backButtonView.origin = [self _backbuttonViewOriginPoint];
        [self.view addSubview:self.backButtonView];
        [self.view bringSubviewToFront:self.backButtonView];
    } else {
        // do nothing
    }
    
    // 是否添加通用参数可控，默认添加
    self.shouldAppendCommonParams = ![self.routeParamObj.allParams tt_boolValueForKey:@"disable_append_common_params"];
}

- (void)_registerJSBridgeHandler
{
    // 取通用参数
    WeakSelf;
    [self.webContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse callback) {
        NSMutableDictionary *commonParams = [([TTNetworkManager shareInstance].commonParamsblock ?
                                              [TTNetworkManager shareInstance].commonParamsblock() : [TTNetworkUtilities commonURLParameters]) mutableCopy];
        [commonParams setValue:@(1) forKey:@"code"];
        callback(TTRJSBMsgSuccess, [commonParams copy]);
    } forMethodName:@"appCommonParams"];
    
    // 请求校验
    [self.webContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse callback) {
        NSString *url = [params tt_stringValueForKey:@"url"];
        NSString *method = [params tt_stringValueForKey:@"method"];
        NSString *contentType = [params tt_stringValueForKey:@"body_content_type"];
        id requestParams = [params objectForKey:@"params"];
        
        NSDictionary *jsonDict = nil;
        if ([contentType isEqualToString:@"json"]) {
            // JSON请求，前端传回jsonString
            if ([requestParams isKindOfClass:[NSString class]]) {
                NSError *error = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[((NSString *)requestParams) dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                if (!error && [json isKindOfClass:[NSDictionary class]]) {
                    jsonDict = [json copy];
                }
            } else if ([requestParams isKindOfClass:[NSDictionary class]]) {
                jsonDict = [requestParams copy];
            } else {
                // 无参数
                jsonDict = nil;
            }
            
            NSInteger const kAKSafeHttpSafeRequestErrorNum = 8;
            NSInteger const kAKSafeHttpAntispamErrorNum = 9;
            [AKNetworkManager requestSafeHttpForJSONWithURL:url
                                                     params:jsonDict
                                                     method:method
                                                   callback:^(NSInteger err_no, NSString *err_tips, NSDictionary *dataDict) {
                NSMutableDictionary *data = [NSMutableDictionary dictionary];
                [data setValue:@(err_no != kAKSafeHttpSafeRequestErrorNum && err_no != kAKSafeHttpAntispamErrorNum) forKey:@"code"];
                [data setValue:dataDict forKey:@"data"];
                TTRJSBMsg msg = (err_no != kAKSafeHttpSafeRequestErrorNum && err_no != kAKSafeHttpAntispamErrorNum) ? TTRJSBMsgSuccess : TTRJSBMsgFailed;
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(msg, [data copy]);
                });
            }];
        } else if ([contentType isEqualToString:@"form"]) {
            // form表单
            if ([requestParams isKindOfClass:[NSDictionary class]]) {
                NSDictionary *paramsDict = [requestParams copy];
                NSMutableArray *formArray = [NSMutableArray array];
                [paramsDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [formArray addObject:({
                        NSMutableDictionary *formDict = [NSMutableDictionary dictionary];
                        [formDict setValue:obj forKey:key];
                        [formDict copy];
                    })];
                }];
                
                [[TTNetworkManager shareInstance] uploadWithURL:url parameters:nil constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
                    // key Generator
                    for (NSDictionary * dict in formArray) {
                        for (NSString * key in dict) {
                            [formData appendPartWithFormData:[dict[key] dataUsingEncoding:NSUTF8StringEncoding] name:key];
                        }
                    }
                } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
//                    SafeHttpRequestCallbackBlock(callback, error == nil, jsonObj);
                    NSMutableDictionary *data = [NSMutableDictionary dictionary];
                    [data setValue:@(error == nil) forKey:@"code"];
                    [data setValue:jsonObj forKey:@"data"];
                    TTRJSBMsg msg = (error == nil) ? TTRJSBMsgSuccess : TTRJSBMsgFailed;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(msg, [data copy]);
                    });
                }];
            }
        }
    } forMethodName:@"safeHttpRequest"];
    
    // 打开h5页面
    [self.webContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse callback) {
        StrongSelf;
//        if (self.navigationController) {
//            AKWebContainerViewController *webContainerVC = [[AKWebContainerViewController alloc] initWithURL:[params tt_stringValueForKey:@"url"] params:({
//                NSMutableDictionary *params = [NSMutableDictionary dictionary];
//                [params setValue:@(YES) forKey:@"disable_append_common_params"];
//                [params copy];
//            })];
//            [self.navigationController pushViewController:webContainerVC animated:YES];
//        } else {
//            //...
//        }
        NSURL *schema = [TTStringHelper URLWithURLString:[params tt_stringValueForKey:@"url"]];
        if (![self _canHandleSpecificOpenPageURL:schema]) {
            if ([[TTRoute sharedRoute] canOpenURL:schema]) {
                if (self.navigationController) {
                    [[TTRoute sharedRoute] openURLByPushViewController:schema];
                } else {
                    [[TTRoute sharedRoute] openURLByPresentViewController:schema userInfo:nil];
                }
            } else {
                // do nothing
            }
        }
        
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"openPage"];
    
    void (^SendSMSMessage)(NSArray *, NSString *) = ^(NSArray *toNumbers, NSString *content) {
        // 发sms短信
        [[AKShareManager sharedManager] sendSMSMessageWithBody:content recipients:toNumbers presentingViewController:self sendCompletion:^(MessageComposeResult result) {
            LOGD(@"send sms result %d", result);
        }];
    };
    
    // 发短信
    [self.webContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse callback) {
        NSArray *toNumbers = [params tt_arrayValueForKey:@"smsto"];
        NSString *content = [params tt_stringValueForKey:@"sms_body"];
        SendSMSMessage([toNumbers copy], [content copy]);
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"sendSMS"];
    
    // 图片分享
    [self.webContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse callback) {
        NSString *platform = [params tt_stringValueForKey:@"platform"];
        NSString *imageURL = [params tt_stringValueForKey:@"image"];
        NSString *text = [params tt_stringValueForKey:@"text"];
        NSString *qrShortLinkURL = [params tt_stringValueForKey:@"qr_code_url"];
        BOOL shouldAppendQRImage = ![params tt_boolValueForKey:@"image_have_qrcode"];
        
        enum AKSharePlatform sharePlatform;
        if ([platform isEqualToString:@"weixin"]) {
            sharePlatform = AKSharePlatformWeChat;
        } else if ([platform isEqualToString:@"weixin_moments"]) {
            sharePlatform = AKSharePlatformWeChatTimeLine;
        } else if ([platform isEqualToString:@"qq"]) {
            sharePlatform = AKSharePlatformQQ;
        } else if ([platform isEqualToString:@"qzone"]) {
            sharePlatform = AKSharePlatformQZone;
        } else if ([platform isEqualToString:@"sms"]) {
            NSArray *toNumbers = [params tt_arrayValueForKey:@"smsto"];
            NSString *content = [params tt_stringValueForKey:@"sms_body"];
            SendSMSMessage([toNumbers copy], [content copy]);
            TTR_CALLBACK_SUCCESS
            return;
        }
        
        if (shouldAppendQRImage) {
            [AKQRShareHelper genQRImageWithOriImage:nil oriImageURL:imageURL qrImage:nil qrImageShortLink:qrShortLinkURL completionBlock:^(UIImage *imageWithQRCode) {
                [[AKShareManager sharedManager] shareToPlatform:sharePlatform contentType:AKShareContentTypeImage text:text title:nil description:nil webPageURL:nil thumbImage:nil thumbImageURL:nil image:imageWithQRCode videoURL:nil extra:nil completionBlock:^(NSDictionary *extra, NSError *error) {
                    // 分享结果回调
                }];
            }];
        } else {
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageHighPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (image && !error) {
                    [[AKShareManager sharedManager] shareToPlatform:sharePlatform contentType:AKShareContentTypeImage text:text title:nil description:nil webPageURL:nil thumbImage:nil thumbImageURL:nil image:image videoURL:nil extra:nil completionBlock:^(NSDictionary *extra, NSError *error) {
                        // 分享结果回调
                    }];
                }
            }];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"shareImage"];
    
    // 跳转到任务中心设置
    [self.webContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse callback) {
        NSURL *url = [NSURL URLWithString:@"sslocal://more"];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByViewController:url userInfo:nil];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"taskSetting"];
    
    // 播放视频教程
    [self.webContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        NSString *groupID = [params tt_stringValueForKey:@"group_id"];
        NSURL *schema = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://detail?groupid=%@", groupID]];
        if ([[TTRoute sharedRoute] canOpenURL:schema]) {
            [[TTRoute sharedRoute] openURLByPushViewController:schema];
        }
    } forMethodName:@"feedbackVideo"];
    
    // 打开反馈页
    [self.webContainer.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        NSString *url = @"sslocal://feedback";
        NSString *questionID = [params tt_stringValueForKey:@"question_id"];
        if (!isEmptyString(questionID)) {
            url = [NSString stringWithFormat:@"sslocal://feedback?question_id=%@", [params tt_stringValueForKey:@"question_id"]];
        }
        if ([[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:url]]) {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url]];
        }
    } forMethodName:@"feedback"];
}

- (BOOL)_canHandleSpecificOpenPageURL:(NSURL *)url
{
    // ugly code 临时处理一些新定义的action
    if ([url.absoluteString rangeOfString:@"/home/news?"].location != NSNotFound) {
        // 切tab
        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
        NSString *tabKey = [paramObj.allParams tt_stringValueForKey:@"default_tab"];
        if (isEmptyString(tabKey)) {
            tabKey = @"tab_stream";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:@{@"tag":tabKey}];
        return YES;
    } else {
        //...
    }
    return NO;
}

- (void)_loadWebViewRequest
{
    if (nil == self.routeParamObj) {
        return;
    }
    
    NSString *requestURLString = [self.routeParamObj.allParams tt_stringValueForKey:@"url"];
    if (isEmptyString(requestURLString)) {
        return;
    }
    
    // 拼接通用参数（包括fp）
    NSDictionary *appendH5Params = nil;
    if (self.shouldAppendCommonParams) {
        if ([TTNetworkManager shareInstance].commonParamsblock) {
            NSDictionary *commonParams = [TTNetworkManager shareInstance].commonParamsblock();
            if (commonParams.count > 0) {
                appendH5Params = commonParams;
            }
        }
        
        if (!appendH5Params) {
            if (/*[TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].figerprintEnabled && */!isEmptyString([TTFingerprintManager sharedInstance].fingerprint)) {
                appendH5Params = [TTNetworkUtilities commonURLParametersAppendKeyAndValues:@{@"fp":[TTFingerprintManager sharedInstance].fingerprint}];
            } else {
                appendH5Params = [TTNetworkUtilities commonURLParameters];
            }
            
            // ugly code : 版本号映射关系计算。同TTNetSerializer中逻辑，暂时为了解耦copy代码。后续整体干掉映射关系
            NSString *versionKey = @"version_code";
            NSString *curVersion = [appendH5Params tt_stringValueForKey:versionKey];
            if (!isEmptyString(curVersion)) {
                NSArray<NSString *> *strArray = [curVersion componentsSeparatedByString:@"."];
                NSInteger version = 0;
                for (NSInteger i = 0; i < strArray.count; i += 1) {
                    NSString *tmp = strArray[i];
                    version = version * 10 + tmp.integerValue;
                }
                version += 560;
                NSMutableArray *newStrArray = [NSMutableArray arrayWithCapacity:3];
                for (NSInteger i = 0; i < 2; i += 1) {
                    NSInteger num = version % 10;
                    version /= 10;
                    NSString *tmp = [NSString stringWithFormat:@"%ld", num];
                    [newStrArray addObject:tmp];
                }
                NSString *tmp = [NSString stringWithFormat:@"%ld",version];
                [newStrArray addObject:tmp];
                NSString *newVersion = [[newStrArray reverseObjectEnumerator].allObjects componentsJoinedByString:@"."];
                [appendH5Params setValue:newVersion forKey:versionKey];
            }
        }
    }
    
    NSURL *requestURL = [NSURL tt_URLWithString:requestURLString parameters:appendH5Params];
    
    [self.webContainer loadRequest:[NSURLRequest requestWithURL:requestURL] appendBizParams:NO];
}

- (void)_showLoadingView
{
    [self.view addSubview:self.loadingView];
}

#pragma mark - public

- (void)registerServiceJSBHandler:(TTRJSBStaticHandler)handler
                    forMethodName:(NSString *)method
{
    [self.webContainer.ttr_staticPlugin registerHandlerBlock:handler forMethodName:method];
}

- (void)reloadWebContainer
{
    [self.webContainer reload];
}

- (void)weakReloadWebContainer
{
    [self.webContainer weakReload];
}

#pragma mark - YSWebViewDelegate

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    // TODO:拦截特殊URL
    if (self.webContainer.isDomReady) {
        self.loadingView.hidden = YES;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    LOGD(@"webview finish load");
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error
{
    LOGD(@"webview finish failed with error %@", error);
}

#pragma mark - actions

- (void)goBackAction
{
    if (![self.backButtonView isCloseButtonShowing]) {
        [self.backButtonView showCloseButton:self.webContainer.canGoBack];
    }
    if ([self.webContainer canGoBack]) {
        [self.webContainer goBack];
    } else {
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
}

- (void)closeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - lazy load

- (TTFullScreenLoadingView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[TTFullScreenLoadingView alloc] initWithFrame:self.view.bounds];
        _loadingView.hidden = NO;
        [_loadingView startLoadingAnimation];
    }
    return _loadingView;
}

- (SSWebViewBackButtonView *)backButtonView
{
    if (!_backButtonView) {
        _backButtonView = [[SSWebViewBackButtonView alloc] init];
        //    self.navigationBar.preferredItemWidth = 75;
        [_backButtonView.backButton addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
        [_backButtonView.closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButtonView;
}

@end
