//
//  TTVMidInsertADNatantView.h
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import "SSViewBase.h"

@protocol TTVMidInsertADNatantViewDelegate;
@class TTVMidInsertADModel;
@interface TTVMidInsertADNatantView : SSViewBase

@property (nonatomic, weak) id <TTVMidInsertADNatantViewDelegate> delegate;

@property (nonatomic, assign) NSInteger durationTime;

- (instancetype)initWithFrame:(CGRect)frame pasterADModel:(TTVMidInsertADModel *)adModel;
- (void)setIsFullScreen:(BOOL)fullScreen;
- (BOOL)isFullScreen;

- (void)pauseTimer;
- (void)resumeTimer;

- (BOOL)isTopMostView;
@end

@protocol TTVMidInsertADNatantViewDelegate <NSObject>

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
