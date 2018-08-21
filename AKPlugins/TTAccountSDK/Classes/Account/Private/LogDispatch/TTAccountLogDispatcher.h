//
//  TTAccountLogDispatcher.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 13/06/2017.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountDefine.h"



NS_ASSUME_NONNULL_BEGIN

@interface TTAccountLogDispatcher : NSObject

+ (void)dispatchAccountLoginSuccessWithReason:(TTAccountStatusChangedReasonType)reasonType
                                     platform:(NSString *)platformNameString;

+ (void)dispatchAccountLoginFailureWithReason:(TTAccountStatusChangedReasonType)reasonType
                                     platform:(NSString *)platformNameString;

+ (void)dispatchAccountSessionExpired:(NSError *)error
                           withUserID:(NSString *)userIDString;

+ (void)dispatchAccountPlatformExpired:(NSError *)error
                          withPlatform:(NSString *)joinedPlatformString;

+ (void)dispatchAccountLogoutSuccess;

+ (void)dispatchAccountLogoutFailure;

@end

NS_ASSUME_NONNULL_END
