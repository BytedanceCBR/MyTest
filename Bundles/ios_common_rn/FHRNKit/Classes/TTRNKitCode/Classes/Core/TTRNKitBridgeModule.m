//
//  TTRNKitBridgeModule.m
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/14.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <React/RCTJavaScriptLoader.h>
#import <TTBaseLib/TTSandBoxHelper.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <React/RCTRootView.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <objc/objc.h>
#import "UIView+BridgeModule.h"
#import "TTRNKitBridgeModule.h"
#import "TTRNKitHostParser.h"
#import "TTRNKitHelper.h"

@interface TTRNKitBridgeModule ()

@property (nonatomic, assign) BOOL useWK;
@property (nonatomic, assign) NSTimeInterval beginLoadingBundleTime;
@property (nonatomic, strong) NSURL *bundleUrl;
@property (nonatomic, assign) NSUInteger bundleSize;
@property (nonatomic, weak) TTRNKitViewWrapper *viewWrapper;

@end

@implementation TTRNKitBridgeModule
@synthesize manager = _manager;
- (instancetype)initWithBundleUrl:(NSURL *)bundleUrl {
    if (self = [super init]) {
        _bundleUrl = bundleUrl;
    }
    return self;
}

- (TTRNKitViewWrapper *)viewWrapper {
    return self.manager.currentViewWrapper;
}

#pragma mark - RCTBridgeDelegate
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
    return self.bundleUrl;
}

- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge {
    return @[self];
}

- (void)loadSourceForBridge:(RCTBridge *)bridge
                 onProgress:(RCTSourceLoadProgressBlock)onProgress
                 onComplete:(RCTSourceLoadBlock)loadCallback {
    self.beginLoadingBundleTime = [[NSDate date] timeIntervalSince1970];
    [RCTJavaScriptLoader loadBundleAtURL:self.bundleUrl onProgress:^(RCTLoadingProgress *progressData) {
        onProgress(progressData);
    } onComplete:^(NSError *error, RCTSource *source) {
        loadCallback(error,source);
        if (!error) {
            self.bundleSize = source.length;
        } else {
            self.bundleSize = 0;
        }
    }];
}

#pragma mark - RCTBridgeModule
+ (NSString *)moduleName {
    return @"TTRNBridge";
}

