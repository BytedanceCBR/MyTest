//
//  TTImageManager.m
//  TestPhotos
//
//  Created by tyh on 2017/4/6.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import "TTImagePickerManager.h"
#import "TTImagePickerCacheManager.h"
#import "UIImage+GIF.h"
#import "UIImage+TTAssetModel.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIDevice+TTAdditions.h"
#import "TTBaseMacro.h"

#define TTImagePickerPanoramicImageWidthDefault  4096

@implementation TTImagePickerResult
@end

@interface TTImagePickerManager()
{
    NSTimer *_timer;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;

@property (nonatomic, copy)dispatch_block_t successAuth;
@property (nonatomic, copy)dispatch_block_t failAuth;

@property (nonatomic, assign) BOOL hideGif;


@end


@implementation TTImagePickerManager


static inline float getTTScreenScale(float width,bool isVideo)
{
    if (isVideo) {
        return 2.0;
    }
    if (width == TTImagePickerImageWidthDefault) {
        return 3.0;
    }else{
        return 3.0;
    }
}


+ (instancetype)manager {
    
    static TTImagePickerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.sortAscendingByModificationDate = YES;
        manager.shouldFixOrientation = NO;
        manager.accessIcloud = NO;
        manager.cacheManager = [[TTImagePickerCacheManager alloc]init];
        manager.icloudDownloader = [[TTImagePickerIcloudDownloader alloc] init];
        manager.hideGif = !iOS9Later || [TTImagePickerManager isLowIphoneVersion];
        
    });
    return manager;
    
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}


- (ALAssetsLibrary *)assetLibrary {
    if (_assetLibrary == nil) _assetLibrary = [[ALAssetsLibrary alloc] init];
    return _assetLibrary;
}

#pragma mark - Get Album
/// Get Album 获得相册/相册数组
- (void)getCameraRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(TTAlbumModel *))completion{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //相册model
        __block TTAlbumModel *model;
        
        BOOL completeFlag = NO;
        
        //iOS8 photos API
        if (iOS8Later) {
            
            
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            //不允许video,PHAssetMediaTypeImage类型，谓词
            if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            
            //不允许image
            if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                        PHAssetMediaTypeVideo];
            
            
            //得到结果
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            //从结果中拿到PHAssetCollection
            for (PHAssetCollection *collection in smartAlbums) {
                // 有可能是PHCollectionList类的的对象，过滤掉
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                model = [self modelWithResult:fetchResult name:collection.localizedTitle allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
                
                dispatch_main_async_safe_ttImagePicker(^{
                    if (completion)
                        completion(model);
                })
                break;
            }
            
            
        } else {
            
            if ([TTImagePickerManager isValidLang]) {
                [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    
                    group = [self getFilterGroupWithGroup:group allowPickingImage:allowPickingImage allowPickingVideo:allowPickingVideo];
                    
                    if ([group numberOfAssets] < 1) return;
                    NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                    if ([self isCameraRollAlbum:name]) {
                        model = [self modelWithResult:group name:name allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
                        dispatch_main_async_safe_ttImagePicker(^{
                            if (completion)
                                completion(model);
                        })
                        *stop = YES;
                    }
                } failureBlock:nil];
            }else{
                [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    
                    group = [self getFilterGroupWithGroup:group allowPickingImage:allowPickingImage allowPickingVideo:allowPickingVideo];
                    if ([group numberOfAssets] < 1) return;
                    NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                    model = [self modelWithResult:group name:name allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
                    dispatch_main_async_safe_ttImagePicker(^{
                        if (completion)
                            completion(model);
                    })
                    *stop = YES;
                } failureBlock:nil];

            
            }
            
        }

    });
    
  }

