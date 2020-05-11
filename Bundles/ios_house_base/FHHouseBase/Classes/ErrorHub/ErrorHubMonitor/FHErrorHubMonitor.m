//
//  FHErrorHubMonitor.m
//  FHHouseBase
//
//  Created by liuyu on 2020/5/9.
//

#import "FHErrorHubMonitor.h"
#import "HMDTTMonitor.h"
@implementation FHErrorHubMonitor

+ (void)errorErrorReportingMessage:(FHHouseErrorHub *)errorHub {
     [[HMDTTMonitor defaultManager] hmdTrackService:@"slardar_local_test_err" metric:nil category:@{@"status" : errorHub.errorInfo} extra:errorHub.extra];
}
@end
