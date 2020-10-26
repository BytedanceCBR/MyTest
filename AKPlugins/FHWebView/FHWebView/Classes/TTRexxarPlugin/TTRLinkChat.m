//
//  TTRLinkChat.m
//  FHWebView
//
//  Created by wangzhizhou on 2020/10/25.
//

#import "TTRLinkChat.h"
#import <TTRexxar/TTRJSBForwarding.h>
#import <FHCommonUI/ToastManager.h>
#import <Photos/PHPhotoLibrary.h>
#import "TTUIResponderHelper.h"
#import <AVFoundation/AVCaptureDevice.h>


typedef void (^FLinkChatPermissionAskActionBlock)(void);

@implementation TTRLinkChat

- (void)getUserPermissionWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    
    NSString *name = param[@"name"];
    if(name.length > 0) {
        if([name isEqualToString:@"photo"]) {
            
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                {
                    callback(TTRJSBMsgSuccess, @{@"permissionRes": @"true"});
                }
                    break;
                case PHAuthorizationStatusDenied:
                case PHAuthorizationStatusRestricted:
                {
                    callback(TTRJSBMsgSuccess, @{@"permissionRes": @"false"});
                    
                    [self guideUserToAllowPermissionWithTitle:nil message:@"此功能需要您开启相册权限,请前往设置中开启" cancelTitle:nil cancelBlk:nil confirmTitle:nil confirmBlk:nil];
                }
                    break;
                case PHAuthorizationStatusNotDetermined:
                {
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            BOOL isAuthed = (status == PHAuthorizationStatusAuthorized);
                            callback(TTRJSBMsgSuccess, @{@"permissionRes": isAuthed?@"true":@"false"});
                        });
                    }];
                }
                    break;
                default:
                    break;
            }
        }
        else if([name isEqualToString:@"camera"] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            switch (status) {
                case AVAuthorizationStatusAuthorized:
                {
                    callback(TTRJSBMsgSuccess, @{@"permissionRes": @"true"});
                }
                    break;
                case  AVAuthorizationStatusRestricted:
                case AVAuthorizationStatusDenied:
                {
                    callback(TTRJSBMsgSuccess, @{@"permissionRes": @"false"});
                    [self guideUserToAllowPermissionWithTitle:nil message:@"此功能需要您开启相机权限,请前往设置中开启" cancelTitle:nil cancelBlk:nil confirmTitle:nil confirmBlk:nil];
                }
                    break;
                case AVAuthorizationStatusNotDetermined:
                {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            callback(TTRJSBMsgSuccess, @{@"permissionRes": granted?@"true":@"false"});
                        });
                    }];
                }
                    break;
                default:
                    break;
            }
        }
        else {
            TTR_CALLBACK_FAILED_MSG(@"未知权限类型");
        }
    }
    else {
        TTR_CALLBACK_FAILED_MSG(@"权限参数无效");
    }
}

- (void)guideUserToAllowPermissionWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelBlk:(FLinkChatPermissionAskActionBlock)cancelBlk confirmTitle:(NSString *)confirmTitle confirmBlk:(FLinkChatPermissionAskActionBlock)confirmBlk  {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message?:@"此功能需要您开启麦克风权限,请前往设置中开启" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle?:@"下次开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(cancelBlk) {
                cancelBlk();
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:confirmTitle?:@"立即开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if(confirmBlk) {
                confirmBlk();
            }
            
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
        }]];
        [[TTUIResponderHelper visibleTopViewController] presentViewController:alert animated:YES completion:nil];
    });
}

- (void)openPhotoLibraryWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    
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
@end