- (void)getAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<TTAlbumModel *> *))completion{
    NSMutableArray *albumArr = [NSMutableArray array];
    
    
    if (iOS8Later) {
        [self getCameraRollAlbum:allowPickingVideo allowPickingImage:allowPickingImage completion:^(TTAlbumModel *model) {
            [albumArr addObject:model];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (iOS8Later) {
                    
                    PHFetchOptions *option = [[PHFetchOptions alloc] init];
                    if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                    if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                                PHAssetMediaTypeVideo];
                    
                    //        if (!self.sortAscendingByModificationDate) {
                    //            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
                    //        }
                    
                    //系统的所有相册 :最近添加、个人收藏、全景... (不想要相机胶卷，所以只能写一大堆...)
                    PHFetchResult *smartAblums1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumGeneric options:nil];
                    PHFetchResult *smartAblums2 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:nil];
                    PHFetchResult *smartAblums3 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil];
                    PHFetchResult *smartAblums4 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
                    PHFetchResult *smartAblums5 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumTimelapses options:nil];
                    PHFetchResult *smartAblums6 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
                    PHFetchResult *smartAblums7 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumBursts options:nil];
                    PHFetchResult *smartAblums8 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSlomoVideos options:nil];
                    PHFetchResult *smartAblums9 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumAllHidden options:nil];
                    
                    
                    //手动创建的
                    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                    //itunes同步的相关相册
                    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
                    
                    NSArray *allAlbums = nil;
                    
                    if (self.accessIcloud) {
                        //icloud相关相册
                        PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
                        
                        PHFetchResult *icloudSharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
                        
                        allAlbums = @[smartAblums1,smartAblums2,smartAblums3,smartAblums4,smartAblums5,smartAblums6,smartAblums7,smartAblums8,smartAblums9,albums,syncedAlbums,myPhotoStreamAlbum,icloudSharedAlbums];
                    }else{
                        allAlbums = @[smartAblums1,smartAblums2,smartAblums3,smartAblums4,smartAblums5,smartAblums6,smartAblums7,smartAblums8,smartAblums9,albums,syncedAlbums];
                    }
                    
                    
                    for (PHFetchResult *fetchResult in allAlbums) {
                        for (PHAssetCollection *collection in fetchResult) {
                            // 有可能是PHCollectionList类的的对象，过滤掉
                            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                            
                            TTAlbumModel *model = [self modelWithResult:fetchResult name:collection.localizedTitle allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
                            //数量小于1的，略过
                            if (model.count < 1) continue;
                            if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;
                            //相机胶卷插上面
                            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                                [albumArr insertObject:model atIndex:0];
                            } else {
                                [albumArr addObject:model];
                            }
                            
                        }
                    }
                    dispatch_main_async_safe_ttImagePicker(^{
                        if (completion && albumArr.count > 0) completion(albumArr);
                    })
                }
            });
            
        }];

    }else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group == nil) {
                    dispatch_main_async_safe_ttImagePicker(^{
                        if (completion && albumArr.count > 0) completion(albumArr);
                    })
                }
                
                group = [self getFilterGroupWithGroup:group allowPickingImage:allowPickingImage allowPickingVideo:allowPickingVideo];
                
                if ([group numberOfAssets] < 1) return;
                NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                if ([self isCameraRollAlbum:name]) {
                    [albumArr insertObject:[self modelWithResult:group name:name allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage] atIndex:0];
                } else if ([name isEqualToString:@"My Photo Stream"] || [name isEqualToString:@"我的照片流"]) {
                    if (albumArr.count) {
                        [albumArr insertObject:[self modelWithResult:group name:name allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage] atIndex:1];
                    } else {
                        [albumArr addObject:[self modelWithResult:group name:name allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage]];
                    }
                } else {
                    [albumArr addObject:[self modelWithResult:group name:name allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage]];
                }
            } failureBlock:nil];
        });
    }
  }

/// 过滤ALAssetsGroup
- (ALAssetsGroup *)getFilterGroupWithGroup:(ALAssetsGroup *)group allowPickingImage:(BOOL)allowPickingImage allowPickingVideo:(BOOL)allowPickingVideo
{
    if (allowPickingImage && allowPickingVideo) {
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
    } else if (allowPickingVideo) {
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
    } else if (allowPickingImage) {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    }
    return group;
}

//判断是不是相机胶卷相册（默认所有照片）
- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    //得到系统版本
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
    }
}


- (TTAlbumModel *)modelWithResult:(id)result name:(NSString *)name allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    
    __block TTAlbumModel *model = [[TTAlbumModel alloc] init];
    model.name = name;
    model.result = result;

//    if ([result isKindOfClass:[PHFetchResult class]]) {
//        PHFetchResult *fetchResult = (PHFetchResult *)result;
//        model.count = fetchResult.count;
//    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
//        ALAssetsGroup *group = (ALAssetsGroup *)result;
//        model.count = [group numberOfAssets];
//    }
    //得到这个相册中所有的元素
    dispatch_group_t getAssetsGroup = dispatch_group_create();
    dispatch_group_enter(getAssetsGroup);
    
    [self getAssetsFromFetchResult:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage completion:^(NSArray<TTAssetModel *> *models) {
        
        model.models = models;
        model.count = models.count;
        dispatch_group_leave(getAssetsGroup);


    }];
    dispatch_group_wait(getAssetsGroup,DISPATCH_TIME_FOREVER);
    return model;
}

- (void)getPostImageWithAlbumModel:(TTAlbumModel *)model completion:(void (^)(UIImage *postImage))completion
{
    if (iOS8Later) {
        //每次得到最新的照片作为封面
        id asset = [model.result lastObject];
        if (!self.sortAscendingByModificationDate) {
            asset = [model.result firstObject];
        }
        //得到这张照片，宽度要80
        [self getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            dispatch_main_async_safe_ttImagePicker(^{
                if (completion) completion(photo);
            })
        }];
    } else {
        //得到封面
        ALAssetsGroup *group = model.result;
        UIImage *postImage = [UIImage imageWithCGImage:group.posterImage];
        dispatch_main_async_safe_ttImagePicker(^{
            if (completion) completion(postImage);
        })
    }
}


