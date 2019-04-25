//
//  TTRVideo.m
//  Article
//
//  Created by muhuai on 2017/5/18.
//
//

#import "TTRVideo.h"

#warning 因为@"kArticleJSBridgePlayVideoNotification" 这个通知import
@implementation TTRVideo

+ (TTRJSBInstanceType)instanceType {
    return TTRJSBInstanceTypeWebView;
}

TTR_PRIVATE_HANDLER(@"TTRVideo.playNativeVideo")
- (void)playNativeVideoWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    if ([param isKindOfClass:[NSDictionary class]] && [param count] > 0) {
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:param];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kArticleJSBridgePlayVideoNotification" object:self.engine userInfo:userInfo];
    } else {
        callback(TTRJSBMsgParamError, @{@"msg": @"参数必须为json类型"});
    }
    callback(TTRJSBMsgSuccess, nil);
}

- (void)playVideoWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    if ([param isKindOfClass:[NSDictionary class]] && [param count] > 0) {
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:param];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kArticleJSBridgePlayVideoNotification" object:self.engine userInfo:userInfo];
    } else {
        callback(TTRJSBMsgParamError, @{@"msg": @"参数必须为json类型"});
    }
    callback(TTRJSBMsgSuccess, nil);
}

- (void)pauseVideoWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kArticleJSBridgePauseVideoNotification" object:self.engine userInfo:nil];
    callback(TTRJSBMsgSuccess, nil);
}
@end
