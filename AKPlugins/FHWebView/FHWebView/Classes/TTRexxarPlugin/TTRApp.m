//
//  TTRApp.m
//  Article
//
//  Created by muhuai on 2017/5/19.
//
//

#import "TTRApp.h"
#import "TTJSBAuthManager.h"
#import "TTInstallIDManager.h"

#import <TTRexxar/TTRexxarNotificationCenter.h>
#import <TTRexxar/TTRJSBForwarding.h>
//#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/TTSandBoxHelper.h>
#import "NSDictionary+TTAdditions.h"
#import <TTBaseLib/TTBaseMacro.h>
#import "TTAccount.h"
#import "TTDeviceHelper.h"
#import "FHEnvContext.h"
#import "ArticleJSManager.h"

extern NSString *const kFHPLoginhoneNumberCacheKey;

@implementation TTRApp

+ (void)load {
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRApp.sendNotification" for:@"sendNotification"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 监控电池电量
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeBatteryState:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeBatteryLevel:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    }
    return self;
}

- (void)isAppInstalledWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString * openURL = [param valueForKey:@"open_url"];
    NSURL * URL = [TTStringHelper URLWithURLString:openURL];
    BOOL installed = NO;
    if (URL && [[UIApplication sharedApplication] canOpenURL:URL]) {
        installed = YES;
    }
    callback(TTRJSBMsgSuccess, @{@"installed":@(installed)});
}

- (void)copyToClipboardWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *content = [param stringValueForKey:@"content" defaultValue:nil];
    NSDictionary *callbackResult = nil;
    if (!isEmptyString(content)) {
        [[UIPasteboard generalPasteboard] setString:content];
        callbackResult = @{@"code": @1};
        callback(TTRJSBMsgSuccess, callbackResult);
    }
    else {
        callbackResult = @{@"code": @0};
        callback(TTRJSBMsgParamError, callbackResult);
    }
    return;
}

- (void)appInfoWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    /**
     *  [14-12-30 下午2:35:17] 苏 琦: appName字段安卓和iOS的所有版本，都传NewsArticle吧，为了让外面的人用着方便。iOS请@晨龙 再另加一个字段给我们内部区分普通探索专业版
     *  [14-12-30 下午2:36:01] 张晨龙: innerAppName
     */
    NSString *appName = [TTSandBoxHelper appName]?:@"f101";
    [data setValue:appName forKey:@"appName"];
    [data setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppName"] forKey:@"innerAppName"];
    [data setValue:[TTSandBoxHelper versionName] forKey:@"appVersion"];
    [data setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    NSString *netType = nil;
    if(TTNetworkWifiConnected()) {
        netType = @"WIFI";
    } else if(TTNetwork4GConnected()) {
        netType = @"4G";
    } else if(TTNetwork4GConnected()) {
        netType = @"3G";
    } else if(TTNetworkConnected()) {
        netType = @"MOBILE";
    }
    
    //无网判断
    NSString *netAvailable = TTNetworkConnected() ? @"1" : @"0";
    [data setValue:netAvailable forKey:@"netAvailable"];
    
    [data setValue:netType forKey:@"netType"];
    
    if([[TTJSBAuthManager sharedManager] engine:webview isAuthorizedMeta:@"device_id" domain:webview.ttr_url.host.lowercaseString]) {
        [data setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    }
    
    if([[TTJSBAuthManager sharedManager] engine:webview isAuthorizedMeta:@"user_id" domain:webview.ttr_url.host.lowercaseString]) {
        
        NSString *uid = [[TTAccount sharedAccount] userIdString];
        if (uid) {
            [data setValue:uid forKey:@"user_id"];
        }
    }
    
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    id form_phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    id logIn_phoneCache = [sendPhoneNumberCache objectForKey:kFHPLoginhoneNumberCacheKey];
    
    NSString *phoneNum = (NSString *)form_phoneCache;
    NSString *phoneNumLogin = (NSString *)logIn_phoneCache;
    [data setValue:phoneNum forKey:@"form_phone"];
    [data setValue:phoneNumLogin forKey:@"login_phone"];

    
    NSString *idfaString = [TTDeviceHelper idfaString];
    [data setValue:idfaString forKey:@"idfa"];
    
    if (callback) {
        callback(TTRJSBMsgSuccess, data);
    }
}

- (void)saveWebPhoneWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    NSString *phoneNum = [param objectForKey:@"phone"];
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    if (phoneNum) {
        [sendPhoneNumberCache setObject:phoneNum forKey:kFHPhoneNumberCacheKey];
    }
}

- (void)configWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *clientID = [param objectForKey:@"client_id"];
    if (isEmptyString(clientID)) {
        if (callback) {
            callback(TTRJSBMsgFailed, @{@"code": @"0", @"msg": @"client_id 不能为空"});
        }
    }
    [[TTJSBAuthManager sharedManager] startGetAuthConfigWithPartnerClientKey:clientID partnerDomain:webview.ttr_url.host.lowercaseString secretKey:nil finishBlock:^(JSAuthInfoModel *authInfo) {
        if (callback) {
            callback(TTRJSBMsgSuccess, @{@"code": @"1"});
        }
    }];
}


