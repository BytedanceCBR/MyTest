//
//  TTVPlayerGestureReducer.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/29.
//

#import "TTVReduxKit.h"
@class TTVPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface TTVSeekReducer : NSObject<TTVReduxReducerProtocol>

- (instancetype)initWithPlayer:(TTVPlayer *)player;


@end

NS_ASSUME_NONNULL_END
