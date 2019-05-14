//
//  TTVLoadingReducer.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/15.
//

#import <Foundation/Foundation.h>
#import "TTVReduxKit.h"
#import "TTVPlayerAction.h"
#import "TTVPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVLoadingReducer : NSObject<TTVReduxReducerProtocol>

- (instancetype)initWithPlayer:(TTVPlayer *)player;

@end

NS_ASSUME_NONNULL_END
