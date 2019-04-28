//
//  ArticleMessageManager.h
//  Article
//
//  Created by Dianwei on 14-5-22.
//
//

#import <Foundation/Foundation.h>

extern NSString *const kGetFollowNumberFinishNofication;
extern NSString *const kGetFollowNumberKey;
extern NSString *const kIsForceGetFollowNumberKey;

@interface ArticleMessageManager : NSObject

+ (instancetype) sharedManager;

/**
 周期性获取消息数
 */
+ (void)startPeriodicalGetFollowNumber;
+ (void)forceRefreshFollowNum;
+ (void)invalidate;

@end
