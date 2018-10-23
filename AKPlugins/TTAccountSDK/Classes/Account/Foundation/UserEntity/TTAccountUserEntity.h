//
//  TTAccountUserEntity.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>



NS_ASSUME_NONNULL_BEGIN


/**
 *  头条账号用户实体
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=524948#id-享评SDK-获取当前登录用户的个人信息
 */
@class TTAccountMediaUserEntity;
@class TTAccountPlatformEntity;
@class TTAccountUserAuditEntity;
@class TTAccountVerifiedUserAuditEntity;
@class TTAccountMediaUserAuditEntity;
@class TTAccountUserAuditSet;
@interface TTAccountUserEntity : NSObject <NSCopying, NSSecureCoding>
// 是否是头条内测用户
@property (nonatomic, assign) BOOL isToutiao;

// IM类APP需使用
@property (nonatomic, copy, nullable) NSString *token;

// 系统新生成的session标识符，跨应用关联登录中使用
/** https://wiki.bytedance.net/pages/viewpage.action?pageId=524948 */
@property (nonatomic,   copy, nonnull) NSString *sessionKey;

// 是否是新用户
@property (nonatomic, assign) BOOL newUser;

// 用户唯一标识
@property (nonatomic, strong, nonnull) NSNumber *userID;

// PGC用户的唯一标识；如存在media_id则表示为是PGC用户，否则表示该用户是非PGC用户
@property (nonatomic, strong, nullable) NSNumber *mediaID;

// PGC用户详细信息
@property (nonatomic, strong, nullable) TTAccountMediaUserEntity *media;

// 能否通过手机号被发现
@property (nonatomic, assign) BOOL canBeFoundByPhone;

// 默认是否开放用户隐私信息，默认为0
@property (nonatomic, assign) NSInteger userPrivacyExtend;

// 用户名
@property (nonatomic,   copy) NSString *name;

// 生日
@property (nonatomic,   copy) NSString *birthday;

// 地区
@property (nonatomic,   copy) NSString *area;

// 行业
@property (nonatomic,   copy) NSString *industry;

// 性别  (0： 未知， 1： 男， 2： 女)
@property (nonatomic, strong) NSNumber *gender;

// 屏幕显示名
@property (nonatomic,   copy) NSString *screenName;

// 手机号
@property (nonatomic,   copy) NSString *mobile;

// 邮箱
@property (nonatomic,   copy) NSString *email;

// 用户头像（小图URL）
@property (nonatomic,   copy) NSString *avatarURL;

// 用户头像（大图URL）
@property (nonatomic,   copy) NSString *avatarLargeURL;

// 用户Profile背景图
@property (nonatomic,   copy) NSString *bgImgURL;

// 用户签名
@property (nonatomic,   copy) NSString *userDescription;

// 用户佩饰
@property (nonatomic,   copy) NSString *userDecoration;

// 区分是否是认证用户
@property (nonatomic, assign) BOOL userVerified __deprecated;

// https://wiki.bytedance.net/pages/viewpage.action?pageId=62426617
@property (nonatomic,   copy) NSString *verifiedContent __deprecated;

// 头条认证展现
@property(nonatomic,    copy) NSString *userAuthInfo;

//
@property (nonatomic,   copy) NSString *verifiedReason;

//
@property (nonatomic,   copy) NSString *verifiedAgency;

//
@property (nonatomic,   copy) NSString *recommendReason;

//
@property (nonatomic,   copy) NSString *reasonType;

//
@property (nonatomic, strong) NSNumber *point;

// 个人主页分享url
@property (nonatomic,   copy) NSString *shareURL;

// safe表示是否设置过密码，如果该字段不存在或不为1表示没有设置过密码，否则设置过
@property (nonatomic, strong) NSNumber *safe;

// 登录用户是否拉黑目标用户
@property(nonatomic,  assign) BOOL isBlocking;

//
@property(nonatomic,  assign) BOOL isBlocked;

// 是否已关注该用户
@property(nonatomic,  assign) BOOL isFollowing;

// 是否被别人关注
@property(nonatomic,  assign) BOOL isFollowed;

//
@property(nonatomic,  assign) BOOL isRecommendAllowed;

// 表示用户是否允许开启站外分享，默认 -1
@property(nonatomic,  assign) NSInteger shareToRepost;

//
@property(nonatomic,    copy) NSString *recommendHintMessage;

