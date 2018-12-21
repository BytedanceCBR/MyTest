//
//  FHEnvContext.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHEnvContext.h"
#import "TTTrackerWrapper.h"
#import "FHUtils.h"

@implementation FHEnvContext

+ (instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

+ (void)recordEvent:(NSDictionary *)params andKey:(NSString *)traceKey
{
    if (kIsNSString(traceKey) && kIsNSDictionary(params)) {
        NSMutableDictionary *pramsDict = [[NSMutableDictionary alloc] initWithDictionary:params];
        pramsDict[@"event_type"] = @"house_app2c_v2";
        [TTTrackerWrapper eventV3:traceKey params:pramsDict];
    }
}

- (void)setTraceValue:(NSString *)value forKey:(NSString *)key
{
    
    
    
}

+ (NSString *)getCurrentUserDeaultCityName
{
    return [FHUtils contentForKey:kUserDefaultCityName];
}

+ (void)setCurrentUserDeaultCityName:(NSString *)cityName
{
    [FHUtils setContent:cityName forKey:kUserDefaultCityName];
}

- (FHClient *)_client
{
    if (!_client) {
        _client = [FHClient new];
    }
    return _client;
}
@end
