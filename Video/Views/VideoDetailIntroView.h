//
//  VideoDetailIntroView.h
//  Video
//
//  Created by Kimi on 12-10-21.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSViewBase.h"

typedef enum {
    VideoDetailIntroViewTypeHalfScreen,
    VideoDetailIntroViewTypeFullScreen
} VideoDetailIntroViewType;

@class VideoData;
@interface VideoDetailIntroView : SSViewBase

@property (nonatomic, retain) VideoData *videoData;
@property (nonatomic) VideoDetailIntroViewType type;

- (id)initWithFrame:(CGRect)frame type:(VideoDetailIntroViewType)type;
- (void)refreshUI;

@end
