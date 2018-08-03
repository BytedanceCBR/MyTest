//
//  TSVChannelDecoupledConfig.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/12.
//

#import "TSVChannelDecoupledConfig.h"
#import "TTSettingsManager.h"
#import "NSDictionary+TTAdditions.h"

@implementation TSVChannelDecoupledConfig

+ (NSDictionary *)config
{
    return [[TTSettingsManager sharedManager] settingForKey:@"tt_short_video_decouple_strategy" defaultValue:@{
                                                                                                               @"strategy" : @0,
                                                                                                               @"count" : @1
                                                                                                               } freeze:YES];
}

+ (TSVChannelDecoupledStrategy)strategy
{
    NSInteger strategy = [[self config] tt_integerValueForKey:@"strategy"];
    
    return strategy == 1 ? TSVChannelDecoupledStrategyEnabled : TSVChannelDecoupledStrategyDisabled;
}

+ (NSInteger)numberOfExtraItemsTakenToDetailPage
{
    NSInteger count = [[self config] tt_integerValueForKey:@"count"];
    
    return MAX(0, count);
}

@end
