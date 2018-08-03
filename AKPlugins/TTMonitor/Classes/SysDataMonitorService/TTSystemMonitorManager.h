//
//  TTSystemMonitorManager.h
//  Article
//
//  Created by 苏瑞强 on 16/7/18.
//
//

#import <Foundation/Foundation.h>

@interface TTSystemMonitorManager : NSObject

+ (instancetype)defaultMonitorManager;

- (void)enableMonitor;

// For OOM Detection
+ (void)setAppCrashFlagForLastTimeLaunch;

@end
