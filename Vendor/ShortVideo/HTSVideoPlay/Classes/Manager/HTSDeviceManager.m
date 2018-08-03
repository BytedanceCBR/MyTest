//
//  AWEDeviceManager.m
//  Aweme
//
//  Created by Quan Quan on 16/8/31.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "HTSDeviceManager.h"
#import "TTSandBoxHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "UIAlertView+Blocks.h"

@implementation HTSDeviceManager

+ (BOOL)isCameraDenied
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied);
}

+ (BOOL)isMicroPhoneDenied
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied);
}

+ (void)requestPhotoLibraryPermission:(void(^)(BOOL success))completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
            case PHAuthorizationStatusNotDetermined: {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        switch (status) {
                                case PHAuthorizationStatusAuthorized: {
                                    if (completion) {
                                        completion(YES);
                                    }
                                    break;
                                }
                                case PHAuthorizationStatusNotDetermined:
                                case PHAuthorizationStatusRestricted:
                                case PHAuthorizationStatusDenied:
                            default: {
                                if (completion) {
                                    completion(NO);
                                }
                            }
                        }
                    });
                }];
                break;
            }
            case PHAuthorizationStatusAuthorized: {
                if (completion) {
                    completion(YES);
                }
                break;
            }
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:
        default: {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(NO);
                }
            });
        }
    }
}

+ (void)presentPhotoLibraryDeniedAlert
{
    NSString *errorTip = [NSString stringWithFormat:NSLocalizedString(@"保存失败，由于系统限制，请在“设置-隐私-照片”中，重新允许%@即可", nil), [TTSandBoxHelper appDisplayName]];
    [UIAlertView showWithTitle:errorTip
                       message:nil
             cancelButtonTitle:NSLocalizedString(@"确定", nil)
             otherButtonTitles:nil
                      tapBlock:nil];
}

@end
