//
//  TTVPlayerSpeedState.h
//  TTVPlayer
//
//  Created by lisa on 2018/12/26.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"

/// 倍速播放模块的 action

NS_ASSUME_NONNULL_BEGIN

@interface TTVPlayerSpeedState : NSObject<TTVReduxStateProtocol>

@property (nonatomic, assign) CGFloat currentSpeed; // 当前播放的倍速

@end

NS_ASSUME_NONNULL_END
