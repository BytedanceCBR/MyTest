//
//  VideoDownloader.h
//  Video
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDownloader.h"





/*
 The video downloader, support break-point continuation downloads.
 the change for download progress and status will publish corresponding notifications.
 Note that You should not restart the download inside the notification, undefined behavior for that.
 */

@interface M3U8VideoDownloader : VideoDownloader

// it will not affect the currently running operations
+ (NSOperationQueue*)videoDownloadQueue;

@end
