//
//  TTAccountManager+AccountUserSynchronization.m
//  Article
//
//  Created by liuzuopeng on 28/05/2017.
//
//

#import "TTAccountManager.h"
#import <TTAccountLoginManager.h>
#import "AccountKeyChainManager.h"



@implementation TTAccountManager (AccountUserSynchronization)

+ (NSString *)suggestExipredWifiString:(NSError *)error
{
    NSString *msgString = nil;
    if((!error || error.code == 1003 /* kSessionExpiredErrorCode */ ||
        error.code == TTAccountErrCodeSessionExpired)) {
        msgString = NSLocalizedString(@"获取授权信息出错，建议在WiFi下尝试", nil);
    }
    return msgString;
}

+ (void)startGetAccountStatus:(BOOL)displayExpirationError
{
    [[self class] startGetAccountStatus:displayExpirationError context:nil];
}

+ (void)startGetAccountStatus:(BOOL)displayExpirationError context:(id)context
{
    if ([[TTAccount sharedAccount] isLogin]) {
//        [TTAccount getUserInfoWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
//            if (error) {
//                NSMutableDictionary *extra = [NSMutableDictionary dictionary];
//                [extra setValue:error.description forKey:@"error_description"];
//                [extra setValue:@(error.code) forKey:@"error_code"];
//
//                NSString *msg = [self.class suggestExipredWifiString:error];
//                if (isEmptyString(msg)) {
//                    msg = [[error userInfo] objectForKey:TTAccountErrMsgKey];
//                    if(isEmptyString(msg)) msg = NSLocalizedString(@"登录失败或账号过期，请选择账号重新登录", nil);
//                }
//                if(displayExpirationError) {
//                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
//                }
//            }
//        }];
//
        [TTAccount getUserAuditInfoWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            
        }];
    }
}

+ (BOOL)tryAssignAccountInfoFromKeychain
{
    BOOL result = NO;
#warning NewAccount @zuopengliu
    //    NSDictionary *account = [[AccountKeyChainManager sharedManager] accountFromKeychain];
    //    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasAssignedInfoFromKeychain] && ![TTAccountManager isLogin]
    //       && [account objectForKey:@"session_id"]) {
    //        if(![[account objectForKey:@"bundle_id"] isEqualToString:[TTSandBoxHelper bundleIdentifier]] && account.count > 0 && ![[account objectForKey:@"is_expired"] boolValue])
    //        {
    //            NSString *sessionID = [account objectForKey:@"session_id"];
    //            if(!isEmptyString(sessionID)) [self requestNewSession:account];
    //            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasAssignedInfoFromKeychain];
    //            [[NSUserDefaults standardUserDefaults] synchronize];
    //            result = YES;
    //        }
    //    }
    
    return result;
}

@end


