//
//  TTAccount+Notifications.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccount+Notifications.h"
//#import <TTNetworkReachabilityManager.h>
#import <TTReachability.h>
#import "TTAccount+NetworkTasks.h"
#import "TTAccountURLSetting.h"
#import "TTAccount.h"
#import "TTAccountConfiguration_Priv.h"
#import "NSString+TTAccountUtils.h"
#import "TTAModelling.h"
#import "TTAccountRespModel.h"
#import "TTAccountUserEntity_Priv.h"
#import "TTAccountNoDispatchJSONResponseSerializer.h"
#import "TTAccountMulticastDispatcher.h"



#pragma mark - TTAccount (AppLaunchHelper)

@implementation TTAccount (AppLaunchHelper)

static NSString * const kTTAccountIsAPPFirstInstallKey = @"kTTAccountIsAPPFirstInstallKey";

+ (BOOL)isAPPFirstInstall
{
    BOOL isFirst = NO;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kTTAccountIsAPPFirstInstallKey]) {
        isFirst = YES;
    } else {
        isFirst = [[NSUserDefaults standardUserDefaults] boolForKey:kTTAccountIsAPPFirstInstallKey];
    }
    return isFirst;
}

+ (void)setAPPHasInstalled
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTAccountIsAPPFirstInstallKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


static NSString *kTTAccountHasTryKeyChainSessionKeyLogin = @"com.toutiao.account.is_keychain_sessionkey_login";

+ (BOOL)isSucceedInRequestingNewSessionLogin
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTAccountHasTryKeyChainSessionKeyLogin];
}

+ (void)setIsSucceedInRequestingNewSessionLogin:(BOOL)success
{
    [[NSUserDefaults standardUserDefaults] setBool:success forKey:kTTAccountHasTryKeyChainSessionKeyLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


static NSString *kTTAccountHasSynchronizeAccountUserStatusByNetwork = @"com.toutiao.account.synchronize_account_user_status_by_network";

+ (BOOL)isSuccceedInSynchronizingAccountUserStatus
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTAccountHasSynchronizeAccountUserStatusByNetwork];
}

+ (void)setIsSucceedInSynchronizingAccountUserStatus:(BOOL)success
{
    [[NSUserDefaults standardUserDefaults] setBool:success forKey:kTTAccountHasSynchronizeAccountUserStatusByNetwork];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end



#pragma mark - TTAccount (Notifications)

@implementation TTAccount (Notifications)

- (void)__registerNotifications__
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
}

- (void)__unregisterNotifications__
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidFinishLaunchingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

#pragma mark - events of Notification

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(clearMemory)]) {
        [self performSelector:@selector(clearMemory)];
    }
#pragma clang diagnostic pop
}

/**
 *  每次APP启动的时候，都会请求并同步用户信息
 */
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    BOOL isFirstInstall __unused = [self.class isAPPFirstInstall];
    BOOL logined = [self isLogin];
    
    // 每次APP启动，未登录通过同步用户信息尝试登录
    if (logined) {
        [self.class setIsSucceedInSynchronizingAccountUserStatus:YES];
        [self autoSynchronizeAccountUserInfo];
    } else {
        // 为了防止本地登录状态丢失，每次APP冷启动，尝试与服务端同步一次
        [self.class setIsSucceedInSynchronizingAccountUserStatus:NO];
        [self autoSynchronizeLoginStatusIfNeeded];
    }
    
    [self.class setAPPHasInstalled];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if ([self isLogin]) {
        [self autoSynchronizeAccountUserInfo];
    } else {
        [self autoSynchronizeLoginStatusIfNeeded];
    }
}

#pragma mark - 自动同步用户登录状态

- (void)autoSynchronizeLoginStatusIfNeeded
{
    if ([self isLogin]) return;
    
    NSString *sessionId = [self sessionKey];
    if ([sessionId length] > 0) {
        if ([[TTAccount accountConf].sharingKeyChainGroup length] > 0 && ![self.class isSucceedInRequestingNewSessionLogin]) {
            // 未登录且sessionKey存在，首次安装或者未通过keychain中sessionKey登录时，尝试requestNewSession进行登录
            [self.class requestNewSessionWithSessionKey:sessionId installId:nil completion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
                if (!error) {
                    [self.class setIsSucceedInRequestingNewSessionLogin:YES];
                }
            }];
        } else {
            [self.class synchronizeAccountUserStatusByNetwork:nil waitUntilDone:NO];
        }
    }
}

#pragma mark - 当首次启动或者从后台进入前台时，通过UserInfo接口实现同步用户信息

- (void)autoSynchronizeAccountUserInfo
{
    if (![TTAccount accountConf].autoSynchronizeUserInfo) return;
    if (![[TTAccount sharedAccount] isLogin]) return;
    
    [TTAccount getUserInfoIgnoreDispatchWithCompletion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
        
    }];
}

