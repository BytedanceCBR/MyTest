//
//  TTVPlayerGestureContainerView.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/2/27.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerContextNew.h"
#import "TTVReduxKit.h"
#import "TTVGesturePart.h"

#import "TTVPlaybackControlView.h"
#import "TTVTouchIgoringView.h"

@class TTVPlayerGestureContainerView;

NS_ASSUME_NONNULL_BEGIN
@protocol TTVPlayerGestureContainerViewDelegate<NSObject>

/**
 container view 发生 layoutSubviews 时回调外面进行布局处理

 @param containerView @see TTVPlayerGestureContainerView
 */
- (void)containerViewLayoutSubviews:(TTVPlayerGestureContainerView *)containerView;

@end

/**
 除了视频播放view之外，看到的所有 view 都加在这个 view 上；这个 view 可以响应单击、双击、滑动等手势以及处理相关冲突
 整体分为两层view，参见下面成员注释，其中最重要的是 controlView：part 中控制功能的控件会加到这个 view 上, 他控制着整体控件的消失和出现
 */
@interface TTVPlayerGestureContainerView : UIView<TTVPlayerContextNew, TTVReduxStateObserver>

/**
 初始化函数，可以创建一个带有手势的，播放器的容器 view

 @param frame frame
 @param haveControlView  是否有controlView，比如教育类的产品，或者广告类的，无法进行播放器控制，就不应该生成这个 controlView
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame haveControlView:(BOOL)haveControlView;

/// 在playback control 的下面，比如弹幕
@property (nonatomic, strong, readonly) TTVTouchIgoringView * controlUnderlayView;

/// 播放控制层：所有能控制播放器的都叫做 control： part 中控制功能的控件会加到这个 view 上, 他控制着整体控件的消失和出现
@property (nonatomic, strong, readonly) TTVPlaybackControlView * playbackControlView;

/// 锁屏时的控制层
@property (nonatomic, strong, readonly) TTVPlaybackControlView * playbackControlView_Lock;

/// 在 playback control的上面，比如各种的提示。loading 等
@property (nonatomic, strong, readonly) TTVTouchIgoringView * controlOverlayView;

/// @see TTVPlayerGestureContainerViewDelegate
@property (nonatomic, weak) NSObject<TTVPlayerGestureContainerViewDelegate> *delegate;

/**
 手动控制控件展示；多用于第一次展示

 @param show 是否需要展示 controlView
 */
- (void)showControl:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
