//
//  TTRNKitViewWrapper.m
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/8.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import "TTRNKitViewWrapper.h"
#import "UIView+BridgeModule.h"
#import "TTRNKitBridgeModule.h"
#import "TTRNKitHostParser.h"
#import "TTRNKitHelper.h"
#import "TTRNKitMacro.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTStringHelper.h>
#import <React/RCTBridgeModule.h>
#if WebBridge
#import <TTRexxar/TTRJSBForwarding.h>
#import <TTRexxar/TTRUIWebView.h>
#import <TTRexxar/TTRWKWebView.h>
#endif
#import <React/RCTRootView.h>
#import "FHIESGeckoManager.h"

#define BasicHost @[@"appInfo",@"bundleInfo",@"open",@"close"]

@interface TTRNKitViewWrapper ()
@property (nonatomic, copy) NSString *schemeUrl;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSDictionary *urlParams;
@property (nonatomic, copy) NSURL *bundleUrl;
@property (nonatomic, weak) TTRNKitViewWrapper *sourceWrapper;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, copy) NSString *channel;
@end

@implementation TTRNKitViewWrapper
@synthesize manager = _manager;

+ (UIColor *)colorWithHexString:(id)hexString
{
    if (![hexString isKindOfClass:[NSString class]] || [hexString length] == 0) {
        return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    }
    
    const char *s = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
    if (*s == '#') {
        ++s;
    }
    unsigned long long value = strtoll(s, nil, 16);
    unsigned long long r, g, b, a;
    switch (strlen(s)) {
        case 2:
            // xx
            r = g = b = value;
            a = 255;
            break;
        case 3:
            // RGB
            r = ((value & 0xf00) >> 8);
            g = ((value & 0x0f0) >> 4);
            b = ((value & 0x00f) >> 0);
            r = r * 16 + r;
            g = g * 16 + g;
            b = b * 16 + b;
            a = 255;
            break;
        case 6:
            // RRGGBB
            r = (value & 0xff0000) >> 16;
            g = (value & 0x00ff00) >>  8;
            b = (value & 0x0000ff) >>  0;
            a = 255;
            break;
        default:
            // RRGGBBAA
            r = (value & 0xff000000) >> 24;
            g = (value & 0x00ff0000) >> 16;
            b = (value & 0x0000ff00) >>  8;
            a = (value & 0x000000ff) >>  0;
            break;
    }
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
}

- (instancetype)initWithSchemeUrl:(NSString *)schemeUrl
                             host:(NSString *)host
                          channel:(NSString *)channel
                        urlParams:(NSDictionary *)urlParams
                        bundleUrl:(NSURL *)bundleUrl
                    sourceWrapper:(TTRNKitViewWrapper *)sourceWrapper {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        _schemeUrl = schemeUrl;
        _host = host;
        _channel = channel;
        if (urlParams[RNModuleName]) {
            _moduleName = urlParams[RNModuleName];
        }else
        {
            _moduleName = urlParams[@"module_name"];
        }
        NSMutableDictionary *urlParamsProcess = [NSMutableDictionary new];
        if (urlParams) {
            [urlParamsProcess addEntriesFromDictionary:urlParams];
        }
        if (_moduleName) {
            [urlParamsProcess setValue:_moduleName forKey:RNModuleName];
        }
        _urlParams = urlParamsProcess;

        _bundleUrl = bundleUrl;
        _sourceWrapper = sourceWrapper;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)reloadData {
    for (UIView *sub in [self subviews]) {
        [sub removeFromSuperview];
    }
    BOOL useWKWebView = [self.urlParams tt_intValueForKey:RNUseWK] == 1
    && [UIDevice currentDevice].systemVersion.doubleValue > 8.0;//由url参数控制webview使用wkwebView还是uiwebView
    if ([self.host isEqualToString:RNReact]
        && [self.bundleUrl.absoluteString length]) {
        NSString *moduleName = [self.urlParams tt_stringValueForKey:RNModuleName];
        [self createRCTRootViewWithModuleName:moduleName];
    } else if ([self.host isEqualToString:RNWebView]) {
        NSString *url = [self.urlParams tt_stringValueForKey:RNUrl];
        [self createWebViewOrFallbackForUrl:url
                                 resultType:TypeWeb
                                     params:@{RNUseWK:@(useWKWebView)}];
    }
    [self dismissLoadingView];
}

- (void)reloadDataForDebugWith:(NSDictionary *)initParams bundleURL:(NSURL *)jsCodeLocation moduleName:(NSString *)moduleName{
    for (UIView *sub in [self subviews]) {
        [sub removeFromSuperview];
    }
    TTRNKitBridgeModule *bridgeModule = [[TTRNKitBridgeModule alloc] initWithBundleUrl:jsCodeLocation];
    [self.manager registerObserver:bridgeModule];
    RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:bridgeModule launchOptions:nil];
    RCTRootView *rnView = [[RCTRootView alloc] initWithBridge:bridge moduleName:moduleName initialProperties:initParams];
    rnView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rnView = rnView;
    [self addSubview:self.rnView];
    if([self.rnView isKindOfClass:[UIView class]])
    {
        [self addConstraintsToView:self.rnView];
    }
}

