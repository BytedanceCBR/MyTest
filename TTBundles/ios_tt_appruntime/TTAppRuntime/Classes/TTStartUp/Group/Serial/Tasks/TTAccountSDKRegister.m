//
//  TTAccountSDKRegister.m
//  wenda
//
//  Created by liuzuopeng on 5/16/17.
//  Copyright © 2017 Bytedance Inc. All rights reserved.
//

#import "TTAccountSDKRegister.h"
#import "TTAccountBusiness.h"
#import "TTAccountLoginConfLogic.h"
#import "TTSandBoxHelper.h"
#import <TTNetBusiness/TTNetworkUtilities.h>
#import "SSCookieManager.h"
#import "TTInstallIDManager.h"
#import "TTProjectLogicManager.h"
#import "SSCommonLogic.h"
#import "NewsBaseDelegate.h"
//#import "TTAccountLoggerImp.h"
#import "TTAccountTestSettings.h"
#import "CommonURLSetting.h"
#import <FHHouseBase/FHURLSettings.h>
#import "FHContainerStartupTask.h"
//#import <BDSDKApi+CompanyProduct.h>
#import "TTLaunchDefine.h"
#import <TTSettingsManager/TTSettingsManager+Private.h>

DEC_TASK("TTAccountSDKRegister",FHTaskTypeSerial,TASK_PRIORITY_HIGH+5);


@implementation TTAccountSDKRegister

- (NSString *)taskIdentifier
{
    return @"TTAccountSDK";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    
    // 需要业务方通过注入的方式，实现打点上报和监控功能
    [FHContainerStartupTask registerInterfaces];
    [self.class logoutIfNoBindMobile];
    [self.class startAccountService];
    [self.class configureAccountSDK];
    [self.class configureAccountLoginManager];
    
//    [self.class bindConsumerBDOpenSDK];
}

//+ (void)bindConsumerBDOpenSDK
//{
//    [BDSDKApi bindConsumerProductType:BDSDKProductTypeToutiao];
//}

/// 如果没有手机号强制登出账号
+ (void)logoutIfNoBindMobile {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([TTAccount sharedAccount].isLogin && ![TTAccount sharedAccount].user.mobile.length) {
            [TTAccount logoutInScene:TTAccountLogoutSceneNormal completion:^(BOOL success, NSError * _Nullable error) {
//                if (success) {
//                    NSLog(@"logoutIfNoBindMobile sucess");
//                }
//                if (error) {
//                    NSLog(@"logoutIfNoBindMobile error %@",error);
//                }
            }];
        }
    });
}

+ (void)startAccountService
{
    [TTAccountService sharedAccountService];
}

+ (void)configureAccountSDK
{
    // 透传SDK Setting， 将业务方setting 接口下发内容透传给SDK。（必须）
    [[TTAccount sharedAccount] updateSettings:[TTSettingsManager sharedManager].currentSettings];
    /*
     前后台切换时是否自动同步用户信息 [Default is NO]；策略是：当前是登录状态，则首次启动或从后台到前台时同步。该接口有session续期的功能，开启后，能在前后台切换时进行session续期，否则可能session 到期后的异常掉线。
     */
    [TTAccount accountConf].autoSynchronizeUserInfo = YES;
    // x_tt_token 长票据功能是否可用,默认开启，可以配置一个开关，控制是否开启
    [TTAccount accountConf].isXTTTokenActive = NO;
    // x_tt_token 长票据功能轮询间隔，默认 10 min
//    [TTAccount accountConf].tokenPollingInterveral = TTATokenPollingInterveralTen;
    // 设置需要票据的域名（必须）
//    NSArray *domainWhiteList = @[@".haoduofangs.com"];
//    [TTAccount accountConf].needTokenDomins = domainWhiteList;
    [TTAccount accountConf].multiThreadSafeEnabled = [TTAccountTestSettings threadSafeSupported];
    if ([TTSandBoxHelper isInHouseApp]) {
        [TTAccount accountConf].sharingKeyChainGroup = @"XXHND5J98K.com.ss.iphone.InHouse.article.News";
    }else{
        [TTAccount accountConf].sharingKeyChainGroup = @"XXHND5J98K.com.bytedance.keychainshare";
    }
//#if defined(INHOUSE)
//    [TTAccount accountConf].sharingKeyChainGroup = @"XXHND5J98K.com.ss.iphone.InHouse.article.News";
//#else
//    [TTAccount accountConf].sharingKeyChainGroup = @"XXHND5J98K.com.bytedance.keychainshare";
//#endif
    
    [TTAccount accountConf].domain = [FHURLSettings baseURL];

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
    
//    TTAccountLoggerImp *delegateImp = [TTAccountLoggerImp new];
//    [TTAccount accountConf].loggerDelegate  = delegateImp;
//    [TTAccount accountConf].monitorDelegate = delegateImp;
    
    [SSCookieManager setSessionIDToCookie:[[TTAccount sharedAccount] sessionKey]];

    [self.class registerAccountPlatforms];
}

