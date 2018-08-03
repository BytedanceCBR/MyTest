//
//  VideoPlayerView.h
//  Video
//
//  Created by Kimi on 12-10-12.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSViewBase.h"
#import "SSPlayControlView.h"

#define PlayerViewHalfScreenHeight ([TTDeviceHelper isPadDevice] ? 640 : 250)

typedef enum {
    VideoPlayerViewTypeHalfscreen,
    VideoPlayerViewTypeFullscreen
} VideoPlayerViewType;

typedef enum SSVideoPlayerViewControlViewPositionType {
    SSVideoPlayerViewControlViewInnerBottom,
    SSVideoPlayerViewControlViewBottom
} SSVideoPlayerViewControlViewPositionType;


@class SSVideoPlayerView;
@protocol SSVideoPlayerViewDelegate <NSObject>

- (void)videoPlayerView:(SSVideoPlayerView *)playerView didChangeFullscreen:(BOOL)fullscreen;
@optional
- (void)videoPlayerView:(SSVideoPlayerView *)playerView handleSwipeRightGesture:(UISwipeGestureRecognizer *)swipeRight;
- (void)videoPlayerViewPlayFailed:(SSVideoPlayerView *)playerView;
@end


@class SSVideoModel;
@interface SSVideoPlayerView : SSViewBase

@property (nonatomic, weak) id<SSVideoPlayerViewDelegate> delegate;
@property (nonatomic, assign) VideoPlayerViewType type;
@property (nonatomic, assign) SSVideoPlayerViewControlViewPositionType controlViewPositionType;

@property (nonatomic, retain) SSVideoModel *video;
@property (nonatomic, retain) SSPlayControlView *controlView;
@property (nonatomic, copy) NSString *trackEventName;

- (id)initWithFrame:(CGRect)frame type:(VideoPlayerViewType)type;
- (void)prepareToPlay;
- (void)pause;
- (void)resume;
- (void)refreshUI;

- (BOOL)isCurrentPlayFailed;
@end
