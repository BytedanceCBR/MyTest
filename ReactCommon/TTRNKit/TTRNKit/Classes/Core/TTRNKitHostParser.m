//
//  TTRNKitHostParser.m
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/11.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import "TTRNKitHostParser.h"
#import "TTRNKitNavViewController.h"
#import "TTRNKitBaseViewController.h"
#import "TTRNKitViewWrapper+Private.h"
#import "TTRNKitHelper.h"
#import "TTRNKitMacro.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTStringHelper.h>
#import <IESGeckoKit/IESGeckoKit.h>

@implementation TTRNKitHostParser

+ (void)parseWithUrlString:(NSString *)urlString
             reactCallback:(RCTResponseSenderBlock)reactCallback
               webCallback:(TTRNKitWebViewCallback)webCallback
             sourceWrapper:(TTRNKitViewWrapper *)sourceWrapper
               showLoading:(BOOL)showLoading
              schemeParams:(TTRNKitRouteParams *)schemeParams
                   context:(TTRNKit *)context
           jsBundleDidLoad:(void(^)(dispatch_block_t enqueueBlock))jsBundleDidLoad {
    id<TTRNKitProtocol> delegate = context.delegate;
    NSString *channel = [schemeParams.queryParams valueForKey:RNChannelName];
    if (channel.length
        && (![context rctBridgeForChannel:channel]
            || [context fallBackForChannel:channel])) {
        NSString *fallBackUrl = [schemeParams.queryParams tt_stringValueForKey:RNFallBackUrl];
        if (fallBackUrl.length) {
            urlString = fallBackUrl;
            schemeParams = [TTRNKitHelper routeParamObjWithString:urlString];
        }
    }
    if (![TTRNKitHelper isEmptyString:urlString] && delegate) {
        BOOL canOpenUrl = NO;
        if ([delegate respondsToSelector:@selector(openUrl:)]) {
            canOpenUrl = [delegate openUrl:urlString];
        }
        if (!canOpenUrl) {//解析url之前先询问delegate是否要自己处理url，否则开始解析
            TTRNKitViewWrapper *viewWrapper;
            if ([schemeParams.scheme hasPrefix:@"http"]) {
                viewWrapper = [[TTRNKitViewWrapper alloc] init];
                [context registerObserver:viewWrapper];
                BOOL useWKWebView = [schemeParams.queryParams tt_intValueForKey:RNUseWK] == 1;
                [viewWrapper createWebViewOrFallbackForUrl:urlString
                                                resultType:TypeWeb
                                                    params:@{RNUseWK:@(useWKWebView)}];
            } else if ([schemeParams.host isEqualToString:RNWebView] || [schemeParams.host isEqualToString:RNReact]) {
                viewWrapper = [[TTRNKitViewWrapper alloc] initWithSchemeUrl:urlString
                                                                       host:schemeParams.host
                                                                    channel:channel
                                                                  urlParams:schemeParams.queryParams
                                                                  bundleUrl:[context bundleUrlForChannel:channel]
                                                              sourceWrapper:sourceWrapper];
                [context registerObserver:viewWrapper];
                if (showLoading) {
                    [viewWrapper showLoadingView];
                }
                __weak typeof(viewWrapper) wviewWrapper = viewWrapper;
                if (jsBundleDidLoad && [schemeParams.host isEqualToString:RNReact]) {
                    jsBundleDidLoad(^() {
                        [wviewWrapper reloadData];
                    });
                } else {
                    [viewWrapper reloadData];
                }
            }
           
            if ([delegate respondsToSelector:@selector(handleWithWrapper:specialHost:url:reactCallback:webCallback:sourceWrapper:context:)]) {
                [delegate handleWithWrapper:viewWrapper
                                specialHost:nil
                                        url:urlString
                              reactCallback:reactCallback
                                webCallback:webCallback
                              sourceWrapper:sourceWrapper
                                    context:context];
            } else {
                if ([delegate respondsToSelector:@selector(presentor)]) {
                    UIViewController *presentor = [delegate presentor];
                    TTRNKitBaseViewController *vc = [[TTRNKitBaseViewController alloc]
                                                     initWithParams:schemeParams.queryParams
                                                     viewWrapper:viewWrapper];
                    if (presentor.navigationController) {
                        [presentor.navigationController pushViewController:vc animated:YES];
                    } else {
                        TTRNKitNavViewController *nav = [[TTRNKitNavViewController alloc] initWithRootViewController:vc];
                        [presentor presentViewController:nav animated:YES completion:nil];
                    }
                }
            }
        }
    }
}
@end
