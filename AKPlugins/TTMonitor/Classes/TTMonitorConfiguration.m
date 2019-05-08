//
//  TTMonitorConfiguration.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/29.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTMonitorConfiguration.h"
#import "TTMonitor.h"
#import "TTExtensions.h"
#import "TTDeviceExtension.h"
#import "TTNetworkManager.h"
#import "TTDebugRealMonitorManager.h"
#import "TTDebugRealConfig.h"
#import "TTImageMonitorManager.h"

#define ttIsEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)

#define kPasswordKey @"astaxje12v98axljzmk1m.@hkjkljl;k"
#define kRemoteSettingsHost1 @"mon.snssdk.com"
#define kRemoteSettingsHost2 @"mon.toutiaocloud.com"
#define kRemoteSettingsHost3 @"mon.toutiaocloud.net"

#define kUploadHost @"mon.snssdk.com"

static NSDictionary * allowedServices;
static NSDictionary * allowedLogTypes;
static NSDictionary * allowedMetrics;
static NSArray * allowedImageHosts;
static dispatch_queue_t configs_queue;

@interface TTMonitorConfigurationAPIReportItem : NSObject

@property(nonatomic, strong)NSString * pattern;
@property(nonatomic, assign)float sampleRatio;
@property(nonatomic, strong)NSRegularExpression *regex;
@property(nonatomic, assign)NSTimeInterval latelyRecordErrorTimeInterval;
@end

@implementation TTMonitorConfigurationAPIReportItem

+(void) load{
    configs_queue = dispatch_queue_create("com.bytedance.monitorfig", DISPATCH_QUEUE_CONCURRENT);
}

- (id)initWithDict:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString * pat = [dict objectForKey:@"pattern"];
    if (!pat) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.pattern = pat;
        self.sampleRatio = [[dict valueForKey:@"sample_ratio"] floatValue];
        NSError *error;
        @try {
            self.regex = [NSRegularExpression
                          regularExpressionWithPattern:_pattern
                          options:0
                          error:&error];
            if (error) {
                self.regex = nil;
            }
        }
        @catch (NSException *exception) {
            self.regex = nil;
        }
        @finally {
        }
    }
    return self;
}

- (BOOL)isNeedSample
{
    float ratio =  ((float)(arc4random() % 10000) / (float)10000);
    if(ratio < _sampleRatio)
    {
        return YES;
    }
    return NO;
}

- (BOOL)isMatchForURL:(NSURL *)URL
{
    if (!_regex) {
        return NO;
    }
    NSString * host = URL.host;
    NSString * path = URL.path;
    NSString * sep = @"";
    if (!([host hasSuffix:@"/"] || [path hasPrefix:@"/"])) {
        sep = @"/";
    }
    NSString * matchStr = [NSString stringWithFormat:@"%@%@%@", host, sep, path];
    if (ttIsEmptyString(matchStr)) {
        return NO;
    }
    
    
    NSTextCheckingResult *match = nil;
    @try {
        match = [_regex firstMatchInString:matchStr
                                   options:0
                                     range:NSMakeRange(0, [matchStr length])];
    }
    @catch (NSException *exception) {
        match = nil;
    }
    @finally {
    }
    
    if (match) {
        return YES;
    }
    return NO;
}

- (void)updateLatelyRecordErrorTimeInterval
{
    self.latelyRecordErrorTimeInterval = [[NSDate date] timeIntervalSince1970];
}

@end

/////////////////////////////////////////////////

@interface TTMonitorConfiguration()
@property(nonatomic, strong)NSArray<TTMonitorConfigurationAPIReportItem *> * reportItems;
@property(nonatomic, assign)BOOL disableReportAPIError;
@property(nonatomic, assign)BOOL enableNetStats;
@property(nonatomic, strong)NSArray * remoteSettingsHost;
@property(nonatomic, copy, readwrite) NSString * appkey;
@property(nonatomic, copy, readwrite) TTMonitorParamsBlock paramsBlock;

@end

static TTMonitorConfiguration *s_manager;
@implementation TTMonitorConfiguration

+ (TTMonitorConfiguration *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[TTMonitorConfiguration alloc] init];
    });
    return s_manager;
}

-(NSInteger)networkStatus{
    if (_networkStatus == MNetworkStatusNone) {
        [self connectionChanged:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNetworkReachabilityChangedNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
    }
    return _networkStatus;
    
}

-(void)connectionChanged:(NSNotification *)notify{
        self.networkStatus = [TTExtensions networkStatus];
}

+ (NSDictionary *)monitorTrackAdditionalParameters
{
    //网络类型， 定义见：
    //https://wiki.bytedance.com/pages/viewpage.action?pageId=16450674
    int networkType = [TTExtensions networkStatus];
    return @{@"network_type" : @(networkType)};
}

+ (void)setEnabledValue:(id)value ForKey:(NSString *)queryKey{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:queryKey];
}

+ (double)queryActionIntervalForKey:(NSString *)queryKey{
    NSNumber * value = [[NSUserDefaults standardUserDefaults] valueForKey:queryKey];
    if (value && [value isKindOfClass:[NSNumber class]]) {
        return [value doubleValue];
    }
    return 120;//默认就是120s。
}

+ (BOOL)queryIfEnabledForKey:(NSString *)queryKey{
    return [self isEnabledForMetricsType:queryKey];
}

