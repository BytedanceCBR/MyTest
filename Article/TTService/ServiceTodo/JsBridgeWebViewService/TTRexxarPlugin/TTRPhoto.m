//
//  TTRPhoto.m
//  Article
//
//  Created by lizhuoli on 2017/9/4.
//
//

#import "TTRPhoto.h"
#import <TTImagePicker/TTImagePicker.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTBaseLib/NSStringAdditions.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/UIImageAdditions.h>

#define kTTRPhotoThumbBase64DataFormatPrefix(format) [NSString stringWithFormat:@"data:image/%@;base64, ", format]
#define kTTRPhotoTempFolderPath [NSTemporaryDirectory() stringByAppendingPathComponent:@"TempVideos"]

#define KTTRPhotoErrorMsgInvalidParameters @"invalid parameters"
#define kTTRPhotoErrorMsgNetworkUnavailable @"network unavailable"
#define kTTRPhotoErrorMsgResourceNotAvailable @"local resource not available"
#define kTTRPhotoErrorMsgNetworkError @"server not response"
#define kTTRPhotoErrorMsgOther @"unknown error"

#define TTR_CALLBACK_FAILED_CODE_MSG(code, msg) \
if (callback) {\
callback(TTRJSBMsgFailed, @{@"code": @(code), @"msg": [NSString stringWithFormat:msg]? :@""});\
}\

@interface TTRPhoto () <TTImagePickerControllerDelegate>

@property (nonatomic, copy) TTRJSBResponse takePhotoCallback;
@property (nonatomic, strong) NSMutableDictionary<NSString *,TTAssetModel *> *totalAssetsDict; // AssetID和AssetModel映射字典，全部操作在主线程，不加锁
@property (nonatomic, copy) NSArray<TTAssetModel *> *currentAssets;
@property (nonatomic, assign) NSInteger columnNumber;

@end

@implementation TTRPhoto

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTImagePickerManager manager].accessIcloud = NO;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanupAssetsMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

+ (TTRJSBInstanceType)instanceType
{
    return TTRJSBInstanceTypeWebView;
}

- (NSMutableDictionary<NSString *,TTAssetModel *> *)totalAssetsDict
{
    if (!_totalAssetsDict) {
        _totalAssetsDict = [NSMutableDictionary dictionary];
    }
    return _totalAssetsDict;
}

#pragma mark - UIApplicationDidReceiveMemoryWarningNotification
- (void)cleanupAssetsMemory
{
    self.currentAssets = nil;
    [self.totalAssetsDict removeAllObjects];
}

#pragma mark - takePhoto JSBridge
- (void)takePhotoWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    SSLog(@"TTRPhoto.takePhoto: %@", param);
    NSString *mode = [param tt_stringValueForKey:@"mode"];
    NSInteger maxImagesCount = [param tt_integerValueForKey:@"max_images_count"];
    NSInteger columnNumber = [param tt_integerValueForKey:@"column_num"];
    BOOL allowTakePicture = YES;
    if ([param valueForKey:@"allow_take_photo"]) {
        allowTakePicture = [param tt_boolValueForKey:@"allow_take_photo"];
    }
    BOOL enableIcloud = [param tt_boolValueForKey:@"enable_icloud"];
    
    TTImagePickerController *imagePickerController = [[TTImagePickerController alloc] initWithDelegate:self];
    
    if (maxImagesCount > 0) imagePickerController.maxImagesCount = maxImagesCount;
    if (columnNumber > 0) imagePickerController.columnNumber = columnNumber;
    imagePickerController.allowTakePicture = allowTakePicture;
    imagePickerController.allowAutoSavePicture = NO;
    imagePickerController.isRequestPhotosBack = NO;
    
    TTImagePickerMode imagePickerMode = TTImagePickerModePhoto;
    if ([mode isEqualToString:@"photo"]) {
        imagePickerMode = TTImagePickerModePhoto;
    } else if ([mode isEqualToString:@"video"]) {
        imagePickerMode = TTImagePickerModeVideo;
    } else if ([mode isEqualToString:@"both"]) {
        imagePickerMode = TTImagePickerModeAll;
    }
    imagePickerController.imagePickerMode = imagePickerMode;
    
    // 参数解析完成……
    
    self.currentAssets = nil; // 清理上次的Assets
    self.takePhotoCallback = callback; // TTImagePicker是基于delegate的，所以必须保留callback，每次调用更新callback，执行完需要置为nil防止泄漏
    self.columnNumber = imagePickerController.columnNumber; // 设置列数，后续计算缩略图宽度需要
    [TTImagePickerManager manager].accessIcloud = enableIcloud; // 设置开启iCloud，注意由于是单例，最后完成后需要还原到默认的NO
    
    [imagePickerController presentOn:[TTUIResponderHelper topmostViewController]];
}