// 粉丝数
@property (nonatomic, assign) long long followersCount;

// 关注数
@property (nonatomic, assign) long long followingsCount;

// 最近访问好友数
@property (nonatomic, assign) long long visitCountRecent;

// 动态数
@property (nonatomic, assign) long long momentsCount;

// 用户审核信息集
@property (nonatomic, strong) TTAccountUserAuditSet *auditInfoSet;

// 第三方平台绑定后的账号信息
@property (nonatomic, strong) NSArray<TTAccountPlatformEntity *> *connects;

// 返回用户`id`对应字符串
- (nonnull NSString *)userIDString;

// Media用户返回对应string，否则返回nil
- (nullable NSString *)mediaIDString;

- (NSDictionary *)toDictionary;
@end



/**
 *  媒体(PGC)用户信息
 */
@interface TTAccountMediaUserEntity : NSObject <NSCopying, NSSecureCoding>
// PGC用户，老的PGC用户ID与登录用户ID不同
@property (nonatomic, strong, nonnull) NSNumber *mediaID;

// 媒体名称
@property (nonatomic,   copy) NSString *name;

// 审核通过的头像
@property (nonatomic,   copy) NSString *avatarURL;

// 是否通过认证
@property (nonatomic, assign) BOOL userVerified;

// 是否展示 "实名认证" 入口(1 展示 0 不展示)
@property (nonatomic, assign) BOOL displayAppOcrEntrance;

- (NSDictionary *)toDictionary;
@end



/**
 *  绑定的第三方平台账号信息
 */
@interface TTAccountPlatformEntity : NSObject <NSCopying, NSSecureCoding>
// 用户在头条平台唯一标识
@property (nonatomic, strong, nonnull) NSNumber *userID;

// 第三方平台的唯一标识
@property (nonatomic,   copy, nonnull) NSString *platformUID;

// 头条内部定义的平台名称
@property (nonatomic,   copy, nonnull) NSString *platform;

// 用户在第三方平台设置的名称
@property (nonatomic,   copy) NSString *platformScreenName;

// 用户在第三方平台的头像链接
@property (nonatomic,   copy) NSString *profileImageURL;

// 第三方平台授权的过期时间
@property (nonatomic, strong) NSNumber *expiredIn;
@property (nonatomic, strong) NSNumber *expiredTime;

- (NSDictionary *)toDictionary;
@end



/**
 * 用户审核信息
 *
 *  @Wiki: https://wiki.bytedance.com/pages/viewpage.action?pageId=62424459#id-账号合并后的用户和关系API-关注页内的兴趣列表
 */
@interface TTAccountUserAuditEntity : NSObject <NSCopying, NSSecureCoding>
@property (nonatomic,   copy) NSString *name;
@property (nonatomic,   copy) NSString *userDescription;
@property (nonatomic,   copy) NSString *avatarURL;

@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic,   copy) NSString *birthday;
@property (nonatomic,   copy) NSString *industry;
@property (nonatomic,   copy) NSString *area;

- (NSDictionary *)toDictionary;
@end

@interface TTAccountVerifiedUserAuditEntity : TTAccountUserAuditEntity

@end

@interface TTAccountMediaUserAuditEntity : TTAccountUserAuditEntity
// 是否在审核中
@property (nonatomic, assign) BOOL auditing;
@property (nonatomic, strong) NSNumber *expiredTime;
@end

@interface TTAccountUserAuditSet : NSObject <NSCopying, NSSecureCoding>
@property (nonatomic, strong) TTAccountUserAuditEntity         *currentUserEntity;
@property (nonatomic, strong) TTAccountVerifiedUserAuditEntity *verifiedUserAuditEntity;
@property (nonatomic, strong) TTAccountMediaUserAuditEntity    *pgcUserAuditEntity;

- (NSDictionary *)toDictionary;
- (NSDictionary *)toOriginalDictionary;
@end



/**
 *  上传图片后，返回的图片实体
 */
@interface TTAccountImageListEntity : NSObject
@property (nonatomic, copy) NSString *origin_url;
@property (nonatomic, copy) NSString *thumb_url;
@property (nonatomic, copy) NSString *medium_url;
@end

@interface TTAccountImageEntity : NSObject
@property (nonatomic,   copy) NSString *web_uri;
// 图片 URL list
@property (nonatomic, strong) TTAccountImageListEntity *url_list;
@end


NS_ASSUME_NONNULL_END
