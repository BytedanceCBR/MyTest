//
//  TSVDebugInfoConfig.m
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 05/12/2017.
//

#import "TSVDebugInfoConfig.h"

@implementation TSVDebugInfoConfig

static NSString * const TSVDebugInfoEnabledKey = @"TSVDebugInfoEnabledKey";

+ (instancetype)config
{
    static dispatch_once_t onceToken;
    static TSVDebugInfoConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[TSVDebugInfoConfig alloc] init];
    });

    return config;
}

- (BOOL)debugInfoEnabled
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:TSVDebugInfoEnabledKey] boolValue];
}

- (void)setDebugInfoEnabled:(BOOL)debugInfoEnabled
{
    [[NSUserDefaults standardUserDefaults] setObject:@(debugInfoEnabled) forKey:TSVDebugInfoEnabledKey];
}

@end
