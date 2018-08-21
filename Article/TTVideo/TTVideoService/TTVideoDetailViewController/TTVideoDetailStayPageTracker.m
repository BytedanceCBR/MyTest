//
//  TTVideoDetailStayPageTracker.m
//  Article
//
//  Created by 刘廷勇 on 16/5/4.
//
//

#import "TTVideoDetailStayPageTracker.h"
#import <TTTracker/TTTrackerProxy.h>

static NSInteger const vaildStayPageMinInterval = 0;
static NSInteger const vaildStayPageMaxInterval = 7200;


@interface TTVideoDetailStayPageTracker ()

@property (nonatomic, assign) NSTimeInterval     startTime;

@end
@implementation TTVideoDetailStayPageTracker


- (instancetype)initWithUniqueID:(int64_t)uniqueID
                      clickLabel:(NSString *)clickLabel
{
    self = [super init];
    if (self) {
        _clickLabel = clickLabel;
        _uniqueID = uniqueID;
    }
    return self;
}
- (void)startStayTrack
{
    if (_startTime == 0 && _uniqueID > 0) {
        _startTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)endStayTrackWithDict:(NSDictionary *)event3Dict
{
    if (_startTime == 0 || _uniqueID == 0) {
        return;
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    double duration = now - _startTime;
    self.startTime = 0;
    if (duration < vaildStayPageMinInterval || duration > vaildStayPageMaxInterval) {
        return;
    }
    [event3Dict setValue:[NSString stringWithFormat:@"%.0f",duration*1000] forKey:@"stay_time"];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[@(_uniqueID) stringValue] forKey:@"value"];

    [dict setValue:@(duration) forKey:@"ext_value"];
    [dict setValue:@"video" forKey:@"page_type"];
    if ([event3Dict.allKeys containsObject:@"item_id"]) {
        [dict setValue:[event3Dict valueForKey:@"item_id" ] forKey:@"item_id"];
    }
    if ([event3Dict.allKeys containsObject:@"aggr_tye"]) {
        [dict setValue:[event3Dict valueForKey:@"aggr_type"] forKey:@"aggr_type"];
    }
    if ([event3Dict.allKeys containsObject:@"log_extra"]) {
        [dict setValue:[event3Dict valueForKey:@"log_extra"] forKey:@"log_extra"];
    }
    if (self.viewIsAppear) {
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTrackerWrapper category:@"umeng"
                      event:@"stay_page"
                      label:_clickLabel
                       dict:dict];
        }
        
        [TTTrackerWrapper eventV3:@"stay_page" params:event3Dict isDoubleSending:YES];
    }
}

- (void)sendFullStayPageWithADId:(NSString *)ad_id logExtra:(NSString *)logExtra
{
    //如果是广告再上报一个广告的埋点
    //需求 https://wiki.bytedance.net/pages/viewpage.action?pageId=89884456
    if (_startTime == 0 || isEmptyString(ad_id)) {
        return;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    double duration = now - _startTime;

    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:ad_id forKey:@"value"];
    [dictionary setValue:@"wap_stat" forKey:@"category"];
    [dictionary setValue:@"full_stay_page" forKey:@"tag"];
    [dictionary setValue:@(duration) forKey:@"ext_value"];
    [dictionary setValue:logExtra forKey:@"log_extra"];
    [dictionary setValue:@"1" forKey:@"is_ad_event"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dictionary setValue:@(connectionType) forKey:@"nt"];
    
    if (self.viewIsAppear) {
        [TTTrackerWrapper eventData:dictionary];
    }
}

/**
 *  返回当前阅读时间
 */
- (float)currentStayDuration
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    double duration = now - _startTime;
    duration = MAX(MIN(duration, vaildStayPageMaxInterval), vaildStayPageMinInterval);
    return (float)duration*1000;
}

@end
