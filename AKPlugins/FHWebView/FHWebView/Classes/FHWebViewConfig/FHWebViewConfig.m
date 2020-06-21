//
//  FHWebViewConfig.m
//  FHWebView
//
//  Created by 谢思铭 on 2019/5/15.
//

#import "FHWebViewConfig.h"
#import "UIColor+Theme.h"
#import "FHEnvContext.h"
#import "FHHomeConfigManager.h"
#import "TTAccount+NetworkTasks.h"
#import "TTAccountLoginManager.h"
#import "TTUIResponderHelper.h"
#import "TTAccountManager.h"

@implementation FHWebViewConfig

+ (instancetype)sharedInstance {
    static FHWebViewConfig *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[FHWebViewConfig alloc] init];
    }
    return _sharedInstance;
}

+ (UIColor *)progressViewLineFillColor {
    return [UIColor themeOrange1];
}

+ (FHAppVersion)appVersion {
    return FHAppVersionC;
}

- (void)showEmptyView:(UIView *)view retryBlock:(void (^)(void))retryBlock {
    
}

- (void)hideEmptyView {
    
}

- (void)showLoading:(UIView *)view {
    
}

- (void)hideLoading {
    
}

+ (UILabel *)defaultTitleView {
    return nil;
}

+ (NSDictionary *)getRequestCommonParams {
    return [[FHEnvContext sharedInstance] getRequestCommonParams];
}

+ (void)onAccountCancellationSuccessCallback:(TTRJSBResponse)callback controller:(UIViewController *)controller {
    NSString *cityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    
    if ([cityId isKindOfClass:[NSString class]] && cityId.length > 0) {
        
        [controller.navigationController popToRootViewControllerAnimated:NO];
        
        if (![[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isCurrentTabFirst]) {
            [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarFirst];
        }
        
        NSString *url = [NSString stringWithFormat:@"fschema://fhomepage?city_id=%@",cityId];
        // 注销登录
        [TTAccount logoutInScene:TTAccountLogoutSceneCancel completion:^(BOOL success, NSError * _Nullable error) {
            callback(TTRJSBMsgSuccess, @{@"code": @(success ? 1 : 0)});
        }];        
        
        [FHEnvContext openLogoutSuccessURL:url completion:^(BOOL isSuccess) {
            
        }];
    }
}

+ (void)loginWithParam:(NSDictionary *)param webView:(UIView<TTRexxarEngine> *)webview {
    TTAccountLoginAlertTitleType type = [param tt_integerValueForKey:@"title_type"];
    NSString *title = [param tt_stringValueForKey:@"title"];
    NSString *alertTitle = [param tt_stringValueForKey:@"alert_title"];
    NSString *platform = [param objectForKey:@"platform"];
    NSString *source = [param tt_stringValueForKey:@"login_source"];
    
    NSDictionary *callbackResult = nil;
    if (isEmptyString(platform)) //全平台
    {
        if (title.length > 0 || alertTitle.length > 0) {
            [TTAccountLoginManager showLoginAlertWithTitle:alertTitle source:source completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
                if (type == TTAccountAlertCompletionEventTypeTip) {
                    [TTAccountLoginManager presentLoginViewControllerFromVC:[TTUIResponderHelper topNavigationControllerFor:webview] title:title source:source completion:^(TTAccountLoginState state) {
                        
                    }];
                }
            }];
        } else {
            [TTAccountManager showLoginAlertWithType:type source:source completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
                if (type == TTAccountAlertCompletionEventTypeTip) {
                    [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:webview] type:TTAccountLoginDialogTitleTypeDefault source:source completion:^(TTAccountLoginState state) {
                        
                    }];
                }
            }];
        }
    }else{
        callbackResult = @{@"code": @0};
    }
}

@end