- (id)init
{
    self = [super init];
    if (self) {
        _networkStatus = MNetworkStatusNone;
        self.remoteSettingsHost = @[kRemoteSettingsHost1, kRemoteSettingsHost2, kRemoteSettingsHost3];
        NSArray * savedAPIReports = [TTMonitorConfiguration savedAPIReports];
        [self refreshReportItems:savedAPIReports];
        self.disableReportAPIError = [TTMonitorConfiguration disableReportError];
        self.enableNetStats = [TTMonitorConfiguration enableNetStat];
    }
    return self;
}

- (void)refreshReportItems:(NSArray *)ary
{
    @try {
        NSMutableArray<TTMonitorConfigurationAPIReportItem *> * reports = (NSMutableArray<TTMonitorConfigurationAPIReportItem *> *)[NSMutableArray arrayWithCapacity:10];
        for (NSDictionary * dict in ary) {
            TTMonitorConfigurationAPIReportItem * item = [[TTMonitorConfigurationAPIReportItem alloc] initWithDict:dict];
            if (item) {
                [reports addObject:item];
            }
        }
        self.reportItems = reports;
    }
    @catch (NSException *exception) {
        self.reportItems = nil;
    }
    @finally {
    }
}

+ (void)tryFetchConfigWithForce:(BOOL)force{
    TTMonitorConfiguration * configuration = (TTMonitorConfiguration *)[TTMonitorConfiguration shareManager];
    [configuration tryFetchConfigWithForce:force];
}
/**
 *  8小时内最多尝试获取一次，become activity的时候获取
 */
- (void)tryFetchConfigWithForce:(BOOL)force
{
    if (!force && ![TTMonitorConfiguration needUpdateConfigration]) {
#ifndef DEBUG
      return;
#endif
    }
    static NSUInteger tryTimes = 0;
    if (tryTimes>3) {
        tryTimes=0;
        //超过3次  不在继续请求，更新时间信息
        [TTMonitorConfiguration updateLatelyUpdateTimestamp];
        return;
    }

    NSString * baseUrl = [NSString stringWithFormat:@"http://%@", [self monitorUrlForTryTimes:tryTimes]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSURL * urlOrigin = [NSURL URLWithString:[TTMonitorConfiguration monitorURLForBaseURL:baseUrl]];
    NSURL * urlNew;
    if ([TTMonitor shareManager].urlTransformBlock) {
        urlNew = [[TTMonitor shareManager].urlTransformBlock(urlOrigin) copy];
    }else{
        urlNew = [urlOrigin copy];
    }
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:urlNew];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"close" forHTTPHeaderField:@"encrypt"];//告诉服务器不使用加密
    NSDictionary * reuqestParams = @{@"encrypt":@"close"};
    
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:[urlNew absoluteString] params:reuqestParams method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        if (!error) {
            if ([obj isKindOfClass:[NSData class]]) {
                @try {
                    NSDictionary * jsonValue = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingMutableContainers error:nil];
                    if ([jsonValue isKindOfClass:[NSDictionary class]]) {
                        [self dealResponse:jsonValue];
                    }
                } @catch (NSException *exception) {
                    tryTimes++;
                    [self tryFetchConfigWithForce:NO];
                } @finally {
                    
                }
            }else
            if([obj isKindOfClass:[NSDictionary class]]){
                [self dealResponse:obj];
            }
            tryTimes = 0;
        }else{
            tryTimes++;
            [self tryFetchConfigWithForce:NO];
        }
    }];
}

-(NSString *)monitorUrlForTryTimes:(NSUInteger)tryTime{
    tryTime = tryTime%3;
    return self.remoteSettingsHost[tryTime];
}


-(id)switchObjectForKey:(NSString *)key inDict:(NSDictionary *)dict{
    id obj = [dict valueForKey:key];
    if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    return nil;
}

