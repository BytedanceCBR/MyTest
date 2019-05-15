//
//  TTVideoPasterADNatantView.h
//  Article
//
//  Created by Dai Dongpeng on 5/26/16.
//
//

#import "SSViewBase.h"

@class TTVideoPasterADModel;
@protocol TTVideoPasterADNatantViewDelegate;

@interface TTVideoPasterADNatantView : SSViewBase

@property (nonatomic, weak) id <TTVideoPasterADNatantViewDelegate> delegate;

@property (nonatomic, assign) NSInteger durationTime;

- (instancetype)initWithFrame:(CGRect)frame pasterADModel:(TTVideoPasterADModel *)adModel;
- (void)setIsFullScreen:(BOOL)fullScreen;
- (BOOL)isFullScreen;

- (void)pauseTimer;
- (void)resumeTimer;

- (void)showPlayButtonAnimated:(BOOL)animated;
- (void)showPauseButtonAnimated:(BOOL)animated;
- (void)hidePlayButtonAnimated:(BOOL)animated;
- (void)hidePauseButtonAnimated:(BOOL)animated;

- (BOOL)isPlayButtonShowed;
- (BOOL)isPauseButtonShowed;

- (BOOL)isTopMostView;
@end

@protocol TTVideoPasterADNatantViewDelegate <NSObject>

- (void)fullScreenbuttonClicked:(UIButton *)button toggledTo:(BOOL)fullScreen;
- (void)skipButtonClicked:(UIButton *)button;
- (void)showDetailButtonClicked:(UIButton *)button;
- (void)pasterADClicked; //点击广告
- (void)backButtonClicked:(UIButton *)button;

- (void)playButtonClicked:(UIButton *)button;
- (void)pauseButtonClicked:(UIButton *)button;

- (void)replayButtonClicked:(UIButton *)button;

- (void)timerOver;
@end
