//
//  TTRNKitViewWrapper.h
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/8.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTRNKitProtocol.h"
#import "TTRNKit.h"

/**
 webView和RCTRootView的包装类
 */
@interface TTRNKitViewWrapper : UIView <TTRNKitObserverProtocol>

@property (nonatomic, strong) UIView *rnView;
@property (nonatomic, strong) UIView *webView;
@property (nonatomic, copy) NSString *moduleName;

- (instancetype)initWithSchemeUrl:(NSString *)schemeUrl
                             host:(NSString *)host
                          channel:(NSString *)channel
                        urlParams:(NSDictionary *)urlParams
                        bundleUrl:(NSURL *)bundleUrl
                    sourceWrapper:(TTRNKitViewWrapper *)sourceWrapper;

- (void)createWebViewOrFallbackForUrl:(NSString *)url
                           resultType:(TTRNKitViewWraperResultType)resultType
                               params:(NSDictionary *)params;

- (void)showLoadingView;

- (void)dismissLoadingView;

@end
