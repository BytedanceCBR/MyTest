//
//  VideoControlView.h
//  Video
//
//  Created by Kimi on 12-10-21.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SSViewBase.h"

#define VideoMovieControlViewHeight 44.f

typedef enum {
    SSPlayControlViewTypeHalfscreen,
    SSPlayControlViewTypeFullscreen
} SSPlayControlViewType;

@class SSPlayControlView;
@protocol SSPlayControlViewDelegate <NSObject>

@optional
- (void)playControlView:(SSPlayControlView *)playControl didHideControl:(BOOL)hide;
- (void)firstPlayInPlayControlView:(SSPlayControlView *)playControl;
- (void)playControlView:(SSPlayControlView *)playControl didChangeFullscreen:(BOOL)fullscreen;
- (void)playControlView:(SSPlayControlView *)playControl didChangePlaybackState:(MPMoviePlaybackState)state;
- (void)playControlView:(SSPlayControlView *)playControl playbackDidFinishForReason:(int)reason;

@end

@interface SSPlayControlView : SSViewBase

@property (nonatomic, assign) id<SSPlayControlViewDelegate> delegate;
@property (nonatomic) SSPlayControlViewType type;
@property (nonatomic) BOOL orientationLocked;
@property (nonatomic, copy) NSString *trackEventName;

- (id)initWithPlayer:(MPMoviePlayerController *)player type:(SSPlayControlViewType)type;
- (id)initWithPlayer:(MPMoviePlayerController *)player;
- (void)refreshUI;
- (void)displayControl:(NSNumber*)display;
- (void)displayFullscreen:(BOOL)display;
- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer;

@end
