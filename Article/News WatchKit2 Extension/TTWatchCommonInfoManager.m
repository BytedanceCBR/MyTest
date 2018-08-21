//
//  TTWatchCommonInfoManager.m
//  Article
//
//  Created by 邱鑫玥 on 16/10/12.
//
//

#import "TTWatchCommonInfoManager.h"

#define kWatchCommonInfoDeviceIDKey @"kWatchCommonInfoDeviceIDKey"

@implementation TTWatchCommonInfoManager

+ (void)saveDeviceID:(NSString *)deviceID{
    [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:kWatchCommonInfoDeviceIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)deviceID{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kWatchCommonInfoDeviceIDKey];
}

@end
