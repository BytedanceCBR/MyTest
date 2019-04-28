//
//  UIView+BridgeModule.h
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/22.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTRNKitBridgeModule.h"

@interface UIView(BridgeModule)
- (TTRNKitBridgeModule *)getBridgeModule;
- (void)setBridgeModule:(TTRNKitBridgeModule *)bridgeModule;
@end
