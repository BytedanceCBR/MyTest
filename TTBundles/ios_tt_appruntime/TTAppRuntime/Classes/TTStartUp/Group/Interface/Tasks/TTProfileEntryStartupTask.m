//
//  TTProfileEntryStartupTask.m
//  Article
//
//  Created by lizhuoli on 2017/6/18.
//
//

#import "TTProfileEntryStartupTask.h"
#import "TTSettingMineTabManager.h"
#import "PGCAccountManager.h"

@implementation TTProfileEntryStartupTask

- (NSString *)taskIdentifier {
    return @"ProfileEntry";
}

#pragma mark - UIApplicationDelegate Method
- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    // 我的页面入口的Cell Entry管理单例
    [TTSettingMineTabManager sharedInstance_tt];
    // PGCAccountManager初始化的时机必须足够早
    [PGCAccountManager shareManager];
}

@end
