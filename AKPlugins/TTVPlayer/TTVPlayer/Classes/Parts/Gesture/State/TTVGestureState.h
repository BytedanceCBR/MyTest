//
//  TTVGestureState.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/4.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerGestureManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 state中的状态， 反应出目前播放器已经处于的状态
 */
@interface TTVGestureState : NSObject

/// pan支持的方向
@property (nonatomic) TTVPlayerPanGestureDirection supportPanDirection;

/// 是否可以 pan
@property (nonatomic, getter=isPanGestureEnabled) BOOL panGestureEnabled;

/// 是否可以 单击
@property (nonatomic, getter=isSingleTapGestureEnabled) BOOL singleTapEnabled;

/// 是否可以 双击
@property (nonatomic, getter=isDoubleGestureEnabled) BOOL doubleTapEnabled;

@end

NS_ASSUME_NONNULL_END
