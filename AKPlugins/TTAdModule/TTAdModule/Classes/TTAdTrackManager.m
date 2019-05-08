//
//  TTAdTrackManager.m
//  Article
//
//  Created by yin on 2017/7/10.
//
//

#import "TTAdTrackManager.h"
#import <TTAdModule/TTAdMonitorManager.h>
#import <TTTracker/TTTrackerProxy.h>
//#import "TTTrackerWrapper.h"

@implementation TTAdTrackManager

#pragma mark 统计事件

+ (void)trackWithTag:(NSString *)tag
               label:(NSString *)label
               value:(NSString *)value
            extraDic:(NSDictionary *)dic
{
    ttTrackEventWithCustomKeys(tag, label, value, nil, dic);
    {
        NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
        [events setValue:tag forKey:@"tag"];
        [events setValue:label forKey:@"label"];
        [events setValue:[NSString stringWithFormat:@"%@", value] forKey:@"value"];
        if (dic) {
            [events addEntriesFromDictionary:dic];
        }
        [TTAdMonitorManager trackAdException:events];
    }
}


//+ (void)trackWithEvents:(NSDictionary *)dic {
//    NSAssert(dic, @"打点数据不能为空");
//    if (dic) {
//        return;
//    }
//    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
//    [events addEntriesFromDictionary:dic];
//    [events setValue:@"1" forKey:@"is_ad_event"];
//    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
//    [events setValue:@(nt) forKey:@"nt"];
//    [TTTrackerWrapper eventData:events];
//}

@end
