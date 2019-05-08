//
//  TTAdMonitorManager.m
//  Article
//
//  Created by yin on 2016/11/18.
//
//

#import "TTAdMonitorManager.h"
#import <TTBaseLib/TTBaseMacro.h>

@interface TTAdMonitorManager ()<TTAppStoreProtocol>
@end

static NSMutableDictionary * _intervalDict;

@implementation TTAdMonitorManager

Singleton_Implementation(TTAdMonitorManager)

+ (void)load
{
    [[SSAppStore shareInstance] registerService:[TTAdMonitorManager sharedManager]];
}

+ (NSMutableDictionary *)intervalDict {
    if (!_intervalDict) {
        _intervalDict = @{}.mutableCopy;
    }
    return _intervalDict;
}

+ (void)trackService:(NSString *)serviceName value:(id)value extra:(NSDictionary *)extra
{
    [[TTMonitor shareManager] trackService:serviceName value:value extra:extra];
}

+ (void)trackService:(NSString *)serviceName status:(NSUInteger)status extra:(NSDictionary *)extra
{
    [[TTMonitor shareManager] trackService:serviceName status:status extra:extra];
}

+ (void)trackAdException:(NSDictionary*)dict
{
    if (dict&&[dict isKindOfClass:[NSDictionary class]]) {
        NSString* log_extra = dict[@"log_extra"];
        NSString* value = [NSString stringWithFormat:@"%@", dict[@"value"]];
        if (![log_extra isKindOfClass:[NSString class]]) {
            return;
        }
        if (log_extra != nil) {
            if ([log_extra isEqualToString:@""]) {
                [[TTMonitor shareManager] trackService:@"ad_idlog_error" status:1 extra:dict];
            }
            else if (value.longLongValue==0||value.longLongValue==1||value.longLongValue==-1)
            {
                [[TTMonitor shareManager] trackService:@"ad_idlog_error" status:2 extra:dict];
            }
        }

    }
}

+ (void)beginTrackIntervalService:(NSString *)serviceName {
    double begin = CACurrentMediaTime();
    [[self intervalDict] setValue:@(begin) forKey:serviceName];
}

+ (void)endTrackIntervalService:(NSString *)serviceName extra:(NSDictionary *)extra {
    if (isEmptyString(serviceName)) {
        return;
    }
    if ([[self intervalDict] objectForKey:serviceName] == nil) {
        return;
    }
    double begin = [[[self intervalDict] objectForKey:serviceName] doubleValue];
    double end = CACurrentMediaTime();
    NSInteger elapse = (NSInteger)((end - begin) * 1000);
    if (elapse > 0) {
       [[TTMonitor shareManager] trackService:serviceName value:@(elapse) extra:extra];
    }
    [[self intervalDict] removeObjectForKey:serviceName];
}

+ (void)trackServiceCount:(NSString *)serviceName adId:(NSString *)adId logExtra:(NSString *)log_extra extValue:(NSDictionary*)extValue
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:adId forKey:serviceName];
    NSMutableDictionary* extraDict = [NSMutableDictionary dictionary];
    [extraDict addEntriesFromDictionary:extValue];
    [extraDict setValue:log_extra forKey:@"log_extra"];
    [[TTMonitor shareManager] trackService:@"ad_monitor_count" value:dict extra:extraDict];
}


#pragma mark  TTAppStoreProtocol

- (void)appStoreDidAppear:(UIViewController *)viewController
{
    [TTAdMonitorManager beginTrackIntervalService:@"tt_ad_appstore"];
}

- (void)appStoreLoad:(BOOL)result error:(NSError *)error appleId:(NSString *)appleId
{
    if (error && error.code != 0) {
        NSMutableDictionary *extra = @{}.mutableCopy;
        [extra setValue:appleId forKey:@"appleID"];
        [TTAdMonitorManager trackService:@"ad_appstore_loadfail" status:1 extra:extra];
    } else {
        [TTAdMonitorManager endTrackIntervalService:@"tt_ad_appstore" extra:nil];
    }
}

@end
