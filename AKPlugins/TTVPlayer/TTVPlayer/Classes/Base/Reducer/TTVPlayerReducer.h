//
//  TTVPlayerReducer.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/4.
//

#import "TTVReduxKit.h"
#import <Foundation/Foundation.h>

@class TTVPlayer;

NS_ASSUME_NONNULL_BEGIN

/**
 这个，reducer 需要知道内核，用来修改跟内核相关的状态
 */
@interface TTVPlayerReducer : NSObject<TTVReduxReducerProtocol>

- (instancetype)initWithPlayer:(TTVPlayer *)player;

@end

NS_ASSUME_NONNULL_END
