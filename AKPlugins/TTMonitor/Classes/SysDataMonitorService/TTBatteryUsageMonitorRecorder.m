//
//  TTBatteryUsageMonitorRecorder.m
//  Article
//
//  Created by 苏瑞强 on 16/7/18.
//
//

#import "TTBatteryUsageMonitorRecorder.h"
#import "TTMonitor.h"

@interface TTBatteryUsageMonitorRecorder ()

@property (nonatomic, assign)UIDeviceBatteryState batteryState;
@property (nonatomic, assign)CGFloat batteryLevel;
@property (nonatomic, assign)CGFloat totalCost;
@end

@implementation TTBatteryUsageMonitorRecorder

-(id)init{
    self = [super init];
    if (self) {
        self.batteryLevel = [[UIDevice currentDevice] batteryLevel];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryStatusUpdated:)
                                                     name:UIDeviceBatteryStateDidChangeNotification
                                                   object:nil];

    }
    return self;
}


-(void)batteryStatusUpdated:(NSNotification *)notify{
    UIDeviceBatteryState batteryState = [[UIDevice currentDevice] batteryState];
    if (batteryState==UIDeviceBatteryStateCharging) {
        CGFloat value = [[UIDevice currentDevice] batteryLevel] - self.batteryLevel;
        self.totalCost += value;
    }else
       if (batteryState == UIDeviceBatteryStateUnplugged || batteryState == UIDeviceBatteryStateUnknown) {
           self.batteryState  = [[UIDevice currentDevice] batteryLevel];
        }
}

- (NSString *)type{
    return @"battery_monitor";
}

- (double)monitorInterval{
    double value = [TTMonitorConfiguration queryActionIntervalForKey:@"battery_monitor_interval"];
    if (value<=0) {
        value = 30;
    }
    return value;
}

- (BOOL)isEnabled{
    return [TTMonitorConfiguration queryIfEnabledForKey:@"battery_monitor"];
}

- (void)recordIfNeeded:(BOOL)isTermite{
    if (![self isEnabled]) {
        return;
    }
    CGFloat value = fabs([[UIDevice currentDevice] batteryLevel] - self.batteryLevel);
    self.batteryLevel = value;
    value += self.totalCost;
    self.totalCost = value;
    [[TTMonitor shareManager] event:[self type] label:@"battery_use" duration:value needAggregate:NO];
    if (isTermite) {
        [[TTMonitor shareManager] event:[self type] label:@"battery_use_one_launch" duration:self.totalCost needAggregate:NO];
    }
}


@end
