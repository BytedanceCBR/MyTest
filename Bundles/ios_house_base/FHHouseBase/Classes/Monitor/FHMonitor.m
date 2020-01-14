//
//  FHMonitor.m
//  FHHouseBase
//
//  Created by 张静 on 2019/5/31.
//

#import "FHMonitor.h"
#import "HMDTTMonitor.h"

@interface FHMonitor ()

@end

@implementation FHMonitor

- (void)trackService:(NSString *)serviceName attributes:(NSDictionary *)attributes
{
    [[HMDTTMonitor defaultManager]hmdTrackService:serviceName attributes:attributes];
}

@end
