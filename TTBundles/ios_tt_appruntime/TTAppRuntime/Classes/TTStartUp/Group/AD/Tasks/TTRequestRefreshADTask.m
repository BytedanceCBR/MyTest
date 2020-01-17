//
//  TTRequestRefreshADTask.m
//  Article
//
//  Created by ranny_90 on 2017/3/21.
//
//

#import "TTRequestRefreshADTask.h"
#import "TTAdManager.h"
//#import "TTLaunchDefine.h"
//
//DEC_TASK("TTRequestRefreshADTask",FHTaskTypeAD,TASK_PRIORITY_HIGH);
#import <FHHouseBase/FHEnvContext.h>

@implementation TTRequestRefreshADTask

- (NSString *)taskIdentifier {
    return @"RequestRefreshAD";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    
    if (![[FHEnvContext sharedInstance] hasConfirmPermssionProtocol]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestRefreshAd];
    });
}

- (void)requestRefreshAd {

    [TTAdManageInstance refresh_requestRefreshAdData];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [TTAdManageInstance refresh_requestRefreshAdData];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
//    [TTAdManageInstance refresh_setRefreshManagerLauchType:TTAppLaunchType_HotLaunch];
    
}

@end
