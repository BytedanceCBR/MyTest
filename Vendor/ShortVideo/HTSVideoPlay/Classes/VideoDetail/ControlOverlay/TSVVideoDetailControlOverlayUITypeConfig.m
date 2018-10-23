//
//  TSVVideoDetailControlOverlayUITypeConfig.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/8/31.
//

#import "TSVVideoDetailControlOverlayUITypeConfig.h"
#import "TTSettingsManager.h"

@implementation TSVVideoDetailControlOverlayUITypeConfig

+ (NSInteger)overlayUIType
{
    NSNumber *style = [[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_detail_control_ui_type" defaultValue:@1 freeze:YES];
    NSAssert([style isKindOfClass:[NSNumber class]], @"style should be integer");
    
    return [style integerValue];
}

@end
