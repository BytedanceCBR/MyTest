//
//  FHMonitor.m
//  Pods
//
//  Created by bytedance on 2020/8/24.
//

#import "FHMonitor.h"
#import <Heimdallr/HMDTTMonitor.h>

@implementation FHMonitor

+ (void)hmdTrackService:(NSString *)serviceName metric:(NSDictionary <NSString *, NSNumber *> *)metric category:(NSDictionary *)category extra:(NSDictionary *)extraValue {
    [[HMDTTMonitor defaultManager] hmdTrackService:serviceName metric:metric category:category extra:extraValue];
}

+ (void)hmdTrackService:(NSString *)serviceName status:(NSInteger)status extra:(NSDictionary *)extraValue {
    [self hmdTrackService:serviceName metric:nil category:@{@"status": @(status)} extra:nil];
}

@end
