//
//  TTAccountRespModel.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountBaseModel.h"



/**
 *  用户Model实体
 *  @Wiki: https://wiki.bytedance.com/pages/viewpage.action?pageId=13961678#id-手机号注册登录-注册/register
 *         https://wiki.bytedance.net/pages/viewpage.action?pageId=73993493 (mediaUser接口描述)
 */
#pragma mark - Response Model

@protocol TTAThirdAccountModel<NSObject>
@end

/** 头条用户关联的第三方账号信息 */
@interface TTAThirdAccountModel : TTADataRespModel
@property (nonatomic, strong) NSNumber *user_id;
@property (nonatomic,   copy) NSString *platform_screen_name;
@property (nonatomic,   copy) NSString *profile_image_url;
@property (nonatomic,   copy) NSString *platform;
@property (nonatomic,   copy) NSString *platform_uid;
@property (nonatomic, strong) NSNumber *expires_in;
@property (nonatomic, strong) NSNumber *expired_time;
@end

/** 媒体用户(PGC)用户信息 */
@interface TTAMediaUserModel : TTADataRespModel
/** PGC用户唯一标识 */
@property (nonatomic, strong) NSNumber *media_id; // id
/** PGC用户名称 (媒体名称) */
@property (nonatomic,   copy) NSString *name;
/** 审核通过的头像 */
@property (nonatomic,   copy) NSString *avatar_url;
/** 是否通过认证 */
@property (nonatomic, strong) NSNumber *user_verified;
/** 是否展示 "实名认证" 入口(1 展示 0 不展示) */
@property (nonatomic, strong) NSNumber *display_app_ocr_entrance;
@end

@interface TTAUserModel : TTADataRespModel
/** 是否时头条内测用户 */
@property (nonatomic, strong) NSNumber *is_toutiao;

/** Session Key */
@property (nonatomic,   copy) NSString *session_key;

/** 每个用户唯一标识 */
@property (nonatomic, strong) NSNumber *user_id;

/** 如存在media_id则表示为是PGC用户，否则表示该用户非PGC用户 */
@property (nonatomic, strong) NSNumber *media_id;

@property (nonatomic, strong) TTAMediaUserModel *media;

/** 区分用户是否通过认证 */
@property (nonatomic, assign) BOOL user_verified;

/** https://wiki.bytedance.net/pages/viewpage.action?pageId=62426617 */
@property (nonatomic,   copy) NSString *user_auth_info;

/** 是否是新用户 [与服务端确认，该字段没有任何含义；新用户是服务端通过did等参数推断出来] */
@property (nonatomic, assign) BOOL new_user;
/** 用户名 */
@property (nonatomic,   copy) NSString *name;
/** 生日 */
@property (nonatomic,   copy) NSString *birthday;
/** 性别 */
@property (nonatomic, strong) NSNumber *gender;
/** 地区 */
@property (nonatomic,   copy) NSString *area;
/** 行业 */
@property (nonatomic,   copy) NSString *industry;
/** 屏幕名称 */
@property (nonatomic,   copy) NSString *screen_name;
/** 手机号 */
@property (nonatomic,   copy) NSString *mobile;
/** 邮箱 */
@property (nonatomic,   copy) NSString *email;
/** 头像URL */
@property (nonatomic,   copy) NSString *avatar_url;
/** 头像佩饰 */
@property (nonatomic,   copy) NSString *user_decoration;

/** 头像大图URL */
@property (nonatomic,   copy) NSString *avatar_large_url;
/** 背景图URL */
@property (nonatomic,   copy) NSString *bg_img_url;
/** 用户描述(简介) */
@property (nonatomic,   copy) NSString *user_description;

/** 能否通过手机号被发现
 *  当值为 "0" 时，为不可通过电话发现，为 "1" 时为可以。默认为可以（比如Key不存在或值错误
 *
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=85312712
 */
@property (nonatomic, assign) BOOL can_be_found_by_phone;

@property (nonatomic, assign) NSInteger user_privacy_extend;

/** 用户是否开启分享并转发
 *
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=95655274
 */
@property (nonatomic, assign) NSInteger share_to_repost;

