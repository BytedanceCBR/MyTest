//
//  TTAccountLoginConfLogic.h
//  TTAccountLogin
//
//  Created by liuzuopeng on 27/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTAccountLoginDefine.h"



typedef NSString * (^TTAccountLoginDynamicConfTextBlock)();
typedef NSString * (^TTAccountLoginDynamicConfTextForTypeBlock)(NSInteger type);
typedef NSArray  * (^TTAccountLoginDynamicConfLoginPlatformListBlock)();

/**
 * 服务端下发设置和配置信息
 */
@interface TTAccountLoginConfLogic : NSObject

#pragma mark - 服务端下发配置

+ (void)setQuickRegisterPageTitleBlock:(TTAccountLoginDynamicConfTextBlock)aHandler;
+ (NSString *)quickRegisterPageTitle;


+ (void)setQuickRegisterButtonTextBlock:(TTAccountLoginDynamicConfTextBlock)aHandler;
+ (NSString *)quickRegisterButtonText;


+ (void)setLoginDialogTitleHandler:(TTAccountLoginDynamicConfTextForTypeBlock)aHandler;
+ (NSString *)loginDialogTitleForType:(NSInteger /*TTAccountLoginDialogTitleType*/)type;


+ (void)setLoginAlertTitleHandler:(TTAccountLoginDynamicConfTextForTypeBlock)aHandler;
+ (NSString *)loginAlertTitleForType:(NSInteger /*TTAccountLoginAlertTitleType*/)type;


+ (void)setLoginPlatformEntryListHandler:(TTAccountLoginDynamicConfLoginPlatformListBlock)aHandler;
+ (NSArray<NSString *> *)loginPlatformEntryList;


+ (BOOL)quickLoginSwitch __deprecated_msg("已不再使用，直接返回NO");


#pragma mark - 配置登录平台相关信息

/**
 *  @{
 *      @(TTAccountLoginPlatformType): ***,
 *  }
 */
+ (void)setLoginPlatformNames:(NSDictionary *)platformNameMapper;
+ (NSString *)loginPlatformNameForType:(TTAccountLoginPlatformType)type;

// 只支持内测版，非内测版不生效
+ (void)setLoginPlatforms:(TTAccountLoginPlatformType)platforms;
+ (TTAccountLoginPlatformType)loginPlatforms;

@end



#define TT_LOGIN_PLATFORM_EMAIL \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeEmail]

#define TT_LOGIN_PLATFORM_PHONE \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypePhone]

#define TT_LOGIN_PLATFORM_HUOSHAN \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeHuoshan]

#define TT_LOGIN_PLATFORM_DOUYIN \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeDouyin]

#define TT_LOGIN_PLATFORM_WECHAT \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeWeChat]

#define TT_LOGIN_PLATFORM_WECHAT_SNS \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeWeChatSNS]

#define TT_LOGIN_PLATFORM_QZONE \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeQZone]

#define TT_LOGIN_PLATFORM_QQWEIBO \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeQQWeibo]

#define TT_LOGIN_PLATFORM_SINAWEIBO \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeSinaWeibo]

#define TT_LOGIN_PLATFORM_RENREN \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeRenRen]

#define TT_LOGIN_PLATFORM_TIANYI \
[TTAccountLoginConfLogic loginPlatformNameForType:TTAccountLoginPlatformTypeTianYi]


