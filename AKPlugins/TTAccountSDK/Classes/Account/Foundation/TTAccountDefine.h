//
//  TTAccountDefine.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#ifndef TTAccountDefine_h
#define TTAccountDefine_h

#import "TTAccountMacros.h"
#import "TTAccountSMSCodeDef.h"
#import "TTAccountStatusCodeDef.h"



/** 账号中错误码相关信息 */
FOUNDATION_EXPORT NSString * const TTAccountErrorDomain;
/** 错误键 */
FOUNDATION_EXPORT NSString * const TTAccountErrorKey;
/** 0表示成功，其它表示失败 */
FOUNDATION_EXPORT NSString * const TTAccountStatusCodeKey;
/** 当状态码非0时，错误消息的键值 */
FOUNDATION_EXPORT NSString * const TTAccountErrMsgKey;
/** 通知中第三方平台名称的键值 */
FOUNDATION_EXPORT NSString * const TTAccountAuthPlatformNameKey;



/**
 *  账号登录状态发生改变时的原因（如手机号、微信、微博登录、登出、过期等)
 *
 *  如下通知中会包含该值：
 *  TTAccountLoginCompletedNotification
 *  TTAccountLogoutCompletedNotification
 *  TTAccountForceLogoutCompletedNotificiaton
 *  TTAccountSessionExpiredNotificiaton
 */
typedef NS_ENUM(NSInteger, TTAccountStatusChangedReasonType) {
    TTAccountStatusChangedReasonTypeAutoSyncLogin,      // 自动同步登录(user/info)，可能因存储信息丢失导致
    TTAccountStatusChangedReasonTypeFindPasswordLogin,  // 通过找回密码/重置密码登录
    TTAccountStatusChangedReasonTypePasswordLogin,      // 手机号和密码登录
    TTAccountStatusChangedReasonTypeSMSCodeLogin,       // 手机号和验证码登录
    TTAccountStatusChangedReasonTypeEmailLogin,         // 邮箱和密码登录
    TTAccountStatusChangedReasonTypeTokenLogin,         // token和手机号登录
    TTAccountStatusChangedReasonTypeSessionKeyLogin,    // sessionKey和installId登录
    TTAccountStatusChangedReasonTypeAuthPlatformLogin,  // 第三方平台授权登录
    TTAccountStatusChangedReasonTypeLogout,             // 退出登录
    TTAccountStatusChangedReasonTypeSessionExpiration,  // 会话过期
};

FOUNDATION_EXPORT NSString *TTAccountStatusChangedReasonKey;


typedef void(^TTAccountLoginCompletedBlock)(BOOL success, NSError *error);


typedef NS_ENUM(NSInteger, TTAccountUserProfileType) {
    TTAccountUserProfileTypeUserName,
    TTAccountUserProfileTypeUserPhone,
    TTAccountUserProfileTypeUserAvatar,
    TTAccountUserProfileTypeUserBgImage,
    TTAccountUserProfileTypeUserDesp,
    TTAccountUserProfileTypeUserGender,
    TTAccountUserProfileTypeUserBirthday,
    TTAccountUserProfileTypeUserProvince,
    TTAccountUserProfileTypeUserCity,
    TTAccountUserProfileTypeUserIndustry,
};

#define TTAccountEnumString(enumInt) ([@(enumInt) stringValue])

FOUNDATION_EXPORT NSString * const TTAccountUserNameKey;
FOUNDATION_EXPORT NSString * const TTAccountUserPhoneKey;
FOUNDATION_EXPORT NSString * const TTAccountUserAvatarKey;
FOUNDATION_EXPORT NSString * const TTAccountUserBackgroundImageKey;
FOUNDATION_EXPORT NSString * const TTAccountUserDescriptionKey;
FOUNDATION_EXPORT NSString * const TTAccountUserGenderKey;
FOUNDATION_EXPORT NSString * const TTAccountUserBirthdayKey;
FOUNDATION_EXPORT NSString * const TTAccountUserProvinceKey;
FOUNDATION_EXPORT NSString * const TTAccountUserCityKey;
FOUNDATION_EXPORT NSString * const TTAccountUserIndustryKey;



typedef NS_ENUM(NSInteger, TTAccountAuthPlatformStatusChangedReasonType) {
    TTAccountAuthPlatformStatusChangedReasonTypeLogin,
    TTAccountAuthPlatformStatusChangedReasonTypeLogout,
    TTAccountAuthPlatformStatusChangedReasonTypeExpiration,
};



@protocol TTAccountSessionTask;
@class TTAccountUserEntity;
@class TTAccountMediaUserEntity;
@class TTAccountPlatformEntity;
@class TTAccountUserAuditEntity;
@class TTAccountVerifiedUserAuditEntity;
@class TTAccountMediaUserAuditEntity;
@class TTAccountUserAuditSet;
@class TTAccountImageEntity;
@class TTAccountImageListEntity;



#endif /* TTAccountDefine_h */
