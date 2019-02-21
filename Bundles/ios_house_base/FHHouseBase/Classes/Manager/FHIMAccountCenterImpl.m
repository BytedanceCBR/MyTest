//
//  FHIMAccountCenterImpl.m
//  AFgzipRequestSerializer
//
//  Created by leo on 2019/2/17.
//

#import "FHIMAccountCenterImpl.h"
#import "TTAccount.h"
#import "TTAccount+Multicast.h"
#import "TIMMulticastDelegate.h"
@interface FHIMAccountCenterImpl ()<TTAccountMulticastProtocol>
{
    __weak id<AccountStatusListener> _litener;
}
@property (nonatomic, strong) TIMMulticastDelegate *observerMulticast;
@end

@implementation FHIMAccountCenterImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
        [TTAccount addMulticastDelegate:self];
        _observerMulticast = [[TIMMulticastDelegate alloc] init];
    }
    return self;
}

-(NSString*)currentUserId {
    return [[TTAccount sharedAccount] userIdString];
}

-(BOOL)isUserLogin {
    return [[TTAccount sharedAccount] isLogin];
}

-(void)registerAccountStatusListener:(id<AccountStatusListener>)listener {
    [_observerMulticast addWeakDelegate:listener onQueue:dispatch_get_main_queue()];
}

- (void)dealloc
{
    [TTAccount removeMulticastDelegate:self];
}

#pragma -- TTAccountMulticastProtocol --

/**
 *  登录成功；如果想知道登录成功的Reason，使用onAccountStatusChanged
 */
- (void)onAccountLogin {
    id<AccountStatusListener> listener = _observerMulticast;
    [listener didLogin];
}

/**
 *  登出成功
 */
- (void)onAccountLogout {
    id<AccountStatusListener> listener = _observerMulticast;
    [listener didLogout];
}

@end
