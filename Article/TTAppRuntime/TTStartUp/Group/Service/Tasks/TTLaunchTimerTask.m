//
//  TTLaunchTimerTask.m
//  Article
//
//  Created by 王双华 on 2017/7/11.
//
//

#import "TTLaunchTimerTask.h"
#import <TTABManager/TTABHelper.h>
//#import "TTABHelper.h"

NSString * const TTLaunchTimerTaskLaunchTimeIntervalKey = @"TTLaunchTimerTaskLaunchTimeIntervalKey";

@implementation TTLaunchTimerTask

- (NSString *)taskIdentifier {
    return @"TTLaunchTimerTask";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    
    [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:TTLaunchTimerTaskLaunchTimeIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
