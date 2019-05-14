//
//  TTVNetworkMonitorState.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/13.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVNetworkMonitorState : NSObject<TTVReduxStateProtocol, NSCopying>

/// 表示是否被弱网中断了播放，只能中断一次
@property (nonatomic) BOOL pausingBycellularNetwork;
@property (nonatomic) BOOL flowTipViewShowed;
@end

NS_ASSUME_NONNULL_END