static void messageSend(TTRNKitBridgeModule *module,
                        NSString *method,
                        id params,
                        RCTResponseSenderBlock reactCallBack,
                        TTRNKitWebViewCallback webCallBack) {
    void(^block)(void) = ^(void) {
        NSMutableDictionary *methodParams = [NSMutableDictionary dictionary];
        methodParams[RNMethod] = method;
        if (![TTRNKitHelper isEmptyString:method]) {
            @try {
                if (params && [params isKindOfClass:[NSDictionary class]] ) {//防止参数类型错误
                    if (((NSDictionary *)params).count > 0) {
                        methodParams[RNParams] = params;
                    }
                    SEL func = NSSelectorFromString([NSString stringWithFormat:@"%@:reactCallback:webCallback:",method]);
                    if ([module respondsToSelector:func]) {
                        ((void(*)(id,SEL, NSDictionary *,
                                  RCTResponseSenderBlock,
                                  TTRNKitWebViewCallback))objc_msgSend)((id)module,
                                                                        func,
                                                                        params,
                                                                        reactCallBack,
                                                                        webCallBack);
                    }
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    };
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#pragma mark - RN export method
RCT_EXPORT_METHOD(call:(NSString *)method
                  params:(id)params
                  callback:(RCTResponseSenderBlock) callback) {//RN页面拦截call本地调用，再分发
    messageSend(self, method, params, callback, nil);
}

# pragma mark - WebView Bridge
- (void)_TTRNKitCallNativeWithParam:(NSDictionary *)param
                           callback:(TTRNKitWebViewCallback)callback
                            webView:(UIView *)webview
                         controller:(UIViewController *)controller {//web页面拦截call本地调用
    NSString *method = [param tt_stringValueForKey:RNMethod];
    TTRNKitBridgeModule *module = [webview getBridgeModule];
    /*webView的bridge是依据类名创建新的实例然后调用实例方法，无法调用到指定实例。
    只好在生成webView的时候关联上对应的module实例，然后在回调中取出来。*/
    if ([param objectForKey:RNParams]) {
        param = [param objectForKey:RNParams];
    }
    messageSend(module, method, param, nil, callback);
}

#pragma mark - sdk default call native handlers
- (void)appInfo:(NSDictionary *)params
  reactCallback:(RCTResponseSenderBlock)reactCallback
    webCallback:(TTRNKitWebViewCallback)webCallback {//rn或者web页面调用appInfo方法
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:self.manager.geckoParams[TTRNKitAppName] ?:@"" forKey:RNAppName];
    [data setValue:self.manager.geckoParams[TTRNKitInnerAppName] ?: @"" forKey:RNInnerAppName];
    [data setValue:[TTSandBoxHelper versionName]?:@"" forKey:RNAppVersion];
    [data setValue:[TTSandBoxHelper ssAppID]?:@"" forKey:RNAId];
    NSString *netType = @"";
    if(TTNetworkWifiConnected()) {
        netType = @"WIFI";
    } else if(TTNetwork4GConnected()) {
        netType = @"4G";
    } else if(TTNetwork3GConnected()) {
        netType = @"3G";
    } else if (TTNetwork2GConnected()) {
        netType = @"2G";
    } else if(TTNetworkConnected()) {
        netType = @"MOBILE";
    }
    [data setValue:netType forKey:RNNetType];
    [data setValue:self.manager.geckoParams[TTRNKitDeviceId] ?:@"" forKey:RNDeviceId];
    [data setValue:self.manager.geckoParams[TTRNKitUserId] ?:@"" forKey:RNUserId];
    [data setValue:[TTDeviceHelper idfaString]?:@"" forKey:RNIDFA];
    [data setValue:@([TTDeviceHelper isIPhoneXDevice]) forKey:RNIsIphoneX];
    
    [data setValue:@(1) forKey:RNCode];
    if (reactCallback) {
        reactCallback(@[data]);
    }
    if (webCallback) {
        webCallback(TTRJSBMsgSuccess,data);
    }
}

- (void)bundleInfo:(NSDictionary *)params
     reactCallback:(RCTResponseSenderBlock)reactCallback
       webCallback:(TTRNKitWebViewCallback)webCallback {//rn或者web页面调用bundleInfo方法
    NSMutableDictionary *bundleInfo = [NSMutableDictionary dictionary];
    bundleInfo[RNBundleName] = self.manager.geckoParams[TTRNKitBundleName] ?: @"";
    bundleInfo[RNModuleName] = self.viewWrapper.moduleName ?: @"";
    bundleInfo[RNBundleSize] = @(_bundleSize);
    bundleInfo[RNBundleInitTime] = @(_beginLoadingBundleTime);
    if (reactCallback) {
        reactCallback(@[bundleInfo]);
    }
    if (webCallback) {
        webCallback(TTRJSBMsgSuccess,bundleInfo);
    }
}

- (void)open:(NSDictionary *)params
reactCallback:(RCTResponseSenderBlock)reactCallback
 webCallback:(TTRNKitWebViewCallback)webCallback {//rn或者web页面调用open方法
    NSString *urlString = [params tt_stringValueForKey:RNUrl];
    [self.manager handleUrl:urlString];
}

- (void)close:(NSDictionary *)params
reactCallback:(RCTResponseSenderBlock)reactCallback
  webCallback:(TTRNKitWebViewCallback)webCallback {//rn或者web页面调用close方法
    UIViewController *wrapperViewController = [TTRNKitHelper findWrapperController:self.viewWrapper];
    [TTRNKitHelper closeViewController:wrapperViewController];
    [self.manager popViewHierarchy];
}

@end
