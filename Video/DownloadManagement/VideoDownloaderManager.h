//
//  VideoDownloaderManager.h
//  Video
//
//  Created by Dianwei on 12-7-24.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDownloader.h"
#import "VideoData.h"

typedef enum VideoDownloaderType
{
    VideoDownloaderTypeM3U8,
    VideoDownloaderTypeMP4
}VideoDownloaderType;

@interface VideoDownloaderManager : NSObject

+ (VideoDownloader*)downloaderForType:(VideoDownloaderType)downloaderType video:(VideoData*)video;
@end
