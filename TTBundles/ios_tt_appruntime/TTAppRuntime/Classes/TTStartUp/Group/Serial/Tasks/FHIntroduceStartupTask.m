//
//  FHIntroduceStartupTask.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/12/18.
//

//#import "FHIntroduceStartupTask.h"
//
//@implementation FHIntroduceStartupTask
//
//@end

#import "FHIntroduceStartupTask.h"
#import "TTLaunchDefine.h"
#import "NewsBaseDelegate.h"
#import "FHIntroduceManager.h"
#import <FHHouseBase/FHEnvContext.h>

DEC_TASK("FHIntroduceStartupTask",FHTaskTypeUI,TASK_PRIORITY_HIGH);

@implementation FHIntroduceStartupTask

- (NSString *)taskIdentifier {
    return @"FHIntroduceStartupTask";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];

    BOOL fromAPNS = [[self class] isFromAPNSWithOptions:launchOptions];
    //只显示一次
    if([FHEnvContext isIntroduceOpen] && !fromAPNS ){
    //只显示一次,push进来不显示
        if([FHIntroduceManager sharedInstance].alreadyShow){
            return;
        }
        [[FHIntroduceManager sharedInstance] showIntroduceView:SharedAppDelegate.window];
        [FHIntroduceManager sharedInstance].alreadyShow = YES;
    }
}

+ (BOOL)isFromAPNSWithOptions:(NSDictionary *)launchOptions {
    return ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil);
}

@end
