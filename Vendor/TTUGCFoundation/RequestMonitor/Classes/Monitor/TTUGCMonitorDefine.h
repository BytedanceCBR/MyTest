//
//  TTUGCMonitorDefine.h
//  TTUGCFoundation
//
//  Created by zoujianfeng on 2019/4/2.
//

#ifndef TTUGCMonitorDefine_h
#define TTUGCMonitorDefine_h

#define kTTUGCPublishBehaviorMonitor @"ugc_publish"
#define kTTUGCMonitorType @"ugc_type"

typedef NS_ENUM(NSUInteger, kTTBehaviorFunnelType) { // 漏斗
    kTTBehaviorFunnelStart = 1,
    kTTBehaviorFunnelBeforeRequest = 2,
    kTTBehaviorFunnelRequestSuccess = 3,
    kTTBehaviorFunnelBackToUserInterface = 4,
};

typedef NS_ENUM(NSUInteger, kTTFirstSightClosedLoopType) {
    kTTFirstSightClosedLoopBegin = 1,
    kTTFirstSightClosedLoopRequest = 2,
    kTTFirstSightClosedLoopResponse = 3,
    kTTFirstSightClosedLoopEnd = 4,
};

#endif
