//
//  TTAccountManagerDefine.h
//  Article
//
//  Created by liuzuopeng on 5/7/17.
//
//

#ifndef TTAccountManagerDefine_h
#define TTAccountManagerDefine_h

#import <TTAccountSDK.h>



/**
 * 客户端区分的用户类型
 */
typedef
NS_ENUM(NSUInteger, TTAccountUserType) {
    TTAccountUserTypeVisitor = 0, // 游客
    TTAccountUserTypeUGC     = 1, // 经过认证的用户(UGC)
    TTAccountUserTypePGC     = 2, // PGC用户
};



typedef
NS_ENUM(NSInteger, TTUserGenderType) {
    TTUserGenderTypeUnknown = 0, // 未知性别
    TTUserGenderTypeMale    = 1, // 男
    TTUserGenderTypeFemale  = 2, // 女
};


//
// 平台名称
//
#define PlatformWeixin              @"weixin_sns"
#define PLATFORM_WEIXIN             @"weixin"
#define PLATFORM_RENREN_SNS         @"renren_sns"
#define PLATFORM_QZONE              @"qzone_sns"
#define PLATFORM_QQ_WEIBO           @"qq_weibo"
#define PLATFORM_SINA_WEIBO         @"sina_weibo"
#define PLATFORM_TIANYI             @"telecom"
#define PLATFORM_EMAIL              @"email"
#define PLATFORM_PHONE              @"phone"
#define PLATFORM_HUOSHAN            @"live_stream"  // APPID:29 PlatformAppID:208
#define PLATFORM_DOUYIN             @"aweme"        // APPID:30 PlatformAppID:210

#define PLATFORM_KAIXIN_SNS         @"kaixin_sns"
#define PLATFORM_TWITTER            @"twitter"
#define PLATFORM_FACEBOOK           @"facebook"



NS_INLINE
BOOL TTPlatformEqualToPlatform(NSString *platformName1, NSString *platformName2)
{
    if (!platformName1 && !platformName2) return YES;
    if (!platformName1 || !platformName2) return NO;
    return [platformName1 isEqualToString:platformName2];
}


//  平台类型 -> 平台名称
#define TTAccountGetPlatformNameByType(type)    \
    [TTAccount platformNameForAccountAuthType:type]

#define TTA_NONNULL_PLATFORM_NAME(type) \
    (TTAccountGetPlatformNameByType(type) ? : @"")

//  平台名称 -> 平台类型
#define TTAccountGetPlatformTypeByName(platform)    \
    [TTAccount accountAuthTypeForPlatform:platform]

// 平台名称 ？= 平台名称
#define TTPlatformNameEqualToPlatformName(platformName1, platformName2) \
    TTPlatformEqualToPlatform(platformName1, platformName2)

#define TTA_PLATFORM_EQUAL_PLATFORM(name1, name2)   \
    TTPlatformNameEqualToPlatformName(name1, name2)

// 平台名称 ？= 平台类型
#define TTPlatformNameEqualToPlatformType(platformName, platformType)   \
    TTPlatformEqualToPlatform(platformName, TTAccountGetPlatformNameByType(platformType))

#define TTA_PLATFORM_EQUAL_TYPE(name1, type1)   \
    TTPlatformNameEqualToPlatformType(name1, type1)



#endif /* TTAccountManagerDefine_h */
