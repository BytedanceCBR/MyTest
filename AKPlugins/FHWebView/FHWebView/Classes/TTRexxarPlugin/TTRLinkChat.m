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
#import "FHAttachmentMessageSender.h"
#import <TTFileUploadClient/TTVideoUploadClient.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "FHMainApi.h"
#import "FHIMConfigManager.h"

@interface TTRVideoUploader : NSObject
+ (instancetype)shared;
- (void)uploadWithLocalFilePath:(NSString *)localFilePath delegate:(id<TTVideoUploadClientProtocol>) delegate;
@end
@interface TTRVideoUploader()
@property (nonatomic, strong) TTVideoUploadClient *videoUploadClient;
@end
@implementation TTRVideoUploader
+ (instancetype)shared {
    static TTRVideoUploader *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TTRVideoUploader alloc] init];
    });
    return _instance;
}
- (void)uploadWithLocalFilePath:(NSString *)localFilePath delegate:(id<TTVideoUploadClientProtocol>)delegate {
    @weakify(self);
    [self fetchAuthorization:^(NSString *authorization, NSString *username, NSError *error) {
        @strongify(self);
        if(error) {
            if(delegate && [delegate respondsToSelector:@selector(uploadVideoDidFinish:error:)]) {
                [delegate uploadVideoDidFinish:nil error:error];
            }
            return;;
        }
        
        if(authorization.length == 0 || username.length == 0) {
            NSError *error = [[NSError alloc] initWithDomain:JSONModelErrorDomain code:-1 userInfo:nil];
            if(delegate && [delegate respondsToSelector:@selector(uploadVideoDidFinish:error:)]) {
                [delegate uploadVideoDidFinish:nil error:error];
            }
            return;
        }
        
        NSString *hostName = @"vas-lf-x.snssdk.com";
        self.videoUploadClient = [[TTVideoUploadClient alloc] initWithFilePath:localFilePath username:username fileUploadProcessType:TTFileUploadProcessTypeOrigina fileType:TTFileUploadFileTypeVideo];
        [self.videoUploadClient setVideoHostname:hostName];
        [self.videoUploadClient setAuthorization:authorization];
        self.videoUploadClient.delegate = delegate;
        [self.videoUploadClient start];
    }];
}
- (void)fetchAuthorization:(void (^)(NSString *authorization, NSString *username, NSError *error))completion {
    
    NSString *path = @"/f101/api/tos_uploader_auth";
    NSString *url = [[FHMainApi host] stringByAppendingString:path];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"scene_type"] = @"house_appeal";
    [[TTNetworkManager shareInstance] requestForJSONWithResponse:url params:param method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (!error) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonObj = (NSDictionary *)obj;
                NSDictionary *data = [jsonObj objectForKey:@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSString *token = [data objectForKey:@"token"];
                    NSString *username = [data objectForKey:@"access_key"];
                    if (completion) {
                        completion(token, username, nil);
                    }
                }
            }
        } else {
            completion(nil, nil, error);
        }
    }];
}
@end


//  内部使用单例
@interface TTRPhotoLibraryHelper : NSObject<TTImagePickerControllerDelegate, TTVideoUploadClientProtocol>
@property (nonatomic, strong) TTImagePickerController *imagePickerController;
@property (nonatomic, weak) UIView<TTRexxarEngine> *attachedWebview;
@property (nonatomic, strong) TTVideoUploadClient *videoUploadClient;
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
    _imagePickerController = [[TTImagePickerController alloc] initWithDelegate:self];
    _imagePickerController.imagePickerMode = TTImagePickerModeVideo;
    _imagePickerController.allowTakePicture = NO;
    _imagePickerController.isGetOriginResource = NO;
    _imagePickerController.enableICloud = YES;
    _imagePickerController.maxVideoCount = 1;
    return _imagePickerController;
}

- (TTVideoUploadClient *)videoUploadClient {
    if(!_videoUploadClient) {
        _videoUploadClient = [[TTVideoUploadClient alloc] init];
    }
    return _videoUploadClient;
}

#pragma mark - TTImagePickerControllerDelegate

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAsset:(TTAsset *)assetModel {
    
    NSAssert(assetModel.type == TTAssetMediaTypeVideo, @"只能上传本地视频");
    
    PHVideoRequestOptions *videoOptions = [[PHVideoRequestOptions alloc] init];
    videoOptions.version = PHVideoRequestOptionsVersionCurrent;
    videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestAVAssetForVideo:assetModel.asset options:videoOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 开始上传
            [self.attachedWebview ttr_fireEvent:@"linkchatUploadVideo" data:@{
                @"state": @1,
                @"success": @(NO),
                @"message": @"开始上传",
                @"data": @{
                }
            }];
            
            NSString *localFilePath = ((AVURLAsset *)asset).URL.path;
            [[TTRVideoUploader shared] uploadWithLocalFilePath:localFilePath delegate:self];
        });
    }];
}

- (void)notifyUploadFailedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 上传失败
        [self.attachedWebview ttr_fireEvent:@"linkchatUploadVideo" data:@{
            @"state": @2,
            @"success": @(NO),
            @"message": error.localizedDescription?:@"上传失败",
            @"data": @{
            }
        }];
    });
}

#pragma mark - TTVideoUploadClientProtocol

- (void)uploadVideoProgressDidUpdate:(NSInteger)progress {
    
}

- (void)uploadVideoDidFinish:(TTUploadVideoInfo *)videoInfo error:(NSError *)error {
    
    if(error) {
        [self notifyUploadFailedWithError:error];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // TODO: 向服务端要拼接好的url
            
            NSString *videoUrl = videoInfo.tosKey;
            NSString *videoCoverImageUrl = videoInfo.coverURL?:@"";

            // 上传成功
            [self.attachedWebview ttr_fireEvent:@"linkchatUploadVideo" data:@{
                @"state": @2,
                @"success": @(YES),
                @"message": @"上传成功",
                @"data": @{
                        @"videoSrc": videoUrl?:@"",
                        @"videoCoverImg": videoCoverImageUrl?:@"",
                }
            }];
        });
    }
}

- (int)uploadVideoCheckIfNeedTry:(NSInteger)errCode tryCount:(NSInteger)tryCount {
    if(tryCount <= 3) {
        return 1;
    }
    return 0;
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
