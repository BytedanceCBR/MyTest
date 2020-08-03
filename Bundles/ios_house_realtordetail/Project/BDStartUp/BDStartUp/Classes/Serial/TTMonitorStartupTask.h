//
//  TTMonitorStartupTask.h
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//
// 依赖库：TTMonitor

#import "BDStartUpManager.h"

extern NSString * const TTDebugrealInitializedNotification;

@interface TTMonitorStartupTask : NSObject <BDStartUpTaskProtocol>

@end

