//
//  TTRJSBForwarding+TTRNKit.m
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/22.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import "TTRJSBForwarding+TTRNKit.h"
#import <objc/runtime.h>
#import "TTRNKitMacro.h"
#import "UIView+BridgeModule.h"

@implementation TTRJSBForwarding (TTRNKit)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(forwardJSBWithCommand:engine:completion:);
        SEL swizzledSelector = @selector(hook_forwardJSBWithCommand:engine:completion:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling
- (void)hook_forwardJSBWithCommand:(TTRJSBCommand *)command
                            engine:(id<TTRexxarEngine>)engine
                        completion:(TTRNKitWebViewCallback)completion {
    if ([engine isKindOfClass:[UIView class]]
        && [((UIView *)engine) getBridgeModule] != nil
        && [command.messageType isEqualToString:@"call"]) {//仅仅对于TTRNKitViewWrapper中的WebView，拦截call调用，先调用sdk的入口方法，再分发
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[RNMethod] = command.fullName?:@"";
        if (command.params && command.params.count > 0){
            params[RNParams] = command.params;
        }
        command.fullName = @"_TTRNKitCallNative";
        command.params = params;
    }
    [self hook_forwardJSBWithCommand:command engine:engine completion:completion];
}
@end
