//
//  TTABHelperTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTABHelperTask.h"
#import "TTSystemPermClientAB.h"
#import <BDABTestSDK/BDABTestBaseExperiment.h>
#import <BDABTestSDK/BDABTestManager.h>
#import <TTTracker/TTTracker.h>
#import "FHEnvContext.h"

#import <TTSettingsManager/TTSettingsManager.h>
#import "TTLaunchDefine.h"

DEC_TASK("TTABHelperTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+4);

@implementation TTABHelperTask

- (NSString *)taskIdentifier {
    return @"ABHelper";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //AB测试，迁移逻辑
//    [[TTABHelper sharedInstance_tt] migrationIfNeed];
    
    //AB测试：分组逻辑 >>客户端实验分组应该放到
//    [[TTABHelper sharedInstance_tt] distributionIfNeed];
    
    [self.class startClientABs];
    // BDABTestSDK 注册
    [self.class registABTests];
    
}

+ (void)registABTests
{
    // 添加服务端实验
    [self registServerABs];
    
    // 添加客户端实验
    [self registClientABs];
    
    // 用于上报vid，追踪实验数据
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

// 添加服务端实验
+ (void)registServerABs
{
    // 注册实验（所有通过BDABTestSDK取值的实验都必须注册
    // 需要添加的服务端实验都在此先注册
    BDABTestBaseExperiment *exp = [[BDABTestBaseExperiment alloc] initWithKey:@"zjing_find_tab_show"
                                                                        owner:@"zjing"
                                                                  description:@"模拟服务端实验找房tab是否增加房源展现，默认为0"
                                                                 defaultValue:@{@"show":@(0)}
                                                                    valueType:BDABTestValueTypeDictionary
                                                                     isSticky:YES settingsValueBlock:^id(NSString *key) {
        if (key.length > 0) {
            NSDictionary *archSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
            if ([archSettings valueForKey:key]) {
                return archSettings[key];
            }
        }
        return nil;
    }];
    [BDABTestManager registerExperiment:exp];
    
    BDABTestBaseExperiment *wuhuDetailCardOrder = [[BDABTestBaseExperiment alloc] initWithKey:@"f_wuhu_detail_card_order"
                                                                        owner:@"shangguanxiangzheng"
                                                                  description:@"芜湖小端房源详情页腰部展位与评测位置互换实验:默认为0"
                                                                 defaultValue:@(0)
                                                                    valueType:BDABTestValueTypeNumber
                                                                     isSticky:YES settingsValueBlock:^id(NSString *key) {
        if (key.length > 0) {
            NSDictionary *archSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
            if ([archSettings valueForKey:key]) {
                return archSettings[key];
            }
        }
        return nil;
    }];
    [BDABTestManager registerExperiment:wuhuDetailCardOrder];
}

// 添加客户端实验
+ (void)registClientABs
{
    // 客户端分层实验在此添加
    [self addShowHouseTest];
    
//    [self addSmallVideoListTest];
    
    [self addHouseCardReadTest];
    
    //启动实验引擎，请确保在所有客户端本地分流实验都注册完成后再调用此接口！
    [BDABTestManager launchClientExperimentManager];
    
    //提前曝光一些实验，否则alog是不会上报这些实验vid的，会导致某些实验结果不对
    [self preExposureExperiment];
}

+ (void)preExposureExperiment {
    //获取实验值，同时为了提前把实验曝光
    //queryExposureExperiments决定了你上报到alog的实验数据，如果上报时候没有你的vid，则表示上报的不对
//    NSString *exposureExperiments = [BDABTestManager queryExposureExperiments];
//    NSLog(@"queryExposureExperiments result is %@", exposureExperiments);
    
    id videoPerload = [BDABTestManager getExperimentValueForKey:@"test_video_perload" withExposure:YES];
    NSLog(@"BDClientABTest test_video_perload is %@",videoPerload);
    
    id res = [BDABTestManager getExperimentValueForKey:@"f_house_read_unread_enable" withExposure:YES];
    NSLog(@"BDClientABTest f_house_read_enable is %@",res);
}
// test 注册字典类型的客户端分层实验
+ (void)addCardStyleTest
{
    //注册实验 每次都必须注册，但是只有第一次能成功
    //生成实验分组
    NSInteger count = 3;
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger index = 0; index < count; ++index) {
        //name:vid
        NSString *name = [NSString stringWithFormat:@"%ld",790672 + index]; // Libra对应d实验组vid
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"card_Style"] = [NSString stringWithFormat:@"%ld",index];
        BDClientABTestGroup *group = [[BDClientABTestGroup alloc] initWithName:name minRegion:1000/count*index maxRegion:1000/count*(index+1)-1 results:@{@"f_test_params":params}];
        if ([group isLegal]) {
            [groups addObject:group];
        }
    }
    //生成实验层
    BDClientABTestLayer *clientLayer = [[BDClientABTestLayer alloc] initWithName:@"test_client" groups:groups];
    if ([clientLayer isLegal]) {
        //注册实验层
        [BDABTestManager registerClientLayer:clientLayer];
    }
    //生成实验
    BDClientABTestExperiment *clientEXP = [[BDClientABTestExperiment alloc] initWithKey:@"f_test_params" owner:@"zhangjing.2018" description:@"模拟测试房源卡片样式，012分别代表单双三排，默认值为0" defaultValue:@{@"f_test_params":@{@"card_Style":@"0"}} valueType:BDABTestValueTypeDictionary isSticky:NO clientLayer:clientLayer];
    //注册实验
    [BDABTestManager registerExperiment:clientEXP];
    //获取实验值
//    id res = [BDABTestManager getExperimentValueForKey:@"f_test_params" withExposure:YES];
//    NSLog(@"BDClientABTest card_Style is %@",res);
//    获取曝光结果
//    NSString *exposureExperiments = [BDABTestManager queryExposureExperiments];
//    NSLog(@"queryExposureExperiments result is %@", exposureExperiments);
}


