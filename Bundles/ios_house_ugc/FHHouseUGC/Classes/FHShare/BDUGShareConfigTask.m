//
//  BDUGShareConfigTask.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/4.
//

#import "BDUGShareConfigTask.h"
#import <TTLaunchDefine.h>
#import <BDUGContainer/BDUGContainer.h>
#import <BDUGLoggerInterface.h>
#import <BDUGShareManager.h>
#import "FHUGLoggerManager.h"
#import <BDUGShareAdapterSetting.h>
#import <FHSharePanel.h>
#import <BDUGShareAdapterSetting.h>
#import "FHShareManager.h"

DEC_TASK("BDUGShareConfigTask",FHTaskTypeSDKs,TASK_PRIORITY_HIGH+2);
@implementation BDUGShareConfigTask

-(NSString *)taskIdentifier {
    return @"BDUGShareConfigTask";
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
