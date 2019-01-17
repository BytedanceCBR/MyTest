//
//  TTRAd.m
//  Article
//
//  Created by muhuai on 2017/5/31.
//
//

#import "TTRAd.h"

#import <TTBaseLib/NSString+URLEncoding.h>
#import <TTBaseLib/NSStringAdditions.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/TTURLUtils.h>
#import <TTRoute/TTRoute.h>
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import "TTLocationManager.h"

@implementation TTRAd
+ (TTRJSBInstanceType)instanceType {
    return TTRJSBInstanceTypeWebView;
}

- (void)openCommodityWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor:webview];
    BOOL isHandled = NO;
    NSString *urlString = param[@"url"];
    if (!isHandled && !isEmptyString(urlString)) { // SDK 不能处理的，使用内置浏览器打开
        NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{@"url" : urlString}];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
    }
}

- (void)callNativePhoneWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *phoneNumber = [param stringValueForKey:@"tel_num" defaultValue:nil];
    NSInteger dialActionType = [param tt_intValueForKey:@"dial_action_type"];
    if (!isEmptyString(phoneNumber)) {
        NSURL *URL = [TTStringHelper URLWithURLString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
        if ([TTDeviceHelper OSVersionNumber] < 8) {
            [self listenCall:dialActionType];
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:URL]];
            [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
            // 这里delay1s之后把callWebView干掉，不能直接干掉，否则不能打电话。
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [callWebview removeFromSuperview];
            });
//            return nil;
        }
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [self listenCall:dialActionType];
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
//    return nil;
}

//监听电话状态
- (void)listenCall:(NSInteger)dialActionType
{
    void (^callBlock)(NSString *status) =  ^(NSString *status){
        if (!isEmptyString(status)) {
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            NSString* jsString = [NSString stringWithFormat:@"window.__toutiaoNativePhoneCallback('%@', '%@');", status, @(timeStamp*1000).stringValue];
            if([NSThread isMainThread])
            {
                [self.engine ttr_evaluateJavaScript:jsString completionHandler:nil];
            }
            else
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.engine ttr_evaluateJavaScript:jsString completionHandler:nil];
                });
            }
        }
    };
    
    //ad_id、log_extra无用,因为只给web传状态,无需打点
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:@"1" forKey:@"ad_id"];
    [dict setValue:@"1" forKey:@"log_extra"];
    [dict setValue:[NSDate date] forKey:@"dailTime"];
    [dict setValue:@"detail_call" forKey:@"position"];
    [dict setValue:@(dialActionType) forKey:@"dailActionType"];
    [dict setValue:callBlock forKey:@"block"];
    [dict setValue:@(YES) forKey:@"web_call"];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance call_callAdDict:dict];
}

- (void)temaiEventWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *queryStr = [param tt_stringValueForKey:@"query"];
    NSMutableDictionary *parameters = [[TTStringHelper parametersOfURLString:queryStr] mutableCopy];
    NSString *extraString = [parameters tt_stringValueForKey:@"extra"];
    
    if (!isEmptyString(extraString)) {
        extraString = [extraString URLDecodedString];
        NSError *error = nil;
        NSDictionary *dict = [extraString JSONValue];
        if (!error && [dict isKindOfClass:[NSDictionary class]]) {
            [parameters setValue:nil forKey:@"extra"];
            [parameters addEntriesFromDictionary:dict];
        }
    }
    
    TTR_CALLBACK_SUCCESS
}

- (void)getAddressWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    
    NSMutableDictionary* locationDict = [NSMutableDictionary dictionaryWithDictionary:[[TTLocationManager sharedManager] getAmapInfo]];
    
    TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
    NSString* provice = placemarkItem.province;
    if (isEmptyString(provice)) {
        provice = [TTLocationManager sharedManager].baiduPlacemarkItem.province;
        if (isEmptyString(provice)){
            provice = [TTLocationManager sharedManager].amapPlacemarkItem.province;
        }
    }
    
    [locationDict setValue:provice forKey:@"province"];
    callback(TTRJSBMsgSuccess, @{@"address_info": locationDict,@"code": @(locationDict[@"latitude"] != nil && [locationDict[@"latitude"] integerValue] != 0)});
}


@end
