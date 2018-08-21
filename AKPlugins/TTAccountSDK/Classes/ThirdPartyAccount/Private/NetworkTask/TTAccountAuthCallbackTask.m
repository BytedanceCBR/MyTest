//
//  TTAccountAuthCallbackTask.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/31/17.
//
//

#import "TTAccountAuthCallbackTask.h"
#import "TTAccountURLSetting+Platform.h"
#import "TTAccountDefine.h"



@implementation TTAccountAuthCallbackTask

+ (id<TTAccountSessionTask>)startSNSSDKSSOAuthCallbackWithParams:(NSDictionary *)params
                                                  completedBlock:(void(^)(TTASNSSDKAuthCallbackRespModel *aRespMdl, NSError *error))completedBlock
{
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTASNSSDKAuthCallbackURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSError *modelError = nil;
        TTASNSSDKAuthCallbackRespModel *respModel = [[TTASNSSDKAuthCallbackRespModel alloc] initWithDictionary:jsonObj error:&modelError];
        if (respModel && ![respModel isRespSuccess] && !error) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:respModel.data.error_description forKey:@"error_description"];
            [userInfo setValue:respModel.data.dialog_tips forKey:@"dialog_tips"];
            [userInfo setValue:respModel.data.auth_token forKey:@"auth_token"];
            error = [NSError errorWithDomain:TTAccountErrorDomain code:respModel.errorCode userInfo:userInfo];
        }
        
        if (completedBlock) {
            completedBlock(respModel, error ? : modelError);
        }
    }];
}



/**
 *  解绑以前通过OAuth绑定的第三方平台
 */
+ (id<TTAccountSessionTask>)startSNSSDKAuthSwitchBindWithReq:(TTASNSSDKAuthSwitchBindReqModel *)reqMdl
                                              completedBlock:(void(^)(TTASNSSDKAuthSwitchBindRespModel *aRespMdl, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:reqMdl.auth_token forKey:@"auth_token"];
    [params setValue:reqMdl.code forKey:@"code"];
    [params setValue:reqMdl.platform forKey:@"platform"];
    [params setValue:reqMdl.mid forKey:@"mid"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTASNSSDKSwitchBindURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        TTASNSSDKAuthSwitchBindRespModel *aModel = [TTASNSSDKAuthSwitchBindRespModel tta_modelWithJSON:jsonObj];
        if (completedBlock) {
            completedBlock(aModel, error);
        }
    }];
}



/**
 *  解绑以前通过OAuth-WAP绑定的第三方平台(/2/auth/login_continue/)
 */
+ (id<TTAccountSessionTask>)startWAPAuthSwitchBindWithReq:(TTACustomWAPAuthSwitchBindReqModel *)reqMdl
                                           completedBlock:(void(^)(TTACustomWAPAuthSwitchBindRespModel *aRespMdl, NSError *error, NSInteger httpStatusCode))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:reqMdl.auth_token forKey:@"auth_token"];
    [params setValue:reqMdl.platform forKey:@"platform"];
    [params setValue:reqMdl.mid forKey:@"mid"];
    [params setValue:@(reqMdl.unbind_exist) forKey:@"unbind_exist"];
    
    return [TTAccountNetworkManager requestForJSONWithURL:[TTAccountURLSetting TTACustomWAPLoginContinueURLString] method:@"POST" params:params extraGetParams:nil needCommonParams:YES follow302Redirect:NO callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
        
        TTACustomWAPAuthSwitchBindRespModel *aModel = [TTACustomWAPAuthSwitchBindRespModel tta_modelWithJSON:jsonObj];
        if (completedBlock) {
            completedBlock(aModel, error, response.statusCode);
        }
    }];
    
//    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTACustomWAPLoginContinueURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
//
//        TTACustomWAPAuthSwitchBindRespModel *aModel = [TTACustomWAPAuthSwitchBindRespModel tta_modelWithJSON:jsonObj];
//        if(completedBlock) {
//            completedBlock(aModel, error);
//        }
//    }];
}



#pragma mark - share app to sns platform

+ (id<TTAccountSessionTask>)shareAppToSNSPlatform:(NSString *)platformString
                                   completedBlock:(void (^)(BOOL success, NSError *error))completedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:platformString forKey:@"platform"];
    
    return [TTAccountNetworkManager postRequestForJSONWithURL:[TTAccountURLSetting TTAShareAppToSNSPlatformURLString] params:params needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        TTShareAppToSNSPlatformRespModel *aModel = [TTShareAppToSNSPlatformRespModel tta_modelWithJSON:jsonObj];
        if (completedBlock) {
            completedBlock(([aModel isRespSuccess] && !error), error);
        }
    }];
}

@end
