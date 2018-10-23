//
//  TTAccountSDKRegister.m
//  wenda
//
//  Created by liuzuopeng on 5/16/17.
//  Copyright © 2017 Bytedance Inc. All rights reserved.
//

#import "TTAccountSDKRegister.h"
#import <TTAccountBusiness.h>
#import <TTAccountLoginConfLogic.h>
#import <TTSandBoxHelper.h>
#import "TTNetworkUtilities.h"
#import "SSCookieManager.h"
#import "TTInstallIDManager.h"
#import "TTProjectLogicManager.h"
#import "SSCommonLogic.h"

#import "NewsBaseDelegate.h"
#import "TTAccountLoggerImp.h"
#import "TTAccountTestSettings.h"

//#import <BDSDKApi+CompanyProduct.h>



@implementation TTAccountSDKRegister

- (NSString *)taskIdentifier
{
    return @"TTAccountSDK";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    
    [self.class startAccountService];
    [self.class configureAccountSDK];
    [self.class configureAccountLoginManager];
    
//    [self.class bindConsumerBDOpenSDK];
}

//+ (void)bindConsumerBDOpenSDK
//{
//    [BDSDKApi bindConsumerProductType:BDSDKProductTypeToutiao];
//}

+ (void)startAccountService
{
    [TTAccountService sharedAccountService];
}

+ (void)configureAccountSDK
{
    [SSCookieManager setSessionIDToCookie:[[TTAccount sharedAccount] sessionKey]];
    
    [TTAccount accountConf].multiThreadSafeEnabled = [TTAccountTestSettings threadSafeSupported];
#if defined(INHOUSE)
    [TTAccount accountConf].sharingKeyChainGroup = @"XXHND5J98K.com.ss.iphone.InHouse.article.News";
#else
    [TTAccount accountConf].sharingKeyChainGroup = @"XXHND5J98K.com.bytedance.keychainshare";
#endif
    
    [TTAccount accountConf].networkParamsHandler = ^NSDictionary *() {
        return [[TTNetworkUtilities commonURLParameters] copy];
    };
    
    [TTAccount accountConf].appRequiredParamsHandler = ^NSDictionary *() {
        NSMutableDictionary *requiredDict = [NSMutableDictionary dictionaryWithCapacity:4];
        [requiredDict setValue:[[TTInstallIDManager sharedInstance] installID] forKey:TTAccountInstallIdKey];
        [requiredDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:TTAccountDeviceIdKey];
        [requiredDict setValue:nil forKey:TTAccountSessionKeyKey];
        [requiredDict setValue:[TTSandBoxHelper ssAppID] forKey:TTAccountSSAppIdKey];
        return [requiredDict copy];
    };
    
    [TTAccount accountConf].accountMessageFirstResponder = [TTAccountService sharedAccountService];
    
    TTAccountLoggerImp *delegateImp = [TTAccountLoggerImp new];
    [TTAccount accountConf].loggerDelegate  = delegateImp;
    [TTAccount accountConf].monitorDelegate = delegateImp;
    
    [self.class registerAccountPlatforms];
}

