//
//  TTCrashAttemptFixTask.h
//  Article
//
//  Created by fengyadong on 2017/5/16.
//
//

#import "TTStartupTask.h"

@interface TTCrashAttemptFixTask : TTStartupTask

extern void fix_nano_crash_if_enable();

@end
