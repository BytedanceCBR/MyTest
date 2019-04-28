//
//  TTCommonURLSettingTask.m
//  Article
//
//  Created by xuzichao on 2017/6/8.
//
//

#import "TTCommonURLSettingTask.h"

#import "CommonURLSetting.h"
#import "TTReportManager.h"
#import "WDCommonURLSetting.h"

@implementation TTCommonURLSettingTask

- (NSString *)taskIdentifier {
    return @"TTCommonURLSettingTask";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    
    [[TTReportManager shareInstance] setDomainBaseURL:[CommonURLSetting baseURL]];
    [[WDCommonURLSetting sharedInstance] setDomainBaseURL:[CommonURLSetting baseURL]];
}

@end