+ (void)registerAccountPlatforms
{
    NSString *WXAppID = [SharedAppDelegate weixinAppID];
    NSString *QQAppID = TTLogicString(@"qqOAuthAppID", @"");
    NSString *WBAppID = TTLogicString(@"sinaAppKey", @"2504490989");
    NSString *WBAppSecret  = TTLogicString(@"sinaAppSecret", @"8ba197824d80d38928470e1ffa4c5618");
    NSString *hotsoonAppID = TTLogicString(@"hotsoonOAuthAppID", @"bdefc41a8703eae8ce"); // 默认值是普通版appId
    NSString *awemeAppID = TTLogicString(@"awemeOAuthAppID", @"bd3ffc36cf30e111d0"); // 默认值是普通版appId
    
    TTAccountPlatformConfiguration *wechatConf = [TTAccountPlatformConfiguration new];
    wechatConf.platformType = TTAccountAuthTypeWeChat;
    wechatConf.consumerKey  = WXAppID;
    wechatConf.platformName = PLATFORM_WEIXIN;
#ifdef INHOUSE
    if ([TTSandBoxHelper isInHouseApp]) {
        wechatConf.platformAppId = @"52";
    }
#endif
    [TTAccount registerPlatform:wechatConf];
    
    TTAccountPlatformConfiguration *QQConf = [TTAccountPlatformConfiguration new];
    QQConf.platformType = TTAccountAuthTypeTencentQQ;
    QQConf.consumerKey  = QQAppID;
    QQConf.platformName = PLATFORM_QZONE;
    [TTAccount registerPlatform:QQConf];
    
    TTAccountPlatformConfiguration *tencentWBConf = [TTAccountPlatformConfiguration new];
    tencentWBConf.platformType = TTAccountAuthTypeTencentWB;
    tencentWBConf.platformName = PLATFORM_QQ_WEIBO;
    [TTAccount registerPlatform:tencentWBConf];
    
    TTAccountPlatformConfiguration *sinawbConf = [TTAccountPlatformConfiguration new];
    sinawbConf.platformType = TTAccountAuthTypeSinaWeibo;
    sinawbConf.consumerKey  = WBAppID;
    sinawbConf.consumerSecret = WBAppSecret;
    sinawbConf.platformName = PLATFORM_SINA_WEIBO;
    sinawbConf.platformRedirectUrl = [CommonURLSetting authLoginSuccessURLString];
    NSString *sinawbSSOSchemeURL = TTLogicStringNODefault(@"sinaAppScheme");
    if (isEmptyString(sinawbSSOSchemeURL)) {
        sinawbSSOSchemeURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SSSinaWeiboSchema"];
    }
    sinawbConf.authCallbackSchemeUrl = sinawbSSOSchemeURL;
    [TTAccount registerPlatform:sinawbConf];
    
    TTAccountPlatformConfiguration *renrenConf = [TTAccountPlatformConfiguration new];
    renrenConf.platformType = TTAccountAuthTypeRenRen;
    renrenConf.platformName = PLATFORM_RENREN_SNS;
    [TTAccount registerPlatform:renrenConf];
    
    TTAccountPlatformConfiguration *tianyiConf = [TTAccountPlatformConfiguration new];
    tianyiConf.platformType = TTAccountAuthTypeTianYi;
    tianyiConf.platformName = PLATFORM_TIANYI;
    [TTAccount registerPlatform:tianyiConf];
    
    TTAccountPlatformConfiguration *hotsoonConf = [TTAccountPlatformConfiguration new];
    hotsoonConf.platformType = TTAccountAuthTypeHuoshan;
    hotsoonConf.consumerKey  = hotsoonAppID;
    hotsoonConf.platformName = PLATFORM_HUOSHAN;
    hotsoonConf.platformAppId = TTLogicString(@"hotsoonPlatformAppID", nil);
    [TTAccount registerPlatform:hotsoonConf];
    
    TTAccountPlatformConfiguration *awemeConf = [TTAccountPlatformConfiguration new];
    awemeConf.platformType = TTAccountAuthTypeDouyin;
    awemeConf.consumerKey  = awemeAppID;
    awemeConf.platformName = PLATFORM_DOUYIN;
    awemeConf.platformAppId = TTLogicString(@"awemePlatformAppID", nil);
    [TTAccount registerPlatform:awemeConf];
}

+ (void)configureAccountLoginManager
{
    [TTAccountLoginConfLogic setQuickRegisterPageTitleBlock:^NSString *{
        return [SSCommonLogic quickRegisterPageTitle];
    }];
    [TTAccountLoginConfLogic setQuickRegisterButtonTextBlock:^NSString *{
        return [SSCommonLogic quickRegisterButtonText];
    }];
    [TTAccountLoginConfLogic setLoginDialogTitleHandler:^NSString *(NSInteger type) {
        return [SSCommonLogic dialogTitleOfIndex:type];
    }];
    [TTAccountLoginConfLogic setLoginAlertTitleHandler:^NSString *(NSInteger type) {
        return [SSCommonLogic loginAlertTitleOfIndex:type];
    }];
    [TTAccountLoginConfLogic setLoginPlatformEntryListHandler:^NSArray *{
        return [SSCommonLogic loginEntryList];
    }];
    
    NSMutableDictionary *platformNameMapper = [NSMutableDictionary dictionary];
    [platformNameMapper setObject:PLATFORM_EMAIL
                           forKey:@(TTAccountLoginPlatformTypeEmail)];
    [platformNameMapper setObject:PLATFORM_PHONE
                           forKey:@(TTAccountLoginPlatformTypePhone)];
    [platformNameMapper setObject:PLATFORM_WEIXIN
                           forKey:@(TTAccountLoginPlatformTypeWeChat)];
    [platformNameMapper setObject:PlatformWeixin
                           forKey:@(TTAccountLoginPlatformTypeWeChatSNS)];
    [platformNameMapper setObject:PLATFORM_QZONE
                           forKey:@(TTAccountLoginPlatformTypeQZone)];
    [platformNameMapper setObject:PLATFORM_QQ_WEIBO
                           forKey:@(TTAccountLoginPlatformTypeQQWeibo)];
    [platformNameMapper setObject:PLATFORM_SINA_WEIBO
                           forKey:@(TTAccountLoginPlatformTypeSinaWeibo)];
    [platformNameMapper setObject:PLATFORM_RENREN_SNS
                           forKey:@(TTAccountLoginPlatformTypeRenRen)];
    [platformNameMapper setObject:PLATFORM_TIANYI
                           forKey:@(TTAccountLoginPlatformTypeTianYi)];
    [platformNameMapper setObject:PLATFORM_HUOSHAN
                           forKey:@(TTAccountLoginPlatformTypeHuoshan)];
    [platformNameMapper setObject:PLATFORM_DOUYIN
                           forKey:@(TTAccountLoginPlatformTypeDouyin)];
    [TTAccountLoginConfLogic setLoginPlatformNames:platformNameMapper];
    
    [TTAccountLoginConfLogic setLoginPlatforms:TTAccountLoginPlatformTypePhone | TTAccountLoginPlatformTypeWeChat];
}

@end
