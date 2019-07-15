//
//  TTUGCImageMonitor.h
//  TTUGCFeature
//
//  Created by SongChai on 2018/3/5.
//

#import <Foundation/Foundation.h>
#import "FRImageInfoModel.h"

@interface TTUGCImageMonitor : NSObject

// 入屏
+ (void)startWithImageModel:(FRImageInfoModel *)imageModel;

// cache
+ (void)inCacheImageModel:(FRImageInfoModel *)imageModel;

// 请求完成
+ (void)requestCompleteWithImageModel:(FRImageInfoModel *)imageModel withSuccess:(BOOL)success;

// 出屏
+ (void)stopWithImageModel:(FRImageInfoModel *)imageModel;

#pragma mark - gif下载统计
/**
 * gif下载统计
 */
+ (void)trackGifDownloadSucceed:(BOOL)succeed index:(NSUInteger)index costTimeInterval:(NSTimeInterval)costTimeInterval;

@end
