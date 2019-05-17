//
//  TTVPlayerControlView.h
//  Article
//
//  Created by panxiang on 2017/5/16.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControlTipView.h"
#import "TTMoviePlayerControlTopView.h"
#import "TTMoviePlayerControlBottomView.h"
#import "TTVPlayerControllerProtocol.h"
#import "ExploreMovieMiniSliderView.h"

@protocol TTVPlayerControlViewDelegate <NSObject>
- (void)controlViewPlayButtonClicked:(UIView *)controlView isPlay:(BOOL)isPlay;
- (void)controlViewBackButtonClicked:(UIView *)controlView;
- (void)controlViewFullScreenButtonClicked:(UIView *)controlView isFull:(BOOL)isFull;
@optional
// 播放上一个
- (void)controlViewPrePlayButtonClicked:(UIView *)controlView;

- (void)controlView:(UIView *)controlView seekProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised;
- (void)controlViewPlayerShareButtonClicked:(UIView *)controlView;

- (void)controlViewPlayerMoreButtonClicked:(UIView *)controlView;

@end

@class SSImageView;
@class TTAlphaThemedButton;
@class SSThemedLabel;
typedef void(^ToolBarHiddenAnimatedBlock)(BOOL hidden);

@interface TTVPlayerControlView : UIView<TTVPlayerViewControlView,TTVPlayerContext>

@property(nonatomic, weak)NSObject <TTVPlayerControlViewDelegate> *delegate;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property(nonatomic, strong)TTMoviePlayerControlBottomView *bottomBarView;
@property(nonatomic, strong)ExploreMovieMiniSliderView * miniSlider;
@property (nonatomic, copy) ToolBarHiddenAnimatedBlock toolBarHiddenBlock;
@property(nonatomic, assign)BOOL enableWaterMark;
@property (nonatomic, assign)NSInteger playerShowShareMore;
@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;

- (void)updateTimeLabel:(NSString *)time durationLabel:(NSString *)duration;
- (void)setToolBarHidden:(BOOL)hidden needAutoHide:(BOOL)needAutoHide animate:(BOOL)animate;

- (void)setVideoTitle:(NSString *)title fontSizeStyle:(NSInteger)style;
- (void)setVideoWatchCount:(NSInteger)watchCount playText:(NSString *)playText;

- (void)refreshSliderFrame;

- (UIView *)toolBar;

- (void)updateFrame;

@end