#pragma mark - Get Assets
/// Get Assets 获得照片数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<TTAssetModel *> *))completion {
    
    NSMutableArray *photoArr = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
      
        [fetchResult enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            PHAsset *asset = obj;
            
            //不支持icloud,过滤case
            if (!self.accessIcloud) {
                //本地无图，icloud有图标识
                NSNumber *cloudPlaceholderKind;
                NSNumber *localResourcesState;

                @try {
                    cloudPlaceholderKind = [obj valueForKey:@"_cloudPlaceholderKind"];
                    localResourcesState = [obj valueForKey:@"_localResourcesState"];

                } @catch (NSException *exception) {
                    NSLog(@"%@ --无法获取到icloud标识，icloud图低清图适配",exception);
                } @finally {
                }
                if (cloudPlaceholderKind && [cloudPlaceholderKind intValue] == 3) {
                    return ;
                }
                if (allowPickingVideo && cloudPlaceholderKind && [cloudPlaceholderKind intValue] == 4) {
                    
                    if (localResourcesState && [localResourcesState intValue] == 130) {
                        //命中icloud本地cached视频
                    }else{
                        return;
                    }
                }
            }
            TTAssetModel *model = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model && model.assetID) {
                [photoArr addObject:model];
            }
        }];
        
        dispatch_main_async_safe_ttImagePicker(^{
            if (completion) completion(photoArr);
        })
        
        
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        
        [self getFilterGroupWithGroup:group allowPickingImage:allowPickingImage allowPickingVideo:allowPickingVideo];
     
        ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop)  {
            
            if (result == nil) {
                dispatch_main_async_safe_ttImagePicker(^{
                    if (completion) completion(photoArr);
                })
                return ;
            }
            TTAssetModel *model = [self assetModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model && model.assetID) {
                [photoArr addObject:model];
            }
        };
        if (self.sortAscendingByModificationDate) {
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock) { resultBlock(result,index,stop); }
            }];
            
        } else {
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock) { resultBlock(result,index,stop); }
            }];
        }
    }
}

- (TTAssetModel *)assetModelWithAsset:(id)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    TTAssetModel *model;
    TTAssetModelMediaType type = TTAssetModelMediaTypePhoto;
    
    // Gif
    if ([self isGif:asset]) {
        type = TTAssetModelMediaTypePhotoGif;
    }
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        if (phAsset.mediaType == PHAssetMediaTypeVideo)      type = TTAssetModelMediaTypeVideo;
        else if (phAsset.mediaType == PHAssetMediaTypeAudio) type = TTAssetModelMediaTypeAudio;
        else if (phAsset.mediaType == PHAssetMediaTypeImage) {
            if (iOS9_1Later) {
                // if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = TZAssetModelMediaTypeLivePhoto;
            }
       
        }
        if (!allowPickingVideo && type == TTAssetModelMediaTypeVideo) return nil;
        if (!allowPickingImage && type == TTAssetModelMediaTypePhoto) return nil;
        if (!allowPickingImage && type == TTAssetModelMediaTypePhotoGif) return nil;
        

        NSString *timeLength = type == TTAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",phAsset.duration] : @"";
        model = [TTAssetModel modelWithAsset:asset type:type timeLength:timeLength];
    } else {
        if (!allowPickingVideo){
            model = [TTAssetModel modelWithAsset:asset type:type];
            return model;
        }
        /// Allow picking video
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            type = TTAssetModelMediaTypeVideo;
            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] integerValue];
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
            model = [TTAssetModel modelWithAsset:asset type:type timeLength:timeLength];
        } else {
            
            model = [TTAssetModel modelWithAsset:asset type:type];
        }
    }
    return model;
}


#pragma mark - Get Photo & Gif
/// Get photo 获得照片本身，默认为屏幕宽度 scale 为3.0。
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    
    return [self getPhotoWithAsset:asset photoWidth:TTImagePickerImageWidthDefault completion:completion progressHandler:nil];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil];
}
/// 指定尺寸的图片获取
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler{

    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:progressHandler isIcloudEabled:self.accessIcloud isSingleTask:NO];
}


- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler  isIcloudEabled:(BOOL)isIcloudEabled isSingleTask:(BOOL)isSingleTask
{
    
    if (photoWidth == TTImagePickerImageWidthDefault) {
        //有缓存，走缓存
        UIImage *cacheImage = [self.cacheManager getImageWithAssetID:[self getAssetIdentifier:asset]];
        
        if (cacheImage) {
            if (cacheImage.size.width < photoWidth/2.0) {
                [self.cacheManager removeImageWithAssetID:[self getAssetIdentifier:asset]];
            }else{
                UIImage *result = [self fixOrientation:cacheImage];
                completion(result,nil,NO);
                return 0;
            }
        }
    }
    BOOL isCached = photoWidth == TTImagePickerImageWidthDefault? YES : NO;

    CGFloat pixelWidth = photoWidth;

    if ([asset isKindOfClass:[PHAsset class]]) {
        
        PHAsset *phAsset = (PHAsset *)asset;
        
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        //判断为全景图
        if (aspectRatio > 3.5) {
            if (pixelWidth == TTImagePickerImageWidthDefault) {
                pixelWidth = TTImagePickerPanoramicImageWidthDefault;
            }else{
                //正常情况下*3 为了让小图相对清晰
                pixelWidth *= 3;
            }
        }
        //相当于非默认的全景图宽度会 *9
        if (pixelWidth != TTImagePickerPanoramicImageWidthDefault) {
            if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                pixelWidth = pixelWidth * getTTScreenScale(pixelWidth,YES);
            }else{
                pixelWidth = pixelWidth * getTTScreenScale(pixelWidth,NO);
            }
        }
    }
    return [self getPhotoWithAssetNonScale:asset photoWidth:pixelWidth completion:completion progressHandler:progressHandler isIcloudEabled:isIcloudEabled isSingleTask:isSingleTask isCached:isCached];

}

- (PHImageRequestID)getPhotoWithAssetNonScale:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion
{
    
    return [self getPhotoWithAssetNonScale:asset photoWidth:photoWidth completion:completion progressHandler:nil isIcloudEabled:self.accessIcloud isSingleTask:NO isCached:NO];
}

- (PHImageRequestID)getPhotoWithAssetNonScale:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler  isIcloudEabled:(BOOL)isIcloudEabled isSingleTask:(BOOL)isSingleTask isCached:(BOOL)isCached
{
   
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        
        CGFloat pixelHeight = photoWidth / aspectRatio;
        //得到需要的size
        CGSize imageSize = CGSizeMake(photoWidth, pixelHeight);
        
        // 修复获取图片时出现的瞬间内存过高问题
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        
        __block UIImage *callBackResult = nil;
        
        PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            //nan crash容错处理
            if (result.size.width <= 0) {
                result = nil;
            }
            if (downloadFinined && result) {
                result = [self fixOrientation:result];
                
                BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                
                if (isDegraded) {
                    callBackResult = result;
                }
                dispatch_main_async_safe_ttImagePicker(^{
                    if (completion) completion(result,info,isDegraded);
                    
                })
                //高清图才去缓存
                if (isCached && !isDegraded && result) {
                    [self.cacheManager setImage:result withAssetID:[self getAssetIdentifier:asset]];
                }
                return;
            }
            else{
                //不支持icloud的兜底
                if (!isIcloudEabled) {
                    if (isCached && callBackResult) {
                        [self.cacheManager setImage:callBackResult withAssetID:[self getAssetIdentifier:asset]];
                    }
                    if (completion) completion(callBackResult,info,NO);
                    return;
                }
            }
            // Download image from iCloud / 从iCloud下载图片
            if ([info objectForKey:PHImageResultIsInCloudKey] && isIcloudEabled) {
                
                [self.icloudDownloader getIcloudPhotoWithAsset:asset
                                                    completion:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                        
                                                        BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                                        //得到长宽10倍尺寸，去用来裁剪，内存大小还是imageData，方便裁剪
                                                        UIImage *resultImage = nil;
                                                        if (imageData) {
                                                            resultImage = [UIImage imageWithData:imageData scale:0.1];
                                                        }
                                                        //nan crash容错处理
                                                        if (resultImage.size.width <= 0) {
                                                            resultImage = nil;
                                                        }
                                                        
                                                        if (resultImage) {
                                                            resultImage = [self scaleImage:resultImage toSize:imageSize];
                                                            resultImage = [[TTImagePickerManager manager] fixOrientation:resultImage];
                                                            //高清图才去缓存
                                                            if (isCached && !isDegraded) {
                                                                [self.cacheManager setImage:resultImage withAssetID:[self getAssetIdentifier:asset]];
                                                            }
                                                        }
                                                        completion(resultImage,info,isDegraded);
                                                        
                                                    } progressHandler:progressHandler isSingleTask:isSingleTask];
            }
        }];
        return imageRequestID;

    }else if ([asset isKindOfClass:[ALAsset class]]) {
    ALAsset *alAsset = (ALAsset *)asset;
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        CGImageRef thumbnailImageRef = alAsset.thumbnail;
        //把图片缩小两倍，以适配-显卡放大,无锯齿
        UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef scale:2.0 orientation:UIImageOrientationUp];
        dispatch_async(dispatch_get_main_queue(), ^{
            //先回调缩略图
            if (completion) completion(thumbnailImage,nil,YES);
            //原图
            if (photoWidth >= TTImagePickerImageWidthDefault) {
                dispatch_async(dispatch_get_global_queue(0,0), ^{
                    ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
                    CGImageRef fullScrennImageRef = [assetRep fullScreenImage];
                    if (!fullScrennImageRef) {
                        fullScrennImageRef = [assetRep fullResolutionImage];
                    }
                    if (!fullScrennImageRef) {
                        fullScrennImageRef = alAsset.aspectRatioThumbnail;
                    }
                    if (!fullScrennImageRef) {
                        fullScrennImageRef = alAsset.thumbnail;
                    }
                    
                    UIImage *fullScrennImage = [UIImage imageWithCGImage:fullScrennImageRef scale:2.0 orientation:UIImageOrientationUp];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) completion(fullScrennImage,nil,NO);
                    });
                    //缓存
                    [self.cacheManager setImage:fullScrennImage withAssetID:[self getAssetIdentifier:asset]];
                });
            }else{
                if (completion) completion(thumbnailImage,nil,NO);
            }
        });
    });
}
    return 0;

}


