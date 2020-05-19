//
//  FHDebugTools.m
//  TTDebug
//
//  Created by 张元科 on 2019/10/9.
//
#if INHOUSE
#import "FHDebugTools.h"
#import "MLeaksConfig.h"
#import "MLeaksFinder.h"
#import "TTInstallIDManager.h"

@implementation FHDebugTools

// 是否开启内存泄漏检测
- (void)configMemLeaks {
    NSString * appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * buildVersionRaw = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UPDATE_VERSION_CODE"];
    NSString *deviceId = [[TTInstallIDManager sharedInstance] deviceID];
    NSString *didStr = [NSString stringWithFormat:@"Device ID:\n%@",deviceId];
    
    //设置过滤条件，一些系统的误报在这里添加过滤白名单，by xsm
    NSDictionary *filters = @{
        @"TTAlphaThemedButton":@[@"__associated_object"],
        @"SSThemedButton":@[@"__associated_object"],
    };
    
//    {
//    *     "类名1" : [@"变量名1.1", @"变量名1.2"...],
//    *     "类名2" : [@"变量名2.1", @"变量名2.2"...]...
    
    
    MLeaksConfig *config = [[MLeaksConfig alloc] initWithAid:@"1370"
                                  enableAssociatedObjectHook:YES
                                                     filters:filters
                                               viewStackType:MLeaksViewStackTypeViewController
                                                  appVersion:appVersion
                                                   buildInfo:buildVersionRaw
                                               userInfoBlock:^NSString *{
                                                   return didStr;
                                               }];
    [TTMLeaksFinder startDetectMemoryLeakWithConfig:config];
}

@end
#endif
