//
//  FHShareConfigTask.m
//  FHHouseShare
//
//  Created by bytedance on 2020/11/4.
//

#import "FHShareConfigTask.h"
#import <TTLaunchDefine.h>
#import <BDUGContainer/BDUGContainer.h>
#import <BDUGLoggerInterface.h>
#import <BDUGShareManager.h>
#import "FHUGLoggerManager.h"
#import <BDUGShareAdapterSetting.h>
#import <FHSharePanel.h>
#import <BDUGShareAdapterSetting.h>
#import "FHShareManager.h"

DEC_TASK("FHShareConfigTask",FHTaskTypeSDKs,TASK_PRIORITY_HIGH+2);
@implementation FHShareConfigTask

-(NSString *)taskIdentifier {
    return @"FHShareConfigTask";
}

-(void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    BDUG_BIND_CLASS_PROTOCOL([FHUGLoggerManager class], BDUGLoggerInterface);
    BDUGShareConfiguration *config = [BDUGShareConfiguration defaultConfiguration];
    config.localMode = YES;
    [BDUGShareManager initializeShareSDKWithConfiguration:config];
    [[BDUGShareAdapterSetting sharedService] setPanelClassName:NSStringFromClass([FHSharePanel class])];
    [[FHShareManager shareInstance] addCustomShareActivity];
}
@end
