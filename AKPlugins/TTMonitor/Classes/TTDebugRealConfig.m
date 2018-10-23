//
//  TTDebugRealConfig.m
//  Pods
//
//  Created by 苏瑞强 on 2017/5/18.
//
//

#import "TTDebugRealConfig.h"

#define kMaxCacheSize @"kmaxCacheSize"
#define kMaxDBCacheSize @"kmaxDBCacheSize"
#define kMaxCacheAge @"kMaxCacheAge"
#define kStartTime @"kStartTime"
#define kEndTime @"kEndTime"
#define kSubmitType @"kSubmitType"
#define kNeedResponseContent @"kNeedNetResponse"
#define kOutdateTimestamp 3*24*60*60

@implementation TTDebugRealConfig

+ (instancetype)sharedInstance{
    {
        static TTDebugRealConfig *defaultRecorder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            defaultRecorder = [[[self class] alloc] init];
        });
        return defaultRecorder;
    }

}

- (void)configDataCollectPolicy : (NSDictionary *)params{
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.receiveUploadCommand = [[params valueForKey:@"should_submit_debugreal"] boolValue];
    self.startTime = [params valueForKey:kStartTime];
    if (!self.startTime) {
        NSTimeInterval timeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] - kOutdateTimestamp;
        NSString * dateStr = [[TTExtensions _dateformatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        self.startTime = dateStr;
    }
    self.endTime = [params valueForKey:kEndTime];
    if (!self.endTime) {
        NSTimeInterval launchTime = [[[NSUserDefaults standardUserDefaults] valueForKey:@"app_launch_timeinteval"] doubleValue];
        NSDate * endDate = [NSDate date];
        if (launchTime>0) {
            endDate = [NSDate dateWithTimeIntervalSince1970:launchTime];
        }
        NSString * dateNowStr = [[TTExtensions _dateformatter] stringFromDate:endDate];
        self.endTime = dateNowStr;
    }
    NSNumber * submitType = [params valueForKey:kSubmitType];
    if ([submitType isKindOfClass:[NSNumber class]]) {
        self.submitTypeFlags = [submitType integerValue];
    }
    
    self.needNetworkReponse = [[params valueForKey:kNeedResponseContent] boolValue];
    
}

-(void)setMaxCacheAge:(NSInteger)maxCacheAge{
    [[NSUserDefaults standardUserDefaults] setInteger:maxCacheAge forKey:kMaxCacheAge];
}

- (NSInteger)maxCacheAge{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kMaxCacheAge];
}

- (void)setMaxCacheSize:(NSInteger)maxCacheSize{
    [[NSUserDefaults standardUserDefaults] setInteger:maxCacheSize forKey:kMaxCacheSize];
}

- (long long)maxCacheSize{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kMaxCacheSize];
}

- (void)setMaxCacheDBSize:(NSInteger)maxCacheDBSize{
    [[NSUserDefaults standardUserDefaults] setInteger:maxCacheDBSize forKey:kMaxDBCacheSize];
}

- (NSInteger)maxCacheDBSize{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kMaxDBCacheSize];
}

@end
