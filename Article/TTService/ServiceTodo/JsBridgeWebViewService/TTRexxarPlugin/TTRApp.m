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
#import "SmAntiFraud.h"

#import <TTRexxar/TTRexxarNotificationCenter.h>
#import <TTRexxar/TTRJSBForwarding.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTStringHelper.h>

@implementation TTRApp

+ (void)load {
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRApp.deviceInfo" for:@"deviceInfo"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRApp.sendNotification" for:@"sendNotification"];
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
    [data setValue:@"NewsArticle" forKey:@"appName"];
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
    
    [data setValue:netType forKey:@"netType"];
    
    if([[TTJSBAuthManager sharedManager] engine:webview isAuthorizedMeta:@"device_id" domain:webview.ttr_url.host.lowercaseString]) {
        [data setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    }
    
    if([[TTJSBAuthManager sharedManager] engine:webview isAuthorizedMeta:@"user_id" domain:webview.ttr_url.host.lowercaseString]) {
        [data setValue:[TTAccountManager userID] forKey:@"user_id"];
    }
    
    NSString *idfaString = [TTDeviceHelper idfaString];
    [data setValue:idfaString forKey:@"idfa"];
    
    if (callback) {
        callback(TTRJSBMsgSuccess, data);
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

- (void)deviceInfoWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSMutableDictionary *deviceInfo = [[[SmAntiFraud shareInstance] getDeviceInfoWithConfiguration:nil] mutableCopy];
    if (callback) {
        callback(TTRJSBMsgSuccess, @{@"code": @"1",
                                     @"data": [deviceInfo copy]});
    }
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
@end
