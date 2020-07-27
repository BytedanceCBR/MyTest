//
//  TTZlinkSDKRegister.m
//  TTAppRuntime
//
//  Created by wangzhizhou on 2019/7/16.
//  需求文档： https://wiki.bytedance.net/pages/viewpage.action?pageId=356855332
//  Zlink接入文档： https://bytedance.feishu.cn/space/doc/doccnuHdgqOlAFbjAYuLHMGYmna#

#import "TTZlinkSDKRegister.h"
#import "TTLaunchDefine.h"
#import "BDUGDeepLinkManager.h"
#import "NewsBaseDelegate.h"
#import "TTInstallIDManager.h"
#import "TTSandBoxHelper.h"
#import "TTNetworkHelper.h"
#import "TTSettingsManager.h"
#import "NSDictionary+TTAdditions.h"

DEC_TASK("TTZlinkSDKRegister",FHTaskTypeSDKs,TASK_PRIORITY_HIGH);

@implementation TTZlinkSDKRegister
- (NSString *)taskIdentifier {
    return NSStringFromClass([self class]);
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [self registerSDK:application options:launchOptions];
}

- (BOOL)registerSDK:(UIApplication *)application options: (NSDictionary *)launchOptions {

    NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    BOOL f_zlink_disable = [fhSettings tt_boolValueForKey:@"f_zlink_disable"];
    if (f_zlink_disable) {
        return NO;
    }
    
    if ([SharedAppDelegate conformsToProtocol:@protocol(BDUGDeepLinkDelegate)]) {
        BDUGDeepLinkManager *manager = [BDUGDeepLinkManager shareInstance];
        manager.delegate = (id<BDUGDeepLinkDelegate>)SharedAppDelegate;
        
        // 获取App支持的把有Schema
        NSMutableArray *schemas = [NSMutableArray array];
        NSArray *bundleUrlTypes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
        for(NSDictionary *bundleUrlType in bundleUrlTypes) {
            NSArray *urlSchemas = [bundleUrlType objectForKey:@"CFBundleURLSchemes"];
            [schemas addObjectsFromArray:urlSchemas];
        }
        
        BDUGDeepLinkInfo *info = [BDUGDeepLinkInfo new];
        info.schemas = schemas;
        [manager registerDeepLinkWithInfo:info];
    }
    return YES;
}
@end