- (void)dealResponse:(NSDictionary *)dict
{
    NSString * message = [dict valueForKey:@"message"];
    if (TTIsEmpty(message) || ![message isKindOfClass:[NSString class]] ||
        ![message isEqualToString:@"success"]) {
        return;
    }
    
    [TTMonitorConfiguration updateLatelyUpdateTimestamp];
    NSDictionary * data = [dict valueForKey:@"data"];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        if ([[data allKeys] containsObject:@"enable_net_stats"]) {
            id obj = [data valueForKey:@"enable_net_stats"];
            if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
                BOOL enable = [obj boolValue];
                [TTMonitorConfiguration setEnableNetStat:enable];
                self.enableNetStats = enable;
            }
        }
        
        if ([[data allKeys] containsObject:@"max_retry_count"]) {
            id obj = [data valueForKey:@"max_retry_count"];
             if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]])  {
                NSInteger count = [obj integerValue];
                [TTMonitorConfiguration saveMaxReportRetryCount:count];
            }
        }
        
        if ([[data allKeys] containsObject:@"once_max_count"]) {
            NSInteger count = [[self switchObjectForKey:@"once_max_count" inDict:data] integerValue];
            [TTMonitorConfiguration saveReportMaxLogCount:count];
        }
        
        if ([[data allKeys] containsObject:@"polling_interval"]) {
            NSInteger interval = [[self switchObjectForKey:@"polling_interval" inDict:data] integerValue];
            [TTMonitorConfiguration saveReportPollingInterval:interval];
        }
        
        if ([[data allKeys] containsObject:@"disable_report_error"]) {
            BOOL disable = [[self switchObjectForKey:@"disable_report_error" inDict:data] boolValue];
            [TTMonitorConfiguration setDisableReportError:disable];
            self.disableReportAPIError = disable;
        }
        
        if ([[data allKeys] containsObject:@"fetch_setting_interval"]) {
            NSInteger interval = [[self switchObjectForKey:@"fetch_setting_interval" inDict:data] integerValue];
            [TTMonitorConfiguration setUpdateDuration:interval];
        }
        
        if ([[data allKeys] containsObject:@"dns_report_interval"]) {
            double interval = [[self switchObjectForKey:@"dns_report_interval" inDict:data] doubleValue];
            [TTMonitorConfiguration saveDNSReportInterval:interval];
        }
        
        if ([[data allKeys] containsObject:@"dns_report_list"]) {
            NSArray * array = [data valueForKey:@"dns_report_list"];
            if (array && [array isKindOfClass:[NSArray class]]) {
             [TTMonitorConfiguration saveDNSReportList:array];
            }
        }
        
        if ([[data allKeys] containsObject:@"api_black_list"]) {
            NSArray * array = [data valueForKey:@"api_black_list"];
            if (array && [array isKindOfClass:[NSArray class]]) {
                [TTMonitorConfiguration saveBlackList:array];
            }
        }
        
        if ([[data allKeys] containsObject:@"debugreal_black_list"]) {
            NSArray * array = [data valueForKey:@"debugreal_black_list"];
            if (array && [array isKindOfClass:[NSArray class]]) {
                [TTMonitorConfiguration saveDebugRealBlackList:array];
            }
        }
        
        if ([[data allKeys] containsObject:@"more_channel_stop_interval"]) {
            [TTMonitorConfiguration setRetryIntervalIfAllHostFailed:[data valueForKey:@"more_channel_stop_interval"]];
        }

        
        if ([[data allKeys] containsObject:@"api_allow_list"]) {
            NSArray * array = [data valueForKey:@"api_allow_list"];
            if (array && [array isKindOfClass:[NSArray class]]) {
                [TTMonitorConfiguration saveWhiteList:array];
            }
        }
        
        if ([[data allKeys] containsObject:@"allow_log_type"]) {
            NSDictionary * obj = [data valueForKey:@"allow_log_type"];
            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
             [TTMonitorConfiguration saveAllowedLogTypes:obj];
            }
        }
        
        if ([[data allKeys] containsObject:@"allow_metric_type"]) {
            NSDictionary * obj = [data valueForKey:@"allow_metric_type"];
            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                [TTMonitorConfiguration saveAllowedMetricsTypes:obj];
            }
        }
        
        if ([[data allKeys] containsObject:@"allow_service_name"]) {
            NSDictionary * obj = [data valueForKey:@"allow_service_name"];
            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                [TTMonitorConfiguration saveAllowedServiceTypes:obj];
            }
        }
        
        if ([[data allKeys] containsObject:@"report_host_new"]) {
            NSArray * array = [data valueForKey:@"report_host_new"];
            if (array && [array isKindOfClass:[NSArray class]]) {
                NSMutableArray * result  = [NSMutableArray arrayWithCapacity:10];
                for (NSString * str in array) {
                    if (!TTIsEmpty(str)) {
                        NSString * tmpStr = nil;
                        if ([str hasPrefix:@"http://"] || [str hasPrefix:@"https://"]) {
                            tmpStr = str;
                        }
                        else {
                            tmpStr = [NSString stringWithFormat:@"http://%@", str];
                        }
                        [result addObject:tmpStr];
                    }
                }
                if ([result count] > 0) {
                    [TTMonitorConfiguration saveReportHosts:result];
                }
            }
        }
        
        NSArray * ary = [data valueForKey:@"api_report"];
        if (ary && [ary isKindOfClass:[NSArray class]] &&[ary count] > 0) {
            [self refreshReportItems:ary];
            [TTMonitorConfiguration saveAPIReport:ary];
        }
        
        if ([[data allKeys] containsObject:@"debugreal_max_age"]) {
            NSNumber * number = [data valueForKey:@"debugreal_max_age"];
            if ([number respondsToSelector:@selector(integerValue)]) {
                [[TTDebugRealConfig sharedInstance] setMaxCacheAge:[number integerValue]];
            }
        }

        if ([[data allKeys] containsObject:@"debugreal_max_cache_size"]) {
            NSNumber * number = [data valueForKey:@"debugreal_max_cache_size"];
            if ([number respondsToSelector:@selector(integerValue)]) {
                [[TTDebugRealConfig sharedInstance] setMaxCacheSize:[number integerValue]];
            }
        }
        
        if ([[data allKeys] containsObject:@"debugreal_max_db_cache_size"]) {
            NSNumber * number = [data valueForKey:@"debugreal_max_db_cache_size"];
            if ([number respondsToSelector:@selector(integerValue)]) {
                [[TTDebugRealConfig sharedInstance] setMaxCacheDBSize:[number integerValue]];
            }
        }
        
        if ([[data allKeys] containsObject:@"enable_encrypt"]) {
            [TTMonitorConfiguration setNeedEncrypt:[data valueForKey:@"enable_encrypt"]];
        }
        
        if ([[data allKeys] containsObject:@"image_allow_list"]) {
            [TTMonitorConfiguration saveAllowedImageHosts:[data valueForKey:@"image_allow_list"]];
        }
        
        if ([[data allKeys] containsObject:@"watchdog_monitor_length"]) {
            [TTMonitorConfiguration setWatchdogRecordLength:[data valueForKey:@"watchdog_monitor_length"]];
        }
        
        if ([[data allKeys] containsObject:@"watchdog_monitor_interval"]) {
            [TTMonitorConfiguration setWatchdogMonitorInterval:[data valueForKey:@"watchdog_monitor_interval"]];
        }
        
        if ([[data allKeys] containsObject:@"watchdog_monitor_threshold"]) {
            [TTMonitorConfiguration setWatchdogMonitorThreshold:[data valueForKey:@"watchdog_monitor_threshold"]];
        }
        
        if ([[data allKeys] containsObject:@"image_sample_interval"]) {
            NSNumber * number = [data valueForKey:@"image_sample_interval"];
            if ([number respondsToSelector:@selector(integerValue)]) {
                [TTImageMonitorManager sharedImageMonitor].pollingInterval = [number integerValue];
            }
        }
    }
}

