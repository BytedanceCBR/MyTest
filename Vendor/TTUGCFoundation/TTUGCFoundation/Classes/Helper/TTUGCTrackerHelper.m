//
//  TTUGCTrackerHelper.m
//  Article
//
//  Created by SongChai on 2017/7/14.
//

#import "TTUGCTrackerHelper.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTRoute.h"
#import "TTDeviceHelper.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>


@implementation TTUGCTrackerHelper

+ (NSDictionary *)trackExtraFromBaseCondition:(NSDictionary *)condition
{
    NSDictionary *params = condition;
    NSString * gdExtJson = [params objectForKey:@"gd_ext_json"];
    gdExtJson = [gdExtJson stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    NSDictionary * gdExtJsonDict = nil;
    if (gdExtJson) {
        gdExtJsonDict = [NSString tt_objectWithJSONString:gdExtJson error:&error];
    }
    if (error || ![gdExtJsonDict isKindOfClass:[NSDictionary class]]) {
        gdExtJsonDict = nil;
    }
    if (gdExtJsonDict == nil) {
        gdExtJson = [gdExtJson stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        error = nil;
        if (gdExtJson) {
            gdExtJsonDict = [NSString tt_objectWithJSONString:gdExtJson error:&error];
        }
        if (error || ![gdExtJsonDict isKindOfClass:[NSDictionary class]]) {
            gdExtJsonDict = nil;
        }
    }
    NSMutableDictionary * dicts = [NSMutableDictionary dictionaryWithDictionary:gdExtJsonDict];
    NSString *enterFrom = [dicts tt_stringValueForKey:@"enter_from"];
    if (!isEmptyString(enterFrom)) {
        enterFrom = [condition tt_stringValueForKey:@"enter_from"];
        if (!isEmptyString(enterFrom)) {
            [dicts setValue:enterFrom forKey:@"enter_from"];
        }
    }
    
    return dicts;
}

+ (NSDictionary *)logPbFromBaseCondition:(NSDictionary *)condition {
    NSDictionary *params = condition;
    NSString *logPb = [params objectForKey:@"log_pb"];
    if ([logPb isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)logPb;
    }
    if (![logPb isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    logPb = [logPb stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *logPbDict = nil;
    if (logPb) {
        logPbDict = [NSString tt_objectWithJSONString:logPb error:&error];
    }
    if (error || ![logPbDict isKindOfClass:[NSDictionary class]]) {
        logPbDict = nil;
    }
    if (logPbDict == nil) {
        logPb = [logPb stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        error = nil;
        if (logPb) {
            logPbDict = [NSString tt_objectWithJSONString:logPb error:&error];
        }
        if (error || ![logPbDict isKindOfClass:[NSDictionary class]]) {
            logPbDict = nil;
        }
    }
    
    return logPbDict;
}

+ (NSString *)schemaTrackForPersonalHomeSchema:(NSString *)schema
                                  categoryName:(NSString *)category
                                      fromPage:(NSString *)from
                                       groupId:(NSString *)group
                                 profileUserId:(NSString *)profile {
    if (isEmptyString(schema)) {
        return schema;
    }
    NSString *result = schema;
    if (!isEmptyString(category)) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"&category_name=%@", category]];
    }
    
    if (!isEmptyString(group)) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"&group_id=%@", group]];
    }
    
    if (!isEmptyString(from)) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"&from_page=%@", from]];
    }
    
    if (!isEmptyString(profile)) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"&profile_user_id=%@", profile]];
    }
    return result;
}

@end