+ (void)registerAccountPlatforms
{
    NSString *WXAppID = [SharedAppDelegate weixinAppID];
    NSString *QQAppID = TTLogicString(@"qqOAuthAppID", @"");
    NSString *WBAppID = TTLogicString(@"sinaAppKey", @"2504490989");
    NSString *WBAppSecret  = TTLogicString(@"sinaAppSecret", @"8ba197824d80d38928470e1ffa4c5618");
    NSString *hotsoonAppID = TTLogicString(@"hotsoonOAuthAppID", @"bdefc41a8703eae8ce"); // 默认值是普通版appId
    NSString *awemeAppID = [TTSandBoxHelper isInHouseApp] ? @"awa2wr3xz81cwr2x" : @"awua3q1k3j4ymeii";; // 默认值是普通版appId
    NSString *awemePlatformID = [TTSandBoxHelper isInHouseApp] ? @"906" : @"846";
    
    //  https://bytedance.feishu.cn/space/doc/doccnmfRT2HS5OmN6LlbtI
    NSString *mobileAppID = [TTSandBoxHelper isInHouseApp] ? @"300011896473" : @"300011896471";
    NSString *mobileAppKey = [TTSandBoxHelper isInHouseApp] ? @"AA0160CB47BC4EC6A87EB2E3CA0DB90B" : @"BD739FE2A70F6C5DF69484BD7B21B758";
    NSString *telecomAppID = @"8025208701";
    NSString *telecomAppKey = @"OIXQNHzyNMdD5s7fwrrNJmvTrvL4qJcq";
    NSString *unicomAppID = @"99166000000000000371";
    NSString *unicomAppKey = @"bf4ca042fafec19a84737211d6f80e49";
    BOOL isTestChannel = [TTSandBoxHelper isInHouseApp];

    // 注册运营商一键登录
    [TTAccount registerOneKeyLoginService:TTAccountMobile appId:mobileAppID appKey:mobileAppKey isTestChannel:isTestChannel];
    [TTAccount registerOneKeyLoginService:TTAccountUnion appId:unicomAppID appKey:unicomAppKey isTestChannel:isTestChannel];
    [TTAccount registerOneKeyLoginService:TTAccountTelecom appId:telecomAppID appKey:telecomAppKey isTestChannel:isTestChannel];
    TTAccountPlatformConfiguration *wechatConf = [TTAccountPlatformConfiguration new];
    wechatConf.platformType = TTAccountAuthTypeWeChat;
    wechatConf.consumerKey  = WXAppID;
    wechatConf.universalLink = @"https://i.haoduofangs.com/";
    wechatConf.platformName = PLATFORM_WEIXIN;
//#ifdef INHOUSE
    if ([TTSandBoxHelper isInHouseApp]) {
        wechatConf.platformAppId = @"52";
    }
//#endif
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
    
    TTAccountPlatformConfiguration *apple = [[TTAccountPlatformConfiguration alloc] init];
    apple.platformAppId = @"844";
    apple.platformType = TTAccountAuthTypeApple;
    [TTAccount registerPlatform:apple];
    
    TTAccountPlatformConfiguration *awemeConf = [TTAccountPlatformConfiguration new];
    awemeConf.platformType = TTAccountAuthTypeDouyin;
    awemeConf.consumerKey  = awemeAppID;
    awemeConf.platformName = PLATFORM_DOUYIN;
    awemeConf.platformAppId = awemePlatformID;
    awemeConf.permissions = [NSOrderedSet orderedSetWithObjects:@"user_info",@"mobile", nil];
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
