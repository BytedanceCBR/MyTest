//
//  BDAccountAPIWrapper.m
//  Bubble
//
//  Created by linlin on 2018/7/17.
//  Copyright © 2018年 linlin. All rights reserved.
//

#import "BDAccountAPIWrapper.h"

@implementation BDAccountAPIWrapper
+ (nullable id <BDAccountSessionTask>)requestSMSCodeWithMobile:(NSString *)mobileString
                                                     oldMobile:(NSString *_Nullable)oldPhoneString
                                                   SMSCodeType:(NSInteger)codeType
                                                       captcha:(NSString *_Nullable)captcha
                                                 unbindExisted:(BOOL)unbind
                                                    completion:(void (^)(NSNumber *_Nullable retryTime /* 过期时间 */, UIImage *_Nullable captchaImage, NSError *_Nullable error))completedBlock {
    return [BDAccountNetworkAPI requestSMSCodeWithMobile:mobileString
                                               oldMobile:oldPhoneString
                                             SMSCodeType:codeType
                                           unbindExisted:unbind
                                                 captcha:captcha
                                              completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
                                                  !completedBlock ?: completedBlock(retryTime, captchaImage, error);
                                              }];
}

@end
