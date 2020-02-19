//
//  FHMineAPI.h
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/13.
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"
#import "FHURLSettings.h"
#import "FHMainApi.h"
#import "TTAccountBusiness.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMineAPI : NSObject

+ (NSString *)host;

+ (void)requestFocusInfoWithCompletion:(void(^_Nullable)(NSDictionary *response , NSError *error))completion;

+ (TTHttpTask *)requestFocusDetailInfoWithType:(NSInteger)type offset:(NSInteger)offset searchId:(nullable NSString *)searchId limit:(NSInteger)limit className:(NSString *)className completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

//发送短信验证码
+ (void)requestSendVerifyCode:(NSString *)phoneNumber captcha:(NSString *_Nullable)captcha completion:(void(^_Nullable)(NSNumber *retryTime, UIImage *captchaImage, NSError *error))completion ;

//登录
+ (void)requestQuickLogin:(NSString *)phoneNumber smsCode:(NSString *)smsCode captcha:(NSString *)captcha completion:(void(^_Nullable)(UIImage *captchaImage, NSNumber *newUser, NSError *error))completion;

+ (NSString *)errorMessageByErrorCode:(NSError *)error;

+ (TTHttpTask *)requestMineConfigWithClassName:(NSString *)className completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

+ (void)uploadUserPhoto:(UIImage *)image completion:(void (^)(NSString *imageURIString, NSError *error))completion;

+ (void)uploadUserProfileInfo:(NSDictionary *)params completion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;

+ (TTHttpTask *)setHomePageAuth:(BOOL)isOn completion:(void (^ _Nonnull)(BOOL success, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