#pragma mark - Get Photo
- (void)getPhotoForAssets:(NSArray<TTAssetModel *> *)assets
{
    __block NSUInteger totalCount = 0;
    __block BOOL callbackCalled = NO;
    NSUInteger count = assets.count;
    self.currentAssets = assets;
    [self.currentAssets enumerateObjectsUsingBlock:^(TTAssetModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.totalAssetsDict setValue:model forKey:model.assetID];
        if (model.thumbImage) {
            // 如果有缩略图，直接返回并避免调用方等待
            // 但是Apple有Bug，iCloud的缩略图是只能用于UIImageView展示的，通过UIPNG/JPEGRepresentation是没法得到NSData的，所以需要Hack处理
            // 必须重新通过Core Graphics（注意，使用UIGraphicsBeginImageContext是不行的）绘制成一个UIImage来处理，统一使用UIImage扩展处理
            model.thumbImage = [model.thumbImage resizedImage:model.thumbImage.size interpolationQuality:kCGInterpolationHigh];
            totalCount++;
            if (totalCount == count && !callbackCalled) {
                callbackCalled = YES;
                [self callTakePhotoCallback];
            }
        } else if (model.cacheImage) {
            // 如果没有缩略图，但是有原图，绘制一下缩略图
            model.thumbImage = [model.cacheImage resizedImage:TTRPhotoGetThumbSizeWithImageSizeAndColumnNumber(model.cacheImage.size, self.columnNumber) interpolationQuality:kCGInterpolationHigh];
            totalCount++;
            if (totalCount == count && !callbackCalled) {
                callbackCalled = YES;
                [self callTakePhotoCallback];
            }
        } else {
            // 什么都没有，需要取图，再绘制缩略图，虽然我觉得设计好的话不应该要求业务层处理这个Case
            [[TTImagePickerManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                // 这个回调函数在iCloud下会回调两次（第一次isDegraded=YES，第二次isDegraded=NO），非iCloud只会调一次（isDegraded=NO），只缓存isDegraded=NO的原图，需要确保回调只调用一次
                if (!isDegraded) {
                    // 本地原图或者iCloud高清图，绘制缩略图
                    model.cacheImage = photo;
                    model.thumbImage = [photo resizedImage:TTRPhotoGetThumbSizeWithImageSizeAndColumnNumber(photo.size, self.columnNumber) interpolationQuality:kCGInterpolationHigh];
                } else {
                    // 低清图，处理一下并立即返回
                    model.thumbImage = [photo resizedImage:photo.size interpolationQuality:kCGInterpolationHigh];
                }
                totalCount++;
                if (totalCount == count && !callbackCalled) {
                    callbackCalled = YES;
                    [self callTakePhotoCallback];
                }
            }];
        }
    }];
}

#pragma mark - Take Photo
- (void)callTakePhotoCallback
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"code"] = @(1);
    
    NSMutableArray *resources = [NSMutableArray arrayWithCapacity:self.currentAssets.count];
    [self.currentAssets enumerateObjectsUsingBlock:^(TTAssetModel * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        // 在TTImagePicker的回调中，生成了thumbImage，这里就直接取了
        UIImage *thumbImage = asset.thumbImage;
        if (!thumbImage) {
            // 加个保护，这时候还取不到缩略图应该是iCloud取图错误，不重试
            return;
        }
        NSData *imageData = UIImageJPEGRepresentation(thumbImage, 1.f);
        NSString *thumbBase64Data = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        if (thumbBase64Data) {
            // 极少Case，如果UIImage编码到JPEG失败，直接不返回
            NSMutableDictionary *resource = [NSMutableDictionary dictionaryWithCapacity:2];
            resource[@"resource_id"] = asset.assetID;
            resource[@"thumb_base64_data"] = [kTTRPhotoThumbBase64DataFormatPrefix(@"jpeg") stringByAppendingString:thumbBase64Data];
            [resources addObject:resource];
        } else {
            NSAssert(NO, @"UIImage can't encode to NSData");
        }
        asset.thumbImage = nil; // free the memory
    }];
    param[@"resources"] = resources;
    
    if (self.takePhotoCallback) {
        self.takePhotoCallback(TTRJSBMsgSuccess, [param copy]);
        self.takePhotoCallback = nil;
    }
}

