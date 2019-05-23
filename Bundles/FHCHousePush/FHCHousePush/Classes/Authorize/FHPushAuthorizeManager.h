//
//  FHPushAuthorizeManager.h
//  FHCHousePush
//
//  Created by 张静 on 2019/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHPushAuthorizeManager : NSObject

+ (void)showArticleAlertIfNeeded:(NSDictionary *)params;
+ (void)showFollowAlertIfNeeded:(NSDictionary *)params;
+ (BOOL)isFollowAlertEnabled;
+ (BOOL)isMessageTipEnabled;
+ (BOOL)isAPNSEnabled;

@end

NS_ASSUME_NONNULL_END
