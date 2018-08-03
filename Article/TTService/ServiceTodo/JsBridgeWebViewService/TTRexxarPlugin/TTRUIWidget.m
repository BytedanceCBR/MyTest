//
//  TTRUIWidget.m
//  Article
//
//  Created by muhuai on 2017/6/13.
//
//

#import "TTRUIWidget.h"
#import <TTUIWidget/TTIndicatorView.h>
#import <TTUIWidget/TTThemedAlertController.h>

@implementation TTRUIWidget

- (void)toastWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *text = [param objectForKey:@"text"];
    // `icon_type` 可选，目前仅一种 type ，即 `icon_success`。
    if (text.length > 0) {
        NSString *iconType = [param objectForKey:@"icon_type"];
        if (!isEmptyString(iconType)) {
            if ([iconType isEqualToString:@"icon_success"]) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            } else {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
        } else {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        callback(TTRJSBMsgSuccess, @{@"code": @1});
    } else {
        callback(TTRJSBMsgParamError, @{@"code": @0,
                                        @"msg": @"text不能为空"});
    }
}

- (void)alertWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    NSString *title = [param tt_stringValueForKey:@"title"];
    if (!isEmptyString(title)) {
        NSString *message = [param tt_stringValueForKey:@"message"];
        TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:title message:message preferredType:TTThemedAlertControllerTypeAlert];
        NSString *cancelTitle = [param tt_stringValueForKey:@"cancel_text"] ?: @"取消";
        [alertController addActionWithTitle:cancelTitle actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            callback(TTRJSBMsgSuccess, @{@"code" : @0});
        }];
        NSString *confirmTitle = [param tt_stringValueForKey:@"confirm_text"] ?: @"确定";
        [alertController addActionWithTitle:confirmTitle actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            callback(TTRJSBMsgSuccess, @{@"code" : @1});
        }];
        [alertController showFrom:controller animated:YES];
    } else {
        callback(TTRJSBMsgParamError, @{@"code" : @0,
                                        @"msg"  : @"title不能为空"});
        
    }
}

@end
