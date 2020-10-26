//
//  TTRLinkChat.m
//  FHWebView
//
//  Created by wangzhizhou on 2020/10/25.
//

#import "TTRLinkChat.h"
#import <TTRexxar/TTRJSBForwarding.h>
#import <FHCommonUI/ToastManager.h>

@implementation TTRLinkChat

- (void)getUserPermissionWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    
    [self showHint:NSStringFromSelector(_cmd)];
    callback(TTRJSBMsgSuccess, @{});
}

- (void)openPhotoLibraryWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    [self showHint:NSStringFromSelector(_cmd)];

    callback(TTRJSBMsgSuccess, @{});
    
    
    [webview ttr_fireEvent:@"linkchatUploadVideo" data:@{
        @"state": @2,
        @"success": @"上传成功",
        @"message": @"",
        @"data": @{
                @"videoSrc": @"no valid",
                @"videoCoverImg": @"none",
                @"width": @100,
                @"size": @"大小按什么单位传？"
        }
    }];
}

- (void)showHint:(NSString *)hint {
    [[ToastManager manager] showToast:hint];
}
@end
