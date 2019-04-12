//
//  TTRNKitMacro.h
//  TTRNKit
//
//  Created by liangchao on 2018/6/14.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#ifndef TTRNKitMacro_h
#define TTRNKitMacro_h
#if __has_include(<TTRexxar/TTRJSBDefine.h>)
#import <TTRexxar/TTRJSBDefine.h>
#endif

/**
 TTRNKit 与业务方对接的关键字
 */
#define TTRNKitUserId @"user_id"
#define TTRNKitScheme @"scheme"
#define TTRNKitAppName @"app_name"
#define TTRNKitInnerAppName @"inner_app_name"
#define TTRNKitDeviceId @"device_id"
#define TTRNKitGeckoKey @"gecko_key"
#define TTRNKitGeckoAppVersion @"gecko_app_version"
#define TTRNKitGeckoChannel @"gecko_channel"
#define TTRNKitAnimationClass @"animation_class"
#define TTRNKitAnimationSize @"animation_size"
#define TTRNKitFallback @"fallback"
#define TTRNKitGeckoDomain @"kTTRNKitGeckoDomain"  //指定gecko包的拉取路径
#define TTRNKitBundleName @"kTTRNKitBundleName" //gecko路径下jsbundle的文件名
#define TTRNKitDefaultBundlePath @"kDefaultBundlePath" //business 包内置的路径
#define TTRNKitCommonBundlePath @"kDefaultCommonBundlePath" //common 包内置的路径
#define TTRNKitCommonBundleMetaPath @"kCommonBundleMetaPath" //common包的metafile路径
#define TTRNKitLoadingViewClass @"kLoadingViewClass"  //loadingView的class
#define TTRNKitLoadingViewSize @"kLoadingViewSize"  //loadingView的Size，会居中显示

/**
 TTRNKit 与js端对接的关键字
 */
#define RNUrl @"url"
#define RNWebView @"webview"
#define RNReact @"react"
#define RNBundleName @"bundleName"
#define RNModuleName @"moduleName"
#define RNChannelName @"channelName"
#define RNFallBackUrl @"fallbackUrl"
#define RNAppName @"appName"
#define RNInnerAppName @"innerAppName"
#define RNAppVersion @"appVersion"
#define RNAId @"aid"
#define RNNetType @"netType"
#define RNDeviceId @"device_id"
#define RNUserId @"user_id"
#define RNIDFA @"idfa"
#define RNIsIphoneX @"is_iphoneX"
#define RNBundleSize @"bundleSize"
#define RNBundleInitTime @"bundleInitTime"
#define RNType @"type"
#define RNParams @"params"
#define RNCode @"code"
#define RNMessage @"message"
#define RNError @"error"
#define RNEvent @"event"
#define RNMethod @"method"
#define RNHideBar @"hide_bar"
#define RNHideStatusBar @"hide_status_bar"
#define RNTitle @"title"
#define RNUseWK @"use_wk"

#define TTRNKitStartUpFabricAPIKey @"kTTRNKitStartUpFabricAPIKey"
#define TTRNKitStartUpTTTrackerLogKey @"kTTRNKitStartUpTTTrackerLogKey"
#define TTRNKitStartUpFabricCrashKey @"kTTRNKitStartUpFabricCrashKey"
#define TTRNKitStartUpFabricCrashValue @"kTTRNKitStartUpFabricCrashValue"
#define TTRNKitInitGeckoParams @"kTTRNKitInitGeckoParams"
#define TTRNKitInitAnimationParams @"kTTRNKitInitAnimationParams"
#define TTRNKitDefaultScheme @"kTTRNKitDefaultScheme"

#define TTRNRegisterStartUpTask \
+ (void)load { \
[[TTStartupGroup group].tasks addObject:[[self alloc] init]]; \
}

#ifndef isEmptyString
#define isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

#if __has_include("TTRNKitDebugViewController.h")
#define DebugSubspec
#endif

#ifndef WebBridge

#if __has_include(<TTRexxar/TTRJSBDefine.h>)
#define WebBridge 1
#else
#define WebBridge 0
#endif

#endif

#ifndef TTRNKitWebViewCallback

#if __has_include(<TTRexxar/TTRJSBDefine.h>)
#define TTRNKitWebViewCallback TTRJSBResponse
#else
typedef void(^TTRNKitWebViewCallback)(int, NSDictionary *);
static int TTRJSBMsgSuccess = 0;
#endif

#endif

#define WeakSelf __weak typeof(self) wself = self
#define StrongSelf __strong typeof(wself) self = wself

// error definition
#define kCommonErrorDomain                  @"kCommonErrorDomain"
#define kNoNetworkErrorCode                 1001
#define kAuthenticationFailCode             1002
#define kSessionExpiredErrorCode            1003
#define kChangeNameExistsErrorCode          1004
#define kUserNotExistErrorCode              1006
#define kMissingSessionKeyErrorCode         1007
#define kInvalidDataFormatErrorCode         1009
#define kUndefinedErrorCode                 1010
#define kExceptionErrorCode                 1011 // note: not all exceptions are error, exception should be handled individually, not by handleError method
#define kMissingKeywordCode                 1012
#define kListHasNoMoreDataErrorCode         1013
#define kInvalidSeverStatusErrorCode        1014
#define kServerUnAvailableErrorCode         1015
#define kUGCAntispamErrorCode               1016
#define kAccountBoundForbidCode             1017 // 禁止绑定切换
#define kUGCUserPostTooFastErrorCode        1018
#define kTTResolveServerDataErrorCode       1019



#endif /* TTRNKitMacro_h */