- (void)sendNotificationWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *name = [param tt_stringValueForKey:@"type"];
    NSDictionary *data = [param tt_dictionaryValueForKey:@"data"];
    
    if (!name.length) {
        TTR_CALLBACK_WITH_MSG(TTRJSBMsgParamError, @"type不能为空");
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:data];
    
    //转发给所有webview容器, 通知前端页面
    [[TTRexxarNotificationCenter defaultCenter] postNotification:name data:data];
    
    TTR_CALLBACK_SUCCESS;
}

//获取状态栏信息，包括时间、电量等，目前小说业务在用
- (void)getStatusBarInfoWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller{
    //时间制式调用
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL isTimeStyleTwelve = containsA.location != NSNotFound;
    //时间的获取
    NSInteger timeStamp = [[NSDate date] timeIntervalSince1970];
    //电池状态
    UIDevice* device = [UIDevice currentDevice];
    UIDeviceBatteryState batteryState = [device batteryState];
    //电量
    float batteryLevel = [device batteryLevel];
    
    if (callback) {
        callback(TTRJSBMsgSuccess, @{@"batteryState": [NSNumber numberWithInt:batteryState],
                                     @"batteryLevel": [NSNumber numberWithFloat:(batteryLevel*100)],
                                     @"timeStyle": [NSNumber numberWithBool:isTimeStyleTwelve],
                                     @"time" :@(timeStamp)});
    }
}

- (void)getArticleConfigWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    NSDictionary *dicData = [ArticleJSManager shareInstance].feArticleH5Config;
    if (dicData && [dicData isKindOfClass:[NSDictionary class]]) {
        if (callback) {
            callback(TTRJSBMsgSuccess, @{@"code": @"1"});
        }
    } else {
        if (callback) {
            callback(TTRJSBMsgFailed, @{@"code": @"0", @"msg": @"fe_article_h5_config 为空"});
        }
    }
}

#pragma mark - BatteryStateDidChangeNotification

//电池状态发生改变时调用
- (void)didChangeBatteryState:(NSNotification *)notification
{
    UIDeviceBatteryState batteryState = [[UIDevice currentDevice] batteryState];
    [self.engine ttr_fireEvent:@"batteryStateChanged"data:@{@"batteryState": [NSNumber numberWithInt:batteryState]}];
}

//电池电量发生改变时调用
- (void)didChangeBatteryLevel:(NSNotification *)notification
{
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
    [self.engine ttr_fireEvent:@"batteryLevelChanged"data:@{@"batteryLevel":[NSNumber numberWithFloat:(batteryLevel * 100)]}];
}


@end
