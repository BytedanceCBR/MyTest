//
//  TTVVolumeManager.h
//  Article
//
//  Created by zhengjiacheng on 2018/8/30.
//

#import <Foundation/Foundation.h>

@interface TTVVolumeManager : NSObject

@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) float currentVolume;
@property (nonatomic, assign, readonly) BOOL enableCustomVolumeView;

+ (instancetype)shared;

/**
 是否使用自定义音量View
 */
- (void)enableCustomVolumeView:(BOOL)enable;

/**
 是否使用全屏样式
 */
- (void)enableFullScreen:(BOOL)fullScreen;

/**
 当外界想手动去掉view时调用，比如：旋转屏幕、和亮度调节互斥等
 
 @param duration 消失动画时间
 */
- (void)dismissVolumeView:(CGFloat)duration;

/**
 当外界想控制音量时调用此方法，例如滑动屏幕调节
 */
- (void)updateVolumeValue:(CGFloat)value;

@end
