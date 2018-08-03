//
//  AWEVideoPlayAccountBridge.h
//  Pods
//
//  Created by 01 on 18/11/2016.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWEVideoPlayAccountBridge : NSObject

+ (void)registerLoginResultListener;

+ (void)registerLogoutResultListener;

+ (BOOL)isCurrentLoginUser:(NSString *)userId;

+ (BOOL)isLogin;

+ (void)checkin;

+ (void)checkout;

+ (void)fetchTTAccount;

+ (void)fetchTTAccountWithCompletion:(nullable void(^)(BOOL success))completion;

+ (void)showLoginView;

+ (NSString *)currentLoginUserId;

@end

NS_ASSUME_NONNULL_END
