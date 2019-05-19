//
//  TTVPlayer+BecomeResignActive.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/23.
//

#import "TTVPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVPlayer (BecomeResignActive)

- (void)addBackgroundObserver;

/// 是否支持后台播放, 默认是 NO，如果设置为 YES，需要在 plist 同时对UIBackgroundModes进行设置
@property (nonatomic) BOOL supportBackgroundPlayback;
@end

NS_ASSUME_NONNULL_END
