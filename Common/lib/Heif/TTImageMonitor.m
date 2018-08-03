//
//  TTImageMonitor.m
//  Article
//
//  Created by fengyadong on 2017/11/17.
//

#import "TTImageMonitor.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "UIImageView+BDTSource.h"

@implementation TTImageMonitor

+ (BOOL)enableHeifImageForSource:(NSString *)source {
    if (source.length <= 0) {
        return NO;
    }
    
    NSInteger value = [self rawSwitchValueForSource:source];
    
    return value & 0b01;
}

+ (BOOL)enableImageMonitorForSource:(NSString *)source {
    if ([source isEqualToString:kBDTSourceUGCCell]) {
        return YES;
    }
    if (source.length <= 0) {
        return NO;
    }
    
    NSInteger value = [self rawSwitchValueForSource:source];
    
    return value & 0b10;
}

+ (NSInteger)rawSwitchValueForSource:(NSString *)source {
    NSDictionary *dict = [[TTSettingsManager sharedManager] settingForKey:@"tt_heif_decode_enable" defaultValue:@{} freeze:NO];
    NSInteger value = [dict tt_integerValueForKey:source];
    
    return value;
}

@end
