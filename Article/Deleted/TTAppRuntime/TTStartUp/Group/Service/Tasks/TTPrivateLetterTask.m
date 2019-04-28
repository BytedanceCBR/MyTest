//
//  TTPrivateLetterTask.m
//  Article
//
//  Created by 杨心雨 on 2017/2/20.
//
//

#import "TTPrivateLetterTask.h"
#import "TTPushService.h"
#import "TTSettingsManager.h"

@implementation TTPrivateLetterTask

- (NSString *)taskIdentifier {
    return @"PrivateLetter";
}
- (BOOL)isConcurrent{
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue];
}

#pragma mark - UIApplicationDelegate Method
- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    // 初始化长连接和IM服务
    [TTPushService sharedService];
}

@end
