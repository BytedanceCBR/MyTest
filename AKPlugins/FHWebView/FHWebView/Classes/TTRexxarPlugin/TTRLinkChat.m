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
#import "TTImagePickerController.h"

//  内部使用单例
@interface TTRPhotoLibraryHelper : NSObject<TTImagePickerControllerDelegate>
@property (nonatomic, strong) TTImagePickerController *imagePickerController;
@property (nonatomic, weak) UIView<TTRexxarEngine> *attachedWebview;

+ (instancetype)shared;
@end

@implementation TTRPhotoLibraryHelper

+ (instancetype)shared {
    static TTRPhotoLibraryHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TTRPhotoLibraryHelper alloc] init];
    });
    return _instance;
}

- (TTImagePickerController *)imagePickerController {
    if(!_imagePickerController) {
        _imagePickerController = [[TTImagePickerController alloc] initWithDelegate:self];
        _imagePickerController.imagePickerMode = TTImagePickerModeVideo;
        _imagePickerController.allowTakePicture = NO;
        _imagePickerController.isGetOriginResource = NO;
        _imagePickerController.enableICloud = YES;
        _imagePickerController.maxVideoCount = 1;
//        _imagePickerController.maxVideoDuration =
    }
    return _imagePickerController;
}
#pragma mark - TTImagePickerControllerDelegate
- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAsset:(TTAsset *)assetModel {
    // 处理上传
    [self processVideoUpload];
}
- (void)processVideoUpload {
    // 上传开始
    
    // 上传成功
    
    // 上传失败
    [self notifyUploadStatus:self.attachedWebview];
}
- (void)notifyUploadStatus:(UIView<TTRexxarEngine> *)webview {
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
                    callback(TTRJSBMsgSuccess, @{@"permissionRes": @(YES)});
                }
                    break;
                case PHAuthorizationStatusDenied:
                case PHAuthorizationStatusRestricted:
                {
                    callback(TTRJSBMsgSuccess, @{@"permissionRes": @(NO)});
                    
                    [self guideUserToAllowPermissionWithTitle:nil message:@"此功能需要您开启相册权限,请前往设置中开启" cancelTitle:nil cancelBlk:nil confirmTitle:nil confirmBlk:nil];
                }
                    break;
                case PHAuthorizationStatusNotDetermined:
                {
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            BOOL isAuthed = (status == PHAuthorizationStatusAuthorized);
                            callback(TTRJSBMsgSuccess, @{@"permissionRes": isAuthed?@(YES):@(NO)});
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
                    callback(TTRJSBMsgSuccess, @{@"permissionRes": @(YES)});
                }
                    break;
                case AVAuthorizationStatusRestricted:
                case AVAuthorizationStatusDenied:
                {
                    callback(TTRJSBMsgSuccess, @{@"permissionRes": @(NO)});
                    [self guideUserToAllowPermissionWithTitle:nil message:@"此功能需要您开启相机权限,请前往设置中开启" cancelTitle:nil cancelBlk:nil confirmTitle:nil confirmBlk:nil];
                }
                    break;
                case AVAuthorizationStatusNotDetermined:
                {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            callback(TTRJSBMsgSuccess, @{@"permissionRes": granted?@(YES):@(NO)});
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
    
    UINavigationController *navVC = [TTUIResponderHelper visibleTopViewController].navigationController;
    if(navVC) {
        [TTRPhotoLibraryHelper shared].attachedWebview = webview;
        [[TTRPhotoLibraryHelper shared].imagePickerController presentOn:navVC];
    }

    callback(TTRJSBMsgSuccess, @{});
}
@end
