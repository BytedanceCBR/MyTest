//
//  AccountKeyChainManager.m
//  Article
//
//  Created by Dianwei on 13-5-12.
//
//

#import "AccountKeyChainManager.h"
#import "SSkeyChainStorage.h"
#import "SSCookieManager.h"
#import <TTInstallService/TTInstallIDManager.h>
#import <TTSandBoxHelper.h>
#import "TTAccountManager.h"



@interface AccountKeyChainManager ()
<
TTAccountMulticastProtocol
>
@end

@implementation AccountKeyChainManager

static AccountKeyChainManager *s_manager;
+ (AccountKeyChainManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[AccountKeyChainManager alloc] init];
    });
    
    return s_manager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)start
{
    [TTAccount addMulticastDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(installIDAvailable:)
                                                 name:kGetInstallIDSucceedNotification
                                               object:nil];
    
}

#pragma mark - TAccountMulticastProtocol

- (void)onAccountGetUserInfo
{
    if ([TTAccountManager isLogin]) {
        NSMutableDictionary *account = [NSMutableDictionary dictionaryWithDictionary:[SSkeyChainStorage objectForKey:@"account"]];
        [account setValue:@NO forKey:@"is_expired"];
        [account setValue:[SSCookieManager sessionIDFromCookie] forKey:@"session_id"];
        
        [SSkeyChainStorage setObject:account key:@"account"];
    }
}

- (void)onAccountSessionExpired:(NSError *)error
{
    NSMutableDictionary *account = [NSMutableDictionary dictionaryWithDictionary:[SSkeyChainStorage objectForKey:@"account"]];
    [account setObject:@YES forKey:@"is_expired"];
    [SSkeyChainStorage setObject:account key:@"account"];
}

- (NSDictionary *)accountFromKeychain
{
    return [SSkeyChainStorage objectForKey:@"account"];
}

- (void)installIDAvailable:(NSNotification *)notification
{
    NSMutableDictionary *account = [NSMutableDictionary dictionaryWithDictionary:[SSkeyChainStorage objectForKey:@"account"]];
    [account setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    [account setValue:[TTSandBoxHelper bundleIdentifier] forKey:@"bundle_id"];
    
    [SSkeyChainStorage setObject:account key:@"account"];
}

@end
