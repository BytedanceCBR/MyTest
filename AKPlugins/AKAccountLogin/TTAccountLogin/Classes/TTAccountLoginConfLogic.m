//
//  TTAccountLoginConfLogic.m
//  TTAccountLogin
//
//  Created by liuzuopeng on 27/05/2017.
//
//

#import "TTAccountLoginConfLogic.h"
#import <TTAccountSDK.h>



@implementation TTAccountLoginConfLogic

static TTAccountLoginDynamicConfTextBlock s_quickRegisterPageTitleHandler;

+ (void)setQuickRegisterPageTitleBlock:(TTAccountLoginDynamicConfTextBlock)aHandler
{
    s_quickRegisterPageTitleHandler = aHandler;
}

+ (NSString *)quickRegisterPageTitle
{
    NSString *buttonText = nil;
    if (s_quickRegisterPageTitleHandler) {
        buttonText = s_quickRegisterPageTitleHandler();
    }
    return [buttonText length] > 0 ? buttonText : NSLocalizedString(@"进入头条", nil);
}

static TTAccountLoginDynamicConfTextBlock s_quickRegisterButtonTextHandler;

+ (void)setQuickRegisterButtonTextBlock:(TTAccountLoginDynamicConfTextBlock)aHandler
{
    s_quickRegisterButtonTextHandler = aHandler;
}

+ (NSString *)quickRegisterButtonText
{
    NSString *buttonText = nil;
    if (s_quickRegisterButtonTextHandler) {
        buttonText = s_quickRegisterButtonTextHandler();
    }
    return [buttonText length] > 0 ? buttonText : NSLocalizedString(@"进入头条", nil);
}

static TTAccountLoginDynamicConfTextForTypeBlock s_loginDialogTitleHandler;

+ (void)setLoginDialogTitleHandler:(TTAccountLoginDynamicConfTextForTypeBlock)aHandler
{
    s_loginDialogTitleHandler = aHandler;
}

+ (NSString *)loginDialogTitleForType:(NSInteger /*TTAccountLoginDialogTitleType*/)type
{
    NSString *defaultTitle = NSLocalizedString(@"登录你的头条,精彩永不丢失", nil);
    if (s_loginDialogTitleHandler) {
        NSString *exoticTitle = s_loginDialogTitleHandler(type);
        if ([exoticTitle length] > 0) {
            defaultTitle = exoticTitle;
        }
    }
    return defaultTitle;
}

static TTAccountLoginDynamicConfTextForTypeBlock s_loginAlertTitleHandler;

+ (void)setLoginAlertTitleHandler:(TTAccountLoginDynamicConfTextForTypeBlock)aHandler
{
    s_loginAlertTitleHandler = aHandler;
}

+ (NSString *)loginAlertTitleForType:(NSInteger /*TTAccountLoginAlertTitleType*/)type
{
    NSString *defaultTitle = NSLocalizedString(@"登录你的头条,精彩永不丢失", nil);
    if (s_loginAlertTitleHandler) {
        NSString *exoticTitle = s_loginAlertTitleHandler(type);
        if ([exoticTitle length] > 0) {
            defaultTitle = exoticTitle;
        }
    }
    return defaultTitle;
}

static TTAccountLoginDynamicConfLoginPlatformListBlock s_loginPlatformListHandler;

+ (void)setLoginPlatformEntryListHandler:(TTAccountLoginDynamicConfLoginPlatformListBlock)aHandler
{
    s_loginPlatformListHandler = aHandler;
}

static NSArray<NSString *> *s_loginPlatformList;

+ (NSArray<NSString *> *)loginPlatformEntryList
{
    if (s_loginPlatformList && [s_loginPlatformList count] > 0) {
        return s_loginPlatformList;
    }
    
    if (s_loginPlatformListHandler) {
        s_loginPlatformList = s_loginPlatformListHandler();
    }
    return s_loginPlatformList;
}

