//
//  RotateAnimator.h
//  ScreenRotate
//
//  Created by mac on 2017/10/19.
//  Copyright © 2017年 zuiye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTVPlayer;

@interface RotateAnimator : NSObject<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

/**
 初始化方法

 @param tag 需要旋转的 view 的 tag
 @return self
 */
- (instancetype)initWithRotateViewTag:(NSUInteger)tag playerVC:(UIViewController *)playerVC;

/// 旋转之前的 frame，用于恢复
@property (nonatomic) CGRect frameBeforePresent;

@end
