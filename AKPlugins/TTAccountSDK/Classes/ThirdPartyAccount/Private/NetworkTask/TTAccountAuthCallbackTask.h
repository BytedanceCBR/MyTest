//
//  TTAccountAuthCallbackTask.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/31/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "TTAccountAuthRespModel.h"
#import "TTAccountAuthReqModel.h"
#import "TTAccountNetworkManager.h"



/**
 *  @Wiki:  https://wiki.bytedance.net/pages/viewpage.action?pageId=13961678
 */
@interface TTAccountAuthCallbackTask : NSObject

#pragma mark - [SNSSDK Auth] sso_callback
/**
 *  使用SNSSDK授权成功后，与头条服务器交互的回调接口
 */
+ (id<TTAccountSessionTask>)startSNSSDKSSOAuthCallbackWithParams:(NSDictionary *)params
                                                  completedBlock:(void(^)(TTASNSSDKAuthCallbackRespModel *aRespMdl, NSError *error))completedBlock;

#pragma mark - [SNSSDK Auth SwitchBind] sso_switch_bind
/**
 *  解绑以前通过OAuth-SNSSDK绑定的第三方平台
 */
+ (id<TTAccountSessionTask>)startSNSSDKAuthSwitchBindWithReq:(TTASNSSDKAuthSwitchBindReqModel *)reqMdl
                                              completedBlock:(void(^)(TTASNSSDKAuthSwitchBindRespModel *aRespMdl, NSError *error))completedBlock;

#pragma mark - [Custom WAP Auth SwitchBind] login_continue
/**
 *  解绑以前通过OAuth-WAP绑定的第三方平台
 */
+ (id<TTAccountSessionTask>)startWAPAuthSwitchBindWithReq:(TTACustomWAPAuthSwitchBindReqModel *)reqMdl
                                           completedBlock:(void(^)(TTACustomWAPAuthSwitchBindRespModel *aRespMdl, NSError *error, NSInteger httpStatusCode))completedBlock;

#pragma mark - share app to sns platform
+ (id<TTAccountSessionTask>)shareAppToSNSPlatform:(NSString *)platformString
                                   completedBlock:(void (^)(BOOL success, NSError *error))completedBlock;

@end
