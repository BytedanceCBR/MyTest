//
//  TTVPlayerStateNetMonitor.h
//  Article
//
//  Created by panxiang on 2018/8/23.
//

#import <Foundation/Foundation.h>

#define TTVNetMonitorManagerActionTypeReplay @"TTVNetMonitorManagerActionTypeReplay"
#define TTVNetMonitorManagerActionTypeContinuePlay @"TTVNetMonitorManagerActionTypeContinuePlay"
#define TTVNetMonitorManagerActionTypeContinuePlay @"TTVNetMonitorManagerActionTypeContinuePlay"
#define TTVNetMonitorManagerActionTypeShow @"TTVNetMonitorManagerActionTypeShow"//流量提示view展示
#define TTVNetMonitorManagerActionTypeSubscrib @"TTVNetMonitorManagerActionTypeSubscrib"//订阅
@interface TTVPlayerStateNetMonitor : NSObject
/**
 由于网络切换4g造成当前为暂停态
 */
@property (nonatomic, assign, readonly) BOOL pausingBycellularNetwork;

@end
