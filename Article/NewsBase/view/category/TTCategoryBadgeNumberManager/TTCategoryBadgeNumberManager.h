//
//  TTCategoryBadgeNumberManager.h
//  Article
//
//  Created by 王霖 on 2017/6/5.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TTCategoryBadgeNumberManager;

@protocol TTCategoryBadgeNumberManagerDelegate <NSObject>

- (void)categoryBadgeNumberDidChange:(TTCategoryBadgeNumberManager *)manager
                          categoryID:(NSString *)categoryID
                      hasNotifyPoint:(BOOL)hasNotifyPoint
                         badgeNumber:(NSUInteger)badgeNumber;

- (BOOL)isCategoryInFirstScreen:(TTCategoryBadgeNumberManager *)manager
                 withCategoryID:(NSString *)categoryID;

@end

@interface TTCategoryBadgeNumberManager : NSObject

@property (nonatomic, weak)id <TTCategoryBadgeNumberManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)updateNotifyPointOfCategoryID:(NSString *)categoryID withClean:(BOOL)clean;
- (void)updateNotifyBadgeNumberOfCategoryID:(NSString *)categoryID withBadgeNumber:(NSUInteger)badgeNumber;
//新增控制频道红点
- (void)updateNotifyBadgeNumberOfCategoryID:(NSString *)categoryID withShow:(BOOL)isShow;

- (NSUInteger)badgeNumberOfCategoryID:(NSString *)categoryID;
- (BOOL)hasNotifyPointOfCategoryID:(NSString *)categoryID;

- (BOOL)isFollowCategoryNeedShowMessageBadgeNumber;

@end

NS_ASSUME_NONNULL_END
