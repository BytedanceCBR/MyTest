//
//  TTAccountRespModel.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccountRespModel.h"



#pragma mark -  user model

@implementation TTAUserModel
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"user_description"    : @"description",
             @"error_description"   : @"description",
             @"momentsCount"        : @"dongtai_count",
             };
}

- (instancetype)init
{
    if ((self = [super init])) {
        _is_toutiao = @(0);
        _can_be_found_by_phone = YES;
        _user_privacy_extend = 0;
        _share_to_repost = -1;
    }
    return self;
}
@end

@implementation TTAMediaUserModel
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"media_id"    : @"id",
             };
}
@end

// 关联的第三方账号信息
@implementation TTAThirdAccountModel
@end

// 登录用户的响应Model
@implementation TTAUserRespModel
@end



#pragma mark -  register by phone

@implementation TTARegisterModel
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"error_description"   : @"description",
             };
}
@end

@implementation TTARegisterRespModel
@end



#pragma mark -  logout

@implementation TTALogoutModel
@end

@implementation TTALogoutRespModel
@end



#pragma mark -  unbind mobile

@implementation TTAUnbindMobileModel
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"error_description"   : @"description",
             };
}
@end

@implementation TTAUnbindMobileRespModel
@end



#pragma mark -  bind mobile

@implementation TTABindMobileModel
@end

@implementation TTABindMobileRespModel
@end



#pragma mark - validate message code

@implementation TTAValidateSMSCodeModel
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"error_description"   : @"description",
             };
}
@end

/**
 *  验证短信验证码ResponseModel
 */
@implementation TTAValidateSMSCodeRespModel
@end




#pragma mark -  get message authorization code

@implementation TTAGetSMSCodeModel
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"error_description"   : @"description",
             };
}
@end

@implementation TTAGetSMSCodeRespModel
@end



#pragma mark - refresh captcha

@implementation TTARefreshCaptchaModel
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"error_description"   : @"description",
             };
}
@end

@implementation TTARefreshCaptchaRespModel
@end



#pragma mark - modify password

@implementation TTAModifyPasswordModel
@end

@implementation TTAModifyPasswordRespModel
@end



#pragma mark - reset password

@implementation TTAResetPasswordModel
@end

@implementation TTAResetPasswordRespModel
@end



#pragma mark - 检查用户名

@implementation TTACheckNameModel

@end

@implementation TTACheckNameRespModel

@end



#pragma mark - update user profile

@implementation TTAUpdateUserExtraProfileItem

@end

@implementation TTAUserAuditInfoItem
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"user_description"    : @"description"
             };
}
@end

@implementation TTAPGCUserAuditInfoItem
@end

@implementation TTAUserVerifiedAuditInfoItem
@end

@implementation TTAUpdateUserProfileModel
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"error_description"   : @"description",
             };
}
@end

@implementation TTAUpdateUserProfileRespModel
@end



#pragma mark - 解绑已绑定的第三方账号

@implementation TTALogoutThirdPartyPlatformModel

@end

@implementation TTALogoutThirdPartyPlatformRespModel
@end



#pragma mark - 请求新的会话

@implementation TTARequestNewSessionModel
+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"user_description"    : @"description",
             @"error_description"   : @"description",
             @"name"                : @"name",
             @"error_name"          : @"name",
             };
}
@end

@implementation TTARequestNewSessionRespModel
@end


