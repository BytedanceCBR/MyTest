//
//  FHErrorHubManagerUtil.m
//  FHHouseBase
//
//  Created by liuyu on 2020/7/11.
//

#import "FHErrorHubManagerUtil.h"
#include <objc/runtime.h>
#include <objc/message.h>
#import "TTSandBoxHelper.h"

@implementation FHErrorHubManagerUtil
- (void)checkRequestResponseWithHost:(NSString *)host requestParams:(NSDictionary *)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type errorHubType:(NSInteger )errorHubType {
    if (![[self getChannel] isEqualToString:@"local_test"] || ![self errorHubSwitch]) {
        return;
    }
    NSObject <FHErrorHubManagerProtocol>*errorhub = objc_msgSend(objc_getClass("FHHouseErrorHubManager"),sel_registerName("sharedInstance"));
    [errorhub checkRequestResponseWithHost:host requestParams:params responseStatus:responseStatus response:response analysisError:analysisError changeModelType:type errorHubType:errorHubType];
}

- (void)checkBuryingPointWithEvent:(NSString *)eventName Params:(NSDictionary* )eventParams {
    if (![[self getChannel] isEqualToString:@"local_test"] || ![self errorHubSwitch]) {
        return;
    }
    NSObject <FHErrorHubManagerProtocol>*errorhub = objc_msgSend(objc_getClass("FHHouseErrorHubManager"),sel_registerName("sharedInstance"));
    [errorhub checkBuryingPointWithEvent:eventName Params:eventParams];
}

- (NSString*)getChannel {
    return [TTSandBoxHelper getCurrentChannel];
}

//现场开关
- (BOOL)errorHubSwitch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"_errorHubSwitch"];
}
@end
