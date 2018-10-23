//
//  TTVPasterADNatantView.h
//  Article
//
//  Created by Dai Dongpeng on 5/26/16.
//
//

#import "SSViewBase.h"

@class TTVPasterADModel;
@protocol TTVPasterADNatantViewDelegate;

@interface TTVPasterADNatantView : SSViewBase

@property (nonatomic, weak) id <TTVPasterADNatantViewDelegate> delegate;

@property (nonatomic, assign) NSInteger durationTime;

- (instancetype)initWithFrame:(CGRect)frame pasterADModel:(TTVPasterADModel *)adModel;
- (void)setIsFullScreen:(BOOL)fullScreen;
- (BOOL)isFullScreen;

- (void)pauseTimer;
- (void)resumeTimer;

- (BOOL)isTopMostView;
@end

@protocol TTVPasterADNatantViewDelegate <NSObject>

- (void)fullScreenbuttonClicked:(UIButton *)button toggledTo:(BOOL)fullScreen;
- (void)skipButtonClicked:(UIButton *)button;
- (void)showDetailButtonClicked:(UIButton *)button;
- (void)pasterADClicked; //点击广告
- (void)backButtonClicked:(UIButton *)button;

- (void)replayButtonClicked:(UIButton *)button;

- (void)timerOver;
- (void)pauseTimer;
- (void)resumeTimer;
@end
