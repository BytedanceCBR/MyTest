//
//  WDParseHelper.m
//  Article
//
//  Created by xuzichao on 2016/11/15.
//
//

#import "WDParseHelper.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTRoute.h"
#import "WDDefines.h"
#import "FHTraceEventUtils.h"

NSString * const kWDLogPbFromKey = @"log_pb";
NSString * const kWDOriginFromKey = @"origin_from";
NSString * const kWDEnterFromKey = @"enter_from";
NSString * const kWDParentEnterFromKey = @"parent_enterfrom";
NSString * const kWDSourceKey = @"source";

@implementation WDParseHelper

+ (NSDictionary *)gdExtJsonFromBaseCondition:(NSDictionary *)condition
{
    NSMutableDictionary * dicts = [self trakExtraFromBaseCondition:condition forKey:@"gd_ext_json"].mutableCopy;
    if (![[dicts allKeys] containsObject:@"enter_from"]) {
        NSString * enterFrom = nil;
        @try {
            enterFrom = [condition objectForKey:@"enter_from"];
        }
        @catch (NSException *exception) {
            enterFrom = nil;
        }
        @finally {
            
        }
        if (!isEmptyString(enterFrom)) {
            [dicts setValue:enterFrom forKey:@"enter_from"];
        }
    } else {
        NSString *categoryname = nil;
        NSString *enterfrom = nil;
        if ([[dicts allKeys] containsObject:@"category_name"]) {
            categoryname = [dicts objectForKey:@"category_name"];
        }
        if ([[dicts allKeys] containsObject:@"enter_from"]) {
            enterfrom = [dicts objectForKey:@"enter_from"];
        }
        if (!isEmptyString(categoryname) && !isEmptyString(enterfrom) && [enterfrom hasSuffix:categoryname]) {
            [dicts removeObjectForKey:@"enter_from"];
            [dicts setValue:[FHTraceEventUtils generateEnterfrom:categoryname] forKey:@"enter_from"];
        }
    }
    return [dicts copy];
}

+ (NSDictionary *)apiParamFromBaseCondition:(NSDictionary *)condition
{
    return [self trakExtraFromBaseCondition:condition forKey:@"api_param"];
}

+ (NSDictionary *)logPbFromBaseCondition:(NSDictionary *)condition
{
    return [self trakExtraFromBaseCondition:condition forKey:@"log_pb"];
}


+ (NSDictionary *)trakExtraFromBaseCondition:(NSDictionary *)condition forKey:(NSString *)key
{
    NSString * jsonStr = [condition objectForKey:key];
    NSDictionary *json = [self protectMethodGetDicFromString:jsonStr];
    return json;
}

+ (NSDictionary *)protectMethodGetDicFromString:(NSString *)jsonStr
{
    jsonStr = [jsonStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    NSDictionary * jsonDict = nil;
    if (jsonStr) {
        jsonDict = [NSString tt_objectWithJSONString:jsonStr error:&error];
    }
    if (error || ![jsonDict isKindOfClass:[NSDictionary class]]) {
        jsonDict = nil;
    }
    if (jsonDict == nil) {
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        error = nil;
        if (jsonStr) {
            jsonDict = [NSString tt_objectWithJSONString:jsonStr error:&error];
        }
        if (error || ![jsonDict isKindOfClass:[NSDictionary class]]) {
            jsonDict = nil;
        }
    }
    return jsonDict;
}

+ (NSDictionary *)routeJsonWithOriginJson:(NSDictionary *)originDict source:(NSString *)source
{
    if ([originDict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *jsonDict = [originDict mutableCopy];
        if (originDict[kWDEnterFromKey]) {
            jsonDict[kWDParentEnterFromKey] = jsonDict[kWDEnterFromKey];
        }
        jsonDict[kWDEnterFromKey] = source;
        if (jsonDict[kWDSourceKey]) {
            [jsonDict removeObjectForKey:kWDSourceKey];
        }
        return [jsonDict copy];
    } else {
        return @{kWDEnterFromKey : source};
    }
}

+ (NSDictionary *)apiParamWithSourceApiParam:(NSDictionary *)originApiParam source:(NSString *)source
{
    if ([originApiParam isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *jsonDict = [originApiParam mutableCopy];
        jsonDict[kWDSourceKey] = source;
        return [jsonDict copy];
    } else {
        NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
        jsonDict[kWDSourceKey] = source;
        return [jsonDict copy];
    }
}

@end
