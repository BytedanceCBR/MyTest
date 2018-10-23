//
//  SSUserModel.h
//  Article
//
//  Created by Dianwei on 14-5-21.
//
//

#import <Foundation/Foundation.h>
#import "TTAccountManagerDefine.h"



/**
 User基类
 */
@interface SSUserBaseModel : NSObject<NSCoding>

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (void)updateWithDictionary:(NSDictionary *)dict;

@property (nonatomic,   copy) NSString *ID; // 该属性对外部只读

@property (nonatomic,   copy) NSString *name;
@property (nonatomic,   copy) NSString *screen_name;
@property (nonatomic,   copy) NSString *avatarURLString;
@property (nonatomic,   copy) NSString *avatarLargeURLString;
@property (nonatomic,   copy) NSString *bgImageURLString;
@property (nonatomic,   copy) NSString *userDescription;
@property (nonatomic,   copy) NSString *userDecoration;
@property (nonatomic,   copy) NSString *showInfo;//我的Tab用户名下面的文案
@property (nonatomic,   copy) NSString *userAuthInfo; // 头条认证展现信息
@property (nonatomic, strong) NSArray  *connects;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic,   copy) NSString *birthday; //个人主页改版新增加
@property (nonatomic,   copy) NSString *area; //个人主页改版新增加
@property (nonatomic, assign) long long followingCount; // 关注数（我关注的人）followings_count
@property (nonatomic, assign) long long followerCount;  // 粉丝数（关注我的人）followers_count
@property (nonatomic, assign) long long visitorCount;   // 访客数（访客）visit_count_recent
@property (nonatomic, assign) long long momnetCount;   // 动态数量
@property (nonatomic, assign) NSInteger pgcLikeCount;   //订阅
@property (nonatomic,   copy) NSString *verifiedReason;

@property (nonatomic,   copy) NSString *shareURL;       // 个人主页分享url
@property (nonatomic,   copy) NSString *media_id; // 如存在media_id则表示为是PGC用户，否则表示该用户不是PGC用户

/**
 *  added 5.2.1：用户badge信息
 */
@property (nonatomic, strong) NSArray *authorBadgeList;

//拉黑
@property (nonatomic, assign) BOOL isBlocking; // 登录用户是否拉黑目标用户
@property (nonatomic, assign) BOOL isBlocked; // 登录用户是否被目标用户拉黑

@property (nonatomic, assign) BOOL isFollowing; //是否关注用户
@property (nonatomic, assign) BOOL isFollowed;  //是否被关注

- (NSDictionary *)toDict;

- (TTAccountUserType)userType;

/**
 *  头条用户是PGC用户
 */
- (BOOL)isToutiaohaoUser;

/**
 *  认证用户，头条用户同时可能是认证用户
 */
- (BOOL)isVerifiedUser;

@end
