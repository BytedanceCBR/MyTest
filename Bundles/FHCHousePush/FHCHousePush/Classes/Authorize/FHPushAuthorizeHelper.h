//
//  FHPushAuthorizeHelper.h
//  FHCHousePush
//
//  Created by 张静 on 2019/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHPushAuthorizeHelper : NSObject

+ (void)setLastTimeShowArticleAlert:(NSInteger)lastTimeShowArticleAlert;
+ (NSInteger)lastTimeShowArticleAlert;

+ (void)setLastTimeShowFollowAlert:(NSInteger)lastTimeShowFollowAlert;
+ (NSInteger)lastTimeShowFollowAlert;

+ (void)setLastTimeShowMessageTip:(NSInteger)lastTimeShowMessageTip;
+ (NSInteger)lastTimeShowMessageTip;

@end

NS_ASSUME_NONNULL_END
