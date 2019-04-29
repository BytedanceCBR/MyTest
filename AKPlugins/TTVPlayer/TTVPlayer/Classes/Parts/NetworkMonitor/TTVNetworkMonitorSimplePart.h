//
//  TTVNetworkMonitorPart.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/12.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContexts.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN


/**
 播放之前，播放过程中，切换到4G，就会给出提示；
 给出提示如果需要选择后继续继续播放，则
 */
@interface TTVNetworkMonitorSimplePart :  NSObject<TTVPlayerContexts, TTVReduxStateObserver, TTVPlayerPartProtocol>
@property (nonatomic, assign) BOOL allowPlayWithoutWiFi;
@property (nonatomic, strong) UIView <TTVFlowTipViewProtocol> *freeFlowTipView; // 流量提示 view：阻塞界面, 只出现一次


@end

NS_ASSUME_NONNULL_END
