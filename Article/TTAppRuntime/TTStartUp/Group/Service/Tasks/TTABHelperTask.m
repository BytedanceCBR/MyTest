//
//  TTABHelperTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTABHelperTask.h"
#import <TTABManager/TTABHelper.h>
#import "TTSystemPermClientAB.h"
#import <BDABTestSDK/BDABTestBaseExperiment.h>
#import <BDABTestSDK/BDABTestManager.h>
#import <TTTracker.h>

@implementation TTABHelperTask

- (NSString *)taskIdentifier {
    return @"ABHelper";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //AB测试，迁移逻辑
    [[TTABHelper sharedInstance_tt] migrationIfNeed];
    
    //AB测试：分组逻辑 >>客户端实验分组应该放到
    [[TTABHelper sharedInstance_tt] distributionIfNeed];
    
    [self.class startClientABs];
    
    [self.class registABTests];

}

// 注册实验（所有通过BDABTestSDK取值的实验都必须注册
+ (void)registABTests
{
    // add by zjing for test
//    BDABTestBaseExperiment *exp = [[BDABTestBaseExperiment alloc] initWithKey:@"zjing_find_tab_show"
//                                                                        owner:@"zjing"
//                                                                  description:@"找房tab是否增加房源展现。。。"
//                                                                 defaultValue:@{@"show":@(0)}
//                                                                    valueType:BDABTestValueTypeDictionary
//                                                                     isSticky:YES];
    [BDABTestManager registerExperiment:exp];
    [TTTracker sharedInstance].abSDKVersionBlock = ^NSString *{
        NSString *exposureVid = [BDABTestManager queryExposureExperiments];
        return exposureVid;
    };
}


+ (void)startClientABs
{
    // 系统弹窗客户端实验
    [TTSystemPermClientAB distributeSPAB];
}

@end
