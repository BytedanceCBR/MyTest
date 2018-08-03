//
//  VideoPlayerView.h
//  Video
//
//  Created by Kimi on 12-10-12.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSViewBase.h"

#define PlayerViewHalfScreenHeight 180.f

typedef enum {
    VideoPlayerViewTypeHalfscreen,
    VideoPlayerViewTypeFullscreen
} VideoPlayerViewType;

@class VideoPlayerView;
@protocol VideoPlayerViewDelegate <NSObject>

- (void)videoPlayerView:(VideoPlayerView *)playerView didChangeFullscreen:(BOOL)fullscreen;
- (void)videoPlayerView:(VideoPlayerView *)playerView handleSwipeRightGesture:(UISwipeGestureRecognizer *)swipeRight;

@end

@class VideoData;

@interface VideoPlayerView : SSViewBase

@property (nonatomic, assign) id<VideoPlayerViewDelegate> delegate;
@property (nonatomic, retain) VideoData *video;
@property (nonatomic, copy) NSString *trackEventName;
@property (nonatomic) VideoPlayerViewType type;

- (id)initWithFrame:(CGRect)frame type:(VideoPlayerViewType)type;
- (void)prepareToPlay;
- (void)pause;
- (void)resume;
- (void)refreshUI;

@end
