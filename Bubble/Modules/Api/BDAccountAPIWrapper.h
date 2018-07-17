//
//  BDAccountAPIWrapper.h
//  Bubble
//
//  Created by linlin on 2018/7/17.
//  Copyright © 2018年 linlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BDAccount/BDAccountSDK.h>
@interface BDAccountAPIWrapper : NSObject
+ (nullable id<BDAccountSessionTask>)requestSMSCodeWithMobile:(NSString *)mobileString
                                                    oldMobile:(NSString * _Nullable)oldPhoneString
                                                  SMSCodeType:(NSInteger)codeType
                                                      captcha:(NSString * _Nullable) captcha
                                                unbindExisted:(BOOL)unbind
                                                   completion:(void(^)(NSNumber * _Nullable retryTime /* 过期时间 */, UIImage * _Nullable captchaImage, NSError * _Nullable error))completedBlock;
@end
