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
#import "BDAssert.h"

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
    [self forwardPluginWithCommand:amendCommand engine:engine completion:^(TTBridgeMsg msg, NSDictionary *dic, void (^resultBlock)(NSString *result)) {
        if (completion) {
            completion(msg, dic, resultBlock);
        }
    }];
}

- (void)forwardWithCommand:(TTBridgeCommand *)command weakEngine:(id<TTBridgeEngine>)engine completion:(TTBridgeCallback)completion {
    TTBridgeCommand *amendCommand = [self amendAliasWith:command];
    id<TTBridgeEngine> __weak weakEngine = engine;
    [self forwardPluginWithCommand:amendCommand engine:weakEngine completion:^(TTBridgeMsg msg, NSDictionary *dic, void (^resultBlock)(NSString *result)) {
        if (completion) {
            completion(msg, dic, resultBlock);
        }
    }];
    NSURL *url = engine.sourceURL;
    NSString *bridgeURL = [[url host] stringByAppendingPathComponent:[url path]];
}

- (void)invoke:(TTBridgeCommand *)command completion:(TTBridgeCallback)completion engine:(id<TTBridgeEngine>)engine {
    NSString *selectorStr = [command.methodName stringByAppendingString:@"WithParam:callback:engine:controller:"];
    SEL selector = NSSelectorFromString(selectorStr);
    
    TTBridgePlugin *plugin = [self _generatePluginWithCommand:command engine:engine];
    if (![plugin respondsToSelector:selector]) {
        if (completion && command.bridgeType == TTBridgeTypeCall) {
            completion(TTBridgeMsgNoHandler, nil, nil);
        }
        return;
    }
    if (command.bridgeType == TTBridgeTypeOn) {
        [plugin setCallback:completion forSelector:selector];
    }
    
    NSDictionary *params = command.params;
    if ([plugin hasExternalHandleForMethod:command.methodName params:params callback:completion]) {
        return;
    }
    
    NSMethodSignature *signature = [plugin methodSignatureForSelector:selector];
    // TTDynamicBridgePlugin 未重载 methodSignatureForSelector 方法会导致这里 signature 初始化失败
    // bridge 通过了鉴权，但是未在当前 webview 上注册其实现，因此也当做 TTBridgeMsgNoHandler 来处理即可
    if (!signature) {
        if (completion) {
            completion(TTBridgeMsgNoHandler, nil, nil);
        }
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = plugin;
    invocation.selector = selector;
    [invocation setArgument:&params atIndex:2];
    [invocation setArgument:&completion atIndex:3];
    [invocation setArgument:&engine atIndex:4];
    UIViewController *source = engine.sourceController;
    [invocation setArgument:&source atIndex:5];
    [invocation invoke];
}

- (void)forwardPluginWithCommand:(TTBridgeCommand *)command engine:(id<TTBridgeEngine>)engine completion:(TTBridgeCallback)completion {
    if (isEmptyString(command.className) || isEmptyString(command.methodName)) {
        if (completion) {
            completion(TTBridgeMsgNoHandler, nil, nil);
        }
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    if ([engine respondsToSelector:@selector(authorization)] &&
        [engine.authorization respondsToSelector:@selector(engine:isAuthorizedBridge:domain:completion:)]) {
        [engine.authorization engine:engine isAuthorizedBridge:command domain:engine.sourceURL.host.lowercaseString completion:^(BOOL success) {
            if (!success) {
                if (completion && command.bridgeType == TTBridgeTypeCall) {
                    completion(TTBridgeMsgNoPermission, nil, nil);
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
- (TTBridgeCommand *)amendAliasWith:(TTBridgeCommand *)command {
    NSString *fullName = self.aliasDic[command.fullName];
    if (isEmptyString(fullName)) {
        return command;
    }
    command.origName = command.fullName;
    command.fullName = fullName;
    return command;
}

- (void)registerAlias:(NSString *)alias for:(NSString *)orig {
     [self.aliasDic setValue:alias forKey:orig];
}

- (NSString *)aliasForOrig:(NSString *)orig {
    return self.aliasDic[orig];
}
@end
