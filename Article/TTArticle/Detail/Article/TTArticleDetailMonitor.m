//
//  TTArticleDetailMonitor.m
//  Article
//
//  Created by muhuai on 2017/7/30.
//
//

#import "TTArticleDetailMonitor.h"

@implementation TTArticleDetailMonitor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serverRequestStartTimeDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)initializeWebRequestTimeMonitor
{
    _webRequestStartTime = CACurrentMediaTime();
}

- (void)initializeServerRequestTimeMonitorWithName:(NSString *)apiName
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [_serverRequestStartTimeDict setValue:@(startTime) forKey:apiName];
}

- (NSString *)intervalFromWebRequestStartTime
{
    CFTimeInterval interval = _webRequestStartTime ? (CACurrentMediaTime() - _webRequestStartTime) * 1000.f : 0;
    //    LOGD(@"[webViewRequest]value: %.1f", interval);
    //过滤异常数据：非正数或大于100s则过滤
    if (interval <= 0 || interval > 100.f * 1000.f) {
        return nil;
    }
    else {
        return [NSString stringWithFormat:@"%.1f", interval];
    }
}

- (NSString *)intervalFromServerRequestStartTimeWithName:(NSString *)apiName
{
    CFTimeInterval startTime = (CFTimeInterval)[_serverRequestStartTimeDict floatValueForKey:apiName defaultValue:0];
    CFTimeInterval interval = startTime ? (CACurrentMediaTime() - startTime) * 1000.f : 0;
    //    LOGD(@"[%@]value: %.1f", apiName, interval);
    return [NSString stringWithFormat:@"%.1f", interval];
}

@end
