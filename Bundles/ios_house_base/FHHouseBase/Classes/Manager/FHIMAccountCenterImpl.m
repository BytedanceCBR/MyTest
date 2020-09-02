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
#import "TTAccountLoginManager.h"
#import "FHLoginViewController.h"

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

-(void)showAlertFLoginVCWithParams:(NSDictionary *)params completeBlock:(FHIMAccountAlertCompletionBlock)complete {
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        
        if(complete) {
            FHIMAccountAlertCompletionEventType imType = (FHIMAccountAlertCompletionEventType)type;
            complete(imType, phoneNum);
        }
    }];
}

- (void)popupHalfLoginIfNeed:(UIViewController *)vc params:(NSDictionary *)dict{
    if(![TTAccount sharedAccount].isLogin) {
        NSURL *URL = [NSURL URLWithString:@"sslocal://flogin"];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:dict];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:params];
        TTRouteObject *routeObj = [[TTRoute sharedRoute] routeObjWithOpenURL:URL userInfo:userInfo];
        FHLoginViewController *loginVC = routeObj.instance;
        
        [loginVC supportCarrierLogin:^(BOOL isSupport) {
            if(isSupport) {
                [loginVC showHalfLogin:vc];
            }
        }];
    }
}

- (NSString *)currentUserAvatar {
    return [TTAccount sharedAccount].user.avatarURL;
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

/// 用户帐号会话过期，按登出处理
/// @param error 过期原因
- (void)onAccountSessionExpired:(NSError *)error {
    id<AccountStatusListener> listener = _observerMulticast;
    [listener didLogout];
}
@end
