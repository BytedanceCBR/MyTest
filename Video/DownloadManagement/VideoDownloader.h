//
//  VideoDownloader.h
//  Video
//
//  Created by Dianwei on 12-7-24.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoData.h"

#define kDefaultMaxConcurrentNumber                     3

#define kVideoDownloaderErrorDomain                     @"kVideoDownloaderErrorDomain"
#define kVideoDownloaderErrorInvalidLogicCode           1001
#define kVideoDownloaderErrorFileManagementFailedCode   1002
#define kVideoDownloaderErrorInvalidFormatCode          1003
#define kVideoDownloaderErrorNoNetworkCode              1004

typedef enum DownloadStatus
{
    DownloadStatusNotStarted,
    DownloadStatusDownloadingIndex,
    DownloadStatusIndexDownloaded,
    DownloadStatusDownloadingFiles,
    DownloadStatusDownloadFinished
}DownloadStatus;

@class VideoDownloader;
@protocol VideoDownloaderProtocol <NSObject>
@optional
- (void)videoDownloader:(VideoDownloader*)downloader progressChangedTo:(NSNumber*)newProgress;
- (void)videoDownloader:(VideoDownloader*)downloader downloadStatusChangedTo:(NSNumber*)newStatus;

// two errors will be delivered:
// 1) ASIHttpOperation error
// 2) error with kVideoDownloaderErrorDomain

- (void)videoDownloader:(VideoDownloader*)downloader failedWithError:(NSError*)error;
@end

@interface VideoDownloader : NSObject
- (id)initWithVideo:(VideoData*)video;
- (void)start;
- (void)startWithPriority:(NSOperationQueuePriority)priority;
- (void)stop;

// remove all download result including intermidate/final files and segments data, no matter the download is finished or not
- (void)remove;

//+ (void)setMaxConcurrentDownloadOperation:(int)max;
//+ (int)maxConcurrentDownloadOperation;

@property(nonatomic, assign)DownloadStatus currentStatus;
@property(nonatomic, readonly)float progress;
@property(nonatomic, retain, readonly)VideoData *video;
@property(nonatomic, assign)NSObject<VideoDownloaderProtocol> *delegate;


@end
