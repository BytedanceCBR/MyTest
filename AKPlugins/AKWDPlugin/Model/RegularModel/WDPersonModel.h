//
//  WDPersonModel.h
//  Forum
//
//  Created by Zhang Leonardo on 15-3-27.
//
//

#import <Foundation/Foundation.h>
#import "WDApiModel.h"

@protocol WDPersonModel;
@class WDRedPackStructModel;

@interface WDPersonModel : NSObject<NSCoding>

@property (nonatomic, strong, nullable)NSString * userID;
/**
 *  给用户展示请使用screenName
 */
@property (nonatomic, copy, nullable)NSString * name;
/**
 *  显示都用screenName
 */
@property (nonatomic, copy, nullable)NSString * screenName;

@property (nonatomic, copy, nullable)NSString * avatarURLString;

@property (nonatomic, copy, nullable)NSString * userIntro;

@property (nonatomic, copy, nullable)NSString * userAuthInfo;

@property (nonatomic, copy, nullable)NSString * userDecoration;
/**
 *  认证机构
 */
@property(nonatomic, copy, nullable)NSString * verfiedAgency;
/**
 *  认证内容
 */
@property(nonatomic, copy, nullable)NSString * verfiedContent;
///**
// *  平台信息
// */
//@property(nonatomic, strong)NSArray * connects;
@property(nonatomic, copy, nullable)NSString * gender;
/**
 *  订阅数
 */
@property(nonatomic, assign) long long pgcLikeCount;
/**
 *  登录用户是否关注目标用户
 */
@property(nonatomic, assign)BOOL isFollowing;
/**
 *  关注数
 */
@property(nonatomic, assign)long long followingCount;
/**
 *  登录用户是否被目标用户关注
 */
@property(nonatomic, assign)BOOL isFollowed;
/**
 *  粉丝数
 */
@property(nonatomic, assign)long long followerCount;
/**
 * 回答问题总数
 */
@property(nonatomic, assign) long long totalAnswerCount;
/**
 * 获得的总点赞数
 */
@property(nonatomic, assign) long long totalDiggCount;
/**
 *  登录用户是否拉黑目标用户
 */
@property(nonatomic, assign)BOOL isBlocking;
/**
 *  登录用户是否被目标用户拉黑
 */
@property(nonatomic, assign)BOOL isBlocked;
/**
 *  客户端透传，表示推荐理由，客户端点击follow时需带上该字段值，
 *  如服务端没有传该值，则默认为0
 */
@property(nonatomic, assign)int reasonType;
/**
 *  推荐理由
 */
@property(nonatomic, copy, nullable)NSString *recommendReason;
/**
 *  手机用户mobile加密值，如果mobile_hash不为空，则表示该用户是手机号用户（手机号用户也需要显示其绑定的其他平台，故mobile和其他社交平台单独处理)
 */
@property (nonatomic, copy, nullable) NSString * mobileHash;

@property(nonatomic, copy, nullable) NSString *phoneNumberString;

/**
 *  发表的帖子数
 */
@property (nonatomic, assign) NSInteger postCount;

/**
 *  回复的帖子数
 */
@property (nonatomic, assign) NSInteger replyCount;

@property (nonatomic, copy, nullable) NSArray *medals;

@property (nonatomic, assign) NSInteger inviteStatus;

@property (nonatomic, strong, nullable) WDRedPackStructModel *redPack;

+ (nullable WDPersonModel *)genWDPersonModelFromDictionary:(nullable NSDictionary *)userDict;

+ (nullable WDPersonModel *)genWDPersonModelFromWDUserModel:(nullable WDUserStructModel *)model;

@end

@interface WDPersonModel (TTFeed)

+ (WDPersonModel *_Nonnull)genWDPersonModelFromWDFeedUserModel:(WDStreamUserStructModel *_Nullable)model;

@end
