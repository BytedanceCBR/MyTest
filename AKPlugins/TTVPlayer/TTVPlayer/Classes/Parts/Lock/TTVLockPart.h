//
//  TTVLockPart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/10.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContextNew.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 控制锁屏相关的逻辑
 */
@interface TTVLockPart : NSObject<TTVPlayerContextNew, TTVReduxStateObserver, TTVPlayerPartProtocol>
/// 锁屏 button，默认是未锁屏状态，切换态是锁屏状态
@property (nonatomic, strong) UIView<TTVToggledButtonProtocol> *lockToggledButton;

@end

NS_ASSUME_NONNULL_END
