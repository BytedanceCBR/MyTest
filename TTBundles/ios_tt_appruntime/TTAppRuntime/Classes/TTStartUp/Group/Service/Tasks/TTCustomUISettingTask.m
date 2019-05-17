//
//  TTCustomUISettingTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTCustomUISettingTask.h"
#import "TTUISettingHelper.h"

@implementation TTCustomUISettingTask

- (NSString *)taskIdentifier {
    return @"CustomUISetting";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //UI部分元素服务端控制，上次从settings获取的设置，本次启动让这些设置生效
    [TTUISettingHelper enforceServerUISettings];
}

@end