/// Get Original Photo / 获取原图
/// 得到原始的图片
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,BOOL isDegraded))completion {
    [self getOriginalPhotoWithAsset:asset completion:completion progressHandler:nil];
}

- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    [self getOriginalPhotoWithAsset:asset completion:completion progressHandler:progressHandler isSingleTask:NO];
}

- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler isSingleTask:(BOOL)isSingleTask
{
    //如果是PHAsset
    if ([asset isKindOfClass:[PHAsset class]]) {
        
        [self getOriginalPhotoDataWithAsset:asset completion:^(NSData *data, BOOL isDegraded) {
            UIImage *image = nil;
            if (data) {
                image = [UIImage imageWithData:data];
            }
            completion(image,isDegraded);
            
        } progressHandler:progressHandler isSingleTask:isSingleTask];
        
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            
            CGImageRef originalImageRef = [assetRep fullResolutionImage];
            if (!originalImageRef) {
                originalImageRef = [assetRep fullScreenImage];
            }
            if (!originalImageRef) {
                originalImageRef = alAsset.aspectRatioThumbnail;
            }
            if (!originalImageRef) {
                originalImageRef = alAsset.thumbnail;
            }
            UIImage *originalImage = [UIImage imageWithCGImage:originalImageRef scale:1.0 orientation:UIImageOrientationUp];
            
            dispatch_main_async_safe_ttImagePicker(^{
                if (completion) completion(originalImage,NO);
            })
        });
    }

}


/// 得到原始的图片数据
- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,BOOL isDegraded))completion {
    [self getOriginalPhotoDataWithAsset:asset completion:completion progressHandler:nil];
}

- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    [self getOriginalPhotoDataWithAsset:asset completion:completion progressHandler:progressHandler isSingleTask:NO];
}

- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler isSingleTask:(BOOL)isSingleTask
{

    if ([asset isKindOfClass:[PHAsset class]]) {
        [self.icloudDownloader getIcloudPhotoWithAsset:asset completion:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (completion) {
                completion(imageData,isDegraded);
            }
        } progressHandler:progressHandler isSingleTask:isSingleTask];
    }
    else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
        Byte *imageBuffer = (Byte *)malloc(assetRep.size);
        NSUInteger bufferSize = [assetRep getBytes:imageBuffer fromOffset:0.0 length:assetRep.size error:nil];
        NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
        dispatch_main_async_safe_ttImagePicker(^{
            if (completion) completion(imageData,NO);
        })
    }
}



/// 得到一组图片 - 默认屏幕宽度 * 2
- (void)getPhotosWithAssets:(NSArray<TTAssetModel *> *)assets completion:(void (^)(NSArray<UIImage *>* photos))completion
{
    [self getPhotosWithAssets:assets photoWidth:TTImagePickerImageWidthDefault completion:completion];
}
/// 得到一组图片 - 指定宽度（默认倍数为宽度 * 2）
- (void)getPhotosWithAssets:(NSArray<TTAssetModel *> *)assets photoWidth:(CGFloat)photoWidth completion:(void (^)(NSArray<UIImage *>* photos))completion
{
    [self getPhotosWithAssets:assets isOriginal:NO photoWidth:photoWidth completion:completion];
}
/// 得到一组图片 - 原图
- (void)getOriginalPhotosWithAssets:(NSArray<TTAssetModel *> *)assets completion:(void (^)(NSArray<UIImage *>* photos))completion
{
    [self getPhotosWithAssets:assets isOriginal:YES photoWidth:0 completion:completion];
}

