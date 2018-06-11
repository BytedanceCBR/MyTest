//
//  TTGetInstallIDTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTGetInstallIDTask.h"
#import "BDStartUpManager.h"

#if __has_include("TTInstallIDManager.h")
#import "TTInstallIDManager.h"
#endif
 
@implementation TTGetInstallIDTask

 - (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
#if __has_include("TTInstallIDManager.h")
     [[TTInstallIDManager sharedInstance] setConfigParamsBlock:^(void) {
         //        配置是否需要加密等参数block
         return @{};
     }];
     NSString *appID = [BDStartUpManager sharedInstance].appID;
     NSString *channel = [BDStartUpManager sharedInstance].channel;
     NSString *appName = [BDStartUpManager sharedInstance].appName;
     NSAssert(appID.length, @"AppID不能为空！");
     NSAssert(channel.length, @"channel不能为空！");
     NSAssert(appName.length, @"appName不能为空！");
     
     [[TTInstallIDManager sharedInstance] startWithAppID:appID
                                                 channel:channel appName:appName finishBlock:^(NSString *deviceID, NSString *installID) {
                                                     
                                                 }];
      
    
    [[TTInstallIDManager sharedInstance] setDidRegisterBlock:^(NSString *deviceID, NSString *installID) {
//        设备注册完成的回调
    }];
#endif
}

@end

