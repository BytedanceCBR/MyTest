//
//  TTVPlayerControlViewState.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/15.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface TTVPlayerControlViewState : NSObject<TTVReduxStateProtocol>

/// control层是否应该显示
@property (nonatomic, getter=isShowed)  BOOL showed;

/// 是否正在拖动,  controlview 的 pan, 不包括 control 里面 part 的截获pan的事件,
@property (nonatomic, getter=isPanning) BOOL panning;

/// 已经锁屏
@property (nonatomic, getter=isLocked)  BOOL locked;
/// 正在锁屏
@property (nonatomic) BOOL locking;
@property (nonatomic) BOOL unlocking;


@end

NS_ASSUME_NONNULL_END
