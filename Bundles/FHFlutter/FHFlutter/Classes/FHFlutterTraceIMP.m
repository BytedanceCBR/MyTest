//
//  FHFlutterTraceIMP.m
//  ABRInterface
//
//  Created by 谢飞 on 2020/9/20.
//

#import "FHFlutterTraceIMP.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>

@implementation FHFlutterTraceIMP

- (void)sendEvent:(NSString *)event label:(NSString *)label value:(id)value extValue:(id)extValue extValue2:(id)extValue2 dict:(NSDictionary *)aDict {
    NSMutableDictionary *pramsTotal = [NSMutableDictionary new];
    [pramsTotal setValue:@"house_app2c_v2" forKey:@"event_type"];
    if ([aDict isKindOfClass:[NSDictionary class]]) {
          [pramsTotal addEntriesFromDictionary:aDict];
    }
    
    [BDTrackerProtocol event:event label:label value:[value stringValue] extValue:[extValue stringValue] extValue2:nil dict:pramsTotal];
}

- (void)sendEventV3:(NSString *)eventName params:(NSDictionary *)params {
    NSMutableDictionary *pramsTotal = [NSMutableDictionary new];
    [pramsTotal setValue:@"house_app2c_v2" forKey:@"event_type"];
    
    if ([params isKindOfClass:[NSDictionary class]]) {
        [pramsTotal addEntriesFromDictionary:params];
    }
    [BDTrackerProtocol eventV3:eventName params:pramsTotal];
}

@end
