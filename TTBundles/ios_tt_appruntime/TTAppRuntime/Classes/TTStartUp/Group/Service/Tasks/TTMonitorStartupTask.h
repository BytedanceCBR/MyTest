//
//  TTMonitorStartupTask.h
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTStartupTask.h"

extern NSString * const TTDebugrealInitializedNotification;

@interface TTMonitorStartupTask : TTStartupTask

+ (BOOL)debugrealInitialized;

@end