/** 用户认证相关信息 */
@property (nonatomic,   copy) NSString *verified_reason;
@property (nonatomic,   copy) NSString *verified_content;
@property (nonatomic,   copy) NSString *verified_agency;
@property (nonatomic,   copy) NSString *recommend_reason;
@property (nonatomic,   copy) NSString *reason_type;

@property (nonatomic, strong) NSNumber *point;

/** 个人主页分享url */
@property (nonatomic,   copy) NSString *share_url;

/** 该字段表示用户是否设置过密码，如该字段为空或不为1表示没有设置过密码，否则设置过 */
@property (nonatomic, strong) NSNumber *safe;

/** 登录用户是否拉黑目标用户 */
@property (nonatomic,  assign) BOOL is_blocking;
/** 是否被拉黑 */
@property (nonatomic,  assign) BOOL is_blocked;

/** 是否关注用户 */
@property (nonatomic,  assign) BOOL is_following;
/** 是否被关注 */
@property (nonatomic,  assign) BOOL is_followed;

@property (nonatomic,  assign) BOOL is_recommend_allowed;
@property (nonatomic,    copy) NSString *recommend_hint_message;

/** 粉丝数 */
@property (nonatomic, strong) NSNumber *followers_count;
/** 关注数 */
@property (nonatomic, strong) NSNumber *followings_count;
/** 最近访问好友数 */
@property (nonatomic, strong) NSNumber *visit_count_recent;
/** 动态数 */
@property (nonatomic, strong) NSNumber *moments_count;

/** 绑定第三方平台后第三方平台的账号信息 */
@property (nonatomic, strong) NSArray<TTAThirdAccountModel> *connects;


/** 登录错误时，返回的图片验证码数据 */
@property (nonatomic,   copy) NSString *captcha;
/** 错误描述，用于弹窗提示 */
@property (nonatomic,   copy) NSString *error_description;
/** 错误码: API返回错误信息汇总参考文件TTAccountDefs文件(TTAErrCode) */
@property (nonatomic, assign) NSInteger error_code;

@end

#pragma mark - 用户登录Response Model
// 用户登录的ResponseModel
@interface TTAUserRespModel : TTABaseRespModel
@property (nonatomic, strong) TTAUserModel *data;
@end




#pragma mark - 手机号注册
/*************************************************
 *      错误码及描述
 *
 *  999     其它错误     返回description
 *  1001	已注册       仅type=1,2时返回
 *  1101	需要验证码	同时返回captcha的值
 *  1102	验证码错误	同时返回新的captcha的值
 *  1103	验证码失效	同时返回新的captcha的值
 ***************************************************/
//  手机号注册DataModel
@interface TTARegisterModel : TTADataRespModel
/** 图片验证码--图片内容的base64编码 */
@property (nonatomic,   copy) NSString *captcha;
/** 错误提示 */
@property (nonatomic,   copy) NSString *error_description;
/** API返回错误信息汇总，参考文件TTAccountDefs文件(TTAErrCode) */
@property (nonatomic, assign) NSInteger error_code;
@end

// 手机号注册ResponseModel
@interface TTARegisterRespModel : TTABaseRespModel
@property (nonatomic, strong) TTARegisterModel *data;
@end




#pragma mark - 退出登录
//  退出登录DataModel
@interface TTALogoutModel : TTADataRespModel
@end

// 退出登录ResponseModel
@interface TTALogoutRespModel : TTABaseRespModel
@property (nonatomic, strong) TTALogoutModel *data;
@end




#pragma mark - 解绑手机号
/*************************************************
 *      错误码及描述
 *
 *  1       session_expired
 *  999     其它错误     返回description
 *  1101	需要验证码	同时返回captcha的值
 *  1102	验证码错误	同时返回新的captcha的值
 *  1103	验证码失效	同时返回新的captcha的值
 ***************************************************/
//  解绑手机号DataModel
@interface TTAUnbindMobileModel : TTADataRespModel
/** 图片验证码--图片内容的base64编码 */
@property (nonatomic,   copy) NSString *captcha;
/** 错误提示 */
@property (nonatomic,   copy) NSString *error_description;
/** API返回错误信息汇总，参考文件TTAccountDefs文件(TTAErrCode) */
@property (nonatomic, assign) NSInteger error_code;
@end

