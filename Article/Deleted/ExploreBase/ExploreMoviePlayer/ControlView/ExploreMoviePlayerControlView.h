//
//  ExploreMoviePlayerControlView.h
//  MyPlayer
//
//  Created by Zhang Leonardo on 15-3-2.
//  Copyright (c) 2015年 leonardo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExploreMoviePlayerControlTipView.h"
#import "TTMoviePlayerControlTopView.h"
#import "TTMoviePlayerControlBottomView.h"
#import "TTMoviePlayerControlLiveBottomView.h"
#import "TTMoviePlayerControlFinishAction.h"
#import "ExploreVideoSP.h"
#import "TTPlayerControlView.h"
#import "ExploreMoviePlayerControlViewDelegate.h"

@class TTImageView;
@class TTAlphaThemedButton;
@class SSThemedLabel;
@class ExploreOrderedData;
@protocol ExploreMoviePlayerControlViewDelegate;
typedef void(^ToolBarHiddenAnimatedBlock)(BOOL hidden);

@interface ExploreMoviePlayerControlView : UIView<TTPlayerControlView>

@property(nonatomic, weak)id<ExploreMoviePlayerControlViewDelegate> delegate;

// 播放结束后显示封面图或相关视频
@property(nonatomic, strong)TTImageView *logoView;
@property(nonatomic, strong)ExploreMoviePlayerControlTipView * tipView;
@property(nonatomic, strong)TTAlphaThemedButton *showDetailButton;
@property(nonatomic, strong)TTMoviePlayerControlBottomView *bottomBarView;
@property(nonatomic, strong)TTMoviePlayerControlLiveBottomView *liveBottomBarView;
@property(nonatomic, strong)TTMoviePlayerControlFinishAction *finishAction; //播放结束页面相关操作
@property(nonatomic, assign)BOOL alwaysShowDetailButton;
@property(nonatomic, assign)BOOL hasFinished; //是否播放完成，只有新版设置这个字段，老版为NO
@property(nonatomic, assign)BOOL forbidLayout;

@property(nonatomic, assign)BOOL enableResolution;
@property(nonatomic, assign)BOOL enableResulutionButtonClicked;
@property(nonatomic, assign)NSInteger shouldShowShareMore;
@property(nonatomic, copy)  NSString *resolutionString;
@property(nonatomic, assign)BOOL isVideoBusiness;

@property (nonatomic, copy) ToolBarHiddenAnimatedBlock toolBarHiddenBlock;
@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;

- (instancetype)initWithFrame:(CGRect)frame videoType:(TTVideoPlayType)type;

- (void)updateTimeLabel:(NSString *)time durationLabel:(NSString *)duration;

- (void)setTotalTime:(NSTimeInterval)total;
- (void)setCacheProgress:(CGFloat)progress;
- (void)setWatchedProgress:(CGFloat)progress;

- (void)setIsPlaying:(BOOL)playing;
- (void)setIsPlaying:(BOOL)playing force:(BOOL)force;
- (void)setIsFullScreen:(BOOL)fullScreen;
- (void)setIsDetail:(BOOL)isDetail;

- (void)finishPlaying;

- (void)showLoadingWithTitleBar;
- (void)hideFullscreenStatusBar:(BOOL)hide;

- (ExploreMoviePlayerControlViewTipType)tipViewType;
- (void)hideTipView;
- (void)showTipView:(ExploreMoviePlayerControlViewTipType)type;
- (void)showTipView:(ExploreMoviePlayerControlViewTipType)type andTipString:(NSString *)tipString;
- (void)setToolBarHidden:(BOOL)hidden;
- (void)setToolBarHidden:(BOOL)hidden needAutoHide:(BOOL)needAutoHide;
- (void)setToolBarHidden:(BOOL)hidden needAutoHide:(BOOL)needAutoHide animate:(BOOL)animate;

- (void)enableSlider;
- (void)disbleSlider;
- (void)setHiddenMiniSliderView:(BOOL)hidden;

- (void)setVideoTitle:(NSString *)title fontSizeStyle:(TTVideoTitleFontStyle)style showInNonFullscreenMode:(BOOL)bShow;
- (void)setVideoPlayTimes:(NSInteger)playTimes;
- (void)setVideoPlayTimesText:(NSString *)playCountText;

- (void)showLogoView:(BOOL)showDetailButton;
- (void)hideLogoView;

- (void)refreshSliderFrame;

- (void)hideTitleBarView:(BOOL)hide;
- (void)touchScreenToExit:(BOOL)touch;
- (BOOL)toolBarViewHidden;

- (void)configureFinishAd:(ExploreOrderedData *)data;

- (BOOL)hasTipType;
//pm恶心需求，详情页视频广告重新出现在屏幕时，只显示继续播放的按钮
- (void)showPlayButtonOnly;

- (UIView *)toolBar;

- (BOOL)hasAdButton;
- (BOOL)hasShowTipView;

- (void)enablePrePlayBtn:(BOOL)enable isFromFinishAtion:(BOOL)isFrom;
- (void)updateFinishActionItemsFrameWithBannerHeight:(CGFloat)height; // 出现芒果TVbanner 更新重播等子控件高度
- (void)updateFinishShareActionItemsFrameWithBannerHeight:(CGFloat)height; // 出现芒果TVbanner 更新重播等子控件高度
- (void)updateFrame;
- (void)reuse;

///...
- (void)resetToolBar4LiveVideoWithStatusView:(UIView *)statusView numOfParticipantsView:(UIView *)numOfParticipantsView;
- (void)reLayoutToolBar4ReplayVideoOfLiveRoom;


@end
