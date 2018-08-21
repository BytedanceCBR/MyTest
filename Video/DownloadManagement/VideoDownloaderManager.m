//
//  VideoDownloaderManager.m
//  Video
//
//  Created by Dianwei on 12-7-24.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDownloaderManager.h"
#import "MP4VideoDownloader.h"
#import "M3U8VideoDownloader.h"

@implementation VideoDownloaderManager
+ (VideoDownloader*)downloaderForType:(VideoDownloaderType)downloaderType video:(VideoData*)video
{
    VideoDownloader *downloader = nil;
    switch (downloaderType) {
        case VideoDownloaderTypeM3U8:
        {
            downloader = [[M3U8VideoDownloader alloc] initWithVideo:video];
        }
            break;
        case VideoDownloaderTypeMP4:
        {
            downloader = [[MP4VideoDownloader alloc] initWithVideo:video];
        }
            break;
        default:
            break;
    }
    
    return [downloader autorelease];
}

@end
