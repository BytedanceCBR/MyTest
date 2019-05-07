//
//  TTVPlayerCustomViewDelegate.h
//  test
//
//  Created by lisa on 2019/3/20.
//  Copyright © 2019 lina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerDefine.h"

@class TTPlayerSliderControlView;
@class TTPlayerProgressHUDView;
@class TTVProgressViewOfSlider;
@class TTVToggledButton;
@class TTVPlayerButton;
@class TTVTouchIgoringView;
@class TTVPlayerBottomToolBar;
@protocol TTVPlayerLoadingViewProtocol;
@protocol TTVPlayerErrorViewProtocol;
@protocol TTVFlowTipViewProtocol;
@protocol TTVToggledButtonProtocol;
@protocol TTVButtonProtocol;
@protocol TTVBarProtocol;
@protocol TTVProgressViewOfSliderProtocol;
@protocol TTVProgressHudOfSliderProtocol;
@protocol TTVSliderControlProtocol;

@class TTVReduxStore;
@class TTVReduxAction;

NS_ASSUME_NONNULL_BEGIN

///-----------------------------------------------------------------
/// @name  player 中可以自定义传入的 view
///-----------------------------------------------------------------
@protocol TTVPlayerCustomViewDelegate <NSObject>

@optional

/// 自定义按钮：返回按钮
- (UIView<TTVButtonProtocol> *)customButtonForKey:(TTVPlayerPartControlKey)key;

/// 自定义状态可切换按钮：播放按钮、全屏按钮、放大屏幕（旋转）按钮
- (UIView<TTVToggledButtonProtocol> *)customToggledButtonForKey:(TTVPlayerPartControlKey)key;

/// 自定义 label
- (UILabel *)customLabelForKey:(TTVPlayerPartControlKey)key;

/// 自定义 loadingView
- (UIView <TTVPlayerLoadingViewProtocol> *)customLoadingView;

/// 自定义错误结束 view
- (UIView <TTVPlayerErrorViewProtocol> *)customPlayerErrorFinishView;

/// 自定义流量提示 view
- (UIView <TTVFlowTipViewProtocol> *)customCellularNetTipView;

/// topbar 容器
- (TTVTouchIgoringView<TTVBarProtocol> *)customTopNavbar;

/// bottombar 容器
- (TTVTouchIgoringView<TTVBarProtocol> *)customBottomToolbar;

/// slider中可拖动指示view
- (UIView *)customSliderIndicatorView;

/// slider 的滑动指示
- (UIView<TTVProgressHudOfSliderProtocol> *)customSliderHUDView;

/// 进度条,带滑块可拖动
- (UIView<TTVSliderControlProtocol> *)customSliderControl;
//- (TTPlayerSliderControlView *)customSliderControl;

/// 进度条沉浸态
- (UIView<TTVProgressViewOfSliderProtocol> *)customProgressViewOfImmersive;

/// 其他没有类型的 view
- (UIView *)customOtherViewForKey:(TTVPlayerPartControlKey)key;

@end

///-----------------------------------------------------------------
/// @name TTVToggledButtonProtocol 可切换 button 自定义协议:支持两种状态切换
///-----------------------------------------------------------------
/// 切换按钮的状态
typedef NS_ENUM(NSUInteger, TTVToggledButtonStatus) {
    TTVToggledButtonStatus_Normal = 0, // 未切换
    TTVToggledButtonStatus_Toggled = 1 // 切换
};
@protocol TTVToggledButtonProtocol <NSObject>

/// button 被点击的回调，需要外部实现
@property (nonatomic, copy) void(^didToggledButtonTouchUpInside)(void);
/// 是否在切换态，默认是 NO，正常状态
@property (nonatomic) TTVToggledButtonStatus currentToggledStatus;
/// toggle 事件发生
@property (nonatomic, copy) void(^buttonWillToggleToStatus)(TTVToggledButtonStatus status);
@property (nonatomic, copy) void(^buttonDidToggleToStatus)(TTVToggledButtonStatus stauts);

/// 设置可能的切换状态下按钮的 Image
- (void)setImage:(UIImage *)image forStatus:(TTVToggledButtonStatus)status;
/// 获取是否切换状态的 Image
- (UIImage *)imageForStatus:(TTVToggledButtonStatus)status;

@optional
/// 设置不同切换状态下按钮的 title
- (void)setTitle:(NSString *)title forStatus:(TTVToggledButtonStatus)status;
/// 获取不同切换状态的 title
- (NSString *)titleForStatus:(TTVToggledButtonStatus)status;

///设置可能的切换状态下按钮的 title的颜色
- (void)setTitleColor:(UIColor *)titleColor forStatus:(TTVToggledButtonStatus)status;
///获取可能的切换状态下按钮的 title的颜色
- (UIColor *)titleColorForStatus:(TTVToggledButtonStatus)status;

//// 接入 redux
/**
 在正常和切换态下，绑定action
 
 @param action 里面包装了 target selector，发出 action 可以执行一个方法，并发出一个事件可能改变 state @see TTVReduxAction
 @param status @TTVToggledButtonStatus
 */
- (void)setAction:(TTVReduxAction *)action forStatus:(TTVToggledButtonStatus)status;
- (TTVReduxAction *)actionForStatus:(TTVToggledButtonStatus)status;
/// redux 的节点，用于派发 action
@property (nonatomic, strong) TTVReduxStore * store;

@end

///-----------------------------------------------------------------
/// @name TTVButtonProtocol
///-----------------------------------------------------------------
@protocol TTVButtonProtocol <NSObject>

/// 设置 button 的 image
@property (nonatomic, strong) UIImage * image;

/// 点击事件
@property (nonatomic, copy) void(^didButtonTouchUpInside)(void);

@optional

