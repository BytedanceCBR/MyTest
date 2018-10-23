//
//  VideoData.h
//  Video
//
//  Created by Tianhang Yu on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OriginalData.h"

#define VideoDataFormatM3U8 @"m3u8"
#define VideoDataFormatMP4  @"mp4"

#define VideoDownloadURLHeaderFFContentType @"ff-content-type"
#define VideoDownloadURLHeaderFFContentTypeM3U8 @"video/m3u8"
#define VideoDownloadURLHeaderFFContentTypeMP4  @"video/mp4"

typedef enum {
    VideoDownloadDataStatusNone,
    VideoDownloadDataStatusDownloadFailed,
    VideoDownloadDataStatusWaiting,
    VideoDownloadDataStatusDownloading,
    VideoDownloadDataStatusPaused,
    VideoDownloadDataStatusHasDownload,
    VideoDownloadDataStatusDeadLink,
    VideoDownloadDataStatusNoDownloadURL
} VideoDownloadDataStatus;

@interface VideoData : OriginalData

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *publishTime;
@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *coverImageURL;
@property (nonatomic, retain) NSString *downloadURL;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSNumber *size;
@property (nonatomic, retain) NSNumber *behotTime;
@property (nonatomic, retain) NSString *shareURL;
@property (nonatomic, retain) NSNumber *diggCount;
@property (nonatomic, retain) NSNumber *buryCount;
@property (nonatomic, retain) NSNumber *commentCount;
@property (nonatomic, retain) NSNumber *userDigged;
@property (nonatomic, retain) NSNumber *userBuried;
@property (nonatomic, retain) NSString *format;
@property (nonatomic, retain) NSNumber *playCount;
@property (nonatomic, retain) NSNumber *rate;
@property (nonatomic, retain) NSNumber *tip;
@property (nonatomic, retain) NSString *socialActionStr;
@property (nonatomic, retain) NSString *altDownloadURL; // 备用download URL
@property (nonatomic, retain) NSString *altFormat;  // 备用格式

@property (nonatomic, retain) NSString *localURL;
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSNumber *downloadStatus;
@property (nonatomic, retain) NSNumber *downloadTime;
@property (nonatomic, retain) NSNumber *userDownloaded;
@property (nonatomic, retain) NSNumber *downloadDataStatus;
@property (nonatomic, retain) NSNumber *downloadProgress;
@property (nonatomic, retain) NSNumber *hasRead;    // 仅用于已下载的data的已读状态
@property (nonatomic, retain) NSNumber *totalLength;
@property (nonatomic, retain) NSNumber *addHistory; // 用户播放，下载，进入过详情页的视频
@property (nonatomic, retain) NSNumber *historyTime;


@end
