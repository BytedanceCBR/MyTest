//
//  MP4VideoDownloader.h
//  Video
//
//  Created by Dianwei on 12-7-24.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDownloader.h"

/*
 The downloader for mp4 format. Unless m3u8 downloader, mp4 downloader treats the file as a whole.
 The download status for this downloader is only DownloadStatusNotStarted, DownloadStatusDownloadingFiles and DownloadStatusDownloadFinished.
 */
@interface MP4VideoDownloader : VideoDownloader

@end
