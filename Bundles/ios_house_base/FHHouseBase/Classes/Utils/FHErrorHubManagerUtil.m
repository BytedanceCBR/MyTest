//
//  FHErrorHubManagerUtil.m
//  FHHouseBase
//
//  Created by liuyu on 2020/7/11.
//

#import "FHErrorHubManagerUtil.h"
#import "FHErrorHubHelper.h"
#import "TTSandBoxHelper.h"

@implementation FHErrorHubManagerUtil
+ (void)checkRequestResponseWithHost:(NSString *)host requestParams:(NSDictionary *)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type {
    
    if (ISOPENLOCALTESTCHECK && ![self canUseDefine]) {
        [self openErrorHubSwitch];
    }
    
    if (![[self getChannel] isEqualToString:@"local_test"] || ![self errorHubSwitch]) {
        return;
    }
    
    Class cls = NSClassFromString(@"FHHouseErrorHubManager");
#pragma clang diagnostic push
#pragma clang diagnostic ignored   "-Wundeclared-selector"
    NSObject <FHErrorHubManagerProtocol>*errorhub = [cls performSelector:@selector(sharedInstance)];
    [errorhub checkRequestResponseWithHost:host requestParams:params responseStatus:responseStatus response:response analysisError:analysisError changeModelType:type errorHubType:1];
#pragma clang diagnostic pop
    
}

+ (void)checkBuryingPointWithEvent:(NSString *)eventName Params:(NSDictionary* )eventParams {
    
    if (ISOPENLOCALTESTCHECK && ![self canUseDefine] ) {
        [self openErrorHubSwitch];
    }
    
    if (![[self getChannel] isEqualToString:@"local_test"] || ![self errorHubSwitch]) {
        return;
    }
    Class cls = NSClassFromString(@"FHHouseErrorHubManager");
#pragma clang diagnostic push
#pragma clang diagnostic ignored   "-Wundeclared-selector"
    NSObject <FHErrorHubManagerProtocol>*errorhub = [cls performSelector:@selector(sharedInstance)];
    [errorhub checkBuryingPointWithEvent:eventName Params:eventParams];
#pragma clang diagnostic pop
}

+ (NSString*)getChannel {
    return [TTSandBoxHelper getCurrentChannel];
}

//现场开关
+ (BOOL)errorHubSwitch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"_errorHubSwitch"];
}

+ (BOOL)canUseDefine {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"_dontUseDefine"];
}

+ (void)openErrorHubSwitch {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"_errorHubSwitch"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"_dontUseDefine"];
}

@end
