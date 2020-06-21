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
#import <TTBaseLib/TTSandBoxHelper.h>
#import "TTAccountManager.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>


@interface AccountKeyChainManager ()
<
TTAccountMulticastProtocol
>

@property (nonatomic, strong) dispatch_queue_t asynQueue;

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
        self.asynQueue = dispatch_queue_create("com.TTNewsAccountBusiness.AccountKeyChainManager", NULL);
    }
    return self;
}

- (void)start
{
    [TTAccount addMulticastDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(installIDAvailable:)
                                                 name:TTInstallDeviceDidRegisteredNotification
                                               object:nil];
    
}

#pragma mark - TAccountMulticastProtocol

- (void)onAccountGetUserInfo
{
    if ([TTAccountManager isLogin]) {
        dispatch_async(self.asynQueue, ^{
            NSMutableDictionary *account = [NSMutableDictionary dictionaryWithDictionary:[SSkeyChainStorage objectForKey:@"account"]];
            [account setValue:@NO forKey:@"is_expired"];
            [account setValue:[SSCookieManager sessionIDFromCookie] forKey:@"session_id"];

            [SSkeyChainStorage setObject:account key:@"account"];
        });
    }
}

- (void)onAccountSessionExpired:(NSError *)error
{
    dispatch_async(self.asynQueue, ^{
        NSMutableDictionary *account = [NSMutableDictionary dictionaryWithDictionary:[SSkeyChainStorage objectForKey:@"account"]];
        [account setObject:@YES forKey:@"is_expired"];
        [SSkeyChainStorage setObject:account key:@"account"];
    });

}

- (NSDictionary *)accountFromKeychain
{
    return [SSkeyChainStorage objectForKey:@"account"];
}

- (void)installIDAvailable:(NSNotification *)notification
{
    dispatch_async(self.asynQueue, ^{
        NSMutableDictionary *account = [NSMutableDictionary dictionaryWithDictionary:[SSkeyChainStorage objectForKey:@"account"]];
        [account setValue:[BDTrackerProtocol deviceID] forKey:@"device_id"];
        [account setValue:[TTSandBoxHelper bundleIdentifier] forKey:@"bundle_id"];

        [SSkeyChainStorage  setObject:account key:@"account"];
    });
}

@end
