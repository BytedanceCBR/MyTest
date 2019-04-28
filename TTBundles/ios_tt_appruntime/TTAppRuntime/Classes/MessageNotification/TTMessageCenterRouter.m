//
//  TTMessageCenterRouter.m
//  Article
//
//  Created by zuopengliu on 29/11/2017.
//

#import "TTMessageCenterRouter.h"



@interface TTMessageCenterRouter ()

@property (nonatomic, strong) NSHashTable<id<TTMessageRouteProtocol>> *routerDelegates;

@end

@implementation TTMessageCenterRouter

+ (instancetype)sharedMessage
{
    static TTMessageCenterRouter *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

- (void)dealloc
{
    [self.routerDelegates removeAllObjects];
}

+ (void)registerRouter:(id<TTMessageRouteProtocol>)router
{
    [[self sharedMessage] registerRouter:router];
}

- (void)registerRouter:(id<TTMessageRouteProtocol>)router
{
    if (!router) return;
    @synchronized(self.routerDelegates) {
        [self.routerDelegates addObject:router];
    }
}

+ (void)unregisterRouter:(id<TTMessageRouteProtocol>)router
{
    [[self sharedMessage] unregisterRouter:router];
}

- (void)unregisterRouter:(id<TTMessageRouteProtocol>)router
{
    if (!router) return;
    @synchronized(self.routerDelegates) {
        [self.routerDelegates removeObject:router];
    }
}

#pragma mark - handle URL

+ (BOOL)canHandleOpenURL:(NSURL *)url
{
    return [[self sharedMessage] __routerDelegatesCanHandleOpenURL:url];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [[self sharedMessage] __routerDelegatesHandleOpenURL:url];
}

#pragma mark - Traverse Router Delegates

#define MSG_ROUTER_CLS(cls) ((Class<TTMessageRouteProtocol>)cls)

- (BOOL)__routerDelegatesCanHandleOpenURL:(NSURL *)url
{
    if (!url) return NO;
    
    BOOL canHandled = NO;
    NSArray<id<TTMessageRouteProtocol>> *referredDelegates = [self.routerDelegates allObjects];
    for (id<TTMessageRouteProtocol> delegate in referredDelegates) {
        Class cls = (Class)[(id)delegate class];
        if (!cls || ![cls conformsToProtocol:@protocol(TTMessageRouteProtocol)]) continue;
        if ([cls respondsToSelector:@selector(canHandleOpenURL:)]) {
            canHandled = [MSG_ROUTER_CLS(cls) canHandleOpenURL:url];
        }
        if (canHandled) break;
    }
    
    return canHandled;
}

- (BOOL)__routerDelegatesHandleOpenURL:(NSURL *)url
{
    if (!url) return NO;
    
    BOOL canHandled = NO;
    NSArray<id<TTMessageRouteProtocol>> *referredDelegates = [self.routerDelegates allObjects];
    for (id<TTMessageRouteProtocol> delegate in referredDelegates) {
        Class cls = (Class)[(id)delegate class];
        if (!cls || ![cls conformsToProtocol:@protocol(TTMessageRouteProtocol)]) continue;
        if ([cls respondsToSelector:@selector(handleOpenURL:)]) {
            canHandled = [MSG_ROUTER_CLS(cls) handleOpenURL:url];
        }
        if (canHandled) break;
    }
    
    return canHandled;
}

#pragma mark - Getter/Setter

- (NSHashTable<id<TTMessageRouteProtocol>> *)routerDelegates
{
    if (!_routerDelegates) {
        _routerDelegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    }
    return _routerDelegates;
}

@end
