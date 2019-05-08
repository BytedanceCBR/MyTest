//
//  TTVPlayerControllerProtocol.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"
#import "TTVPlayerStateStore.h"

@protocol TTVViewLayout
@optional;
- (void)layoutWithSuperViewFrame:(CGRect)superViewFrame;
@end

@protocol TTVPlayerControlViewDelegate <NSObject>
- (void)controlViewPlayButtonClicked:(UIView *)controlView isPlay:(BOOL)isPlay;
- (void)controlViewBackButtonClicked:(UIView *)controlView;
- (void)controlViewFullScreenButtonClicked:(UIView *)controlView isFull:(BOOL)isFull;
@optional

- (void)controlView:(UIView *)controlView seekProgress:(CGFloat)progress complete:(void(^)(BOOL success))finised;
- (void)controlViewPlayerShareButtonClicked:(UIView *)controlView;

- (void)controlViewPlayerMoreButtonClicked:(UIView *)controlView;

@end

@class TTVPlayerStateAction;
@class TTVPlayerStateModel;
@protocol TTVPlayerContext <NSObject>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@end

@protocol TTVPlayerViewControlView <NSObject>
@property(nonatomic, weak)NSObject <TTVPlayerControlViewDelegate> *delegate;
@property(nonatomic, strong)UIView <TTVPlayerControlBottomView> *bottomBarView;
@property(nonatomic, strong ,readonly)UIView *miniSlider;
- (void)setVideoTitle:(NSString *)title;
- (void)setVideoWatchCount:(NSInteger)watchCount playText:(NSString *)playText;
- (void)setToolBarHidden:(BOOL)hidden needAutoHide:(BOOL)needAutoHide;

@optional
@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;

@end

@protocol TTVPlayerViewTrafficView <NSObject>
- (void)setTrafficVideoDuration:(NSInteger)duration videoSize:(NSInteger)videoSize inDetail:(BOOL)inDetail ;
- (void)setContinuePlayBlock:(dispatch_block_t)continuePlayBlock;
@end

@protocol TTVPlayerControlTipView <NSObject>
@property(nonatomic, assign)TTVPlayerControlTipViewType tipType;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, assign) CGRect superViewFrame;//适配X使用
@end


@protocol TTVPlayerControlBottomViewDelegate <NSObject>

- (void)bottomViewWatchedProgressWillChange:(CGFloat)watchedProgress cacedProgress:(CGFloat)cacedProgress;
- (void)bottomViewWatchedProgressChanging:(CGFloat)watchedProgress cacedProgress:(CGFloat)cacedProgress;
- (void)bottomViewWatchedProgressChanged:(CGFloat)watchedProgress cacedProgress:(CGFloat)cacedProgress;
- (void)bottomViewFullScreenButtonClicked;
- (void)bottomViewResolutionButtonClicked;

@end

@protocol TTVPlayerControlBottomView <NSObject>
@property (nonatomic, weak) id <TTVPlayerControlBottomViewDelegate> delegate;
@property (nonatomic, assign)CGFloat cacheProgress;
@property (nonatomic, assign)CGFloat watchedProgress;
- (void)updateFrame;
- (void)updateWithCurTime:(NSString *)curTime totalTime:(NSString *)totalTime;

@optional
@property (nonatomic, strong ,readonly) UIButton *resolutionButton;
@property (nonatomic, strong ,readonly) UIButton *fullScreenButton;
@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;

@end




