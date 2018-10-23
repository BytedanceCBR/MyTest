//
//  VideoDownloadView.h
//  Video
//
//  Created by 于 天航 on 12-8-1.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoMainViewController.h"

typedef enum VideoDownloadViewType {
    VideoDownloadViewTypeNormal,
    VideoDownloadViewTypeDownloading
} VideoDownloadViewType;

@class VideoData;

@interface VideoDownloadView : UIView

@property (nonatomic, copy) NSString *trackEventName;

- (void)setVideo:(VideoData *)video type:(VideoDownloadViewType)type;
- (void)refreshUI;

@end