#pragma mark - confirmUploadPhoto JSBridge
- (void)confirmUploadPhotoWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    SSLog(@"TTRPhoto.confirmUploadPhoto: %@", param);
    if (SSIsEmptyDictionary(param)) {
        TTR_CALLBACK_FAILED_CODE_MSG(0, KTTRPhotoErrorMsgInvalidParameters);
        return;
    }
    NSString *resourceID = [param tt_stringValueForKey:@"resource_id"];
    if (isEmptyString(resourceID)) {
        TTR_CALLBACK_FAILED_CODE_MSG(0, KTTRPhotoErrorMsgInvalidParameters);
        return;
    }
    NSString *url = [param tt_stringValueForKey:@"url"];
    NSString *path = [param tt_stringValueForKey:@"path"];
    NSString *urlString;
    
    if (!isEmptyString(url) && !isEmptyString(path)) {
        // url && path
        TTR_CALLBACK_FAILED_CODE_MSG(0, KTTRPhotoErrorMsgInvalidParameters);
        return;
    } else if (!isEmptyString(url) && isEmptyString(path)) {
        // url && !path
        urlString = url;
    } else if (isEmptyString(url) && !isEmptyString(path)) {
        // !url && path
        NSURL *baseURL = [NSURL URLWithString:[CommonURLSetting baseURL]];
        urlString = [NSURL URLWithString:path relativeToURL:baseURL].absoluteString;
    }
    
    NSDictionary *params = [param tt_dictionaryValueForKey:@"params"];
    NSString *name = [param tt_stringValueForKey:@"name"];
    if (isEmptyString(name)) {
        name = @"image";
    }
    BOOL needCommonParams = YES;
    if ([param objectForKey:@"need_common_params"]) {
        needCommonParams = [param tt_boolValueForKey:@"need_common_params"];
    }
    
    // 参数解析完成……
    
    TTAssetModel *model = [self.totalAssetsDict valueForKey:resourceID];
    if (!model) {
        TTR_CALLBACK_FAILED_CODE_MSG(-2, kTTRPhotoErrorMsgResourceNotAvailable);
        return;
    }
    
    if (model.type == TTAssetModelMediaTypeVideo) {
        [[TTImagePickerManager manager] getVideoAVURLAsset:model.asset completion:^(AVURLAsset *asset) {
            if (!asset) {
                TTR_CALLBACK_FAILED_CODE_MSG(-2, kTTRPhotoErrorMsgResourceNotAvailable);
                return;
            }
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError *fileError;
                NSURL *videoFileURL = [self copyURLAssetToSandbox:asset error:&fileError];
                dispatch_main_async_safe_ttImagePicker(^{
                    if (!fileError) {
                        [self uploadVideoWithURL:urlString params:params name:name videoFileURL:videoFileURL needCommonParams:needCommonParams callback:callback];
                    } else {
                        TTR_CALLBACK_FAILED_CODE_MSG(-2, kTTRPhotoErrorMsgResourceNotAvailable);
                    }
                });
            });
        }];
    } else {
        if (!model.cacheImage) {
            // 有可能之前缩略图没有对应原图，这里需要取一次。部分图可能会有缓存
            [[TTImagePickerManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded) {
                    // 忽略低清图，这里有可能iCloud第一次回调
                    return;
                }
                model.cacheImage = photo;
                NSData *imageData = UIImageJPEGRepresentation(model.cacheImage, 1.f);
                if (imageData) {
                    [self uploadPhotoWithURL:urlString params:params name:name imageData:imageData needCommonParams:needCommonParams callback:callback];
                } else {
                    TTR_CALLBACK_FAILED_CODE_MSG(-2, kTTRPhotoErrorMsgResourceNotAvailable);
                }
            }];
        } else {
            NSData *imageData = UIImageJPEGRepresentation(model.cacheImage, 1.f);
            if (imageData) {
                [self uploadPhotoWithURL:urlString params:params name:name imageData:imageData needCommonParams:needCommonParams callback:callback];
            } else {
                TTR_CALLBACK_FAILED_CODE_MSG(-2, kTTRPhotoErrorMsgResourceNotAvailable);
            }
        }
    }
}