+ (NSString *)monitorURLForBaseURL:(NSString *)baseUrl{
    NSString* newBaseUrl = [NSString stringWithFormat:@"%@/monitor/appmonitor/v2/settings", baseUrl];
    //+ (NSString*)URLString:(NSString *)URLStr appendCommonParams:(NSDictionary *)commonParams;
    NSDictionary * commonParams = [TTMonitorConfiguration httpHeaderParams];
    return [TTExtensions URLString:newBaseUrl appendCommonParams:commonParams];
}

#define kTTmonitorConfigurationLatelyUpdateTimestampKey @"kTTmonitorConfigurationLatelyUpdateTimestampKey"

//判断是否需要更新配置
+(BOOL)needUpdateConfigration
{
    NSTimeInterval latelyTimestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:kTTmonitorConfigurationLatelyUpdateTimestampKey] doubleValue];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if ((now - latelyTimestamp) > [self minUpdateDuration]) {
        return YES;
    }
    return NO;
}

/**
 *  更新最近更新配置时间
 */
+ (void)updateLatelyUpdateTimestamp
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setValue:@(now) forKey:kTTmonitorConfigurationLatelyUpdateTimestampKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#define kTTMonitorConfigurationUpdateDurationKey @"kTTMonitorConfigurationUpdateDurationKey"
/**
 *  设置最小的获取间隔
 *
 *  @param minDuration 单位秒
 */
+ (void)setUpdateDuration:(NSInteger)minDuration
{
    //1分钟以下，5天以上都认为是脏数据
    if (minDuration < (1 * 60) || minDuration > (5 * 24 * 60 * 60)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(minDuration) forKey:kTTMonitorConfigurationUpdateDurationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  获取最小的获取间隔
 *
 *  @return 最小的获取间隔
 */
+ (NSInteger)minUpdateDuration
{
    NSInteger duration = (NSInteger)[[[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationUpdateDurationKey] doubleValue];
    if (duration < (1 * 60) || duration > (5 * 24 * 60 * 60)) {
        duration = 10 * 60;
    }
    return duration;
}


#pragma mark -- config

#define kTTMonitorConfigurationReportHostsKey @"kTTMonitorConfigurationReportHostsKey"

/**
 *  存储上报host
 *
 *  @param ary 待上报的host的列表
 *
 *  @return YES：存储成功，NO:存储失败
 */
+ (BOOL)saveReportHosts:(NSArray *)ary
{
    if (!([ary isKindOfClass:[NSArray class]] && [ary count] > 0)) {
        return NO;
    }
    
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:[ary copy]];
    if (!data) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigurationReportHostsKey];
    BOOL success = [[NSUserDefaults standardUserDefaults] synchronize];
    if (!success) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTMonitorConfigurationReportHostsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return success;
}

+ (NSArray *)reportHosts
{
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationReportHostsKey];
    if (!data) {
        return nil;
    }
    NSArray * ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!([ary isKindOfClass:[NSArray class]] && [ary count] > 0)) {
        return @[@"http://mon.snssdk.com/monitor/collect/"];//默认值
    }
    return ary;
}

#define kTTMonitorConfigurationDNSReportListKey @"kTTMonitorConfigurationDNSReportListKey"

+(BOOL)saveDNSReportList:(NSArray *)ary{
    if (!([ary isKindOfClass:[NSArray class]] && [ary count] > 0)) {
        return NO;
    }
    
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:[ary copy]];
    if (!data) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigurationDNSReportListKey];
    BOOL success = [[NSUserDefaults standardUserDefaults] synchronize];
    if (!success) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTMonitorConfigurationDNSReportListKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return success;
}

+ (NSArray *)dnsReportList{
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationDNSReportListKey];
    if (!data) {
        return nil;
    }
    NSArray * ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return ary;
}

#define kTTMonitorConfigurationBlackListKey @"kTTMonitorConfigurationBlackListKey"
+(BOOL)saveBlackList:(NSArray *)ary{
    if (!([ary isKindOfClass:[NSArray class]] && [ary count] > 0)) {
        return NO;
    }
    
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:[ary copy]];
    if (!data) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigurationBlackListKey];
    BOOL success = [[NSUserDefaults standardUserDefaults] synchronize];
    if (!success) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTMonitorConfigurationBlackListKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return success;
}

