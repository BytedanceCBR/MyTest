//
//  TTAppPageManagerTask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTAppPageManagerTask.h"
#import "TTRoute.h"
#import "TTRouteService.h"
#import "NewsBaseDelegate.h"
#import "TTLaunchDefine.h"

DEC_TASK("TTAppPageManagerTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+10);

@implementation TTAppPageManagerTask

- (NSString *)taskIdentifier {
    return @"AppPageManager";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
//    [[TTRoute sharedRoute] setAppWindow:SharedAppDelegate.window];
    
    //实现TTRoute业务相关逻辑
    [TTRouteService registerTTRouteService];
}

@end
