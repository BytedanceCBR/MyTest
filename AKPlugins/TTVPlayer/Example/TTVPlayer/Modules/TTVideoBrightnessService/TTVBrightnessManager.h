//
//  TTVBrightnessManager.h
//  Article
//
//  Created by mazhaoxiang on 2018/11/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTVBrightnessManager : NSObject

@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) float currentBrightness;

+ (instancetype)shared;

/**
 是否使用全屏样式
 */
- (void)enableFullScreen:(BOOL)fullScreen;

/**
 当外界想手动去掉view时调用，比如：旋转屏幕、和音量调节互斥等
 */
- (void)dismissBrightnessView:(CGFloat)duration;

/**
 当外界想控制亮度时调用此方法，例如滑动屏幕调节
 */
- (void)updateBrightnessValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
