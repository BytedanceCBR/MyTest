//
//  TTRNKitBridgeModule.h
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/14.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTBridgeDelegate.h>
#import "TTRNKitMacro.h"
#if WebBridge
#import <TTRexxar/TTRDynamicPlugin.h>
#endif
#import "TTRNKitViewWrapper+Private.h"
#import "TTRNKit.h"

@interface TTRNKitBridgeModule : 
#if WebBridge
TTRDynamicPlugin
#else
NSObject
#endif
<RCTBridgeModule,RCTBridgeDelegate,TTRNKitObserverProtocol>

@property (nonatomic, copy) NSDictionary *geckoParams;

- (instancetype)initWithBundleUrl:(NSURL *)bundleUrl;

#if WebBridge
TTR_EXPORT_HANDLER(_TTRNKitCallNative);
#endif

@end
