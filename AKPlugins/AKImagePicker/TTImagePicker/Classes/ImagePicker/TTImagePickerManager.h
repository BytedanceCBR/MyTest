//
//  TTImageManager.h
//  TestPhotos
//
//  Created by tyh on 2017/4/6.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAssetModel.h"
#import "TTAlbumModel.h"
#import "TTImagePickerDefineHead.h"
#import "TTImagePickerCacheManager.h"
#import "TTImagePickerIcloudDownloader.h"

#define TTImagePickerImageWidthDefault  KScreenWidth

@interface TTImagePickerResult : NSObject
@property(nonatomic, strong) TTAssetModel* assetModel;
@property(nonatomic, strong) UIImage* image; //都是静图，gif只有第一帧
@property(nonatomic, strong) NSData* data; //如果是gif，会有data
@end

@interface TTImagePickerManager : NSObject

#pragma mark - Init
/// 单例
+ (instancetype)manager;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


#pragma mark - Property
/// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;
/// 是否修正图片转向 （默认YES，修正为UIImageOrientationUp）
@property (nonatomic, assign) BOOL shouldFixOrientation;
/// 是否支持icloud相册，以及icloud图片请求，默认为NO,全局控制
@property (nonatomic, assign) BOOL accessIcloud;
/// 大图缓存类
@property (nonatomic, strong)TTImagePickerCacheManager *cacheManager;
/// icloud下载类
@property (nonatomic, strong)TTImagePickerIcloudDownloader *icloudDownloader;

#pragma mark - Get Album

/**
 获得默认的相机胶卷相册（所有照片）

 @param allowPickingVideo 是否需要视频
 @param allowPickingImage 是否需要图片
 @param completion 获取完成的回调
 */

- (void)getCameraRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(TTAlbumModel *model))completion;

/// 获得所有相册
- (void)getAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<TTAlbumModel *> *models))completion;

/// 获得相册封面照
- (void)getPostImageWithAlbumModel:(TTAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;

#pragma mark - Get Asset


/**
 获得相册所有Asset（图片或者视频）
 
 @param result 相册对象
 */
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<TTAssetModel *> *))completion;



#pragma mark - Get Photo

/**
 根据Asset得到照片,默认本地没有，则会去icloud同步
 默认尺寸为 屏幕宽度 *3
 注意，所有方法里，只有默认尺寸图片做了缓存，缓存会写两次，isDegraded为YES时候会写一次，如果isDegraded为NO，高清还会写一次。
 @param asset 图片或者视频对象
 @param completion isDegraded标识是否是低品质图，如果有高品质图会二次回调这个completion。
 @return 请求的id,可以用这个id来cancel这次请求
 */

- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

/// 可以指定尺寸:photoWidth  返回的图片宽度为 photoWidth * 3，全景图为宽度 * 9
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

/// 可以得到图片获取进度:progressHandler
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

/// isIcloudEabled：可以指定单张图片是否请求icloud
/// isSingleTask：如果是预览，同一时间只有一个task（串行队列单任务）的请求还是选中download（串行队列多任务），如果是为了下载图片isSingleTask传NO即可。
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler  isIcloudEabled:(BOOL)isIcloudEabled isSingleTask:(BOOL)isSingleTask;

/// 可以指定尺寸:photoWidth  返回图片宽度不变，仍为：photoWidth
- (PHImageRequestID)getPhotoWithAssetNonScale:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

/// 图片请求最终方法，所有参数全
- (PHImageRequestID)getPhotoWithAssetNonScale:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler  isIcloudEabled:(BOOL)isIcloudEabled isSingleTask:(BOOL)isSingleTask isCached:(BOOL)isCached;


/// 根据Asset得到照片,原图,默认本地没有，则会去icloud同步。
/// 得到原始的图片,isDegraded标识是否是低品质图，如果YES则为低品质，NO为高品质。如果有高品质图会二次回调这个completion
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,BOOL isDegraded))completion ;
/// 得到原图，并且可以获取进度。
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;
/// 得到原图，并且可以指定是否是预览的task
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler isSingleTask:(BOOL)isSingleTask;



/// 得到原始的图片data，isDegraded标识是否是低品质图，如果YES则为低品质，NO为高品质。
/// tips:Gif可以用这个方法获取到data，然后播放，判断isDegraded为NO，在播放。
- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,BOOL isDegraded))completion;

/// 得到原图data，并且可以获取进度。
- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;
/// 得到原图data，并且可以指定是否是预览的task。
- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler isSingleTask:(BOOL)isSingleTask;



/// 得到一组图片 - 默认屏幕宽度 * 3
- (void)getPhotosWithAssets:(NSArray<TTAssetModel *> *)assets completion:(void (^)(NSArray<UIImage *>* photos))completion;
/// 得到一组图片 - 指定宽度（默认倍数为宽度 * 3）
- (void)getPhotosWithAssets:(NSArray<TTAssetModel *> *)assets photoWidth:(CGFloat)photoWidth completion:(void (^)(NSArray<UIImage *>* photos))completion;
/// 得到一组图片 - 原图
- (void)getOriginalPhotosWithAssets:(NSArray<TTAssetModel *> *)assets completion:(void (^)(NSArray<UIImage *>* photos))completion;

/// 得到一组图片 - 默认屏幕宽度 * 3
- (void)getPhotosWithAssets:(NSArray<TTAssetModel *> *)assets result:(void (^)(NSArray<TTImagePickerResult *>* photos))resultBlock;


#pragma mark - Get Video
/// Get video 获得视频（播放视频时需要）
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;


/// 得到视频的AVURLAsset
/// 参数asset：iOS8以上PHAsset或者以下的ALAsset，返回asset：AVURLAsset
/// (然后可以通过微头条视频发布器那一套压缩规则，得到最终的本地视频地址,关联类：TTVideoReencodeCompressHelper，详细的可以问问霜晴)
- (void)getVideoAVURLAsset:(id)asset completion:(void (^)(AVURLAsset * asset))completion;

- (void)getVideoAVURLAsset:(id)asset completion:(void (^)(AVURLAsset * asset))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;


#pragma mark - Auth

/// 开始获取相册授权，授权成功回调successAuth，授权失败回调failAuth。
/// 如果没选择、则一直不会触发回调，内部会做一个轮询，来得知用户是否决定授权
- (void)startAuthAlbumWithSuccess:(dispatch_block_t)successAuth fail:(dispatch_block_t)failAuth;

/// 返回YES如果得到了授权使用相册
- (BOOL)authorizationStatusAuthorized;


#pragma mark - Tools

/// 保存图片到相册，回调中可以拿到对应的Asset
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(id asset, NSError *error))completion;

/// 得到默认需要的图片尺寸，屏幕宽 *3
- (UIImage *)getdefaultImageSize:(UIImage *)image;

/// 得到Asset的ID，Asset唯一标识
- (NSString *)getAssetIdentifier:(id)asset;

- (TTAssetModel *)assetModelWithAsset:(id)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage;
/// 压缩图片到制定尺寸
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage;

/// 是否需要icloud同步高清图的
- (BOOL)isNeedIcloudSync:(id)asset;
@end
