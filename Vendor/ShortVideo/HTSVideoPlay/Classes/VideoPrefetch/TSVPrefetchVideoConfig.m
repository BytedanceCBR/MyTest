//
//  TSVPrefetchVideoConfig.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/9/4.
//

#import "TSVPrefetchVideoConfig.h"
#import "TTSettingsManager.h"
#import "BTDNetworkUtilities.h"
#import "NSDictionary+TTAdditions.h"

#define TSVVideoPrefetchSizeDefaultValue (800 * 1024)

@implementation TSVPrefetchVideoConfig

+ (NSDictionary *)prefetchConfig
{
    return [[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_video_prefetch" defaultValue:@{
                                                                                                        @"enabled" : @0,
                                                                                                        @"prefetch_size" : @TSVVideoPrefetchSizeDefaultValue
                                                                                                        } freeze:NO];
}

+ (BOOL)isPrefetchEnabled
{
    BOOL settingEnabled = [[self prefetchConfig] tt_boolValueForKey:@"enabled"];
    
    return settingEnabled && BTDNetworkWifiConnected();
}

+ (NSUInteger)prefetchSize
{
    NSUInteger ret = [[self prefetchConfig] tt_unsignedIntegerValueForKey:@"prefetch_size"];
    
    if (ret <= 0) {
        ret = TSVVideoPrefetchSizeDefaultValue;
    }
    
    return ret;
}

@end
