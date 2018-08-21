//
//  TTAccountNewSessionTask.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/26/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountNewSessionTask.h"
#import "TTAModelling.h"
#import "TTAccountRespModel.h"
#import "TTAccountNetworkManager.h"
#import "TTAccount.h"
#import "TTAccountUserEntity_Priv.h"
#import "TTAccountConfiguration_Priv.h"
#import "TTAccountURLSetting.h"
#import "TTAccountMulticastDispatcher.h"
#import "TTAccountLogDispatcher.h"



@implementation TTAccountNewSessionTask

#pragma mark - 请求新的回话
+ (id<TTAccountSessionTask>)requestNewSessionWithSessionKey:(NSString *)sessionKey
                                                  installId:(NSString *)installId
                                                 completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock
{
    if (!sessionKey || !installId) {
        NSDictionary *requiredParams = [[TTAccount accountConf] tta_appRequiredParameters];
        if (!sessionKey) sessionKey = [requiredParams valueForKey:TTAccountFromSessionKeyKey];
        if (!installId)  installId  = [requiredParams valueForKey:TTAccountInstallIdKey];
    }
    
    if (!sessionKey || !installId) {
        if (completedBlock) {
            NSError *paramError =
            [NSError errorWithDomain:TTAccountErrorDomain
                                code:TTAccountErrCodeClientParamsInvalid
                            userInfo:@{
                                       TTAccountErrMsgKey: @"from_session_key or from_install_id is nil"
                                       }];
            completedBlock(nil, paramError);
        }
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:sessionKey forKey:@"from_session_key"];
    [params setValue:installId forKey:@"from_install_id"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTARequestNewSessionURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTARequestNewSessionRespModel *aModel = [TTARequestNewSessionRespModel tta_modelWithJSON:jsonObj];
        TTAccountUserEntity *user = error ? nil : [[TTAccountUserEntity alloc] initWithUserModel:aModel.data];
        
        TTAccountStatusChangedReasonType reasonType = TTAccountStatusChangedReasonTypeSessionKeyLogin;
        
        if (error) {
            if (completedBlock) {
                completedBlock(nil, error);
            }
            
            [TTAccountLogDispatcher dispatchAccountLoginFailureWithReason:reasonType platform:nil];
            
            return;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setUser:)]) {
            [[TTAccount sharedAccount] performSelector:@selector(setUser:) withObject:user];
        }
        
        if ([[TTAccount sharedAccount] respondsToSelector:@selector(setIsLogin:)]) {
            [[TTAccount sharedAccount] setIsLogin:YES];
        }
#pragma clang diagnostic pop
        
        [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:user platform:nil reason:reasonType bisectBlock:^{
            if (completedBlock) {
                completedBlock(user, nil);
            }
        }];
        
        // logger
        [TTAccountLogDispatcher dispatchAccountLoginSuccessWithReason:reasonType platform:nil];
    }];
}

@end
