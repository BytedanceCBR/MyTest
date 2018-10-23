//
//  TTWatchdogMonitorRecorder.h
//  Pods
//
//  Created by xushuangqing on 2017/7/18.
//
//

#import <Foundation/Foundation.h>

extern NSString * const TTWatchDogDidTrigeredNotification;

@interface TTWatchdogMonitorRecorder : NSObject

- (void)startMonitor;

@end
