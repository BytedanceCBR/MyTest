//
//  WDTrackerHelper.m
//  Pods
//
//  Created by wangqi.kaisa on 2017/9/13.
//
//

#import "WDTrackerHelper.h"
#import <TTBaseLib/TTBaseMacro.h>

@implementation WDTrackerHelper

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
    
    return result;
}

@end
