//
//  ArticleBadgeManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-5-24.
//
//
//  用于管理头条badge的请求

#import <Foundation/Foundation.h>
#import "SSUserModel.h"

//badge数刷新notification, 约定在主线程抛出
#define kArticleBadgeManagerRefreshedNotification @"kArticleBadgeManagerRefreshedNotification"
#define kCategoryBadgeChangeNotification @"kCategoryBadgeChangeNotification"

@interface ArticleBadgeManager : NSObject

@property(nonatomic, retain, readonly)NSNumber * settingNewNumber;//设置更新的数字
@property(nonatomic, retain, readonly)NSNumber * followNumber;//5.5我的关注更新数字
@property(nonatomic, strong, readonly)NSNumber * messageNotificationNumber;//新版消息通知更新数字
@property(nonatomic, strong, readonly)NSNumber * privateLetterUnreadNumber;//私信未读数
@property(nonatomic, retain, readonly)NSNumber * subscribeHasNewUpdatesIndicator;

+ (ArticleBadgeManager *)shareManger;

- (void)startFetch;
//请求接口，刷新我的关注的更新数据
- (void)refreshFollowNumber;

- (void)clearSubscribeHasNewUpdatesIndicator;

//更新关注tab badge
- (void)refreshWithFollowNumber:(NSInteger)followNumber;
//清除我的关注的更新数量
- (void)clearFollowNumber;

@end
