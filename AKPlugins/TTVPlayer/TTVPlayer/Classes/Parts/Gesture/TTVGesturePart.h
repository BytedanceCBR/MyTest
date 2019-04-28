//
//  TTVGesturePart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/4.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContextNew.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerGestureManager.h"
#import "TTVGestureState.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVGesturePart : NSObject<TTVPlayerContextNew, TTVReduxStateObserver, TTVPlayerPartProtocol>

/// 实际响应手势的类
@property (nonatomic, strong, readonly) TTVPlayerGestureManager * gestureVC;


@end



NS_ASSUME_NONNULL_END