#pragma mark - 通过请求User/Info接口实现同步登录

static BOOL s_isSynchronizingAccountUserByNetwork = NO;

+ (void)synchronizeAccountUserStatusByNetwork:(void (^)(BOOL loggedOnCurrently))completedBlock
                                waitUntilDone:(BOOL)wait
{
    // 申请同步用户信息时，判断是否存在任务正在同步账号用户，若存在直接返回
    if (s_isSynchronizingAccountUserByNetwork) {
        if (completedBlock) completedBlock(NO);
        return;
    }
    
    // 是否已经同步过账号用户信息
    if ([self.class isSuccceedInSynchronizingAccountUserStatus]) {
        if (completedBlock) completedBlock(NO);
        return;
    }
    
    s_isSynchronizingAccountUserByNetwork = YES;
    
    if (wait) {
        /**
         *  未登录，两种情况进入该逻辑：
         *      1. 第一次安装
         *      2. NSUserDefault中信息丢失
         *  防止这样情况发生，需要首先和服务器确认；
         */
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_queue_t queue = dispatch_queue_create("com.toutiao.account.launch_get_user_profile.queue", NULL);
        dispatch_async(queue, ^(void) {
            NSTimeInterval requestTimeout = 3.f;
            
            NSDictionary *commonNetParams = [[TTAccount accountConf] tta_commonNetworkParameters];
            
            NSURL *requestURL = [[TTAccountURLSetting TTAGetUserInfoURLString] tta_URLByAppendQueryItems:commonNetParams];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:requestTimeout];
            [request setHTTPMethod:@"GET"];
            
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                [self.class handleAccountUserNetworkSynchronization:completedBlock jsonData:data error:error originalURL:requestURL];
                
                // 唤醒
                dispatch_semaphore_signal(semaphore);
                
            }];
            
            [task resume];
        });
        
        // 阻塞并等待同步执行完成
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    } else {
        // 异步请求
        dispatch_queue_t queue = dispatch_queue_create("com.toutiao.account.launch_get_user_profile.queue", NULL);
        dispatch_async(queue, ^(void) {
            NSTimeInterval requestTimeout = 3.f;
            
            NSDictionary *commonNetParams = [[TTAccount accountConf] tta_commonNetworkParameters];
            
            NSURL *requestURL = [[TTAccountURLSetting TTAGetUserInfoURLString] tta_URLByAppendQueryItems:commonNetParams];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:requestTimeout];
            [request setHTTPMethod:@"GET"];
            
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                [self.class handleAccountUserNetworkSynchronization:completedBlock jsonData:data error:error originalURL:requestURL];
                
            }];
            
            [task resume];
        });
    }
}

+ (void)handleAccountUserNetworkSynchronization:(void (^)(BOOL loggedOnCurrently))completedBlock
                                       jsonData:(id)data
                                          error:(NSError *)error
                                    originalURL:(NSURL *)reqURL
{
    if (!error) {
        NSError *parseServerError = nil;
        [TTAccountNoDispatchJSONResponseSerializer handleResponseResult:data responseError:nil resultError:&parseServerError originalURL:reqURL];
        error = parseServerError;
    }
    
    if (error && (labs(error.code) >= 500 && labs(error.code) < 600)) {
        // 服务端错误，过滤掉
        
    } else {
        [self.class setIsSucceedInSynchronizingAccountUserStatus:YES];
    }
    
    TTAUserRespModel *aModel  = [TTAUserRespModel tta_modelWithJSON:data];
    TTAccountUserEntity *user = nil;
    
    if (!error && [aModel isRespSuccess]) {
        user = [[TTAccountUserEntity alloc] initWithUserModel:aModel.data];
    }
    
    // synchronize user info
    if (user) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
            [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:user];
        }
        
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:YES];
        }
#pragma clang diagnostic pop
    }
    else if (error && error.code == TTAccountErrCodeSessionExpired) {
        // 登录过期
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:NO];
        }
#pragma clang diagnostic pop
    }
    
    if (user) {
        [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:user platform:nil reason:TTAccountStatusChangedReasonTypeAutoSyncLogin bisectBlock:^{
            // callback
            if (completedBlock) {
                completedBlock(!error && [aModel isRespSuccess] && user);
            }
        } wait:NO];
    } else {
        // callback
        if (completedBlock) {
            completedBlock(!error && [aModel isRespSuccess] && user);
        }
    }
    
    // -1001表示是否是网络请求超时
    if (error && (error.code != -1001) && [TTReachability isNetworkConnected]) {
        // error not nil, and network available
        
    }
    
    s_isSynchronizingAccountUserByNetwork = NO;
}

@end
