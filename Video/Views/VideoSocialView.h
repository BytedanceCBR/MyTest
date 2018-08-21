//
//  VideoSocialView.h
//  Video
//
//  Created by Kimi on 12-10-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSViewBase.h"

#define VideoSocialViewHeight 44.f

typedef enum {
    VideoSocialViewTypeHalfScreen,
    VideoSocialViewTypeFullScreen
} VideoSocialViewType;

@class VideoSocialView;
@protocol VideoSocailViewDelegate <NSObject>

@optional
- (void)videoSocialView:(VideoSocialView *)socialView didClickedBackButton:(UIButton *)backButton;

@end

@class VideoData;
@interface VideoSocialView : SSViewBase

- (id)initWithFrame:(CGRect)frame type:(VideoSocialViewType)type;

@property (nonatomic, assign) id<VideoSocailViewDelegate> delegate;
@property (nonatomic, retain) VideoData *videoData;
@property (nonatomic) VideoSocialViewType type;
@property (nonatomic, copy) NSString *trackEventName;

- (void)refreshUI;

@end
