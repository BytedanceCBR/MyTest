//
//  TTVNetworkMonitorReducer.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/13.
//

#import <Foundation/Foundation.h>
#import "TTVReduxKit.h"
#import "TTVPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVNetworkMonitorReducer : NSObject<TTVReduxReducerProtocol>
- (instancetype)initWithPlayer:(TTVPlayer *)player;

@end

NS_ASSUME_NONNULL_END
