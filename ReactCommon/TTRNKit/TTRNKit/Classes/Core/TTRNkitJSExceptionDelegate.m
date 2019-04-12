//
//  TTRNkitJSExceptionDelegate.m
//  AFgzipRequestSerializer
//
//  Created by renpeng on 2018/9/4.
//

#import "TTRNkitJSExceptionDelegate.h"
#import "TTCommonBridgeManager.h"
#import "TTRNKit.h"
#import <objc/runtime.h>

static NSString *fallBackKey = @"fallBack";
static void(*vIMP)(id slf, SEL selector, NSError *error) = nil;
static void hook_vIMP(id slf, SEL selector, NSError *error) {
    TTRNkitJSExceptionDelegate *delegate = [TTCommonBridgeManager getExceptionDelegateForRNBridge:slf];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL sel = @selector(handleJSError:stack:);
    if ([delegate respondsToSelector:sel]) {
        [delegate performSelector:sel
                       withObject:[error description]
                       withObject:nil];
    }
#pragma clang diagnostic pop
    vIMP(slf, selector, error);
}

static NSMutableDictionary *_fallBackDic;

@implementation TTRNkitJSExceptionDelegate
@synthesize fallBack = _fallBack;
@synthesize manager = _manager;
+ (void)load {
    Class targetClass = NSClassFromString(@"RCTCxxBridge");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL originalSelector = @selector(handleError:);
#pragma clang diagnostic pop
    Method originalMethod = class_getInstanceMethod(targetClass, originalSelector);
    vIMP = (void(*)(id, SEL, NSError*))method_getImplementation(originalMethod);
    method_setImplementation(originalMethod, (IMP)hook_vIMP);
    _fallBackDic = [NSMutableDictionary dictionary];
}

#pragma  mark - fallback
static NSString *appVersion() {
    static NSString *version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ?: @"0.0";
    });
    return version;
}

//@{fallBack:@{appVersion:{bundleIdentifier:fallback}}}
- (void)setFallBack:(BOOL)fallBack {
    void(^block)(void) = ^{
        if (fallBack
            && [self.manager.delegate respondsToSelector:@selector(fallBackForChannel:jsContextIsValid:)]) {
            RCTBridge *bridge = [self.manager rctBridgeForChannel:self.channel];
            [self.manager.delegate fallBackForChannel:self.channel jsContextIsValid:bridge.isValid];
        } else {
            if (self.fallBack != fallBack) {
                [[self class] setFallBackInPersistence:fallBack
                                  withBundleIdentifier:[self channel]];
                _fallBack = fallBack;
                [_fallBackDic setObject:@(fallBack) forKey:self.channel];
            }
        }
    };
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (BOOL)fallBack {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_fallBack = [[self class] fallBackForIdentifier:[self channel]];
        [_fallBackDic setObject:@(self->_fallBack) forKey:self.channel];
    });
    return _fallBack;
}

+ (void)setFallBackInPersistence:(BOOL)fallBack withBundleIdentifier:(NSString *)identifier {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *fallBackDicAllVersion = [NSMutableDictionary dictionaryWithDictionary:[userDefault objectForKey:fallBackKey] ?: @{}];
    NSMutableDictionary *fallBackDicCurVersion = [NSMutableDictionary dictionaryWithDictionary:
                                                  [fallBackDicAllVersion objectForKey:appVersion()] ?: @{}];
    [fallBackDicAllVersion removeAllObjects];//则移除所有版本的fallback,只保留当前版本
    [fallBackDicCurVersion setValue:@(fallBack) forKey:identifier];
    [fallBackDicAllVersion setValue:fallBackDicCurVersion forKey:appVersion()];
    [userDefault setObject:fallBackDicAllVersion forKey:fallBackKey];
}

+ (BOOL)fallBackForIdentifier:(NSString *)identifier {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *fallBackDicAllVersion = [userDefault objectForKey:fallBackKey];
    NSDictionary *fallBackDicCurVersion = [fallBackDicAllVersion valueForKey:appVersion()];
    NSNumber *fallBack = [fallBackDicCurVersion valueForKey:identifier];
    return fallBack ? [fallBack boolValue] : NO;
}

- (instancetype)initWithChannel:(NSString *)channel bundleIdentifier:(NSString *)identifier {
    if (self = [super init]) {
        _channel = channel;
        _bundleIdentifier = identifier;
    }
    return self;
}

#pragma mark - RCTExceptionsManagerDelegate
- (void)handleJSError:(NSString *)message stack:(NSArray *)stack {//处理生产环境的fatal crash
    self.fallBack = YES;
}

- (void)handleSoftJSExceptionWithMessage:(NSString *)message
                                   stack:(NSArray *)stack
                             exceptionId:(NSNumber *)exceptionId {
    [self handleJSError:message stack:stack];
}
- (void)handleFatalJSExceptionWithMessage:(NSString *)message
                                    stack:(NSArray *)stack
                              exceptionId:(NSNumber *)exceptionId {
    [self handleJSError:message stack:stack];
}

#pragma mark - PublicAPI
+ (BOOL)fallBackForChannel:(NSString *)channel {
    if (!channel.length) {
        return NO;
    }
    if (![_fallBackDic valueForKey:channel]) {
        _fallBackDic[channel] = @([self fallBackForIdentifier:channel]);
    }
    return [_fallBackDic[channel] boolValue];
}

+ (void)setFallBackForChannelsInPersistence:(NSArray *)channels {
    for (NSString *channel in channels) {
        [self setFallBackInPersistence:NO withBundleIdentifier:channel];
    }
}
@end
