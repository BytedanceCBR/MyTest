//
//  TTAdAppDownloadManagerStayPageTracker.m
//  Article
//
//  Created by rongyingjie on 2017/7/10.
//
//

#import <Foundation/Foundation.h>
#import "TTAdAppDownloadManagerStayPageTracker.h"

@implementation TTAdAppDownloadManagerStayPageTracker

+ (void)load
{
    [TTAdAppDownloadManager sharedManager].stay_page_traker = [self sharedInstance];
}
// 这个方法没有暴露。。。
+ (instancetype)sharedInstance{
    static TTAdAppDownloadManagerStayPageTracker *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)startStayTracker
{
    if (_startTime == 0) {
        self.startTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)endStayTrackerWithAd_id:(NSString *)ad_id log_extra:(NSString *)log_extra
{
    if (_startTime == 0 || isEmptyString(ad_id)) {
        return;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    double duration = now - _startTime;
    self.startTime = 0;
    if (duration < 0 || duration > 7200) {
        return;
    }
    
    if (!isEmptyString(ad_id)) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"wap_stat" forKey:@"category"];
        [dict setValue:@"stay_page" forKey:@"tag"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        // 转换成毫秒
        [dict setValue:ad_id forKey:@"value"];
        [dict setValue:[NSString stringWithFormat:@"%.0f", duration*1000] forKey:@"ext_value"];
        [dict setValue:log_extra forKey:@"log_extra"];
        
        [TTTrackerWrapper eventData:dict];
    }
}

@end
