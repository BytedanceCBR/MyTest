//
//  TTAccountMulticast.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/25/17.
//
//

#import "TTAccountMulticast.h"
#import "TTAccountMulticast+Internal.h"
#import "TTAccount.h"
#import <objc/runtime.h>



@interface TTAccountMulticast()

@property (nonatomic, strong) NSHashTable<NSObject<TTAccountMulticastProtocol> *> *delegates;

@end

@implementation TTAccountMulticast

- (instancetype)init
{
    if ((self = [super init])) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static TTAccountMulticast *sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

- (void)registerDelegate:(NSObject<TTAccountMulticastProtocol> *)delegate
{
    if (!delegate) return;
    if (![delegate conformsToProtocol:@protocol(TTAccountMulticastProtocol)]) {
        BOOL success = class_addProtocol([delegate class], @protocol(TTAccountMulticastProtocol));
        if (!success) {
            TTALogE(@"SEL: [%@] failure", NSStringFromSelector(_cmd));
        }
    }
    @synchronized (self.delegates) {
        [self.delegates addObject:delegate];
    }
}

- (void)unregisterDelegate:(NSObject<TTAccountMulticastProtocol> *)delegate
{
    if (!delegate) return;
    @synchronized (self.delegates) {
        [self.delegates removeObject:delegate];
    }
}

- (void)broadcastAccountProfileChanged:(NSDictionary *)changedFields
                                 error:(NSError *)error
{
    tta_dispatch_async_main_thread_safe(^{
        NSArray<id<TTAccountMulticastProtocol>> *referredDelegates = [self.delegates allObjects];
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountUserProfileChanged:error:)]) {
                [delegate onAccountUserProfileChanged:changedFields error:error];
            }
        }
    });
}

- (void)broadcastAccountSessionExpired:(NSError *)error
{
    tta_dispatch_async_main_thread_safe(^{
        NSArray<id<TTAccountMulticastProtocol>> *referredDelegates = [self.delegates allObjects];
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountSessionExpired:)]) {
                [delegate onAccountSessionExpired:error];
            }
        }
        
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountStatusChanged:platform:)]) {
                [delegate onAccountStatusChanged:TTAccountStatusChangedReasonTypeSessionExpiration platform:nil];
            }
        }
    });
}

- (void)broadcastLoginSuccess:(TTAccountUserEntity *)user
                     platform:(NSString *)platformName
                       reason:(TTAccountStatusChangedReasonType)reasonType
{
    tta_dispatch_async_main_thread_safe(^{
        NSArray<id<TTAccountMulticastProtocol>> *referredDelegates = [self.delegates allObjects];
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountLogin)]) {
                [delegate onAccountLogin];
            }
        }
        
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountStatusChanged:platform:)]) {
                [delegate onAccountStatusChanged:reasonType platform:platformName];
            }
        }
    });
}

- (void)broadcastLogout
{
    tta_dispatch_async_main_thread_safe(^{
        NSArray<id<TTAccountMulticastProtocol>> *referredDelegates = [self.delegates allObjects];
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountLogout)]) {
                [delegate onAccountLogout];
            }
        }
        
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountStatusChanged:platform:)]) {
                [delegate onAccountStatusChanged:TTAccountStatusChangedReasonTypeLogout platform:nil];
            }
        }
    });
}

- (void)broadcastGetUserInfo
{
    tta_dispatch_async_main_thread_safe(^{
        NSArray<id<TTAccountMulticastProtocol>> *referredDelegates = [self.delegates allObjects];
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountGetUserInfo)]) {
                [delegate onAccountGetUserInfo];
            }
        }
    });
}

- (void)broadcastLoginAccountAuthPlatform:(NSString *)platformName
                                    error:(NSError *)error
{
    tta_dispatch_async_main_thread_safe(^{
        NSArray<id<TTAccountMulticastProtocol>> *referredDelegates = [self.delegates allObjects];
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountAuthPlatformStatusChanged:platform:error:)]) {
                [delegate onAccountAuthPlatformStatusChanged:TTAccountAuthPlatformStatusChangedReasonTypeLogin platform:platformName error:error];
            }
        }
    });
}

- (void)broadcastLogoutAccountAuthPlatform:(NSString *)platformName
                                     error:(NSError *)error
{
    tta_dispatch_async_main_thread_safe(^{
        NSArray<id<TTAccountMulticastProtocol>> *referredDelegates = [self.delegates allObjects];
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountAuthPlatformStatusChanged:platform:error:)]) {
                [delegate onAccountAuthPlatformStatusChanged:TTAccountAuthPlatformStatusChangedReasonTypeLogout platform:platformName error:error];
            }
        }
    });
}

- (void)broadcastExpireAccountAuthPlatform:(NSString *)platformName
                                     error:(NSError *)error
{
    tta_dispatch_async_main_thread_safe(^{
        NSArray<id<TTAccountMulticastProtocol>> *referredDelegates = [self.delegates allObjects];
        for (id<TTAccountMulticastProtocol> delegate in referredDelegates) {
            if ([delegate respondsToSelector:@selector(onAccountAuthPlatformStatusChanged:platform:error:)]) {
                [delegate onAccountAuthPlatformStatusChanged:TTAccountAuthPlatformStatusChangedReasonTypeExpiration platform:platformName error:error];
            }
        }
    });
}

@end
