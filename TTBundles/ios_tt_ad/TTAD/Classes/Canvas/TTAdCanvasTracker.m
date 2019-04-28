//
//  TTAdCanvasTracker.m
//  Article
//
//  Created by carl on 2017/5/17.
//
//

#import "TTAdCanvasTracker.h"

#import "TTAdCommonUtil.h"
#import "TTAdTrackManager.h"
#import "TTTrackerProxy.h"
#import "TTTrackerWrapper.h"

@interface TTAdCanvasTracker ()
@property (nonatomic, strong) NSDate *startDateStamp;
@property (nonatomic, strong) NSDate *loadStamp;
@property (nonatomic, copy) NSString *group_id;
@property (nonatomic, strong) id<TTAd> model;
@end

@implementation TTAdCanvasTracker

+ (instancetype)tracker:(id<TTAd>)model {
    TTAdCanvasTracker *tracker = [[TTAdCanvasTracker alloc] init];
    tracker.startDateStamp = [NSDate date];
    tracker.model = model;
    return tracker;
}

- (void)native_page {
    
    NSMutableDictionary* events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:@"detail_immersion_ad" forKey:@"tag"];
    [events setValue:@"native_page" forKey:@"label"];
    
    [events setValue:self.model.ad_id forKey:@"value"];
    [events setValue:self.model.log_extra forKey:@"log_extra"];
    
    NSTimeInterval duration_s = [[NSDate date] timeIntervalSinceDate:self.startDateStamp];
    NSInteger duration_ms = (NSInteger)(duration_s * 1000);
    [events setValue:@(duration_ms) forKey:@"duration"];
    
    [[self class] ad_logEvent:events];
}

- (void)wap_staypage {
    
    NSMutableDictionary* events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events setValue:@"wap_stat" forKey:@"category"];
    [events setValue:@"ad_wap_stat" forKey:@"label"];
    [events setValue:@"stay_page" forKey:@"tag"];
    
    [events setValue:self.model.ad_id forKey:@"value"];
    [events setValue:self.model.log_extra forKey:@"log_extra"];
    
    NSTimeInterval duration_s = [[NSDate date] timeIntervalSinceDate:self.loadStamp];
    NSInteger duration_ms = (NSInteger)(duration_s * 1000);
    [events setValue:@(duration_ms) forKey:@"ext_value"];
    
    [[self class] ad_logEvent:events];
}

- (void)wap_load {
   
    self.loadStamp = [NSDate date];
    
    NSMutableDictionary *events = [NSMutableDictionary dictionary];
    
    [events setValue:@"wap_stat" forKey:@"category"];
    [events setValue:@"ad_wap_stat" forKey:@"label"];
    [events setValue:@"load" forKey:@"tag"];
    
    [events setValue:self.model.ad_id forKey:@"value"];
    [events setValue:self.model.log_extra forKey:@"log_extra"];
    [events setValue:self.group_id forKey:@"ext_value"];
    
    NSTimeInterval duration_s = [[NSDate date] timeIntervalSinceDate:self.startDateStamp];
    NSInteger duration_ms = (NSInteger)(duration_s * 1000);
    [events setValue:@(duration_ms) forKey:@"load_time"];
    
    [[self class] ad_logEvent:events];
}

- (void)wap_loadfinish {
    NSMutableDictionary *events = [NSMutableDictionary dictionary];
    [events setValue:@"wap_stat" forKey:@"category"];
    [events setValue:@"ad_wap_stat" forKey:@"label"];
    [events setValue:@"load_finish" forKey:@"tag"];
    
    [events setValue:self.model.ad_id forKey:@"value"];
    [events setValue:self.model.log_extra forKey:@"log_extra"];
    [events setValue:self.group_id forKey:@"ext_value"];
    
    NSTimeInterval duration_s = [[NSDate date] timeIntervalSinceDate:self.startDateStamp];
    NSInteger duration_ms = (NSInteger)(duration_s * 1000);
    [events setValue:@(duration_ms) forKey:@"load_time"];
   
    [[self class] ad_logEvent:events];
}

- (void)wap_loadfail {
   
    NSMutableDictionary *events = [NSMutableDictionary dictionary];
    
    [events setValue:@"wap_stat" forKey:@"category"];
    [events setValue:@"ad_wap_stat" forKey:@"label"];
    [events setValue:@"load_fail" forKey:@"tag"];
    
    [events setValue:self.model.ad_id forKey:@"value"];
    [events setValue:self.model.log_extra forKey:@"log_extra"];
    [events setValue:self.group_id forKey:@"ext_value"];
    
    NSTimeInterval duration_s = [[NSDate date] timeIntervalSinceDate:self.startDateStamp];
    NSInteger duration_ms = (NSInteger)(duration_s * 1000);
    [events setValue:@(duration_ms) forKey:@"load_time"];
    
    [[self class] ad_logEvent:events];
}

- (void)trackLeave
{
    NSMutableDictionary* dict = @{}.mutableCopy;
    
    NSTimeInterval duration_s = [[NSDate date] timeIntervalSinceDate:self.loadStamp];
    NSInteger duration_ms = (NSInteger)(duration_s * 1000);
    [dict setValue:@(duration_ms) forKey:@"duration"];
    [self trackCanvasTag:@"detail_immersion_ad" label:@"close_detail" dict:dict];
}

+ (void)ad_logEvent:(NSDictionary *)dict {
    NSParameterAssert(dict != nil && [dict isKindOfClass:[NSDictionary class]]);
    
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events addEntriesFromDictionary:dict];
    
    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];

    [TTTrackerWrapper eventData:events];
}

#pragma mark -- track

- (void)trackCanvasTag:(NSString*)tag label:(NSString*)label dict:(NSDictionary*)dict
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dictionary setValue:self.model.log_extra forKey:@"log_extra"];
    [dictionary setValue:@(connectionType) forKey:@"nt"];
    [dictionary setValue:@"1" forKey:@"is_ad_event"];
    
    [TTAdTrackManager trackWithTag:tag label:label value:self.model.ad_id extraDic:dictionary];
}

+ (void)trackerWithModel:(id<TTAd>)model tag:(NSString*)tag label:(NSString*)label extra:(NSDictionary*)extra {
    if (!model) {
        return;
    }
    
    NSParameterAssert(tag != nil);
    NSParameterAssert(label != nil);
    NSParameterAssert([model conformsToProtocol:@protocol(TTAd)]);
    
    if (![model conformsToProtocol:@protocol(TTAd)]) {
        return;
    }
    
    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    [events setValue:model.ad_id forKey:@"value"];
    [events setValue:model.log_extra forKey:@"log_extra"];
    
    if (extra) {
        [events addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:events];
}

- (void)trackCanvasRN:(NSDictionary *)dict
{
    [[self class] ad_logEvent:dict];
}

@end
