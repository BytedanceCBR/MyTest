//
//  VideoDownloadsManager.h
//  Video
//
//  Created by Tianhang Yu on 12-7-25.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum VideoFeedbackFailedType {
    VideoFeedbackFailedTypeDownloadFailed,
    VideoFeedbackFailedTypePlayFailed
} VideoFeedbackFailedType;

#define VideoDownloadDataManagerNewProgressNotification @"VideoDownloadDataManagerNewProgressNotification"
#define kVideoDownloadDataManagerNewProgressNumberKey @"kVideoDownloadDataManagerNewProgressNumberKey"

#define kVideoDownloadDataManagerBatchStartedUserDefaultKey @"kVideoDownloadDataManagerBatchStartedUserDefaultKey"

static inline bool videoDownloadDataManagerBatchStarted () {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoDownloadDataManagerBatchStartedUserDefaultKey];
}

static inline void setVideoDownloadDataManagerBatchStarted (bool started) {
    [[NSUserDefaults standardUserDefaults] setBool:started forKey:kVideoDownloadDataManagerBatchStartedUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

typedef enum {
    VideoDownloadDataListTypeDownloading = 1,
    VideoDownloadDataListTypeHasDownload = 2
} VideoDownloadDataListType;

@class VideoDownloadDataManager;

@protocol VideoDownloadDataManagerDelegate <NSObject>

@optional
- (void)downloadManager:(VideoDownloadDataManager *)manager didReceivedDownloadDataList:(NSArray *)dataList dataListType:(VideoDownloadDataListType)type error:(NSError *)error;

@end


@class VideoData;

@interface VideoDownloadDataManager : NSObject

@property (nonatomic, assign) id<VideoDownloadDataManagerDelegate> delegate;
@property (nonatomic, readonly) VideoDownloadDataListType dataListType;
@property (nonatomic, readonly) BOOL downloading;
@property (nonatomic, readonly) BOOL batchStarted;

+ (VideoDownloadDataManager *)sharedManager;
+ (NSUInteger)downloadTabCount;

- (void)startGetDownloadDataListByType:(VideoDownloadDataListType)dataListType;

- (void)currentDownloadStart;
- (void)currentDownloadStop;

- (void)batchStart;
- (void)batchStop;

- (void)startWithVideoData:(VideoData *)video;
- (void)stopWithVideoData:(VideoData *)video;
- (void)retryWithVideoData:(VideoData *)video;
- (void)removeWithVideoData:(VideoData *)video;

// feedback
- (void)videoFeedbackFailed:(VideoFeedbackFailedType)type video:(VideoData *)video;

@end

