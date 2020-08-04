//
//  TTVPlayerGestureManager.h
//  Article
//
//  Created by lisa on 2018/1/28.
//
//

#import <Foundation/Foundation.h>
//#import "TTVideoBrightnessService.h"
//#import "TTVideoVolumeService.h"
/**
 TODO：去掉音量、亮度、进度条的耦合
 */

typedef NS_ENUM(NSUInteger, TTVPlayerPanGestureDirection) {
    TTVPlayerPanGestureDirection_Unknown = 0,
    TTVPlayerPanGestureDirection_Vertical = 1 << 0,
    TTVPlayerPanGestureDirection_Horizontal = 1 << 1,
    TTVPlayerPanGestureDirection_All = TTVPlayerPanGestureDirection_Horizontal | TTVPlayerPanGestureDirection_Vertical
};

@interface TTVPlayerGestureManager : NSObject

@property (nonatomic, weak) UIView* controlView;

@property (nonatomic, copy) void(^volumeDidChanged)(CGFloat volume ,BOOL isSystemVolumeButton);
@property (nonatomic, copy) void(^doubleTapClick)(void);
@property (nonatomic, copy) void(^singleTapClick)(void);
@property (nonatomic, copy) void(^changeVolumeClick)(void);
@property (nonatomic, copy) void(^changeBrightnessClick)(void);

//@property (nonatomic, strong, readonly) TTVideoVolumeService *volumeService;
//@property (nonatomic, strong, readonly) TTVideoBrightnessService *brightnessService;

@property (nonatomic, assign, getter=isLocked) BOOL locked;
@property (nonatomic, assign) BOOL isNoneFullScreenPlayerGestureEnabled;
@property (nonatomic, assign) BOOL controlShowingBySingleTap; // 控件 是否因 单击手势 呼出
@property (nonatomic, assign) BOOL supportsPortaitFullScreen;

/**
 panning 手势, 最后可识别为 dragging 或者是 swipping
 手势对外的 对外回调, 外界拿到方向，位移，状态，左右，来进行判断
 */
@property (nonatomic, copy) void(^pan)(UIPanGestureRecognizer * gestureRecogizer, UIView * viewAddedPanGesture,TTVPlayerPanGestureDirection direction, BOOL isSwiped);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPlayerControlView:(UIView *)controlView NS_DESIGNATED_INITIALIZER;

- (void)enablePanGestures:(BOOL)enable;
- (void)enableSingleTapGesture:(BOOL)enable;
- (void)enableDoubleTapGesture:(BOOL)enable;

- (void)removeAllGesture;
- (void)_buildGestures;

@property (nonatomic) TTVPlayerPanGestureDirection supportedPanDirection;//控制支持手势方向 全屏默认支持所有的



@end


