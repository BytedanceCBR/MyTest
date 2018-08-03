//
//  TTIMManager.m
//  Article
//
//  Created by matrixzk on 28/03/2017.
//
//

#import "TTIMManager.h"
#import "TTIMSDKService.h"
#import "TTInstallIDManager.h"
#import "TTIMSDKOptions.h"
#import "TTNetworkManager.h"
#import "TTPushService.h"
#import <TTAccountBusiness.h>


@interface TTIMManager () <TTIMSDKServiceDelegate, TTAccountMulticastProtocol>
@property (nonatomic, assign) NSInteger getTokenCount;
@property (nonatomic, copy)   NSString  *token;
@end


@implementation TTIMManager
{
    NSUInteger _retryCountOfGetToken;
    BOOL _isGettingToken;
}

@synthesize token = _token;

+ (instancetype)sharedManager
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config
{
    TTIMSDKOptions *options = [TTIMSDKOptions new];
    options.service = 2;
    options.method = 1;
    options.fpid = [kFpId integerValue];
    options.appid = [[TTSandBoxHelper ssAppID] integerValue];
    
#if INHOUSE
    [options updateNetTypeForTest:[SSCommonLogic imCommunicateStrategy]];
#endif
   
    [[TTIMSDKService sharedInstance] configIMServiceWithDeviceId:[[TTInstallIDManager sharedInstance] deviceID]
                                                         options:options];
    _retryCountOfGetToken = 0;
    _isGettingToken = NO;
    _getTokenCount = 0;
}

- (void)reGetTokenWhileTokenInvalid
{
    if (_isGettingToken) return;
    
    if (_retryCountOfGetToken >= 1) return;
    
    _isGettingToken = YES;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[TTAccountManager userID] forKey:@"client_uid"];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting plLoginUrl] params:dic method:@"GET" needCommonParams:YES callback:^(NSError *error,id jsonObj){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *token = nil;
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = [((NSDictionary *)jsonObj) tt_dictionaryValueForKey:@"data"];
                token = [data tt_stringValueForKey:@"token"];
            }
            
            if (!error && token.length > 0) {
                // reset token
                self.token = token;
                [[TTIMSDKService sharedInstance] loginWithToken:token
                                                      accountId:[TTAccountManager userID]];
                _retryCountOfGetToken++;
                
            } else {
                
                _retryCountOfGetToken = 0;
                _getTokenCount++;
                if (_getTokenCount < 10) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        if ([TTAccountManager isLogin]) {
                            [self reGetTokenWhileTokenInvalid];
                        }
                    });
                }
            }
            
            _isGettingToken = NO;
        });
    }];
}


#pragma mark - Public

- (void)logoutIMService
{
    _retryCountOfGetToken = 0;
    _getTokenCount = 0;
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting plLogoutUrl] params:nil method:@"POST" needCommonParams:YES callback:^(NSError *error,id jsonObj){
        
        if (error) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[TTAccountManager setIMToken:nil];
            self.token = nil;
            [[TTIMSDKService sharedInstance] logout];
        });
    }];
}

- (void)loginIMService
{
    if (isEmptyString(self.token)) {
        [[TTIMSDKService sharedInstance] loginWithToken:@""
                                              accountId:[TTAccountManager userID]];
        [self reGetTokenWhileTokenInvalid];
    } else {
        [[TTIMSDKService sharedInstance] loginWithToken:self.token
                                              accountId:[TTAccountManager userID]];
        _retryCountOfGetToken = 0;
    }
}


#pragma mark - TTIMSDKServiceDelegate

// 当发消息时遇到 error 为 token 失效时回调
- (void)ttim_onSendMessageAriseErrorTokenInvalid
{
    [self reGetTokenWhileTokenInvalid];
}

// 当发消息时遇到 error 为设备未绑定时回调
- (void)ttim_onSendMessageAriseErrorDeviceNotBind
{
    [self reGetTokenWhileTokenInvalid];
}

// 当发消息时遇到 error 为该用户非好友时回调
- (void)ttim_onSendMessageAriseErrorUserNotFound
{
}

/// IM服务上线成功
- (void)ttim_onServiceOnlineSucceed
{
    
}

/// IM服务上线失败
- (void)ttim_onServiceOnlineFailed:(IMErrorCode)errorCode
{
    
}

/// IM服务注销成功
- (void)ttim_onServiceOfflineSucceed
{
    
}


#pragma mark - Token

- (void)setToken:(NSString *)token
{
    if ([token isEqualToString:_token]) return;
    
    _token = token;
    [[NSUserDefaults standardUserDefaults] setValue:_token forKey:@"TTIMAccountToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)token
{
    if (!_token) {
        _token = [[NSUserDefaults standardUserDefaults] stringForKey:@"TTIMAccountToken"] ? : @"";
    }
    return _token;
}

@end