- (void)setAction:(TTVReduxAction *)action;
- (TTVReduxAction *)action;

@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong) UIColor * titleColor;

/// redux 的节点，用于派发 action
@property (nonatomic, strong) TTVReduxStore * store;

@end

///-----------------------------------------------------------------
/// @name  loadingview 自定义协议
///-----------------------------------------------------------------

@protocol TTVPlayerLoadingViewProtocol <NSObject>

- (void)startLoading;
- (void)stopLoading;

@optional
//- (void)showFreeFlowTip:(BOOL)show;//免流 TODO 是否应该放在这里？？？不应该，应该支持设置文字
- (void)setLoadingText:(NSString *)text;

@end

///-----------------------------------------------------------------
/// @name   错误提示界面自定义协议
///-----------------------------------------------------------------
@protocol TTVPlayerErrorViewProtocol <NSObject>
@required
@property (nonatomic, strong) void(^didClickRetry)(void);
@property (nonatomic, strong) void(^didClickBack)(void);

@property (nonatomic, readonly) BOOL isShowed; // 是否正在界面展示

- (void)setErrorText:(NSString*)errorText;

- (void)showRetry:(BOOL)show;//是否显示重试按钮,默认YES
- (void)show;
- (void)dismiss;

@end

///-----------------------------------------------------------------
/// @name   弱网提示自定义协议
///-----------------------------------------------------------------
@protocol TTVFlowTipViewProtocol <NSObject>

@required
@property (nonatomic, copy)  dispatch_block_t continuePlayBlock; // 点击继续的 block

// 在界面上设置提示文案
- (void)setTipLabelText:(NSString *)tipLabelText;

@optional

@property (nonatomic, copy)  dispatch_block_t quitBlock;         // 退出

// 不一定会有获取流量
@property (nonatomic, copy)   dispatch_block_t subscribeBlock; // 流量订阅点击回调
@property (nonatomic, assign) BOOL             isSubscribe;    // 是否订阅？？？

@end

///-----------------------------------------------------------------
/// @name bar
///-----------------------------------------------------------------
@protocol TTVBarProtocol <NSObject>

@property (nonatomic, strong) UIImageView   *backgroundImageView;  // 背景图片

@end
///-----------------------------------------------------------------
/// @name slider
///-----------------------------------------------------------------
@protocol TTVProgressViewOfSliderProtocol <NSObject>

/// 当前播放进度
@property (nonatomic, readonly) CGFloat progress;

/// 当前缓存进度
@property (nonatomic, readonly) CGFloat cacheProgress;

/// 设置当前进度
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

/// 设置当前缓存进度
- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated;

/// 已看进度view
@property (nonatomic, strong) UIView * trackProgressView;

/// 缓存进度 view
@property (nonatomic, strong) UIView * cacheProgressView;

@end

@protocol TTVSliderControlProtocol <NSObject>

/// 拖动进度点的 view
@property (nonatomic, strong) UIView * thumbView;

/// 拖动进度点背景 view
@property (nonatomic, strong) UIView * thumbBackgroundView;

@property (nonatomic, strong) UIView<TTVProgressViewOfSliderProtocol> * progressView;

//// 结束 seek，如果不能拖动的，则不需要实现这个回调
@property (nonatomic, copy) void(^didSeekToProgress)(CGFloat progress, CGFloat fromProgress);

/// 拖动中，如果不能拖动的，则不需要实现这个回调
@property (nonatomic, copy) void(^seekingToProgress)(CGFloat progress, BOOL cancel, BOOL end);

/// 当前播放进度
@property (nonatomic, readonly) CGFloat progress;

/// 当前缓存进度
@property (nonatomic, readonly) CGFloat cacheProgress;

/// 设置当前进度
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

/// 设置当前缓存进度
- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated;

///// 标记某个点？？
//@property (nonatomic, strong) NSArray <NSNumber *>*markPoints;
//@property (nonatomic, strong) NSArray <NSNumber *>*openingPoints;//片头片尾
@optional
/// 设置 thumb 的填充色
@property (nonatomic, copy) NSString * thumbColorString;
/// 设置 thumbbackground 的填充色
@property (nonatomic, copy) NSString * thumbBackgroundColorString;
/// 设置进度滑块 Image
@property (nonatomic, strong) UIImage * thumbImage;
/// 设置进度滑块背景 Image
@property (nonatomic, strong) UIImage * thumbBackgroundImage;   // 趁在进度点后面的 image

@end

@protocol TTVProgressHudOfSliderProtocol <NSObject>

/// 展示 slider hud
- (void)showWithCompletion:(void (^)(BOOL finished))completion;

/// slider hud 消失
- (void)dismissWithCompletion:(void (^)(BOOL finished))completion;

/// 当前播放进度
@property (nonatomic, readonly) CGFloat progress;

/// 当前缓存进度
@property (nonatomic, readonly) CGFloat cacheProgress;

/// 设置当前进度
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

/// 设置当前缓存进度
- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated;

/// 设置 slider 的总时间
@property (nonatomic) NSTimeInterval totalTime;

/// 是否显示取消
@property (nonatomic) BOOL showCancel;

/// 是否正在展示
@property (nonatomic) BOOL isShowing;

/// 进度条
@property (nonatomic, strong) UIView<TTVProgressViewOfSliderProtocol> * progressView;

/// 时间 label
@property (nonatomic, strong) UILabel *timeLabel;

/// 背景
@property (nonatomic, strong) UIView * backgroundView;


@optional
@property (nonatomic, strong) UIColor * tintColor;
@property (nonatomic, copy) NSString *  currentTimeTextColorString;
@property (nonatomic, copy) NSString *  totalTimeTextColorString;
@property (nonatomic)       CGFloat     textSize;

@end

NS_ASSUME_NONNULL_END
