//
//  TTBridgePlugin.m
//  TTBridgeUnify
//
//  Modified from TTRexxar of muhuai.
//  Created by 李琢鹏 on 2018/10/30.
//

#import "TTBridgePlugin.h"
#import <objc/runtime.h>
#import "TTBridgeDefines.h"
#import "BDAssert.h"

static const void *TTBridgeHandlersKey  = &TTBridgeHandlersKey;
static const void *TTBridgeSavedCallbacksKey  = &TTBridgeSavedCallbacksKey;

@interface TTBridgePlugin ()

@end

@implementation TTBridgePlugin

+ (instancetype)sharedPlugin {
    return nil;
}

+ (TTBridgeInstanceType)instanceType {
    return TTBridgeInstanceTypeNormal;
}

+ (TTBridgeAuthType)authType {
    return TTBridgeAuthPublic;
}

+ (void)registerHandlerBlock:(TTBridgePluginHandler)handler forEngine:(id<TTBridgeEngine>)engine selector:(SEL)selector {
    if (!engine) {
        return;
    }
    if (![[self new] respondsToSelector:selector]) {
        //bridge必须和plugin绑定，如果没有默认实现的方法，不允许注册外部实现
        BDAssert(NO, @"%@ doesn't implement %@", NSStringFromClass(self), NSStringFromSelector(selector));
        return;
    }
    NSMutableDictionary *allHandlers = objc_getAssociatedObject(engine, TTBridgeHandlersKey);
    if (!allHandlers) {
        allHandlers = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(engine, TTBridgeHandlersKey, allHandlers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSMutableDictionary *handlers = allHandlers[NSStringFromClass(self.class)];
    if (!handlers) {
        handlers = [NSMutableDictionary dictionary];
        allHandlers[NSStringFromClass(self.class)] = handlers;
    }
    handlers[NSStringFromSelector(selector)] = handler;
}

+ (TTBridgePluginHandler)handlerWithMethod:(NSString *)method ofEngine:(id<TTBridgeEngine>)engine {
    NSString *selectorStr = [method stringByAppendingString:@"WithParam:callback:engine:controller:"];
    NSMutableDictionary *allHandlers = objc_getAssociatedObject(engine, TTBridgeHandlersKey);
    return allHandlers[NSStringFromClass(self.class)][selectorStr];
}

- (BOOL)hasExternalHandleForMethod:(NSString *)method params:(NSDictionary *)params callback:(TTBridgeCallback)callback {
    TTBridgePluginHandler handler = [self.class handlerWithMethod:method ofEngine:self.engine];
    if (handler) {
        handler(params, callback);
        return YES;
    }
    return NO;
}

+ (void)performCallbackForEngine:(id<TTBridgeEngine>)engine selector:(SEL)selector msg:(TTBridgeMsg)msg params:(NSDictionary *)params {
    [self performCallbackForEngine:engine selector:selector msg:msg params:params resultBlock:nil];
}

+ (void)performCallbackForEngine:(id<TTBridgeEngine>)engine selector:(SEL)selector msg:(TTBridgeMsg)msg params:(NSDictionary *)params resultBlock:(void (^)(NSString *result))resultBlock{
    if (!engine) {
        return;
    }
    if ([self instanceType] == TTBridgeInstanceTypeNormal) {
        BDAssert(NO, @"On call bridge can not be TTBridgeInstanceTypeNormal type.");
        return;
    }
    NSMutableDictionary *callbacks = objc_getAssociatedObject(engine, TTBridgeSavedCallbacksKey);
    TTBridgeCallback callback = callbacks[NSStringFromSelector(selector)];
    if (callback) {
        callback(msg, params, resultBlock);
    }
}

- (void)setCallback:(TTBridgeCallback)callback forSelector:(SEL)selector {
    if ([self.class instanceType] == TTBridgeInstanceTypeNormal) {
        BDAssert(NO, @"On call bridge can not be TTBridgeInstanceTypeNormal type.");
        return;
    }
    NSMutableDictionary *callbacks = objc_getAssociatedObject(self.engine, TTBridgeSavedCallbacksKey);
    if (!callbacks) {
        callbacks = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self.engine, TTBridgeSavedCallbacksKey, callbacks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    callbacks[NSStringFromSelector(selector)] = callback;
}

- (void)removeCallback:(TTBridgeCallback)callback forSelector:(SEL)selector {
    NSMutableDictionary *callbacks = objc_getAssociatedObject(self.engine, TTBridgeSavedCallbacksKey);
    [callbacks removeObjectForKey:NSStringFromSelector(selector)];
}

@end
