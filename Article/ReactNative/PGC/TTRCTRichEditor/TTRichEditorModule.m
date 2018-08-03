//
//  TTRichEditorModule.m
//  Article
//
//  Created by liaozhijie on 2017/7/21.
//
//

#import <Foundation/Foundation.h>
#import "TTUIResponderHelper.h"
#import "TTIndicatorView.h"
#import "TTNetworkManager.h"
#import "TTHTTPResponseSerializerBase.h"
#import "TTUGCImageCompressHelper.h"
#import "TTThemedAlertController.h"
#import "TTURLUtils.h"

#import "TTRichEditorModule.h"
#import "TTPGCAssetUtil.h"

@interface TTRichEditorModule ()

@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation TTRichEditorModule

- (instancetype)init {
    if (self == [super init]) {
        self.rejectBlocks = [[NSMutableDictionary alloc] init];
        self.resolveBlocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - react methods

RCT_EXPORT_MODULE(RichEditorModule)

// 显示弹窗
RCT_EXPORT_METHOD(showAlert:(NSDictionary  *)params
                  callback:(RCTResponseSenderBlock)callback) {
    // get params
    NSString * message = [self getStringWithDefaultVal:params
                                                   key:@"message"
                                            defaultVal:@"确认退出？已撰写文章会保存草稿"];
    NSString * okLabel = [self getStringWithDefaultVal:params
                                                   key:@"positiveButton"
                                            defaultVal:@"继续写"];
    NSString * cancalLabel = [self getStringWithDefaultVal:params
                                                       key:@"negativeButton"
                                                defaultVal:@"退出"];

    TTThemedAlertController * alertController = [[TTThemedAlertController alloc] initWithTitle:message message:nil preferredType:TTThemedAlertControllerTypeAlert];

    [alertController addActionWithTitle:okLabel actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
    [alertController addActionWithTitle:cancalLabel actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        callback(@[@"CANCEL"]);
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [alertController showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
    });
}

// 显示loading
RCT_EXPORT_METHOD(showSpinner:(NSDictionary  *)params
                  callback:(RCTResponseSenderBlock)callback) {
    self.indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:nil indicatorImage:nil dismissHandler:nil];
    _indicatorView.showDismissButton = NO;
    _indicatorView.autoDismiss = NO;

    dispatch_async(dispatch_get_main_queue(), ^{
        [_indicatorView showFromParentView:nil];
        callback(@[]);
    });
}

// 关闭loading
RCT_EXPORT_METHOD(hideSpinner) {
    if (_indicatorView == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_indicatorView dismissFromParentView];
        self.indicatorView = nil;
    });
}

