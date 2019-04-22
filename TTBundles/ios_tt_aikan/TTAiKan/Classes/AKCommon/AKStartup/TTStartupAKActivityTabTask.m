//
//  TTStartupAKActivityTabTask.m
//  Article
//
//  Created by 冯靖君 on 2018/3/5.
//

#import "TTStartupAKActivityTabTask.h"
#import "AKActivityTabManager.h"
#import "AKRedPacketManager.h"
#import <TTRoute.h>

@implementation TTStartupAKActivityTabTask

- (NSString *)taskIdentifier
{
    return @"ak_activity_tab";
}

- (BOOL)isResident
{
    return NO;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    
    // 更新任务tab状态
    [[AKActivityTabManager sharedManager] startUpdateActivityTabState];
}

@end