//以copy代码形式进行的加功能，目标以后干掉另一种取图逻辑
- (void)getPhotosWithAssets:(NSArray<TTAssetModel *> *)assets result:(void (^)(NSArray<TTImagePickerResult *>*))resultBlock {
    NSAssert(!SSIsEmptyArray(assets), @"Assets is empty");
    
    NSUInteger photoWidth = TTImagePickerImageWidthDefault;
    
    TTImagePickerManager *manager =[TTImagePickerManager manager];
    NSMutableArray<TTImagePickerResult*> *photos = [assets mutableCopy];
    
    dispatch_queue_t getPhotoQueue = dispatch_queue_create("GetPhotoQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t getPhotoGroup = dispatch_group_create();
    dispatch_semaphore_t semphore = dispatch_semaphore_create(1);
    
    for (int i = 0; i < assets.count; i++) {
        
        TTAssetModel *model = assets[i];
        
        dispatch_group_enter(getPhotoGroup);
        dispatch_async(getPhotoQueue, ^{
            if (model.type == TTAssetModelMediaTypePhotoGif) { //gif要返回原图
                [manager getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, BOOL isDegraded) {
                    dispatch_semaphore_wait(semphore,DISPATCH_TIME_FOREVER);
                    
                    TTImagePickerResult* result = [[TTImagePickerResult alloc] init];
                    result.image = [UIImage imageWithData:data];
                    result.data = data;
                    result.assetModel = model;
                    
                    [photos replaceObjectAtIndex:i withObject:result];
                    dispatch_semaphore_signal(semphore);
                    dispatch_group_leave(getPhotoGroup);
                }];
            } else{
                [manager getPhotoWithAsset:model.asset photoWidth:photoWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (!isDegraded) {
                        dispatch_semaphore_wait(semphore,DISPATCH_TIME_FOREVER);
                        
                        TTImagePickerResult* result = [[TTImagePickerResult alloc] init];
                        result.image = photo;
                        result.assetModel = model;
                        
                        [photos replaceObjectAtIndex:i withObject:result];
                        dispatch_semaphore_signal(semphore);
                        dispatch_group_leave(getPhotoGroup);
                    }
                }];
            }
            
        });
        
    }
    dispatch_group_notify(getPhotoGroup, dispatch_get_main_queue(), ^(){
        if (resultBlock)
            resultBlock([photos copy]);
    });
}

- (void)getPhotosWithAssets:(NSArray<TTAssetModel *> *)assets isOriginal:(BOOL)isOriginal photoWidth:(CGFloat)photoWidth completion:(void (^)(NSArray<UIImage *>* photos))completion
{
    NSAssert(!SSIsEmptyArray(assets), @"Assets is empty");
    
    TTImagePickerManager *manager =[TTImagePickerManager manager];
    NSMutableArray *photos = [assets mutableCopy];
    
    dispatch_queue_t getPhotoQueue = dispatch_queue_create("GetPhotoQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t getPhotoGroup = dispatch_group_create();
    dispatch_semaphore_t semphore = dispatch_semaphore_create(1);
    
    for (int i = 0; i < assets.count; i++) {

        TTAssetModel *model = assets[i];
    
        dispatch_group_enter(getPhotoGroup);
        dispatch_async(getPhotoQueue, ^{
            if (isOriginal) {
                [manager getOriginalPhotoWithAsset:model.asset completion:^(UIImage *photo, BOOL isDegraded) {
                    if (!isDegraded && photo) {
                        dispatch_semaphore_wait(semphore,DISPATCH_TIME_FOREVER);
                        photo.assetModel = model;
                        [photos replaceObjectAtIndex:i withObject:photo];
                        dispatch_semaphore_signal(semphore);
                        dispatch_group_leave(getPhotoGroup);
                    }
                }];
            } else if (model.type == TTAssetModelMediaTypePhotoGif) { //gif要返回原图
                [manager getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, BOOL isDegraded) {
                    dispatch_semaphore_wait(semphore,DISPATCH_TIME_FOREVER);
                    UIImage * photo = [UIImage sd_animatedGIFWithData:data];
                    photo.assetModel = model;
                    if (photo) {
                        [photos replaceObjectAtIndex:i withObject:photo];
                    }
                    dispatch_semaphore_signal(semphore);
                    dispatch_group_leave(getPhotoGroup);
                }];
            } else{
                [manager getPhotoWithAsset:model.asset photoWidth:photoWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (!isDegraded && photo) {
                        dispatch_semaphore_wait(semphore,DISPATCH_TIME_FOREVER);
                        photo.assetModel = model;
                        [photos replaceObjectAtIndex:i withObject:photo];
                        dispatch_semaphore_signal(semphore);
                        dispatch_group_leave(getPhotoGroup);
                    }
                }];
            }
            
        });
        
    }
    dispatch_group_notify(getPhotoGroup, dispatch_get_main_queue(), ^(){
        if (completion)
            completion([photos copy]);
    });
}


#pragma mark - Get Video

/// 获取视频播放需要的AVPlayerItem
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * _Nullable, NSDictionary * _Nullable))completion
{
    [self getVideoWithAsset:asset completion:completion progressHandler:nil];
}

- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            dispatch_main_async_safe_ttImagePicker(^{
                if (progressHandler) {
                    progressHandler(progress,error,stop,info);
                }
            })
        };
        options.networkAccessAllowed = self.accessIcloud;
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVPlayerItem *playerItem = [[AVPlayerItem alloc]initWithAsset:asset];
            dispatch_main_async_safe_ttImagePicker(^{
                if (completion) completion(playerItem,info);
            })

        }];

    }
    if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *defaultRepresentation = [alAsset defaultRepresentation];
        NSString *uti = [defaultRepresentation UTI];
        NSURL *videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
        dispatch_main_async_safe_ttImagePicker(^{
            if (completion && playerItem) completion(playerItem,nil);
        })
    }
}


/// 得到视频的AVURLAsset
- (void)getVideoAVURLAsset:(id)asset completion:(void (^)(AVURLAsset * asset))completion{
    
    [self getVideoAVURLAsset:asset completion:completion progressHandler:nil];
}

- (void)getVideoAVURLAsset:(id)asset completion:(void (^)(AVURLAsset * asset))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            dispatch_main_async_safe_ttImagePicker(^{
                if (progressHandler) {
                    progressHandler(progress,error,stop,info);
                }
            })
        };      
        options.networkAccessAllowed = self.accessIcloud;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
            
            AVURLAsset *videoAsset = nil;
            if ([avasset isKindOfClass:[AVURLAsset class]]) {
                videoAsset = (AVURLAsset*)avasset;
            }
            //坑死人！
            dispatch_main_async_safe_ttImagePicker(^{
                if (completion) {
                    completion(videoAsset);
                }
            })
        }];
        
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        NSURL *videoURL =[asset valueForProperty:ALAssetPropertyAssetURL]; // ALAssetPropertyURLs
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        dispatch_main_async_safe_ttImagePicker(^{
            if (completion) {
                completion(videoAsset);
            }
        })
    }
}


#pragma mark - ImgHandle

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (!self.shouldFixOrientation) return aImage;
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}




#pragma mark - Tools 

/// Save photo
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(id, NSError *))completion
{
    if (iOS8Later) {
        NSMutableArray *imageIds = [NSMutableArray array];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            
            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
            
            //            options.shouldMoveFile = YES;
            //            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                if (completion) {
                    //成功后取相册中的图片对象
                    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
                    PHAsset *imageAsset = result.firstObject;
                    dispatch_main_async_safe(^{
                        if (completion) {
                            completion(imageAsset,nil);
                        }
                    });
                }
            } else {
                dispatch_main_async_safe(^{
                    if (completion) {
                        completion(nil,error);
                    }
                });
            }
        }];
    } else {
        
        [self.assetLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:[self orientationFromImage:image] completionBlock:^(NSURL *assetURL, NSError *error) {
            
            if (error) {
                dispatch_main_async_safe(^{
                    if (completion) {
                        completion(nil,error);
                    }
                });
            } else {
                // 多给系统0.5秒的时间，让系统去更新相册数据
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        dispatch_main_async_safe(^{
                            if (completion) {
                                completion(asset,nil);
                            }
                        });
                    } failureBlock:^(NSError *error) {
                        dispatch_main_async_safe(^{
                            if (completion) {
                                completion(nil,error);
                            }
                        });
                    }];
                });
            }
        }];
    }
}



/// 默认图片尺寸
- (UIImage *)getdefaultImageSize:(UIImage *)image
{
    float scale = image.size.height/image.size.width;
    float height = scale * TTImagePickerImageWidthDefault * getTTScreenScale(TTImagePickerImageWidthDefault,NO);
    float finnalHeight = ceil(height);
    return [self scaleImage:image toSize:CGSizeMake(TTImagePickerImageWidthDefault *getTTScreenScale(TTImagePickerImageWidthDefault,NO), finnalHeight)];
}
/// 压缩到制定尺寸
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}
- (ALAssetOrientation)orientationFromImage:(UIImage *)image {
    NSInteger orientation = image.imageOrientation;
    return orientation;
}


- (NSString *)getAssetIdentifier:(id)asset {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        return phAsset.localIdentifier;
    }
    if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        NSURL *assetUrl = [alAsset valueForProperty:ALAssetPropertyAssetURL];
        return assetUrl.absoluteString;
    }
    return @"";
}

- (BOOL)isGif:(id)asset
{
    if (self.hideGif) {
        return NO;
    }
    if ([asset isKindOfClass:[PHAsset class]]) {
        //icloud下来的图片会失去gif属性
        if ([self isNeedIcloudSync:asset]) {
            return NO;
        }
        PHAsset *phAsset = (PHAsset *)asset;
        if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            return YES;
        }
        return NO;
    }else{
//        ALAsset *alAsset = (ALAsset *)asset;
//        ALAssetRepresentation *re = [alAsset representationForUTI:(__bridge NSString *)kUTTypeGIF];
//        if (re) {
//            return YES;
//        }
//        return NO;
        return NO;
    }
 
}

