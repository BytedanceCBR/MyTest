//
//  Log.h
//  TestTTPushManagerPod
//
//  Created by gaohaidong on 5/22/16.
//  Copyright © 2016 bytedance. All rights reserved.
//
#import "TTDebugRealMonitorManager.h"

#ifndef Log_h
#define Log_h

// LOGE, LOGW, LOGI are enabled in release mode

#define LOGE( s, ... ) NSLog(@"Error %s: %@", __FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define LOGW( s, ... ) NSLog(@"Warning %s: %@", __FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define LOGI( s, ... ) NSLog(@"Info %s: %@", __FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

// LOGD, LOGT are disabled in release mode

#ifdef DEBUG

#ifndef LOGD
    #define LOGD( s, ... ) NSLog(@"Debug %s: %@", __FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#endif

#ifndef LOGD
    #define LOGT( s, ... ) NSLog(@"Trace %s: %@", __FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#endif

#ifndef TICK
    #define TICK  NSDate *startTime = [NSDate date]
#endif

#ifndef TOCK
    #define TOCK  LOGD(@"took time: %f seconds.", -[startTime timeIntervalSinceNow])
#endif

#else

#define LOGD( s, ... )

#define LOGT( s, ... )

#define TICK
#define TOCK

#endif

#define ENTER LOGD(@"Enter.")
#define EXIT  LOGD(@"Exit.")

/** 私信 */
#ifdef DEBUG
#define PLLOGD(s, ...) NSLog(@"Debug<PrivateLetter> %s: %@", __FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define PLLOGD(s, ...)
#endif

#ifdef __OBJC__
#ifdef DEBUG
#define TLS_LOG(__FORMAT__, ...) \
CLS_LOG(__FORMAT__,##__VA_ARGS__); \
[TTDebugRealMonitorManager cacheDevLogWithEventName:([NSString stringWithFormat:(__FORMAT__), ##__VA_ARGS__]) params:nil];

#else
#define TLS_LOG(__FORMAT__, ...) \
CLS_LOG(__FORMAT__,##__VA_ARGS__); \
[TTDebugRealMonitorManager cacheDevLogWithEventName:([NSString stringWithFormat:(__FORMAT__), ##__VA_ARGS__]) params:nil];
#endif
#endif
#endif /* Log_h */

