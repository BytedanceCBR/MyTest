//
//  TTUserInfoStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTUserInfoStartupTask.h"
#import <TTAccountBusiness.h>
#import "TTProjectLogicManager.h"
#import "TTAccountTestSettings.h"



@implementation TTUserInfoStartupTask

- (NSString *)taskIdentifier
{
    return @"UserInfo";
}

- (BOOL)isResident
{
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TTAccountManager startGetAccountStatus:NO context:self];
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (!TTLogicBool(@"isI18NVersion", NO)) {
        [TTAccountManager tryAssignAccountInfoFromKeychain];
    }
    
    [self.class getAccountUserInfoWithContext:self];
}

+ (void)getAccountUserInfoWithContext:(id)context
{
    [self.class getAccountUserInfoWithExpirationError:NO context:context];
}

+ (void)getAccountUserInfoWithExpirationError:(BOOL)displayExpirationError
                                      context:(id)context
{
    TTAccountReqUserInfo cond = [TTAccountTestSettings reqUserInfoCond];
    NSTimeInterval delay = [TTAccountTestSettings delayTimeInterval];
    
    switch (cond) {
        case TTAccountReqUserInfoWillEnterForegroundDelayNs: {
            if (delay > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TTAccountManager startGetAccountStatus:displayExpirationError context:context];
                });
            } else {
                [TTAccountManager startGetAccountStatus:displayExpirationError context:context];
            }
        }
            break;
        case TTAccountReqUserInfoWillEnterForegroundDelayNsAndInForeground: {
            if (delay > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                        [TTAccountManager startGetAccountStatus:displayExpirationError context:context];
                    }
                });
            } else {
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    [TTAccountManager startGetAccountStatus:displayExpirationError context:context];
                }
            }
        }
            break;
        case TTAccountReqUserInfoWillEnterForeground:
        default: {
            [TTAccountManager startGetAccountStatus:displayExpirationError context:context];
        }
            break;
    }
}

@end
