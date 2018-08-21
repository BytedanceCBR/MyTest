//
//  TTForumPostImageCache.h
//  Article
//
//  Created by SongChai on 05/06/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTAssetModel.h"


//子线程串行处理
//所有数据同步全部主线程处理
static void TTMainSafeSycnExecuteBlock(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static void TTMainSafeExecuteBlock(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

typedef enum : NSUInteger {
    IcloudSyncNone,      //不需要icloud
    IcloudSyncExecuting, //进行中
    IcloudSyncFailed,    //失败
    IcloudSyncComplete,  //完成
} IcloudSyncStatus;

typedef void(^TTForumPostImageCacheComplete)(NSString* path); //nil表示失败

typedef void(^PostIcloudCompletion)(BOOL success);
typedef void(^PostIcloudProgressHandler)(double progress, NSError *error, BOOL *stop, NSDictionary *info);


@interface TTForumPostImageCacheTask : NSObject
@property(nonatomic, strong) NSString* key;
@property(nonatomic, strong) id originalSource;

@property(nonatomic, strong) TTAssetModel* assetModel;

@property(nonatomic, assign) IcloudSyncStatus status;
@property(nonatomic, strong) NSArray <PostIcloudCompletion> *icloudCompletes;
@property(nonatomic, strong) NSArray <PostIcloudProgressHandler> *icloudProgresses;

//@property(nonatomic, copy) PostIcloudCompletion icloudComplete;
//@property(nonatomic, copy) PostIcloudProgressHandler icloudProgress;


@end

@interface TTForumPostImageCache : NSObject

+ (TTForumPostImageCache*)sharedInstance;

//originalSource可能是PLAsset ALAsset UIImage
//UIImage仅仅在拍照之后使用，没毛病，缺陷是UIImage内存销毁后不能正确找到资源，所以少用

//上传时候使用，上传失败之后存草稿使用
- (void) queryFilePathWithSource:(TTForumPostImageCacheTask*)task complete:(void (^)(NSString*))block;

- (BOOL) fileExist:(TTForumPostImageCacheTask*)task;
/**
 将源内容加入图片缓存区

 @param originalSource 源内容支持NSString、UIImage、PLAsset、ALAsset、TTAssetModel，其它类型一律不支持
 @return 返回图片cache的任务
 */
- (TTForumPostImageCacheTask*) saveCacheSource:(id)originalSource;
- (NSArray<TTForumPostImageCacheTask*>*) saveCacheWithAssets:(NSArray<TTAssetModel*> *)models;

//发布器中删除一张图片调用，发布成功调用，发布失败存草稿时调用，只删内存任务，不删本地缓存
- (void) removeCacheSource:(id)originalSource;
- (void) removeTask:(TTForumPostImageCacheTask*)task;

//发布成功调用，删内存任务，删本地缓存
- (void) deleteCacheSource:(id)originalSource;
- (void) deleteTask:(TTForumPostImageCacheTask*)task;
@end