- (void)createWebViewOrFallbackForUrl:(NSString *)url
                           resultType:(TTRNKitViewWraperResultType)resultType
                               params:(NSDictionary *)params {
    if (![TTRNKitHelper isEmptyString:url]) {
        if (resultType == TypeWeb){//如果是直接打开http类型的地址
            NSURLRequest *request = [NSURLRequest requestWithURL:[TTStringHelper URLWithURLString:url]];
            BOOL useWK = [params tt_boolValueForKey:RNUseWK];
            if (self.manager.delegate
                && [self.manager.delegate respondsToSelector:@selector(createWebViewForRequest:useWK:)]) {
                self.webView = [self.manager.delegate createWebViewForRequest:request useWK:useWK];
            }
#if WebBridge
            else {
                if (useWK) {
                    TTRWKWebView *webView = [[TTRWKWebView alloc] initSharedConfigurationViewWithFrame:CGRectZero];
                    webView.backgroundColor = [UIColor whiteColor];
                    [webView ttr_loadRequest:request];
                    self.webView = webView;
                } else {
                    TTRUIWebView *webView = [[TTRUIWebView alloc] init];
                    webView.backgroundColor = [UIColor whiteColor];
                    [webView ttr_loadRequest:request];
                    self.webView = webView;
                }
                
            }
#endif
            if (self.webView) {
                [self.webView setBridgeModule:[self.manager rnKitBridgeModuleForChannel:self.channel]];
                self.webView.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:self.webView];
                if([self.webView isKindOfClass:[UIView class]])
                {
                    [self addConstraintsToView:self.rnView];
                }
                if (self.manager.delegate
                    && [self.manager.delegate respondsToSelector:@selector(renderContentWithUrl:resultType:viewWrapper:)]) {
                    [self.manager.delegate renderContentWithUrl:url
                                                     resultType:resultType
                                                    viewWrapper:self];
                }
            }
        }
    }
}

 - (NSString *)getGeckoKey
{
    if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"] isEqualToString:@"local_test"]) {
        return @"adc27f2b35fb3337a4cb1ea86d05db7a";
    }else
    {
        return @"7838c7618ea608a0f8ad6b04255b97b9";
    }
}

- (void)createRCTRootViewWithModuleName:(NSString *)moduleName {
    NSMutableDictionary *urlsPrams = [NSMutableDictionary dictionaryWithDictionary:_urlParams];
    [urlsPrams setValue:[self getGeckoKey] forKey:@"gecko_key"];
    NSString *geckoBundlePath = geckoBundlePathForGeckoParams(urlsPrams, _channel);
    geckoBundlePath = [geckoBundlePath stringByAppendingString:[NSString stringWithFormat:@"/%@",_urlParams[@"bundle_name"]]];

    if ([geckoBundlePath isKindOfClass:[NSString class]] && [[NSFileManager defaultManager] fileExistsAtPath:geckoBundlePath isDirectory:nil]) {
        NSURL *urlJSBundle1 = [NSURL URLWithString:geckoBundlePath];
        
        TTRNKitBridgeModule *bridgeModule = [[TTRNKitBridgeModule alloc] initWithBundleUrl:urlJSBundle1];
        [self.manager registerObserver:bridgeModule];
        RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:bridgeModule launchOptions:nil];
        RCTRootView *rnView = [[RCTRootView alloc] initWithBridge:bridge moduleName:moduleName initialProperties:_urlParams];
        rnView.translatesAutoresizingMaskIntoConstraints = NO;
        self.rnView = rnView;
        
        if([self.rnView isKindOfClass:[UIView class]])
        {
            [self addSubview:self.rnView];
            [self addConstraintsToView:self.rnView];
        }
    }else
    {
        //尝试重新下载
        [FHIESGeckoManager configGeckoInfo];
    }

//    TTRNKitBridgeModule *bridgeModule = [[TTRNKitBridgeModule alloc] initWithBundleUrl:urlJSBundle1];
//    RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:bridgeModule launchOptions:nil];
//
//
//    RCTRootView *rnView = [[RCTRootView alloc] initWithBridge:bridge
//                                                   moduleName:moduleName
//                                            initialProperties:_urlParams];
////    RCTRootView *rnView = [[RCTRootView alloc] initWithBridge:[self.manager rctBridgeForChannel:self.channel]
////                                                   moduleName:moduleName
////                                            initialProperties:_urlParams];
//    _rnView = rnView;
//    NSString *hex = _urlParams[@"placeholderColor"];
//    if (hex) {
//        _rnView.backgroundColor = [self.class colorWithHexString:hex];
//    }
//    _rnView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addSubview:self.rnView];
//    [self addConstraintsToView:self.rnView];
//    [self sendSubviewToBack:self.rnView];
//    [self renderJsBundleSucceed];
}

- (void)renderJsBundleSucceed {
    if (self.manager.delegate && [self.manager.delegate respondsToSelector:@selector(renderContentWithUrl:resultType:viewWrapper:)]) {
        [self.manager.delegate renderContentWithUrl:self.schemeUrl
                                         resultType:TypeReact
                                        viewWrapper:self];
    }
}

- (void)showLoadingView {
    NSDictionary *animationParams = self.manager.animationParams;
    [self showLoadingView:
     [TTRNKitHelper getLoadingViewWith:[animationParams tt_stringValueForKey:TTRNKitAnimationClass]
                                  size:[[animationParams objectForKey:TTRNKitAnimationSize] CGSizeValue]
      ]];
}

- (void)showLoadingView:(UIView *)loadingView {
    if (!loadingView) {
        return;
    }
    if (!_loadingView) {
        _loadingView = loadingView;
        _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_loadingView];
//        [self addConstraints:@[
//                               [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
//                               [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
//                               [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_loadingView.frame.size.width],
//                               [NSLayoutConstraint constraintWithItem:_loadingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_loadingView.frame.size.height]
//                               ]];
//        [self bringSubviewToFront:_loadingView];
    }
}

- (void)dismissLoadingView {
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}

- (void)addConstraintsToView:(UIView *)view {
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:0]
                           ]];
}
@end
