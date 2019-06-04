//
//  TTURLCacheSettingTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTURLCacheSettingTask.h"
#import "TTLaunchDefine.h"

DEC_TASK("TTURLCacheSettingTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+9);

@implementation TTURLCacheSettingTask

- (NSString *)taskIdentifier {
    return @"URLCacheSetting";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:40 * 1024 * 1024
                                                             diskPath:@"TTURLCache"];
    [NSURLCache setSharedURLCache:URLCache];
}

@end