- (BOOL)isNeedIcloudSync:(id)asset
{
    if (![asset isKindOfClass:[PHAsset class]]) {
        return NO;
    }
    PHAsset *phAsset = asset;
    
    BOOL isImage = phAsset.mediaType == PHAssetMediaTypeImage;
    BOOL isVideo = phAsset.mediaType == PHAssetMediaTypeVideo;
    
    //本地无图，icloud有图标识
    NSNumber *cloudPlaceholderKind;
    NSNumber *localResourcesState;
    
    @try {
        cloudPlaceholderKind = [asset valueForKey:@"_cloudPlaceholderKind"];
        localResourcesState = [asset valueForKey:@"_localResourcesState"];
        
    } @catch (NSException *exception) {
        NSLog(@"%@ --无法获取到icloud标识，icloud图低清图适配",exception);
    } @finally {
    }
    if (isImage && cloudPlaceholderKind && [cloudPlaceholderKind intValue] == 3) {
        return YES;
    }
    if (isVideo && cloudPlaceholderKind && [cloudPlaceholderKind intValue] == 4) {
        
        if (localResourcesState && [localResourcesState intValue] == 130) {
            //命中icloud本地cached视频
        }else{
            return YES;
        }
    }
    return NO;
}


#pragma mark - Auth

- (void)startAuthAlbumWithSuccess:(dispatch_block_t)successAuth fail:(dispatch_block_t)failAuth
{
    self.successAuth = successAuth;
    self.failAuth = failAuth;
    //已得到相册权限结果，直接返回
    if (![self isAuthAlbumIng]) {
        return;
    }
    //正在获取权限中，返回
    if (_timer) {
        NSLog(@"正获取在授权中...");
        return;
    }
    //触发相册权限
    [[TTImagePickerManager manager] getCameraRollAlbum:YES allowPickingImage:YES completion:^(TTAlbumModel *model) {
    }];
    
    [self startTimer];
}

//返回YES，代表还在auth
- (bool)isAuthAlbumIng
{
    switch ([self authorizationStatus]) {
        case PHAuthorizationStatusNotDetermined:
            return YES;

        case PHAuthorizationStatusAuthorized:
        {
            if (self.successAuth != nil) {
                self.successAuth();
                //释放Block，防止循环引用
                self.successAuth = nil;
                self.failAuth = nil;
            }
            [self stopTimer];
            
            return NO;
        }
        default:
            if (self.failAuth != nil) {
                self.failAuth();
                //释放Block，防止循环引用
                self.successAuth = nil;
                self.failAuth = nil;
            }
            [self stopTimer];
            return NO;
    }
}

- (void)startTimer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(isAuthAlbumIng) userInfo:nil repeats:YES];
    }
}
- (void)stopTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

/// 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized {
    return [self authorizationStatus] == PHAuthorizationStatusAuthorized;
}

- (NSInteger)authorizationStatus {
    if (iOS8Later) {
        return [PHPhotoLibrary authorizationStatus];
    } else {
        return [ALAssetsLibrary authorizationStatus];
    }
    return NO;
}


#pragma clang diagnostic pop
//14年及以后出来的手机算高端手机
+ (BOOL )isLowIphoneVersion {
    static BOOL lowIphoneVersion = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* platString = [UIDevice currentDevice].platform;
        if (platString) {
            if ([platString isEqualToString:@"i386"] || [platString isEqualToString:@"x86_64"]) {
                lowIphoneVersion = NO;
            } else if ([platString hasPrefix:@"iPhone"]) { //6和6plus以上手机可以
                NSString* str = [[platString componentsSeparatedByString:@","] firstObject];
                int version = [[str substringFromIndex:[str rangeOfString:@"iPhone"].length] intValue];
                if (version >= 7) {
                    lowIphoneVersion = NO;
                }
            } else if ([platString hasPrefix:@"iPad"]) { //air2代和mini4代及所有pro可以
                NSString* str = [[platString componentsSeparatedByString:@","] firstObject];
                int version = [[str substringFromIndex:[str rangeOfString:@"iPad"].length] intValue];
                if (version >= 5) {
                    lowIphoneVersion = NO;
                }
            }
        }
    });
    
    return lowIphoneVersion;
}


+ (BOOL)isValidLang
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    if ([preferredLang isEqualToString:@"en-CN"] || [preferredLang isEqualToString:@"en"]||[preferredLang isEqualToString:@"zh-Hans"]||[preferredLang isEqualToString:@"zh-Hans-CN"]) {
        return YES;
    }
    return NO;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.cacheManager removeAllImages];
}
@end
