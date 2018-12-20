//
//  FHUserTracker.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHUserTracker.h"
#import <TTTracker.h>

@implementation FHUserTracker

+(NSDictionary *)basicParam
{
    // ["event_type": "house_app2c_v2"]
    return @{@"event_type":@"house_app2c_v2"};
}

+(void)writeEvent:(NSString *)event params:(NSDictionary *)param
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:param];
    [params addEntriesFromDictionary:[self basicParam]];
    [TTTracker eventV3:event params:params];;
}

+(void)writeEvent:(NSString *)event withModel:(FHTracerModel *_Nullable)model
{
    if (event.length == 0) {
        return;
    }    
    NSMutableDictionary *param = [model logDict];
    [param addEntriesFromDictionary:[self basicParam]];
    [TTTracker eventV3:event params:param];
    
}

@end
