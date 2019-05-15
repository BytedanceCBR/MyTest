//
//  TTVPlayFinishViewState.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/5.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVPlayerFinishViewState : NSObject<TTVReduxStateProtocol>

/// 错误 view 出现
@property (nonatomic, getter=isPlayerErrorViewShowed) BOOL  playerErrorViewShowed;
@property (nonatomic) BOOL  playerErrorViewShouldShow;


/// 播放结束，重播出现
@property (nonatomic, getter=isplayerFinishNoErrorViewShow) BOOL playerFinishNoErrorViewShow;

@end

NS_ASSUME_NONNULL_END
