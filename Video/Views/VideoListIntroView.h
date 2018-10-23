//
//  VideoIntroView.h
//  Video
//
//  Created by Tianhang Yu on 12-7-26.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoData;

typedef enum {
    VideoIntroViewTypeList,
    VideoIntroViewTypeDownloadingList,
} VideoIntroViewType;

@interface VideoListIntroView : UIView

@property (nonatomic, retain) VideoData *videoData;
@property (nonatomic) BOOL showGrayForRead;

- (id)initWithFrame:(CGRect)frame type:(VideoIntroViewType)type;
- (void)setVideoData:(VideoData *)videoData type:(VideoIntroViewType)type;
- (void)refreshUI;

@end
