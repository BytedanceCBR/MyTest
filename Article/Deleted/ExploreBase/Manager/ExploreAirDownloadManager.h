//
//  ExploreAirDownloadManager.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-19.
//
//

#import <Foundation/Foundation.h>
#import "CategoryModel.h"


#pragma mark - CategoryModel + AirDownload
@interface CategoryModel (AirDownload)
- (BOOL)isAirDownloadRequired;
- (void)setAirDownloadRequired:(BOOL)required;
@end


/**
 *  下载进度Block
 *
 *  @param isFinish                 是否完成
 *  @param category                 当前正在下载的category model
 *  @param downloadedImgCount       当前频道已经下载的图片的数量
 *  @param totalImgCount            当前频道需要下载的图片的数量
 *  @param downloadedItemCount      当前频道已经下载的item的数量
 *  @param totalItemCount           当前频道需要下载的item的数量
 *  @param percent                  当前category下载的进度 0 - 1 表示
 *  @param totalPercent             离线下载的进度         0 - 1 表示
 */
typedef void(^ExploreAirDownloadProgressBlock)(BOOL isFinish,
                                               CategoryModel * category,
                                               NSUInteger downloadedImgCount,
                                               NSUInteger totalImgCount,
                                               NSUInteger downloadedItemCount,
                                               NSUInteger totalItemCount,
                                               CGFloat percent,
                                               CGFloat totalPercent);

@interface ExploreAirDownloadManager : NSObject

/**
 *  获得离线下载的全局manager
 */
+ (ExploreAirDownloadManager *)shareInstance;

/**
 *  开始离线下载
 *
 *  @param array         category model 的数组
 *  @param progressBlock 进度Block
 */
- (void)startAirDownloadForCategorys:(NSArray *)array finishBlock:(ExploreAirDownloadProgressBlock)progressBlock;
/**
 *  取消这次离线下载
 */
- (void)cancel;

/*
 *  所有的频道
 */
- (NSArray *)allSubScribedCategories;

/*
 *  选择离线的频道
 */
- (NSArray *)airDownloadSubScribedCategories;

+ (NSString *) downloadFormatStringWithCategory:(CategoryModel *) category
                           downloadedImageCount:(NSUInteger)downloadedImgCount
                                totalImageCount:(NSUInteger) totalImageCount
                            downloadedItemCount:(NSUInteger) downloadedItemCount
                                 totalItemCount:(NSUInteger) totalItemCount;

@end
