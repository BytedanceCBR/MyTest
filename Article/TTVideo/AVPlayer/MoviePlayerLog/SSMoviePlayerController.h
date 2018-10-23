//
//  ExploreMoviePlayerController.h
//  MyPlayer
//
//  Created by Zhang Leonardo on 15-3-2.
//  Copyright (c) 2015年 leonardo. All rights reserved.
//

#import "TTAVMoviePlayerController.h"
#import "SSMoviePlayerTrackManager.h"
#import "TTVAudioActiveCenter.h"

@protocol SSMoviePlayerControllerDelegate;

/**
 *  包含播放状态、加载状态的监听以及播放统计
 */
@interface SSMoviePlayerController : TTAVMoviePlayerController

@property(nonatomic, weak)id<SSMoviePlayerControllerDelegate> movieDelegate;

@property(nonatomic, assign, readonly)NSTimeInterval playbackTime;

@property(nonatomic, assign, readonly)BOOL           hasUserStopped;

@property(nonatomic, strong)SSMoviePlayerTrackManager *trackManager;

@property(nonatomic, assign)CGRect           frame;
@property (nonatomic, strong) TTVAudioActiveCenter *activeCenter;

//NOTE:  方法调用顺序 ,init -> 必用属性赋值 -> prepareInit
//为了将初始化方法简化,不用在以后需要加参数的时候,都得修改初始化方法.
//子类重写必须调用[super prepareInit]
- (void)prepareInit;

- (void)moviePause;

- (void)movieStop;

- (void)moviePlay;

- (void)seekToProgress:(CGFloat)progress;

- (void)moviePlayContentForURL:(NSURL *)url;

- (void)reset;

- (void)cancelPlaying;

- (void)refreshPlayButton;

- (void)invalidatePlaybackTimer;

@end

@protocol SSMoviePlayerControllerDelegate <NSObject>

@optional

- (void)movieStateChanged:(SSMoviePlayerController *)movieController;//每一次播放状态改变

@required

// 开始播放后后显示画面第一帧
- (void)movieControllerShowedOneFrame:(SSMoviePlayerController *)movieController;
// 缓冲中
- (void)movieControllerMovieStalled:(SSMoviePlayerController *)movieController;

// 预加载完成后,可播放
- (void)movieControllerMoviePlayable:(SSMoviePlayerController *)movieController;

// 拖动进度条
- (void)movieController:(SSMoviePlayerController *)movieController seekToTime:(NSTimeInterval)afterTime fromTime:(NSTimeInterval)beforeTime;

// 播放结束通知
- (void)movieControllerPlaybackDidFinish:(SSMoviePlayerController *)movieController;

//自研播放器 prepare to play 但是还没有render ,此时调用seek ,解决seek 出现第一帧的bug
- (void)movieControllerPlaybackPrepareToPlay:(SSMoviePlayerController *)movieController;

- (void)movieController:(SSMoviePlayerController *)movieController playbackHasError:(NSError *)error;
@end
