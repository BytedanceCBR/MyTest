//
//  TTAccountManager+AccountUserSynchronization.m
//  Article
//
//  Created by liuzuopeng on 28/05/2017.
//
//

#import "TTAccountManager.h"
#import "TTAccountLoginManager.h"
#import "AccountKeyChainManager.h"
#import "FHMainApi.h"
#import "FHUserInfoModel.h"
#import "FHUserInfoManager.h"

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
        [TTAccount getUserInfoWithScene:TTAccountRequestNormal completion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
            
            __block NSError *backError = error;
            Class cls = NSClassFromString(@"FHUserInfoModel");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                //参考 TTAccountLoggerImp 赋值 FHUserInfoManager 单例中的
                //userInfo 对象
                NSMutableDictionary *userDict = [userEntity toDictionary].mutableCopy;
                if (userEntity.expendAttrs) {
                    [userDict addEntriesFromDictionary:userEntity.expendAttrs];
                }
                if (userDict) {
                    NSDictionary *dataDict = @{@"data" : userDict};
                    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&backError];
                    id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:data class:cls error:&backError];
                    if(!backError && [model isKindOfClass:[FHUserInfoModel class]]){
                        [FHUserInfoManager sharedInstance].userInfo = (FHUserInfoModel *)model;
                    }
                }
            });
            
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:error.description forKey:@"error_description"];
            [extra setValue:@(error.code) forKey:@"error_code"];
            
            NSString *msg = [self.class suggestExipredWifiString:error];
            if (isEmptyString(msg)) {
                msg = [[error userInfo] objectForKey:TTAccountErrMsgKey];
                if(isEmptyString(msg)) msg = NSLocalizedString(@"登录失败或账号过期，请选择账号重新登录", nil);
            }
            if(displayExpirationError) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
        }];
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
    }
}

+ (BOOL)tryAssignAccountInfoFromKeychain
{
    BOOL result = NO;
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