+ (BOOL)quickLoginSwitch
{
    return NO;
}

static NSDictionary *s_platformNameMappers;

+ (void)setLoginPlatformNames:(NSDictionary *)platformNameMapper;
{
    s_platformNameMappers = platformNameMapper;
}

+ (NSString *)loginPlatformNameForType:(TTAccountLoginPlatformType)type
{
    NSString *platformNameString = nil;
    if (s_platformNameMappers) {
        platformNameString = [s_platformNameMappers objectForKey:@(type)];
    }
    
    if ([platformNameString length] <= 0) {
        NSAssert(NO, @"cann't find platform name of type <%ld>", (long)type);
        platformNameString = [self.class defaultPlatformNameFromAccountSDKForType:type];
    }
    return platformNameString;
}

static TTAccountLoginPlatformType s_supportedPlatforms;

+ (void)setLoginPlatforms:(TTAccountLoginPlatformType)platforms
{
    s_supportedPlatforms = platforms;
}

+ (TTAccountLoginPlatformType)loginPlatforms
{
    return s_supportedPlatforms;
}

//#define PlatformWeixin              @"weixin_sns"
//#define PLATFORM_WEIXIN             @"weixin"
//#define PLATFORM_RENREN_SNS         @"renren_sns"
//#define PLATFORM_QZONE              @"qzone_sns"
//#define PLATFORM_QQ_WEIBO           @"qq_weibo"
//#define PLATFORM_SINA_WEIBO         @"sina_weibo"
//#define PLATFORM_TIANYI             @"telecom"
//#define PLATFORM_EMAIL              @"email"
//#define PLATFORM_PHONE              @"phone"
+ (NSString *)defaultPlatformNameFromAccountSDKForType:(TTAccountLoginPlatformType)loginPlatformType
{
    NSString *defLoginPlatformName = nil;
    switch (loginPlatformType) {
        case TTAccountLoginPlatformTypeEmail: {
            defLoginPlatformName = @"email";
        }
            break;
        case TTAccountLoginPlatformTypePhone: {
            defLoginPlatformName = @"phone";
        }
            break;
        case TTAccountLoginPlatformTypeWeChat: {
            defLoginPlatformName = [TTAccountAuthWeChat platformName] ? : @"weixin";
        }
            break;
        case TTAccountLoginPlatformTypeWeChatSNS: {
            defLoginPlatformName = @"weixin_sns";
        }
            break;
//        case TTAccountLoginPlatformTypeQZone: {
//            defLoginPlatformName = [TTAccountAuthTencent platformName] ? : @"qzone_sns";
//        }
//            break;
//        case TTAccountLoginPlatformTypeQQWeibo: {
//            defLoginPlatformName = [TTAccountAuthTencentWeibo platformName] ? : @"qq_weibo";
//        }
//            break;
//        case TTAccountLoginPlatformTypeSinaWeibo: {
//            defLoginPlatformName = [TTAccountAuthWeibo platformName] ? : @"sina_weibo";
//        }
//            break;
//        case TTAccountLoginPlatformTypeRenRen: {
//            defLoginPlatformName = [TTAccountAuthRenren platformName] ? : @"renren_sns";
//        }
//            break;
//        case TTAccountLoginPlatformTypeTianYi: {
//            defLoginPlatformName = [TTAccountAuthTianYi platformName] ? : @"telecom";
//        }
//            break;
//        case TTAccountLoginPlatformTypeHuoshan: {
//            defLoginPlatformName = [TTAccountAuthHuoShan platformName] ? : @"hotsoon";
//        }
//            break;
//        case TTAccountLoginPlatformTypeDouyin: {
//            defLoginPlatformName = [TTAccountAuthDouYin platformName] ? : @"aweme";
//        }
//            break;
        default: {
            defLoginPlatformName = [TTAccountAuthWeChat platformName] ? : @"weixin";
        }
            break;
    }
    return defLoginPlatformName;
}

@end
