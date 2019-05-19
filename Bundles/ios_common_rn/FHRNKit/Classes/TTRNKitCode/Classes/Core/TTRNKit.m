//
//  TTRNKit.m
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/11.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import "TTRNKit.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <React/RCTExceptionsManager.h>
#if WebBridge
#import <TTRexxar/TTRJSBForwarding.h>
#endif
#import <TTBaseLib/TTStringHelper.h>
#import <React/RCTBridge+Private.h>
#import <IESGeckoKit/IESGeckoKit.h>
#import <React/RCTConvert.h>
#import <React/RCTAssert.h>
#import "TTRNkitJSExceptionDelegate.h"
#import "TTRNKitNavViewController.h"
#import "TTCommonBridgeManager.h"
#import "TTRNKitStartUpSetting.h"
#import "TTRNKitBridgeModule.h"
#import "TTRNKitHostParser.h"
#import "TTRNKitHelper.h"
#import "TTRNKitMacro.h"
#ifdef DebugSubspec
#import "TTRNKitDebugViewController.h"
#endif

static NSString *geckoParamsKey = @"kGeckoParams";
@interface ViewWrapper : NSObject
@property (nonatomic, weak) UIView *view;
@end
@implementation ViewWrapper
@end

@interface TTRNKit ()

@property (nonatomic, strong) NSMutableArray<ViewWrapper*> *viewHierarchy;
@property (nonatomic, strong) TTCommonBridgeInfo *webviewBridgeInfo;

@end

@implementation TTRNKit

#if WebBridge
+ (void)load {
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRWenda.deleteAnswerDraft" for:@"delete_answer_draft"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRNKitBridgeModule._TTRNKitCallNative" for:@"_TTRNKitCallNative"];
}
#endif

- (instancetype)initWithGeckoParams:(NSDictionary *)geckoParams animationParams:(NSDictionary *)animationParams {
    if (self = [super init]) {
        _animationParams = animationParams;
        _geckoParams = geckoParams;
        _viewHierarchy = [NSMutableArray array];
        _bridgeInfos = [NSMutableDictionary dictionary];
        if ([geckoParams valueForKey:TTRNKitGeckoDomain]) {
            [IESGeckoKit setPlatformDomain:[geckoParams valueForKey:TTRNKitGeckoDomain]];
        }
        [self syncGeckoBundle];
    }
    return self;
}

- (void)setBridgeInfo:(TTCommonBridgeInfo *)bridgeInfo {
    [self.bridgeInfos setValue:bridgeInfo forKey:bridgeInfo.channel];
}

- (void)syncGeckoBundle {
//    [TTRNKitGeckoWrapper syncWithGeckoParams:self.geckoParams completion:nil];
}

#pragma mark - public method
- (void)clearRNResourceForChannel:(NSString *)channel {
    if (!channel.length) {
        return;
    }
    [_bridgeInfos removeObjectForKey:channel];
    [TTCommonBridgeManager removeBridgeForChannel:channel geckoParams:self.geckoParams];
}

- (BOOL)tryStartRNResourceWithChannel:(NSString *)channel {
    TTCommonBridgeInfo *bridgeInfo = [self.bridgeInfos valueForKey:channel];
    WeakSelf;
    if (!bridgeInfo.bridge) { //目前按照_bridgeInfo.bridge来判断是否初始化过RN相关的资源
        TTCommonBridgeInfo *bridgeInfo = [TTCommonBridgeManager bridgeWithGeckoParams:self.geckoParams
                                                                              manager:self
                                                                              channel:channel];
        if (bridgeInfo.bridge) {
            [self setBridgeInfo:bridgeInfo];
            return YES;
        }
        return NO;
    }
    return YES; //已经初始化过，认为start成功
}

