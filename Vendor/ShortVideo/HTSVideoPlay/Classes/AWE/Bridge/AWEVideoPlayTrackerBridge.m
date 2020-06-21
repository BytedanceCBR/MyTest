//
//  AWEVideoPlayTrackerBridge.m
//  Pods
//
//  Created by lili.01 on 18/11/2016.
//
//

#import "AWEVideoPlayTrackerBridge.h"
#import "TTBaseMacro.h"
#import <TTPlatformBaseLib/TTTrackerWrapper.h>

@implementation AWEVideoPlayTrackerBridge

+ (void)trackEvent:(NSString *)event params:(NSDictionary *)params
{
    NSMutableDictionary *moduleParams = [NSMutableDictionary new];
    [moduleParams setValue:event forKey:@"event"];
    NSMutableDictionary *mutParams = [NSMutableDictionary dictionaryWithDictionary:params];

//    if (![params[@"event_type"] isEqualToString:@"house_app2c_v2"])
//    {
//        [mutParams setValue:@88 forKey:@"demand_id"];
//    }
    NSMutableArray *needRemoveKeys = [NSMutableArray array];
    for (id key in mutParams.allKeys) {
        id value = mutParams[key];
        if ([value isKindOfClass:[NSString class]]) {
            NSString *valueStr = (NSString *)value;
            if (valueStr.length == 0) {
                [needRemoveKeys addObject:key];
            }
        }
    }
    [mutParams removeObjectsForKeys:needRemoveKeys];
    
    [moduleParams setValue:[mutParams copy] forKey:@"params"];
    [TTTrackerWrapper eventV3:event params:[mutParams copy]];
}

@end
