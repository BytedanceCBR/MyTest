//
//  TTAdSingletonManager.m
//  Article
//
//  Created by yin on 2017/4/28.
//
//

#import "TTAdSingletonManager.h"
#import <TTBaseLib/TTBaseMacro.h>

@interface TTAdSingletonManager ()

@property (nonatomic, strong) NSMutableDictionary* singletonDict;

@end

@implementation TTAdSingletonManager

Singleton_Implementation(TTAdSingletonManager)

+ (void)load
{
    __unused TTAdSingletonManager* singletonManager = [TTAdSingletonManager sharedManager];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.singletonDict = [NSMutableDictionary dictionary];
        WeakSelf;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            StrongSelf;
            [self passSingletonNotificationBlock:^(id key, id<TTAdSingletonProtocol>obj, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(applicationWillEnterForegroundNotification:)]) {
                    [obj applicationWillEnterForegroundNotification:note];
                }
                
            }];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            StrongSelf;
            [self passSingletonNotificationBlock:^(id key, id<TTAdSingletonProtocol>obj, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(applicationDidBecomeActiveNotification:)]) {
                    [obj applicationDidBecomeActiveNotification:note];
                }
                
            }];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            StrongSelf;
            [self passSingletonNotificationBlock:^(id key, id<TTAdSingletonProtocol>obj, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(applicationDidEnterBackgroundNotification:)]) {
                    [obj applicationDidEnterBackgroundNotification:note];
                }
            }];
        }];
    }
    return self;
}

- (void)passSingletonNotificationBlock:(void(^)(id key, id  _Nonnull obj, BOOL * _Nonnull stop))block
{
    [self.singletonDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj&&[obj conformsToProtocol:@protocol(TTAdSingletonProtocol)]) {
            id<TTAdSingletonProtocol>manager = obj;
            block(key, manager, stop);
        }
    }];
}

- (BOOL)registerSingleton:(id<TTAdSingletonProtocol>)singleton forKey:(NSString *)key {
    if (![singleton conformsToProtocol:@protocol(TTAdSingletonProtocol)]) {
        return NO;
    }
    if (!isEmptyString(key)) {
        [self.singletonDict setValue:singleton forKey:key];
        if ([self.singletonDict valueForKey:key]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)unRegisterSingleton:(id<TTAdSingletonProtocol>)singleton forKey:(NSString *)key
{
    if (!isEmptyString(key)) {
        if (![self.singletonDict valueForKey:key]) {
            return NO;
        }
        [self.singletonDict setValue:nil forKey:key];
        if (![self.singletonDict valueForKey:key]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray*)singletonsArray
{
    NSMutableArray* array = [NSMutableArray alloc];
    [self.singletonDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj && [obj conformsToProtocol:@protocol(TTAdSingletonProtocol)]) {
            [array addObject:obj];
        }
    }];
    return array;
}

#pragma mark -自定义方法

- (void)applicationDidLaunch
{
    [self passSingletonNotificationBlock:^(id key, id<TTAdSingletonProtocol>obj, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(applicationDidFinishLaunchingNotification:)]) {
            [obj applicationDidFinishLaunchingNotification:nil];
        }
    }];
}

@end

