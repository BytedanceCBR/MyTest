//
//  FriendDataManager.h
//  Article
//
//  Created by Dianwei on 12-11-2.
//
//

#import <Foundation/Foundation.h>
#import "TTFollowManager.h"

typedef enum FriendDataListType
{
    FriendDataListTypeNone    =   -1,
    FriendDataListTypeFowllowing    =   1, // 关注列表
    FriendDataListTypeFollower      =   2, // 粉丝列表
    FriendDataListTypeSuggestUser   =   3, // 值得关注列表
    FriendDataListTypePlatformFriends   = 4, // 告诉朋友列表
    FriendDataListTypeWidgetSuggestUser = 5,
    FriendDataListTypeVisitor           = 6, // 访客
} FriendDataListType;

NS_ASSUME_NONNULL_BEGIN

@class FriendDataManager;

@protocol FriendDataManagerDelegate <NSObject>
@optional
- (void)friendDataManager:(nonnull FriendDataManager*)dataManager finishGotListWithType:(FriendDataListType)type error:(nullable NSError*)error result:(nullable NSArray*)result totalNumber:(unsigned long long)totalNumber anonymousNumber:(unsigned long long)anonymousNumber hasMore:(BOOL)hasMore offset:(int)offset;
- (void)friendDataManager:(nonnull FriendDataManager*)dataManager finishActionType:(FriendActionType)type error:(nullable NSError*)error result:(nullable NSDictionary*)result;
- (void)friendDataManager:(nonnull FriendDataManager *)dataManager gotFollowersCount:(long long)followerCount followingCount:(long long)followingCount newFriendCount:(long long)newFriendCount pgcLikeCount:(long long)pgcLikeCount error:(nullable NSError*)error;

- (void)friendDataManager:(nonnull FriendDataManager *)dataManager finishFriendProfileResult:(nullable NSDictionary*)result error:(nullable NSError*)error;
@end

@interface FriendDataURLSetting : NSObject

+ (NSString*)joinFriendsURLString;

+ (NSString*)followingURLString;
+ (NSString*)followerURLString;
+ (NSString*)visitorHistoryURLString;
+ (NSString*)suggestedUserURLString;
+ (NSString*)widgetSuggestedUserURLString;
+ (NSString*)platformFriendURLString;

+ (NSString*)userProfileURLString;
@end

@interface FriendDataManager : NSObject
@property(nonatomic, weak)NSObject<FriendDataManagerDelegate> * _Nullable delegate;

+ (nonnull instancetype)sharedManager;

// if user_id is nil, get own list, user_id is only valid for following and follower list
- (void)startGetFriendListType:(FriendDataListType)listType userID:(nonnull NSString *)userID count:(int)count offset:(int)offset;
- (void)startGetFriendListType:(FriendDataListType)listType friendModelClass:(nonnull Class)friendModelClass userID:(nonnull NSString*)userID count:(int)count offset:(int)offset;

- (void)startGetFriendProfileByUserID:(nonnull NSString *)userID extraTrack:(nullable NSDictionary *)extraTrack;

- (void)startGetJoinFriendsWithOffset:(NSInteger)offset finishBlock:(nullable void(^)(NSArray *_Nullable result, BOOL newAccount, NSInteger newCount, NSInteger originalCount, BOOL hasMore, NSError *_Nullable error))finishBlock;


+ (BOOL)hasNewFriendCount;
/*
 *  判断是否应该提醒， 当用户第一次安装或者删除后安装时候， 不应该提醒
 */
+ (BOOL)relationCountNeedNotify;

- (void)cancelGetFriendListType:(FriendDataListType)listType;
- (void)cancelAllRequests;
@end

NS_ASSUME_NONNULL_END