- (void)handleUrl:(NSString *)urlString {
    TTRNKitRouteParams *schemeParams = [TTRNKitHelper routeParamObjWithString:urlString];
    NSString *channel = [schemeParams.queryParams valueForKey:RNChannelName];
    if (!channel.length) {
        channel = @"channel not exists";
    }
    WeakSelf;
    if (![self tryStartRNResourceWithChannel:channel]
        && ![self.bridgeInfos valueForKey:channel]
        && !self.webviewBridgeInfo) {
        TTCommonBridgeInfo *info = [TTCommonBridgeManager webBridgeInfoWithManager:self
                                                                           channel:channel];
        self.webviewBridgeInfo = info;
    }
    TTCommonBridgeInfo *bridgeInfo = [self.bridgeInfos valueForKey:channel] ?: self.webviewBridgeInfo;
    __weak typeof(bridgeInfo) wbridgeInfo = bridgeInfo;
    BOOL showLoading = !(bridgeInfo.jsDidLoad);
    [TTRNKitHostParser parseWithUrlString:urlString
                            reactCallback:nil
                              webCallback:nil
                            sourceWrapper:nil
                              showLoading:showLoading
                             schemeParams:schemeParams
                                  context:self
                          jsBundleDidLoad:^(dispatch_block_t enqueueBlock) {
                              if (!(wbridgeInfo.jsDidLoad) && ![wself fallBackForChannel:channel]) {
                                  [wbridgeInfo enqueueJSDidLoadCompleiton:enqueueBlock];
                              } else {
                                  enqueueBlock();
                              }
                          }];
}

- (void)enterDebug:(UIViewController *)presentor contentViewController:(UIViewController *)contentViewController{
#ifdef DebugSubspec
    TTRNKitDebugViewController *debugVC = [[TTRNKitDebugViewController alloc]
                                           initWithContentViewController:contentViewController
                                           initModuleParams:_geckoParams];
    [self registerObserver:debugVC];
    
    if (presentor.navigationController) {
        [presentor.navigationController pushViewController:debugVC animated:YES];
    } else {
        TTRNKitNavViewController *nav = [[TTRNKitNavViewController alloc] initWithRootViewController:debugVC];
        [presentor presentViewController:nav animated:YES completion:nil];
    }

#else
    NSAssert(NO, @"请安装Debug子库");
#endif
}

#pragma mark - manageViewHierarchy
- (TTRNKitViewWrapper *)currentViewWrapper {
    if (self.viewHierarchy.count) {
        return [self.viewHierarchy lastObject].view;
    }
    return nil;
}

- (void)pushViewWrapper:(TTRNKitViewWrapper *)viewWrapper {
    ViewWrapper *wrapper = [[ViewWrapper alloc] init];
    wrapper.view = viewWrapper;
    [self.viewHierarchy addObject:wrapper];
}

- (void)popViewHierarchy {
    if (self.viewHierarchy.count) {
        [self.viewHierarchy removeLastObject];
    }
}

//获取TTRNKit的状态
- (void)registerObserver:(id<TTRNKitObserverProtocol>)observer {
    if ([observer respondsToSelector:@selector(setManager:)]) {
        observer.manager = self;
    }
    if ([observer isKindOfClass:[TTRNKitViewWrapper class]]) {
        [self pushViewWrapper:observer];
    }
}

#pragma mark - info GET
- (BOOL)fallBackForChannel:(NSString *)channel {
    if ([self.delegate respondsToSelector:@selector(fallBackForChannel:jsContextIsValid:)]) {
        return NO;
    }
    return [TTRNkitJSExceptionDelegate fallBackForChannel:channel];
}

- (NSURL *)bundleUrlForChannel:(NSString *)channel {
    return self.bridgeInfos[channel].bundleUrl;
}

- (TTRNKitBridgeModule *)rnKitBridgeModuleForChannel:(NSString *)channel {
    if (!channel.length) {
        return self.webviewBridgeInfo.bridgeDelegate;
    }
    return self.bridgeInfos[channel].bridgeDelegate ?: self.webviewBridgeInfo.bridgeDelegate;
}

- (RCTBridge *)rctBridgeForChannel:(NSString *)channel {
    return self.bridgeInfos[channel].bridge;
}

@end
