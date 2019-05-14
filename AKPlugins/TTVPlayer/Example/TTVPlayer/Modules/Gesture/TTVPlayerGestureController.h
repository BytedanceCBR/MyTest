//
//  TTVPlayerGestureController.h
//  Article
//
//  Created by liuty on 2017/1/8.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStateGesture.h"
#import "TTVideoBrightnessService.h"
#import "TTVideoVolumeService.h"
#import "TTPlayerProgressHUDView.h"

/**
 TODO：去掉音量、亮度、进度条的耦合
 */
@interface TTVPlayerGestureController : NSObject

@property (nonatomic, copy) void(^seekingToProgress)(CGFloat progress, CGFloat fromProgress, BOOL cancel, BOOL end);
@property (nonatomic, copy) void(^swipeProgressSeeking)(CGFloat fromProgress,CGFloat currentProgress);
@property (nonatomic, copy) void(^volumeDidChanged)(CGFloat volume ,BOOL isSystemVolumeButton);
@property (nonatomic, copy) void(^doubleTapClick)(void);
@property (nonatomic, copy) void(^singleTapClick)(void);
@property (nonatomic, copy) void(^changeVolumeClick)();
@property (nonatomic, copy) void(^changeBrightnessClick)();
@property (nonatomic, copy) void(^ProgressViewShowBlock)(BOOL show);

@property (nonatomic, strong, readonly) TTVideoVolumeService *volumeService;
@property (nonatomic, strong, readonly) TTVideoBrightnessService *brightnessService;
@property (nonatomic, strong, readonly) TTPlayerProgressHUDView *progressView;
@property (nonatomic, assign, readonly, getter=isProgressSeeking) BOOL progressSeeking;
@property (nonatomic, assign, getter=isLocked) BOOL locked;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL videoPlayerDoubleTapEnable;
@property (nonatomic, assign) BOOL isNoneFullScreenPlayerGestureEnabled;
@property (nonatomic, assign) TTVPlayerGestureDirection supportedDirection;//控制支持手势方向 全屏默认支持所有的
@property (nonatomic, assign) BOOL controlShowingBySingleTap; // 控件 是否因 单击手势 呼出
@property (nonatomic, assign) CGFloat currentPlayingTime; // 控件 是否因 单击手势 呼出
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) BOOL supportsPortaitFullScreen;
@property (nonatomic, assign) BOOL isPlaybackEnded;



- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPlayerControlView:(UIView *)controlView NS_DESIGNATED_INITIALIZER;

- (void)setProgressHubShow:(BOOL)show;

- (void)enablePanGestures:(BOOL)enable;

- (void)enableSingleTapGesture:(BOOL)enable;

- (void)enableDoubleTapGesture:(BOOL)enable;

- (void)enableProgressHub:(BOOL)enable;

- (void)cancelPanGesture;

@end