#pragma mark - Upload Photo
- (void)uploadPhotoWithURL:(NSString *)URLString params:(nullable NSDictionary *)params name:(NSString *)name imageData:(NSData *)data needCommonParams:(BOOL)needCommonParams callback:(TTRJSBResponse)callback {
    NSAssert(data, @"imageData is empty");
    NSAssert(callback, @"callback is empty");
    if (isEmptyString(URLString)) {
        // 暂时默认上传接口为/data/2/upload_image
        URLString = [CommonURLSetting uploadImageString];
    }
    
    if (!TTNetworkConnected()) {
        TTR_CALLBACK_FAILED_CODE_MSG(-1, kTTRPhotoErrorMsgNetworkUnavailable);
        return;
    }
    
    [[TTNetworkManager shareInstance] uploadWithURL:URLString parameters:params constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:name fileName:@"image.jpeg" mimeType:@"image/jpeg"];
    } progress:nil needcommonParams:needCommonParams callback:^(NSError *error, id jsonObj) {
        if (error) {
            TTR_CALLBACK_FAILED_CODE_MSG(-3, kTTRPhotoErrorMsgNetworkError);
            return;
        } else {
            if (callback) {
                callback(TTRJSBMsgSuccess, @{@"code": @(1), @"result": jsonObj});
            }
        }
    }];
}

#pragma mark - Upload Video
- (void)uploadVideoWithURL:(nullable NSString *)URLString params:(nullable NSDictionary *)params name:(NSString *)name videoFileURL:(NSURL *)fileURL needCommonParams:(BOOL)needCommonParams callback:(TTRJSBResponse)callback {
    NSAssert(fileURL, @"videoFileURL is empty");
    NSAssert(callback, @"callback is empty");
    if (isEmptyString(URLString)) {
        // 暂时默认上传接口为UGC视频上传
        URLString = nil;
    }
    
    if (!TTNetworkConnected()) {
        TTR_CALLBACK_FAILED_CODE_MSG(-1, kTTRPhotoErrorMsgNetworkUnavailable);
        return;
    }
    //TODO:Jason 可以把相关的视频上传逻辑干掉
}

#pragma mark - Helper
- (NSURL *)copyURLAssetToSandbox:(AVURLAsset *)asset error:(NSError **)error
{
    NSAssert(asset, @"asset is empty");
    NSAssert(error, @"error pointer is empty");
    //相册资源视频转换为沙盒路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString *filePath = [kTTRPhotoTempFolderPath stringByAppendingPathComponent:fileName];
    
    if (![fileManager fileExistsAtPath:kTTRPhotoTempFolderPath]) {
        //如果不存在，则创建
        [fileManager createDirectoryAtPath:kTTRPhotoTempFolderPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:error];
    }
    
    //文件路径
    NSURL *assetFileURL = asset.URL;
    NSURL *videoFileURL = [NSURL fileURLWithPath:filePath];
    [fileManager copyItemAtURL:assetFileURL toURL:videoFileURL error:error];
    
    return videoFileURL;
}

static inline CGSize TTRPhotoGetThumbSizeWithImageSizeAndColumnNumber(CGSize imageSize, NSUInteger columnNumber)
{
    if (imageSize.width == 0 || imageSize.height == 0) {
        return CGSizeZero;
    }
    if (!columnNumber) {
        columnNumber = 4;
    }
    
    const CGFloat scale = 3;
    CGFloat thumbWidth = SSScreenWidth / columnNumber * scale;
    CGFloat thumbHeight = imageSize.height / imageSize.width * thumbWidth;
    
    return CGSizeMake(thumbWidth, thumbHeight);
}

#pragma mark - TTImagePickerControllerDelegate
- (void)ttImagePickerControllerDidCancel:(TTImagePickerController *)picker
{
    [self callTakePhotoCallback];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickerPhotosAndVideoWithSourceAssets:(NSArray<TTAssetModel *> *)assets
{
    [self getPhotoForAssets:assets];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAssetModel *> *)assets withInfo:(NSDictionary *)info
{
    NSMutableArray<TTAssetModel *> *mutableAssets = [NSMutableArray array];
    if (assets) {
        [mutableAssets addObjectsFromArray:assets];
    }
    
    // 设置allowAutoSavePicture=NO时不自动存照片，手动存并统一用Model来处理
    [[TTImagePickerManager manager] savePhotoWithImage:photo completion:^(id asset, NSError *error) {
        if (asset) {
            TTAssetModel *model = [TTAssetModel modelWithAsset:asset type:TTAssetModelMediaTypePhoto];
            model.cacheImage = photo;
            [mutableAssets addObject:model];
        }
        [self getPhotoForAssets:[mutableAssets copy]];
    }];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray<TTAssetModel *> *)assets
{
    // 设置isRequestPhotosBack=NO时，返回的photos是nil，需要获取
    [self getPhotoForAssets:assets];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAsset:(TTAssetModel *)assetModel
{
    // coverImage会被缓存，因此可以走统一的逻辑进行读取
    NSMutableArray<TTAssetModel *> *mutableAssets = [NSMutableArray array];
    if (assetModel) {
        [mutableAssets addObject:assetModel];
    }
    [self getPhotoForAssets: [mutableAssets copy]];
}

@end
