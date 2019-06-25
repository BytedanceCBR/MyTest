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

#import "TTLaunchDefine.h"

DEC_TASK("TTCommonURLSettingTask",FHTaskTypeService,TASK_PRIORITY_HIGH+11);

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
