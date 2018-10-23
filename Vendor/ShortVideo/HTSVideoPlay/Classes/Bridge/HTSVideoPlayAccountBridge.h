//
//  HTSVideoPlayAccountBridge.h
//  Pods
//
//  Created by SongLi.02 on 18/11/2016.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTSVideoPlayUserModel;
@interface HTSVideoPlayAccountBridge : NSObject

+ (void)registerLoginResultListener;

+ (void)registerLoginResultListenerWithListenr:(id)listerner object:(nullable id)object completion:(void(^)(BOOL success))completion;

+ (void)removeLoginResultListenerWithListner:(id)listerner;

+ (void)registerLogoutResultListener;

+ (void)loginHotsoon;

+ (BOOL)isCurrentLoginUser:(NSString *)userId;

+ (BOOL)isLogin;

+ (void)showLoginView;

+ (NSString *)currentLoginUserId;

+ (HTSVideoPlayUserModel *)currentLoginUser;

+ (void)clearLoginUser;

@end

NS_ASSUME_NONNULL_END
