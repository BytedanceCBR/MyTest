//
//  TTVSpeedReducer.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/24.
//

#import <Foundation/Foundation.h>
#import "TTVReduxKit.h"

@class TTVPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface TTVSpeedReducer : NSObject<TTVReduxReducerProtocol>

- (instancetype)initWithPlayer:(TTVPlayer *)player;

@end

NS_ASSUME_NONNULL_END
