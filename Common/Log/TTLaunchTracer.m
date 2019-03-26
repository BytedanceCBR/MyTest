//
//  TTLaunchTracer.m
//  NewsLite
//
//  Created by leo on 2018/9/18.
//

#import "TTLaunchTracer.h"
#import "TTTracker.h"

@interface TTLaunchTracer ()
{
    BOOL _hasReportLaunch;
}
@end

@implementation TTLaunchTracer

static TTLaunchTracer* _instance;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TTLaunchTracer alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _hasReportLaunch = NO;
    }
    return self;
}

- (void)setLaunchFrom:(TTAppLaunchFrom)from {
    self.launchFromType = from;
}

- (void)writeEvent {

    // 仅第一次进程启动时出发上报
    if (_hasReportLaunch) {
        return;
    }
    _hasReportLaunch = YES;
    NSString* launchType = @"enter_launch";
    if (_launchFromType == TTAPPLaunchFromRemotePush) {
        launchType = @"click_news_notify";
    }
    NSMutableDictionary *params = @{@"gd_label": launchType,
                                    @"tips": @(_badgeNumber),
                                    @"event_type": @"house_app2c_v2"}.mutableCopy;
    [TTTracker eventV3:@"launch_log" params:params];
}

- (void)willEnterForeground {
    _hasReportLaunch = NO;
    _launchFromType = TTAPPLaunchFromBackground;
}

@end
