//
//  TTVSpeedState.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTVSpeedState : NSObject

/// 是否应该展示 selectView,由外界进行调用
@property (nonatomic) BOOL speedSelectViewShouldShow;
/// 倍速选择页面，已经展示
@property (nonatomic) BOOL speedSelectViewShowed;

/// 播放速度
@property (nonatomic) CGFloat speed;
@end

NS_ASSUME_NONNULL_END