// 解绑手机号ResponseModel
@interface TTAUnbindMobileRespModel : TTABaseRespModel
@property (nonatomic, strong) TTAUnbindMobileModel *data;
@end




#pragma mark - 绑定手机号
/*************************************************
 *      错误码及描述
 *
 *  1       session_expired
 *  999     其它错误        返回description
 *  1006	不存在绑定的手机号
 *  1102	验证码错误	同时返回新的captcha的值
 *  1103	验证码失效	同时返回新的captcha的值
 ***************************************************/
// 绑定手机号DataModel
@interface TTABindMobileModel : TTAUserModel

@end

// 绑定手机号ResponseModel
@interface TTABindMobileRespModel : TTABaseRespModel
@property (nonatomic, strong) TTABindMobileModel *data;
@end




#pragma mark - 验证短信验证码
/*************************************************
 *      错误码及描述
 *
 *  999     其它错误     返回description
 *  1001	已注册       仅type=1,2时返回
 *  1101	需要验证码	同时返回captcha的值
 *  1102	验证码错误	同时返回新的captcha的值
 *  1103	验证码失效	同时返回新的captcha的值
 ***************************************************/
/**
 *  验证短信验证码DataModel
 */
@interface TTAValidateSMSCodeModel : TTADataRespModel
// Error fields
/** 图片验证码--图片内容的base64编码 */
@property (nonatomic,   copy) NSString *captcha;
/* API返回错误信息汇总，参考文件TTAccountDefs文件(TTAErrCode) */
@property (nonatomic, assign) NSInteger error_code;
/** 错误提示 */
@property (nonatomic,   copy) NSString *error_description;
@end

// 验证短信验证码ResponseModel
@interface TTAValidateSMSCodeRespModel : TTABaseRespModel
@property (nonatomic, strong) TTAValidateSMSCodeModel *data;
@end




#pragma mark - 获取短信验证码
/*************************************************
 *      错误码及描述
 *
 *  1       session_expired
 *  999     其它错误     返回description
 *  1001	已注册	    仅type=1,2时返回
 *  1002	手机号为空	同时返回captcha值
 *  1101	需要验证码	同时返回captcha的值
 *  1102	验证码错误	同时返回新的captcha的值
 *  1103	验证码失效	同时返回新的captcha的值
 ***************************************************/
/**
 *  获取手机验证码DataModel
 */
@interface TTAGetSMSCodeModel : TTADataRespModel
// Success fields
/** 验证码过期重试时间 */
@property (nonatomic, strong) NSNumber *retry_time;
/** 服务端发送验证码的手机号（会打码，比如139*****123）*/
@property (nonatomic,   copy) NSString *mobile;

// Error fields
/** 图片验证码--图片内容的base64编码 */
@property (nonatomic,   copy) NSString *captcha;
/* API返回错误信息汇总，参考文件TTAccountDefs文件(TTAErrCode) */
@property (nonatomic, assign) NSInteger error_code;
/** 错误提示 */
@property (nonatomic,   copy) NSString *error_description;
/** 解绑弹窗提示 */
@property (nonatomic,   copy) NSString *dialog_tips;
@end

// 获取验证码ResponseModel
@interface TTAGetSMSCodeRespModel : TTABaseRespModel
@property (nonatomic, strong) TTAGetSMSCodeModel *data;
@end




#pragma mark - 刷新图片验证码
// 刷新图片验证码DataModel
@interface TTARefreshCaptchaModel : TTADataRespModel
/** 图片验证码--图片内容的base64编码 */
@property (nonatomic, copy) NSString *captcha;
@end

// 刷新图片验证码ResponseModel
@interface TTARefreshCaptchaRespModel : TTABaseRespModel
@property (nonatomic, strong) TTARefreshCaptchaModel *data;
@end




#pragma mark - 重置密码
/*************************************************
 *      错误码及描述
 *
 *  999     其它错误     返回description
 *  1101	需要验证码	同时返回captcha的值
 *  1102	验证码错误	同时返回新的captcha的值
 *  1103	验证码失效	同时返回新的captcha的值
 ***************************************************/
// 重置密码DataModel
@interface TTAResetPasswordModel : TTAUserModel

@end