//房源卡片已读功能客户端实验:https://data.bytedance.net/libra/flight/578159/edit
+ (void)addHouseCardReadTest {
    NSInteger count = 2;
     NSMutableArray *groups = [NSMutableArray arrayWithCapacity:count];
     for (NSInteger index = 0; index < count; ++index) {
         NSString *name = [NSString stringWithFormat:@"%ld", 2345078 + index];
         NSMutableDictionary *params = @{}.mutableCopy;
         params[@"f_house_read_unread_enable"] = @(index);
         BDClientABTestGroup *group = [[BDClientABTestGroup alloc] initWithName:name minRegion:1000/count*index maxRegion:1000/count*(index + 1) - 1 results:params];
         if ([group isLegal]) {
             [groups addObject:group];
         }
     }
     //生成实验层
     BDClientABTestLayer *clientLayer = [[BDClientABTestLayer alloc] initWithName:@"f_client_layer1" groups:groups];
     if ([clientLayer isLegal]) {
         [BDABTestManager registerClientLayer:clientLayer];
     }
     BDClientABTestExperiment *clientEXP = [[BDClientABTestExperiment alloc] initWithKey:@"f_house_read_unread_enable" owner:@"xubinbin.19971226" description:@"列表页大类页开启房源卡片已读功能" defaultValue:@(0) valueType:BDABTestValueTypeDictionary isSticky:NO clientLayer:clientLayer];
     [BDABTestManager registerExperiment:clientEXP];
}

// test 注册字符串类型的客户端分层实验
+ (void)addShowHouseTest
{
    NSInteger count = 2;
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger index = 0; index < count; ++index) {
        //name:vid
        NSString *name = [NSString stringWithFormat:@"%ld",792556 + index]; // Libra对应d实验组vid
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"show_house"] = [NSString stringWithFormat:@"%ld",index];
        BDClientABTestGroup *group = [[BDClientABTestGroup alloc] initWithName:name minRegion:1000/count*index maxRegion:1000/count*(index+1)-1 results:params];
        if ([group isLegal]) {
            [groups addObject:group];
        }
    }
    //生成实验层
    BDClientABTestLayer *clientLayer = [[BDClientABTestLayer alloc] initWithName:@"test_client1" groups:groups];// 此处name @"test_client" 必须和Libra客户端分层保持一致么？
    if ([clientLayer isLegal]) {
        //注册实验层
        [BDABTestManager registerClientLayer:clientLayer];
    }
    //生成实验
    BDClientABTestExperiment *clientEXP = [[BDClientABTestExperiment alloc] initWithKey:@"show_house" owner:@"zhangjing.2018" description:@"模拟测试找房tab是否展示房源，1表示展示。默认值为0" defaultValue:@"0" valueType:BDABTestValueTypeString isSticky:NO clientLayer:clientLayer];
    //注册实验
    [BDABTestManager registerExperiment:clientEXP];
    
//    id res1 = [BDABTestManager getExperimentValueForKey:@"show_house" withExposure:YES];
//    NSLog(@"BDClientABTest show_house is %@",res1);
////    获取曝光结果
//    NSString *exposureExperiments = [BDABTestManager queryExposureExperiments];
//    NSLog(@"queryExposureExperiments result is %@", exposureExperiments);
}

@end
