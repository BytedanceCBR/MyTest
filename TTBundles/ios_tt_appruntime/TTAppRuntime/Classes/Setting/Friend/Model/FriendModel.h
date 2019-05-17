//
//  FriendModel.h
//  Article
//
//  Created by Dianwei on 12-11-2.
//
//

//未来改为Friend池概念，去除这些notification

#define KFriendModelChangedNotification @"KFriendModelChangedNotification"

#define kFriendModelUserIDKey       @"kFriendModelUserIDKey"
#define kFriendModelISFollowingKey  @"kFriendModelISFollowingKey"
#define kFriendModelISFollowedKey  @"kFriendModelISFollowedKey"
#define kFriendModelISBlockingKey  @"kFriendModelISBlockingKey"

#import <Foundation/Foundation.h>

@interface FriendModel : NSObject

+ (FriendModel *)accountUser;

@property(nonatomic, copy)NSString * verfiedAgency; //认证机构
@property(nonatomic, copy)NSString * verfiedContent; //认证内容
@property(nonatomic, copy)NSString *userID;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *gender;
@property(nonatomic, copy)NSString *screenName;
@property(nonatomic, copy)NSString *avatarURLString;
@property(nonatomic, copy)NSString *avatarLargeURLString;
@property(nonatomic, copy)NSString *platform;
@property(nonatomic, copy)NSString *userDescription;
@property(nonatomic, strong)NSNumber *followingCount;
@property(nonatomic, strong)NSNumber *followerCount;
@property(nonatomic, strong)NSNumber *followingTime;
@property(nonatomic, strong)NSNumber *isFollowing; // 登录用户是否关注目标用户
@property(nonatomic, strong)NSNumber *isFollowed; // 登录用户是否被目标用户关注
@property(nonatomic, strong)NSNumber *hasInvited; // 已邀请，存储在内存的临时状态
@property(nonatomic, strong)NSNumber *hasSNS;     // 是否在SNS网站有好友关系，仅用在 Suggest User 中
@property(nonatomic, copy)NSString *lastUpdate;
@property(nonatomic, copy)NSString *userAuthInfo; // 头条认证展现
@property(nonatomic, strong)NSNumber * pgcLikeCount;
@property(nonatomic, assign)BOOL isTipNew;      //新加入
@property(nonatomic, copy)NSString * reason;  //推荐原因
@property(nonatomic, copy)NSString *verifySource;
@property(nonatomic, copy)NSString *verifyDesc;
@property(nonatomic, copy)NSString *platformScreenName;
@property(nonatomic, copy)NSString *mobileHash;
@property(nonatomic, copy)NSString *recommendReason;
@property(nonatomic, assign)BOOL showSpringFestivalIcon;
@property(nonatomic, copy)NSString *springFestivalScheme;

@property(nonatomic, strong)NSNumber *entityLikeCount; //喜欢的文章数
/**
 *  added 5.2.1: 用户badge信息
 */
@property(nonatomic, copy)NSArray *authorBadgeList;

//拉黑
@property(nonatomic, strong)NSNumber *isBlocking; // 登录用户是否拉黑目标用户
@property(nonatomic, strong)NSNumber *isBlocked; // 登录用户是否被目标用户拉黑
@property(nonatomic, assign)NSUInteger newSource; //新来源
@property(nonatomic, assign)NSUInteger newReason; //新推荐理由

- (id)initWithDictionary:(NSDictionary*)data;
- (void)updateWithDictionary:(NSDictionary*)data;   // won't update user id
- (NSMutableDictionary *)dictionaryInfo;

- (void)postFriendModelChangedNotification;
@end
