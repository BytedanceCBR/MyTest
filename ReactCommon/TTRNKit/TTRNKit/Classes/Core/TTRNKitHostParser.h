//
//  TTRNKitHostParser.h
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/11.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "TTRNKitViewWrapper.h"
#import "TTRNKit.h"

@class TTRouteParamObj;

@interface TTRNKitHostParser : NSObject
+ (void)parseWithUrlString:(NSString *)urlString
             reactCallback:(RCTResponseSenderBlock)reactCallback
               webCallback:(TTRNKitWebViewCallback)webCallback
             sourceWrapper:(TTRNKitViewWrapper *)sourceWrapper
               showLoading:(BOOL)showLoading
              schemeParams:(TTRouteParamObj *)schemeParams
                   context:(TTRNKit *)context
           jsBundleDidLoad:(void(^)(dispatch_block_t enqueueBlock))jsBundleDidLoad;

@end
