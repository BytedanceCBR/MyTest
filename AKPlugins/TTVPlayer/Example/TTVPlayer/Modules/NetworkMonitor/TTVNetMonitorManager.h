//
//  TTVNetMonitorManager.h
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayer.h"
#import "TTVNetTrafficFreeFlowTipView.h"
#import "TTVNetMonitorTracker.h"
@protocol UIView <NSObject>

@end

typedef UIView <TTVNetTrafficFreeFlowTipView> *(^TTVCreateFlowTipView)(void);
@interface TTVNetMonitorManager : NSObject<TTVPlayerContext>
// 广告View，流量提醒时不能遮住广告
@property (nonatomic, weak) UIView *belowSubview;
@property (nonatomic, assign) BOOL allowPlayWithoutWiFi;
- (void)customNetTrafficTipView:(TTVCreateFlowTipView)create;
- (void)registerNetTrafficTracker:(NSObject <TTVNetMonitorTracker> *)tracker;
- (void)enableFlowTip:(BOOL)flowTipEnable;
- (void)beginMonitor;
- (void)removeFlowTipView;
@end

@interface TTVPlayer (TTVNetMonitorManager)
- (TTVNetMonitorManager *)netMonitorManager;
@end
