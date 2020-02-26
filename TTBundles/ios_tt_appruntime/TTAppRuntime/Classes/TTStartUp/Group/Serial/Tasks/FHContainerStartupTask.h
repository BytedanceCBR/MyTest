//
//  FHContainerStartupTask.h
//  Pods
//
//  Created by 张静 on 2020/2/4.
//

#import "TTStartupTask.h"
#import <BDUGMonitorInterface/BDUGMonitorInterface.h>
#import <BDUGTrackerInterface/BDUGTrackerInterface.h>
#import <BDUGSettingsInterface/BDUGSettingsInterface.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHContainerStartupTask : TTStartupTask<BDUGTrackerInterface,BDUGMonitorInterface,BDUGSettingsInterface>

#pragma mark 代理注册
+ (void)registerInterfaces;

@end

NS_ASSUME_NONNULL_END