+ (NSArray *)blackList{
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationBlackListKey];
    if (!data) {
        return nil;
    }
    NSArray * ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return ary;
}


#define kTTMonitorConfigurationWhiteListKey @"kTTMonitorConfigurationWhiteListKey"

+(BOOL)saveWhiteList:(NSArray *)ary{
    if (!([ary isKindOfClass:[NSArray class]] && [ary count] > 0)) {
        return NO;
    }
    
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:[ary copy]];
    if (!data) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigurationWhiteListKey];
    BOOL success = [[NSUserDefaults standardUserDefaults] synchronize];
    if (!success) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTMonitorConfigurationWhiteListKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return success;
}

+ (NSArray *)whiteList{
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationWhiteListKey];
    if (!data) {
        return nil;
    }
    NSArray * ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return ary;
}


#define kTTMonitorConfigurationDebugRealBlackListKey @"kTTMonitorConfigurationDebugRealBlackListKey"
+(BOOL)saveDebugRealBlackList:(NSArray *)ary{
    if (!([ary isKindOfClass:[NSArray class]] && [ary count] > 0)) {
        return NO;
    }
    
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:[ary copy]];
    if (!data) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigurationDebugRealBlackListKey];
    BOOL success = [[NSUserDefaults standardUserDefaults] synchronize];
    if (!success) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTMonitorConfigurationDebugRealBlackListKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return success;
}

+ (NSArray *)debugBlackList{
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationDebugRealBlackListKey];
    if (!data) {
        return nil;
    }
    NSArray * ary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return ary;
}

#define kTTMonitorConfigurationDNSReportIntervalKey @"kTTMonitorConfigurationDNSReportIntervalKey"