// 选择图片
RCT_EXPORT_METHOD(selectImage:(NSDictionary  *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    // 暂存promise block
    NSString * promiseTag = @"selectImage";
    [_resolveBlocks setObject:resolve forKey:promiseTag];
    [_rejectBlocks setObject:reject forKey:promiseTag];

    dispatch_async(dispatch_get_main_queue(), ^{
        TTImagePickerController *picker = [[TTImagePickerController alloc] initWithDelegate:self];
        picker.maxImagesCount = 1;
        [picker presentOn:[TTUIResponderHelper topmostViewController]];
    });
}

// 上传图片
RCT_EXPORT_METHOD(uploadImage:(NSDictionary  *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSString * imgUrlStr = [params valueForKey:@"imgUri"];
    NSString * hostUrl = [params valueForKey:@"hostUrl"];
    NSString * uploadUrl = [params valueForKey:@"uploadUrl"];

    if (imgUrlStr == nil || imgUrlStr.length == 0
        || hostUrl == nil || hostUrl.length == 0
        || uploadUrl == nil || uploadUrl.length == 0) {
        NSError * invalidUrlError = [[NSError alloc] initWithDomain:@"" code:NSURLErrorBadURL userInfo:nil];
        reject(@"2", invalidUrlError.localizedDescription, invalidUrlError);
    }

    NSDictionary * queryParams = [params valueForKey:@"queryParams"];
    uploadUrl = [hostUrl stringByAppendingString:uploadUrl];

    WeakSelf;
    void (^upload)() = ^(UIImage *image) {
        if (!image) {
            NSError * invalidImageError = [[NSError alloc] initWithDomain:@"" code:NSURLErrorUnknown userInfo:nil];
            reject(@"2", invalidImageError.localizedDescription, invalidImageError);
            return;
        }
        StrongSelf;
        // 压缩图片
        NSData * compressedData = UIImageJPEGRepresentation([TTUGCImageCompressHelper processImageForUploadImage:image], 1.0);
        // 上传图片
        [self uploadFile:uploadUrl fileData:compressedData params:queryParams finishBlock:^(NSError * error, NSDictionary * json) {
            if (error) {
                reject([NSString stringWithFormat: @"%ld", (long)error.code], error.localizedDescription,  error);
            } else {
                resolve(json);
            }
        }];
    };

    if ([imgUrlStr isEqualToString:[self getSelectedImageKey]]) {
        upload(self.selectedImage);
        self.selectedImage = nil;
    } else {
        NSURL * imgUrl = [NSURL URLWithString:imgUrlStr];
        // 根据 asset-url 拿取 图片资源
        [TTPGCAssetUtil getImageDataFromURL:imgUrl resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
            if (!imageData) {
                NSError * invalidImageError = [[NSError alloc] initWithDomain:@"" code:NSURLErrorUnknown userInfo:nil];
                reject(@"2", invalidImageError.localizedDescription, invalidImageError);
                return;
            }
            upload([UIImage imageWithData:imageData]);
        }];
    }
}

# pragma mark - handle images
// 处理图片选择回调
- (void)onImageSelected:(NSArray<UIImage *> *)images assets:(NSArray<TTAssetModel *> *)assets {
    NSString * promiseTag = @"selectImage";
    RCTPromiseResolveBlock resolve = [self getResolveBlock:promiseTag];

    if (assets == nil && (images == nil || images.count == 0)) {
        resolve(nil);
        [self resetPromse:promiseTag];
        return;
    }

    if (assets == nil) {
        // 由于TTImagePickerController 并不能获取保存后的图片，而是获取到拍照得到的图片
        // 所以无法拿到asset-url
        // 目前将拍照得到的照片存起来以备上传
        self.selectedImage = images[0];
        resolve(@{ @"image_uri": [self getSelectedImageKey] });
    } else {
        NSMutableArray * imageInfoes = [[NSMutableArray alloc] init];
        for (TTAssetModel * model in assets) {
            NSURL * url = [TTPGCAssetUtil getURLStringFromAsset:model.asset];
            [imageInfoes addObject:[url absoluteString]];
        }

        NSMutableArray * resolveInfo = [[NSMutableArray alloc] init];
        for (NSString * url in imageInfoes) {
            [resolveInfo addObject:@{ @"image_uri": url }];
        }
        if (imageInfoes.count == 1) {
            resolve(resolveInfo[0]);
        } else {
            resolve(resolveInfo);
        }
    }
    [self resetPromse:promiseTag];
}

- (NSString *)getSelectedImageKey {
    return @"__image__";
}

#pragma mark - promise utils
- (void)setPromise:(NSString *)key
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    [self.resolveBlocks setObject:resolve forKey:key];
    [self.rejectBlocks setObject:reject forKey:key];
}

- (RCTPromiseResolveBlock)getResolveBlock:(NSString *)key {
    return [self.resolveBlocks valueForKey:key];
}

- (RCTPromiseRejectBlock)getRejectBlock:(NSString *)key {
    return [self.rejectBlocks valueForKey:key];
}

- (void)resetPromse:(NSString *)key {
    [self.resolveBlocks removeObjectForKey:key];
    [self.rejectBlocks removeObjectForKey:key];
}

#pragma mark - upload
- (void)uploadFile:(NSString *)urlString
          fileData:(NSData *)fileData
            params:(NSDictionary *)params
       finishBlock:(void(^)(NSError *error, NSDictionary * json))finishBlock {
    NSURL * url = [TTURLUtils URLWithString:urlString queryItems:params];
    [[TTNetworkManager shareInstance] uploadWithURL:[url absoluteString]
                                         parameters:nil
                          constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
                              [formData appendPartWithFileData:fileData
                                                          name:@"upfile"
                                                      fileName:@"upfile.jpeg"
                                                      mimeType:@"image/jpeg"
                               ];
                          }
                                           progress:nil
                                   needcommonParams:YES
                                           callback:^(NSError *error, id jsonObj) {
                                               if (finishBlock) {
                                                   finishBlock(error, jsonObj);
                                               }
                                           }
     ];
}

#pragma mark - TTImagePickerControllerDelegate
- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray<TTAssetModel *> *)assets {
    [self onImageSelected:photos assets:assets];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAssetModel *> *)assets withInfo:(NSDictionary *)info {
    NSArray<UIImage *> * photos = [[NSArray alloc] initWithObjects:photo, nil];
    [self onImageSelected:photos assets:assets];
}

- (void)ttImagePickerControllerDidCancel:(TTImagePickerController *)picker {
    NSString * promiseTag = @"selectImage";
    [self getResolveBlock:promiseTag](nil);
    [self resetPromse:promiseTag];
}

#pragma mark - utils
- (NSString *)getStringWithDefaultVal:(NSDictionary *) dict
                                  key:(NSString *)key
                           defaultVal:(NSString *)defaultVal {
    NSString * val = [dict objectForKey:key];
    if (!val) {
        val = defaultVal;
    }
    return NSLocalizedString(val, nil);
}

@end