// 重置密码ResponseModel
@interface TTAResetPasswordRespModel : TTABaseRespModel
@property (nonatomic, strong) TTAResetPasswordModel *data;
@end




#pragma mark - 修改密码
/*************************************************
 *      错误码及描述
 *
 *  1       session_expired
 *  999     其它错误     返回description
 *  1101	需要验证码	同时返回captcha的值
 *  1102	验证码错误	同时返回新的captcha的值
 *  1103	验证码失效	同时返回新的captcha的值
 ***************************************************/
// 修改密码DataModel
@interface TTAModifyPasswordModel : TTAUserModel

@end

// 修改密码ResponseModel
@interface TTAModifyPasswordRespModel : TTABaseRespModel
@property (nonatomic, strong) TTAModifyPasswordModel *data;
@end




/**
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=1153405#id-用户API-检查用户名是否冲突
 */
@interface TTACheckNameModel : TTADataRespModel
@property (nonatomic, copy) NSString *available_name;
@end

@interface TTACheckNameRespModel : TTABaseRespModel
@property (nonatomic, strong) TTACheckNameModel *data;
@end



#pragma mark - 更新用户信息
/**
 *  更新用户信息DataModel
 *
 * @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=73997212#id-用户信息API文档-用户信息API文档-用户审核信息
 *        https://wiki.bytedance.net/pages/viewpage.action?pageId=73997212#id-用户信息API文档-修改额外信息
 */
@interface TTAUpdateUserExtraProfileItem : TTADataRespModel
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic,   copy) NSString *birthday;
@property (nonatomic,   copy) NSString *industry;
@property (nonatomic,   copy) NSString *area; // province/city
@end

@interface TTAUserAuditInfoItem : TTADataRespModel
@property (nonatomic,   copy) NSString *name;
@property (nonatomic,   copy) NSString *user_description;
@property (nonatomic,   copy) NSString *avatar_url;

@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic,   copy) NSString *birthday;
@property (nonatomic,   copy) NSString *industry;
@property (nonatomic,   copy) NSString *area; // province/city
@end

@interface TTAPGCUserAuditInfoItem : TTADataRespModel
@property (nonatomic, strong) NSNumber *is_auditing;
@property (nonatomic, strong) NSNumber *audit_expire_time;
@property (nonatomic, strong) TTAUserAuditInfoItem *audit_info;
@end

@interface TTAUserVerifiedAuditInfoItem : TTADataRespModel
@property (nonatomic, strong) TTAUserAuditInfoItem *audit_info;
@end

@interface TTAUpdateUserProfileModel : TTADataRespModel
@property (nonatomic,   copy) NSString *existed_name;
@property (nonatomic,   copy) NSString *tip;
@property (nonatomic,   copy) NSString *name;
@property (nonatomic,   copy) NSString *error_description; // description

// update_extra接口返回字段
@property (nonatomic, strong) TTAUpdateUserExtraProfileItem *attrs;

// update/v3接口返回字段
@property (nonatomic, strong) TTAUserAuditInfoItem *current_info;
@property (nonatomic, strong) TTAPGCUserAuditInfoItem *pgc_audit_info;
@property (nonatomic, strong) TTAUserVerifiedAuditInfoItem *verified_audit_info;
@end

/**
 *  更新用户信息ResponseModel
 */
@interface TTAUpdateUserProfileRespModel : TTABaseRespModel
@property (nonatomic, strong) TTAUpdateUserProfileModel *data;
@end




#pragma mark - 解绑第三方账号
/**
 *  解绑第三方账号ResponseModel
 */
@interface TTALogoutThirdPartyPlatformModel : TTADataRespModel

@end

@interface TTALogoutThirdPartyPlatformRespModel : TTABaseRespModel
@property (nonatomic, strong) TTALogoutThirdPartyPlatformModel *data;
@end




#pragma mark - 请求新的会话
/**
 *  请求新的会话
 *  https://wiki.bytedance.net/pages/viewpage.action?pageId=524948
 */
@interface TTARequestNewSessionModel : TTAUserModel
/** Eg: "session_expired" */
@property (nonatomic, copy) NSString *error_name;
@end

@interface TTARequestNewSessionRespModel : TTABaseRespModel
@property (nonatomic, strong) TTARequestNewSessionModel *data;
@end

