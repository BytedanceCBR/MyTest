//
//  TTDebugConsoleManager.m
//  Article
//
//  Created by gaohaidong on 6/24/16.
//
//

#import "TTDebugConsoleManager.h"
#import "TTPushManager.h"
#import "TTLCSServerConfig.h"

#import "TTNetworkManager.h"

static NSString * const kLogOff = @"*debug0#";
static NSString * const kLogOn  = @"*debug1#";

static NSString * const kTTNetLogOn  = @"*debug2#";

@implementation TTDebugConsoleManager

+ (instancetype)sharedTTDebugConsoleManager
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (void)processCommand:(NSString *)command {
    if (![[TTLCSServerConfig sharedInstance] isEnabled]) {
        return;
    }
    
    NSString *trimmed = [command stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmed isEqualToString:kLogOn]) {
        [[TTPushManager sharedManager] enableDebugLog:YES];
    } else if ([trimmed isEqualToString:kLogOff]) {
        [[TTPushManager sharedManager] enableDebugLog:NO];
    } else if ([trimmed isEqualToString:kTTNetLogOn]) {
        [[TTNetworkManager shareInstance] enableVerboseLog];
    }
}

@end
