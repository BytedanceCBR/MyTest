//
//  TTVPlayerControlViewReducer.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/15.
//

#import <Foundation/Foundation.h>
#import "TTVReduxKit.h"
@class TTVPlayer;
NS_ASSUME_NONNULL_BEGIN

@interface TTVPlayerControlViewReducer : NSObject<TTVReduxReducerProtocol>

- (instancetype)initWithPlayer:(TTVPlayer *)player;

@end

NS_ASSUME_NONNULL_END
