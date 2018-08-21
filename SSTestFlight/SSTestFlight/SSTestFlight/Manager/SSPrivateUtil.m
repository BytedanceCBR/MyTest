//
//  SSPrivateUtil.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-28.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "SSPrivateUtil.h"

#define kSystem @"System"
#define kUser @"User"
@implementation SSPrivateUtil

+ (NSDictionary *)deviceInstallAppInfos
{
    static NSString *const cacheFileName = @"com.apple.mobile.installation.plist";
    NSString *relativeCachePath = [[@"Library" stringByAppendingPathComponent: @"Caches"] stringByAppendingPathComponent: cacheFileName];
    NSDictionary *cacheDict = nil;
    NSString *path = nil;
    // Loop through all possible paths the cache could be in
    for (short i = 0; 1; i++)
    {
        
        switch (i) {
            case 0: // Jailbroken apps will find the cache here; their home directory is /var/mobile
                path = [NSHomeDirectory() stringByAppendingPathComponent: relativeCachePath];
                break;
            case 1: // App Store apps and Simulator will find the cache here; home (/var/mobile/) is 2 directories above sandbox folder
                path = [[NSHomeDirectory() stringByAppendingPathComponent: @"../.."] stringByAppendingPathComponent: relativeCachePath];
                break;
            case 2: // If the app is anywhere else, default to hardcoded /var/mobile/
                path = [@"/var/mobile" stringByAppendingPathComponent: relativeCachePath];
                break;
            default: // Cache not found (loop not broken)
                return nil;
            break; }
        
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath: path isDirectory: &isDir] && !isDir) // Ensure that file exists
            cacheDict = [NSDictionary dictionaryWithContentsOfFile: path];
        
        if (cacheDict) // If cache is loaded, then break the loop. If the loop is not "broken," it will return nil
            break;
    }
    return cacheDict;
}

+ (BOOL)isAppInstalled:(NSString *)appBundle
{
    if (isEmptyString(appBundle)) {
        return NO;
    }
    
    NSDictionary * dict = [self deviceInstallAppInfos];
    if ([[[dict objectForKey:kSystem] allKeys] containsObject:appBundle]) {
        return YES;
    }
    if ([[[dict objectForKey:kUser] allKeys] containsObject:appBundle]) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)appBundleVersionIfInstalled:(NSString *)appBundle
{
    if (isEmptyString(appBundle)) {
        return nil;
    }
    
    NSDictionary * dict = [self deviceInstallAppInfos];
    NSString * systemVersion = [[[dict objectForKey:kSystem] objectForKey:appBundle] objectForKey:@"CFBundleVersion"];
    if (!isEmptyString(systemVersion)) {
        return systemVersion;
    }
    NSString * userVersion = [[[dict objectForKey:kUser] objectForKey:appBundle] objectForKey:@"CFBundleVersion"];
    if (!isEmptyString(userVersion)) {
        return userVersion;
    }
    return nil;
}


@end
