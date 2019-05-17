//
//  TTVGestureReducer.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/4.
//

#import <Foundation/Foundation.h>
#import "TTVReduxKit.h"
#import "TTVGestureState.h"
#import "TTVPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVGestureReducer : NSObject<TTVReduxReducerProtocol>

- (instancetype)initWithPlayer:(TTVPlayer *)player;

@end

NS_ASSUME_NONNULL_END
