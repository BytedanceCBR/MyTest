//
//  UIView+BridgeModule.m
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/22.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import "UIView+BridgeModule.h"
#import <objc/runtime.h>

@implementation UIView(BridgeModule)
- (TTRNKitBridgeModule *)getBridgeModule{
    return objc_getAssociatedObject(self, @selector(getBridgeModule));
}
- (void)setBridgeModule:(TTRNKitBridgeModule *)bridgeModule{
    if (bridgeModule){
        objc_setAssociatedObject(self, @selector(getBridgeModule), bridgeModule, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
@end
