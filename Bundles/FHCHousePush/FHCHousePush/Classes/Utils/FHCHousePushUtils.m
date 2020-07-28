//
//  FHCHousePushUtils.m
//  FHCHousePush
//
//  Created by 张静 on 2019/4/10.
//

#import "FHCHousePushUtils.h"
#include "TTRoute.h"

@implementation FHCHousePushUtils

+ (long long)fixLongLongTypeGroupID:(long long)gIDStr
{
    long long fixedID = gIDStr;
    if (fixedID < 0) {  //逻辑修正，爱看2.7(包括)版本之前，使用int32存储groupID，溢出，新版本需要兼容负数groupID
        fixedID = fixedID + 4294967296;
    }
    return fixedID;
}

+ (NSString *)fixStringTypeGroupID:(NSString *)gIDStr
{
    long long fixedID = [self fixLongLongTypeGroupID:[gIDStr longLongValue]];
    NSString * fixedGroupIDString = [NSString stringWithFormat:@"%lli", fixedID];
    return fixedGroupIDString;
}


+ (NSNumber *)fixNumberTypeGroupID:(NSNumber *)gID
{
    long long fixedID = [self fixLongLongTypeGroupID:[gID longLongValue]];
    return @(fixedID);
}

+ (TTRouteUserInfo *)getPushUserInfo:(TTRouteParamObj *)paramObj{
    NSMutableDictionary *info =  [NSMutableDictionary new];
    [info setValue:@(1) forKey:@"isFromPush"];

    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionaryWithDictionary:@{ @"enter_from": @"push",
                                                                                       @"enter_type": @"click",
                                                                                       @"element_from": @"be_null",
                                                                                       @"rank": @"be_null",
                                                                                       @"card_type": @"be_null",
                                                                                       @"origin_from": @"push",
                                                                                       @"origin_search_id": @"be_null"
    } ];
    if ([paramObj.queryParams.allKeys containsObject:@"origin_from"]) {
        NSString *value = [paramObj.queryParams objectForKey:@"origin_from"];
        if (value != nil) {
            [tracerDict setValue:value forKey:@"origin_from"];
        }
    }
    [info setValue:tracerDict forKey:@"tracer"];
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:info.copy];
    
    return userInfo;
}

@end
