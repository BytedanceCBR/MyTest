//
//  TTOOMMonitorRecorder.h
//  Pods
//
//  Created by ShaJie on 1/6/2017.
//
//

#import <TTMonitor/TTMonitor.h>
#import "TTBaseSystemMonitorRecorder.h"

@interface TTOOMMonitorRecorder : TTBaseSystemMonitorRecorder

// 尝试检测程序上次结束进程是否因为 OOM
- (void)tryOOMDetection;

// App state 传入处理
- (void)handleApplicationTermination;
- (void)handleApplicationEnterForeground;
- (void)handleApplicationEnterBackground;

// 标记程序上次启动发生了崩溃
+ (void)setAppCrashFlagForLastTimeLaunch;

@end
