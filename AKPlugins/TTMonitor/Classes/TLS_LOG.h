//
//  TLS_LOG.h
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/8/28.
//

#import <Crashlytics/Crashlytics.h>
#import "TTDebugRealMonitorManager.h"

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
