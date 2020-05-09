//
//  FHErrorHubMonitor.m
//  FHHouseBase
//
//  Created by liuyu on 2020/5/9.
//

#import "FHErrorHubMonitor.h"
#import "HMDTTMonitor.h"
@implementation FHErrorHubMonitor

+ (void)errorErrorReportingMessage:(NSString *)errorInfo extr:(NSDictionary *)extr {
     [[HMDTTMonitor defaultManager] hmdTrackService:@"slardar_local_test_err" metric:nil category:@{@"status" : errorInfo} extra:extr];
}
@end
