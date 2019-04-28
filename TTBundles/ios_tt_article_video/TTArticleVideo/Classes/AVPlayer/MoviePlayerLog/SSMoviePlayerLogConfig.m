//
//  SSMoviePlayerLogConfig.m
//  Article
//
//  Created by Chen Hong on 15/8/26.
//
//

#import "SSMoviePlayerLogConfig.h"

@implementation SSMoviePlayerLogConfig

+ (BOOL)fetchDNSInfo
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"movieSetFetchDNSInfo"] boolValue];
}

+ (void)setFetchDNSInfo:(BOOL)fetch
{
    [[NSUserDefaults standardUserDefaults] setValue:@(fetch) forKey:@"movieSetFetchDNSInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)fetchServerIPFromHead
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"videoFetchServerIPFromHead"] boolValue];
}

+ (void)setFetchServerIPFromHead:(BOOL)fetch
{
    [[NSUserDefaults standardUserDefaults] setValue:@(fetch) forKey:@"videoFetchServerIPFromHead"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