+ (double)dnsReportInterval
{
    double result = [[[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationDNSReportIntervalKey] doubleValue];
    return result;
}

+ (void)saveDNSReportInterval:(double)reportInterval
{
    [[NSUserDefaults standardUserDefaults] setValue:@(reportInterval) forKey:kTTMonitorConfigurationDNSReportIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#define kTTMonitorConfigurationMaxReportRetryCountKey @"kTTMonitorConfigurationMaxReportRetryCountKey"

+ (NSInteger)maxReportRetryCount
{
    NSInteger result = [[[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationMaxReportRetryCountKey] intValue];
    if (result > 10) {
        result = 10;
    }
    return result;
}

+ (void)saveMaxReportRetryCount:(NSInteger)retryCount
{
    if (retryCount > 10 || retryCount < 1) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(retryCount) forKey:kTTMonitorConfigurationMaxReportRetryCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#define kTTMonitorConfigurationOnceReportMaxLogCountKey @"kTTMonitorConfigurationOnceReportMaxLogCountKey"

+ (NSInteger)onceReportMaxLogCount
{
    NSInteger result = [[[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationOnceReportMaxLogCountKey] integerValue];
    if (result < 10 || result > 1000) {
        result = 100;
    }
    return result;
}

+ (void)saveReportMaxLogCount:(NSInteger)count
{
    if (count < 10 || count > 1000) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(count) forKey:kTTMonitorConfigurationOnceReportMaxLogCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#define kTTMonitorConfigurationReportPollingIntervalKey @"kTTMonitorConfigurationReportPollingIntervalKey"

+ (NSInteger)reportPollingInterval
{
    NSInteger result = [[[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationReportPollingIntervalKey] integerValue];
    if (result < 10 || result > 1000) {
        result = 120;
    }
    return result;
}

+ (void)saveReportPollingInterval:(NSInteger)interval
{
    if (interval < 10 || interval > 1000) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:@(interval) forKey:kTTMonitorConfigurationReportPollingIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#define kTTMonitorConfigutaionAPIReportsKey @"kTTMonitorConfigutaionAPIReportsKey"

+ (void)saveAPIReport:(NSArray *)apiReports
{
    if ([apiReports isKindOfClass:[NSArray class]] &&
        [apiReports count] > 0) {
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:apiReports];
        [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigutaionAPIReportsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *)savedAPIReports {
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigutaionAPIReportsKey];
    if (data) {
        NSArray * array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([array isKindOfClass:[NSArray class]] && [array count] > 0) {
            return array;
        }
    }
    return nil;
}

#pragma mark -- TTNetworkMonitorRecorderConfigurationProtocol

- (BOOL)isNeedSampleURL:(TTNetworkMonitorTransaction *)transaction {
    NSString * urlStr = transaction.request.URL.absoluteString;
    if (!urlStr) {
        return NO;
    }
    /**
     *  灰度的时候_reportItems遇到过为null，所以加上如下安全判断
     */
    if (![self.reportItems isKindOfClass:[NSArray class]]) {
        return NO;
    }
    for (TTMonitorConfigurationAPIReportItem * item in self.reportItems) {
        if ([item isNeedSample]) {
            if ([item isMatchForURL:[NSURL URLWithString:urlStr]]) {
                return YES;
                break;
            }
        }
    }
    return NO;
}

- (BOOL)_isContainedInBlackList:(TTNetworkMonitorTransaction *)transaction{
    NSArray * blackList = [TTMonitorConfiguration blackList];
    if (![blackList isKindOfClass:[NSArray class]]) {
        return NO;
    }
    if (!blackList || blackList.count<=0) {
        return NO;
    }
    if (transaction.requestUrl) {
        NSString * url = [transaction.requestUrl copy];
        if (!url || ![url isKindOfClass:[NSString class]]) {
            return NO;
        }
        for(NSString * blackUrl in blackList){
            if ([blackUrl isKindOfClass:[NSString class]]) {
                if ([url rangeOfString:blackUrl].location!=NSNotFound) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)isContainerInWhiteList:(TTNetworkMonitorTransaction *)transaction{
    NSArray * whiteList = [TTMonitorConfiguration whiteList];
    if (![whiteList isKindOfClass:[NSArray class]]) {
        return NO;
    }
    if (!whiteList || whiteList.count<=0) {
        return NO;
    }
    if (transaction.request.URL && [transaction.request.URL isKindOfClass:[NSURL class]]){
        NSString * url = [transaction.request.URL.absoluteString copy];
        if (!url || ![url isKindOfClass:[NSString class]]) {
            return NO;
        }
        for(NSString * whiteUrl in whiteList){
            if ([whiteUrl isKindOfClass:[NSString class]]) {
                if ([url rangeOfString:whiteUrl].location!=NSNotFound) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)debugRealItemContainedInBlackList:(TTNetworkMonitorTransaction *)transaction{
    if (![TTDebugRealMonitorManager sharedManager].enabled) {//如果开关关掉，视为所有都在黑名单里
        return YES;
    }
    NSArray * blackList = [TTMonitorConfiguration debugBlackList];
    if (![blackList isKindOfClass:[NSArray class]]) {
        return NO;
    }
    if (!blackList || blackList.count<=0) {
        return NO;
    }
    if (transaction.requestUrl) {
        NSString * url = [transaction.requestUrl copy];
        if (!url || ![url isKindOfClass:[NSString class]]) {
            return NO;
        }
        for(NSString * blackUrl in blackList){
            if ([blackUrl isKindOfClass:[NSString class]]) {
                if ([url rangeOfString:blackUrl].location!=NSNotFound) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)configAppKey:(NSString *)appkey paramBlock:(TTMonitorParamsBlock)aparamBlock{
    _appkey = appkey;
    _paramsBlock = aparamBlock;
}

- (NSDictionary *)params{
    if (!_params) {
        if (self.paramsBlock) {
            _params = self.paramsBlock();
        }
        return _params;
    }
    return _params;
}

- (BOOL)isNeedRecorderErrorURL:(TTNetworkMonitorTransaction *)transaction
{
    if (_disableReportAPIError) {
        return NO;
    }
    return YES;
}

- (BOOL)isNeedMonitorAllURL:(TTNetworkMonitorTransaction *)transaction{
    return _enableNetStats;
//    if (_enableNetStats) {
//        return YES;
//    }
//    return [self isContainerInWhiteList:transaction];
}

- (BOOL)isImageRequestUrl:(TTNetworkMonitorTransaction *)transaction{
    NSArray * allowedImageHosts = [TTMonitorConfiguration savedAllowedImageHosts];
    if (![allowedImageHosts isKindOfClass:[NSArray class]]) {
        return NO;
    }
    if (!allowedImageHosts || allowedImageHosts.count<=0) {
        return NO;
    }
    if (transaction.requestUrl) {
        NSString * url = [transaction.requestUrl copy];
        if (!url || ![url isKindOfClass:[NSString class]]) {
            return NO;
        }
        for(NSString * imageRequestHost in allowedImageHosts){
            if ([imageRequestHost isKindOfClass:[NSString class]]) {
                if ([url rangeOfString:imageRequestHost].location!=NSNotFound) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

#pragma mark -- report error

#define kTTMonitorConfigurationDisableReportErrorKey @"kTTMonitorConfigurationDisableReportErrorKey"

+ (BOOL)disableReportError
{
    NSObject * obj = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationDisableReportErrorKey];
    if (!obj) {
        return YES;//默认开启
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTMonitorConfigurationDisableReportErrorKey];
}

+ (void)setDisableReportError:(BOOL)disable
{
    [[NSUserDefaults standardUserDefaults] setValue:@(disable) forKey:kTTMonitorConfigurationDisableReportErrorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#define kTTMonitorConfigurationEnableNetStatKey @"kTTMonitorConfigurationEnableNetStatKey"

+ (BOOL)enableNetStat{
    NSObject * obj = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigurationEnableNetStatKey];
    if (!obj) {
        return NO;//默认不开启
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTMonitorConfigurationEnableNetStatKey];
}

+ (void)setEnableNetStat:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setValue:@(enable) forKey:kTTMonitorConfigurationEnableNetStatKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSMutableDictionary * s_headerParameter;

+ (NSDictionary *)httpHeaderParams{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:20];
        [result setValue:[[(TTMonitorConfiguration *)[TTMonitorConfiguration shareManager] params] valueForKey:@"install_id"] forKey:@"install_id"];
        NSString *deviceID = [[(TTMonitorConfiguration *)[TTMonitorConfiguration shareManager] params] valueForKey:@"device_id"];
        [result setValue:deviceID forKey:@"device_id"];
        [result setValue:[TTExtensions bundleIdentifier] forKey:@"package"];
        
        // ugly code : 版本号映射关系计算。同TTNetSerializer中逻辑，暂时为了解耦copy代码。后续整体干掉映射关系
//        [result setValue:[TTExtensions versionName] forKey:@"app_version"];
        NSString *curVersion = [TTExtensions versionName];
        NSArray<NSString *> *strArray = [curVersion componentsSeparatedByString:@"."];
        NSInteger version = 0;
        for (NSInteger i = 0; i < strArray.count; i += 1) {
            NSString *tmp = strArray[i];
            version = version * 10 + tmp.integerValue;
        }
        version += 600;
        NSMutableArray *newStrArray = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger i = 0; i < 2; i += 1) {
            NSInteger num = version % 10;
            version /= 10;
            NSString *tmp = [NSString stringWithFormat:@"%ld", num];
            [newStrArray addObject:tmp];
        }
        NSString *tmp = [NSString stringWithFormat:@"%ld",version];
        [newStrArray addObject:tmp];
        NSString *newVersion = [[newStrArray reverseObjectEnumerator].allObjects componentsJoinedByString:@"."];
        [result setValue:newVersion forKey:@"app_version"];

        [result setValue:[TTExtensions buildVersion] forKey:@"update_version_code"];
        [result setValue:[NSNumber numberWithBool:[TTExtensions isJailBroken]] forKey:@"is_jailbroken"];
        
        [result setValue:[TTExtensions connectMethodName] forKey:@"access"];
        [result setValue:@"iOS" forKey:@"os"];
        [result setValue:[TTExtensions appDisplayName] forKey:@"display_name"];
        [result setValue:[TTExtensions OSVersion] forKey:@"os_version"];
        [result setValue:[TTDeviceExtension platformString] forKey:@"device_model"];
        [result setValue:[TTExtensions currentLanguage] forKey:@"language"];
        [result setValue:[TTExtensions openUDID] forKey:@"openudid"];
        [result setValue:[(TTMonitorConfiguration *)[TTMonitorConfiguration shareManager] appkey] forKey:@"appkey"];
       [result setValue:[TTExtensions getCurrentChannel] forKey:@"channel"];
        [result setValue:[TTExtensions ssAppID] forKey:@"aid"];
        NSInteger millisecondsFromGMT =  [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
        [result setValue:@(millisecondsFromGMT) forKey:@"timezone"];
        
        if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
            NSString *vUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [result setValue:vUDID forKey:@"vid"];
            [result setValue:vUDID forKey:@"vendor_id"];
        }
        [result setValue:@"close" forKey:@"encrypt"];//告诉服务器不使用加密
        // idfa
        [result setValue:[TTExtensions idfaString] forKey:@"idfa"];
        [result setValue:[TTExtensions userAgentString] forKey:@"user_agent"];
        [result setValue:[TTExtensions resolutionString] forKey:@"resolution"];
        s_headerParameter = [result copy];
    });
    return s_headerParameter;
}

#define kTTMonitorConfigutaionAllowedLogTypesKey @"kTTMonitorConfigutaionAllowedLogTypesKey"

+ (void)saveAllowedLogTypes:(NSDictionary *)aallowedLogTypes
{
    dispatch_async(configs_queue, ^{
        if ([allowedLogTypes isKindOfClass:[NSDictionary class]] &&
            [allowedLogTypes count] > 0) {
            NSData * data = [NSKeyedArchiver archivedDataWithRootObject:allowedLogTypes];
            [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigutaionAllowedLogTypesKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        allowedLogTypes = [aallowedLogTypes copy];
    });
}

+ (NSDictionary *)savedAllowedLogTypes {
    __block NSDictionary * localAllowedLogTypes;
    dispatch_sync(configs_queue, ^{
        if (allowedLogTypes) {
            localAllowedLogTypes = allowedLogTypes;
        }else{
            NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigutaionAllowedLogTypesKey];
            if (data) {
                NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
                    allowedLogTypes = [dict copy];
                    localAllowedLogTypes = allowedLogTypes;
                }
            }
        }
    });
    return localAllowedLogTypes;
}

#define kTTMonitorConfigutaionAllowedMeTricsTypesKey @"kTTMonitorConfigutaionAllowedMeTricsTypesKey"

+ (void)saveAllowedMetricsTypes:(NSDictionary *)allowedMericsType
{
    dispatch_barrier_async(configs_queue, ^{
        if ([allowedMericsType isKindOfClass:[NSDictionary class]] &&
            [allowedMericsType count] > 0) {
            NSData * data = [NSKeyedArchiver archivedDataWithRootObject:allowedMericsType];
            [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigutaionAllowedMeTricsTypesKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (allowedMetrics) {
            allowedMetrics = [allowedMericsType copy];
        }
    });
}

+ (NSDictionary *)savedAllowedMetricsTypes {
    __block NSDictionary * localAlloedMetrics;
    dispatch_sync(configs_queue, ^{
        if (allowedMetrics) {
            localAlloedMetrics = allowedMetrics;
        }else{
            NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigutaionAllowedMeTricsTypesKey];
            if (data) {
                NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
                    allowedMetrics = [dict copy];
                    localAlloedMetrics = allowedMetrics;
                }
            }
        }
    });
    return localAlloedMetrics;
}

#define kTTMonitorConfigutaionAllowedImageHostsKey @"kTTMonitorConfigutaionAllowedImageHostsKey"

+ (void)saveAllowedImageHosts:(NSArray *)allowedMericsType
{
    if ([allowedMericsType isKindOfClass:[NSArray class]]) {
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:allowedMericsType];
        [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigutaionAllowedImageHostsKey];
    }
}

+ (NSArray *)savedAllowedImageHosts {
    NSData * data = [[NSUserDefaults standardUserDefaults] valueForKey:kTTMonitorConfigutaionAllowedImageHostsKey];
    if (data) {
        NSArray * imageHostLists = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([imageHostLists isKindOfClass:[NSArray class]] && [imageHostLists count] > 0) {
            return imageHostLists;
        }
    }
    return nil;
}

#define kTTMonitorConfigutaionAllowedServiceKey @"kTTMonitorConfigutaionAllowedServiceKey"

+ (void)saveAllowedServiceTypes:(NSDictionary *)allowedServiceTypes
{
    dispatch_barrier_async(configs_queue, ^{
        if ([allowedServiceTypes isKindOfClass:[NSDictionary class]] &&
            [allowedServiceTypes count] > 0) {
            NSData * data = [NSKeyedArchiver archivedDataWithRootObject:allowedServiceTypes];
            [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTMonitorConfigutaionAllowedServiceKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (allowedServiceTypes && allowedServices) {
            allowedServices = [allowedServiceTypes copy];
        }
    });
}

+ (NSDictionary *)savedAllowedServiceTypes {
    __block NSDictionary * localAllowedService;
    dispatch_sync(configs_queue, ^{
        if (allowedServices) {
            localAllowedService = allowedServices;
        }else{
            NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorConfigutaionAllowedServiceKey];
            if (data) {
                NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
                    allowedServices = [dict copy];
                    localAllowedService = allowedServices;
                }
            }
        }
    });
    return localAllowedService;
}

+ (BOOL)isEnabledForLogType:(NSString *)logType{
    NSDictionary * dict = [self savedAllowedLogTypes];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        return [[dict valueForKey:logType] boolValue];
    }
    return NO;
}

+ (BOOL)isEnabledForMetricsType:(NSString *)logType{
    NSDictionary * dict = [self savedAllowedMetricsTypes];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        return [[dict valueForKey:logType] boolValue];
    }
    return NO;
}

+ (BOOL)isEnabledForServiceType:(NSString *)logType{
    NSDictionary * dict = [self savedAllowedServiceTypes];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        return [[dict valueForKey:logType] boolValue];
    }
    return NO;
}

#define kRetryIntervalIfAllHostFailedServiceKey @"kRetryIntervalIfAllHostFailedServiceKey"
+(void)setRetryIntervalIfAllHostFailed:(NSNumber *)value{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:kRetryIntervalIfAllHostFailedServiceKey];
}

+ (double)retryIntervalIfAllHostFailed{
    NSInteger result;
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:kRetryIntervalIfAllHostFailedServiceKey];
    if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
        result = [obj doubleValue];
    }
    if (result <=0) {
        result = 30*60;
    }
    return result;
}

#define kNeedEncryptKey @"kNeedEncryptKey"
+ (BOOL)needEncrypt{
    NSObject * obj = [[NSUserDefaults standardUserDefaults] objectForKey:kNeedEncryptKey];
    if (!obj) {
        return YES;//默认开启
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNeedEncryptKey];
}

+(void)setNeedEncrypt:(NSNumber *)value{
    if (![value isKindOfClass:[NSNumber class]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:[value boolValue] forKey:kNeedEncryptKey];
}

#define kWatchdogMonitorLengthKey @"kWatchdogMonitorLengthKey"
+ (double)watchdogRecordLength {
    NSObject *obj = [[NSUserDefaults standardUserDefaults] objectForKey:kWatchdogMonitorLengthKey];
    if (!obj || ![obj isKindOfClass:[NSNumber class]]) {
        return 120;
    }
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kWatchdogMonitorLengthKey];
}

+ (void)setWatchdogRecordLength:(NSNumber *)value {
    if (![value isKindOfClass:[NSNumber class]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setDouble:[value doubleValue] forKey:kWatchdogMonitorLengthKey];
}

#define kWatchdogMonitorIntervalKey @"kWatchdogMonitorIntervalKey"
+ (double)watchdogMonitorInterval {
    NSObject *obj = [[NSUserDefaults standardUserDefaults] objectForKey:kWatchdogMonitorIntervalKey];
    if (!obj || ![obj isKindOfClass:[NSNumber class]]) {
        return 1.0;
    }
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kWatchdogMonitorIntervalKey];
}

+ (void)setWatchdogMonitorInterval:(NSNumber *)value {
    if (![value isKindOfClass:[NSNumber class]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setDouble:[value doubleValue] forKey:kWatchdogMonitorIntervalKey];
}

#define kWatchdogMonitorThresholdKey @"kWatchdogMonitorThresholdKey"
+ (double)watchdogMonitorThreshold {
    NSObject *obj = [[NSUserDefaults standardUserDefaults] objectForKey:kWatchdogMonitorThresholdKey];
    if (!obj || ![obj isKindOfClass:[NSNumber class]]) {
        return 1.0;
    }
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kWatchdogMonitorThresholdKey];
}

+ (void)setWatchdogMonitorThreshold:(NSNumber *)value {
    if (![value isKindOfClass:[NSNumber class]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setDouble:[value doubleValue] forKey:kWatchdogMonitorThresholdKey];
}

@end
