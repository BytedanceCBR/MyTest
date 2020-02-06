//
//  TTRShortVideo.m
//  Article
//
//  Created by xushuangqing on 10/12/2017.
//

#import "TTRShortVideo.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTSettingsManager.h"

NSString * const TTWebviewRedpackIntroClickedNotification = @"TTWebviewRedpackIntroClickedNotification";

@implementation TTRShortVideo

- (void)getRedPackIntroWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    callback(TTRJSBMsgSuccess, @{@"res": @(NO)});
}

- (void)redpackWebIntroClickedWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    [[NSNotificationCenter defaultCenter] postNotificationName:TTWebviewRedpackIntroClickedNotification object:webview];
    TTR_CALLBACK_SUCCESS;
}

@end
