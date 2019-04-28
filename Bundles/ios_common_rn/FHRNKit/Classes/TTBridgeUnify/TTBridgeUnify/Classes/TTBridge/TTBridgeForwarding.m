 //
//  TTBridgeForwarding.m
//  TTBridgeUnify
//
//  Modified from TTRexxar of muhuai.
//  Created by 李琢鹏 on 2018/10/30.
//


#import "TTBridgeForwarding.h"
#import "TTBridgePlugin.h"
#import "TTBridgeAuthorization.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface TTBridgeForwarding ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *aliasDic;
@end
@implementation TTBridgeForwarding

+ (instancetype)sharedInstance {
    static TTBridgeForwarding *forwarding;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        forwarding = [[TTBridgeForwarding alloc] init];
    });
    return forwarding;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _aliasDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)forwardWithCommand:(TTBridgeCommand *)command engine:(id<TTBridgeEngine>)engine completion:(TTBridgeCallback)completion {
    TTBridgeCommand *amendCommand = [self amendAliasWith:command];
    
    //为了兼容异步授权的逻辑, 所有invoke改为block形式
    
    //动态 别名
    [self forwardPluginWithCommand:amendCommand engine:engine completion:^(TTBridgeMsg msg, NSDictionary *dic) {
        if (msg != TTBridgeMsgNoHandler) {
            if (completion) {
                completion(msg, dic);
            }
            return;
        }
        //动态 原名
        [self forwardPluginWithCommand:command engine:engine completion:completion];
    }];
}

- (void)forwardWithCommand:(TTBridgeCommand *)command weakEngine:(id<TTBridgeEngine>)engine completion:(TTBridgeCallback)completion {
    TTBridgeCommand *amendCommand = [self amendAliasWith:command];
    
    id<TTBridgeEngine> __weak weakEngine = engine;
    //为了兼容异步授权的逻辑, 所有invoke改为block形式
    
    //动态 别名
    [self forwardPluginWithCommand:amendCommand engine:weakEngine completion:^(TTBridgeMsg msg, NSDictionary *dic) {
        if (msg != TTBridgeMsgNoHandler) {
            if (completion) {
                completion(msg, dic);
            }
            return;
        }
        //动态 原名
        [self forwardPluginWithCommand:command engine:weakEngine completion:completion];
    }];
}

- (void)invoke:(TTBridgeCommand *)command completion:(TTBridgeCallback)completion engine:(id<TTBridgeEngine>)engine {
    NSString *selectorStr = [command.methodName stringByAppendingString:@"WithParam:callback:engine:controller:"];
    SEL selector = NSSelectorFromString(selectorStr);
    
    TTBridgePlugin *plugin = [self _generatePluginWithCommand:command engine:engine];
    if (![plugin respondsToSelector:selector]) {
        if (completion) {
            completion(TTBridgeMsgNoHandler, nil);
        }
        return;
    }
    
    NSDictionary *params = command.params;
    
    if (command.bridgeType == TTBridgeTypeOn) {
        [plugin setCallback:completion forSelector:selector];
    }

    if (![plugin shoudHandleBridgeForMethod:command.methodName params:params callback:completion]) {
        return;
    }
    
    [plugin handleBridgeForMethod:command.methodName params:params callback:completion];
    
    if ([plugin respondsToSelector:selector]) {
        NSMethodSignature *signature = [plugin methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = plugin;
        invocation.selector = selector;
        
        [invocation setArgument:&params atIndex:2];
        [invocation setArgument:&completion atIndex:3];
        [invocation setArgument:&engine atIndex:4];
        NSLog(@"engine.sourceController = %@",engine.sourceController);
        
        UIViewController *source = engine.sourceController;
        [invocation setArgument:&source atIndex:5];
        [invocation invoke];
    }
}

- (void)forwardPluginWithCommand:(TTBridgeCommand *)command engine:(id<TTBridgeEngine>)engine completion:(TTBridgeCallback)completion {
    if (isEmptyString(command.className) || isEmptyString(command.methodName)) {
        if (completion) {
            completion(TTBridgeMsgNoHandler, nil);
        }
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    if ([engine respondsToSelector:@selector(authorization)] && [engine.authorization respondsToSelector:@selector(engine:isAuthorizedBridge:domain:completion:)]) {
        [engine.authorization engine:engine isAuthorizedBridge:command domain:engine.sourceURL.host.lowercaseString completion:^(BOOL success) {
            if (!success) {
                if (completion) {
                    completion(TTBridgeMsgNoPermission, nil);
                }
            } else {
                [weakSelf invoke:command completion:completion engine:engine];
            }
        }];
        return;
    }
    
    [self invoke:command completion:completion engine:engine];
}


- (TTBridgePlugin *)_generatePluginWithCommand:(TTBridgeCommand *)command engine:(id<TTBridgeEngine>)engine {
    Class cls = NSClassFromString(command.className);
    if (![cls isSubclassOfClass:[TTBridgePlugin class]]) {
        return nil;
    }
    
    TTBridgeInstanceType instanceType = [cls instanceType];
    TTBridgePlugin *plugin;
    
    if (instanceType == TTBridgeInstanceTypeNormal) {
        plugin = [[cls alloc] init];
        
    } else if (instanceType == TTBridgeInstanceTypeGlobal) {
        plugin = [cls sharedPlugin];
        
    } else {//通过关联引用 来保证 在 同一个engine下只有一个plugin实例
        if (engine != nil) {
            plugin = objc_getAssociatedObject(engine, NSSelectorFromString(command.className));
            if (!plugin) {
                plugin = [[cls alloc] init];
                objc_setAssociatedObject(engine, NSSelectorFromString(command.className), plugin, OBJC_ASSOCIATION_RETAIN);
            }
        } else {
            plugin = [[cls alloc] init];
        }
    }
    plugin.engine = engine;
    
    return plugin;
}

#pragma mark - 别名相关
//查找别名映射  appinfo -> TTUtil.appinfo
- (TTBridgeCommand *)amendAliasWith:(TTBridgeCommand *)command {
    NSString *fullName = self.aliasDic[command.fullName];
    
    if (isEmptyString(fullName)) {
        return command;
    }

    TTBridgeCommand *amendCommand = [command copy];
    amendCommand.origName = amendCommand.fullName;
    amendCommand.fullName = fullName;
    return amendCommand;
}

- (void)registerAlias:(NSString *)alias for:(NSString *)orig {
     [self.aliasDic setValue:alias forKey:orig];
}

- (NSString *)aliasForOrig:(NSString *)orig {
    return self.aliasDic[orig];
}
@end
