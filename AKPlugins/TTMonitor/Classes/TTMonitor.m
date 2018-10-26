//
//  TTMonitor.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/28.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTMonitor.h"
#import "TTMonitorTracker.h"
#import "TTMonitorLogPackagerProtocol.h"
#import "TTMonitorReporter.h"
#import "TTMonitorAggregater.h"
#import "TTMonitorTrackItem.h"
#import "TTMonitorAggregateItem.h"
#import "TTMonitorStoreItem.h"
#import "TTNetworkMonitorRecorder.h"
#import "TTMonitorConfiguration.h"
#import "TTNetworkMonitorManager.h"
#import "TTMonitorLogPackager.h"
#import "TTSystemMonitorManager.h"
#import "TTNetworkManagerMonitorNotifier.h"
#import "TTMonitorPersistenceStore.h"
#import "TTDebugRealMonitorManager.h"
#import "TTDebugRealStorgeService.h"
#import "TTImageMonitorManager.h"
#import "TTMonitorReporterResponse.h"
#import "TTMemoryUsageMonitorRecorder.h"
#import "TTMonitorFileUploader.h"
#import "HMDTTMonitor.h"
#import "TTSandBoxHelper.h"

@interface TTMonitor()
{
    NSUInteger _flushInterval;
    NSUInteger _latelyFlushInterval;
}

@property (nonatomic, assign) BOOL inBackGroundMode;
@property (nonatomic, strong)TTMonitorAggregater * aggregater;
@property (nonatomic, strong)TTMonitorTracker * tracker;
@property (nonatomic, strong)TTMonitorReporter * reporter;
@property (nonatomic, strong)dispatch_queue_t serialQueue;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)Class<TTMonitorLogPackagerProtocol> packClass;
@property (nonatomic, strong)Class<TTMonitorConfigurationProtocol> configurationClass;
@property (nonatomic, strong)HMDTTMonitor *monitor;
@end

@implementation TTMonitor

static TTMonitor *s_manager;

+ (TTMonitor *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[TTMonitor alloc] init];
    });
    return s_manager;
}

- (id)init
{
    self = [super init];
    if (self) {
//        NSString *label = @"com.bytedance.ttmonitor.serialqueue";
//        self.serialQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
//
//        self.flushInterval = [_configurationClass reportPollingInterval];
//        dispatch_async(self.serialQueue, ^{
//            [self initializeBlockObj];
//        });
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
//        //初始化网络监控类
//        [[TTNetworkManagerMonitorNotifier defaultNotifier] setEnable:YES];
        self.monitor = [HMDTTMonitor defaultManager];
    }
    return self;
}

///这里做了延迟处理 是不希望在程序启动的时候 占据启动资源
- (void)startIfNeed
{
//    dispatch_async(self.serialQueue, ^{
//        [self flushIfNeed];
//    });
}

- (void)startWithAppkey:(NSString *)appKey paramsBlock:(TTMonitorParamsBlock)block{
//    [(TTMonitorConfiguration *)[TTMonitorConfiguration shareManager] configAppKey:appKey paramBlock:block];
//
//    [[TTMonitor shareManager] setMonitorConfiguration:[TTMonitorConfiguration class]];
//    [[TTMonitor shareManager] setPackagerClass:[TTMonitorLogPackager class]];
//    //[[TTMonitor shareManager] startIfNeed];  启动的时候尽量少做事情   监控不急着上报  先去掉了
//
//    [[TTNetworkMonitorRecorder defaultRecorder] setConfigurationClass:[TTMonitorConfiguration class]];
//    //补充额外的业务层的信息
//    [[TTNetworkMonitorRecorder defaultRecorder] setTrackParamsblock:^(void) {
//        return [TTMonitorConfiguration monitorTrackAdditionalParameters];
//    }];
//
//    //开启网络监控
//    [[TTNetworkMonitorManager defaultMonitorManager] enableMonitor];
//    //开启系统常用指标监控
//    [TTSystemMonitorManager defaultMonitorManager];
}

- (void)setMonitorConfiguration:(Class<TTMonitorConfigurationProtocol>)configurationClass
{
//    self.configurationClass = configurationClass;
//    [self.reporter setMonitorConfiguration:configurationClass];
//    _flushInterval = [_configurationClass reportPollingInterval];
}

//- (void)setPackagerClass:(Class<TTMonitorLogPackagerProtocol>)packClass
//{
//    self.packClass = packClass;
//}

/**
 *  初始化延时的对象， 如property等
 */
//- (void)initializeBlockObj
//{
//    self.tracker = [[TTMonitorTracker alloc] init];
//    self.reporter = [[TTMonitorReporter alloc] init];
//    self.aggregater = [[TTMonitorAggregater alloc] init];
//}

HMDTTMonitorTrackerType convertType(TTMonitorTrackerType type)
{
    return (HMDTTMonitorTrackerType)type;
}

#pragma mark -- 监控日志

- (void)trackData:(NSDictionary *)data
             type:(TTMonitorTrackerType)type
{
    [self.monitor hmdTrackData:data type:convertType(type)];
}


- (void)trackData:(NSDictionary *)data
       logTypeStr:(NSString *)logType
{
    [self.monitor hmdTrackData:data logTypeStr:logType];
}


- (void)trackService:(NSString *)serviceName value:(id)value extra:(NSDictionary *)extraValue
{
    [self.monitor hmdTrackService:serviceName value:value extra:extraValue];
}

- (void)trackService:(NSString *)serviceName
          attributes:(NSDictionary *)attributes
{
    [self.monitor hmdTrackService:serviceName attributes:attributes];
}

- (void)trackService:(NSString *)serviceName status:(NSInteger)status extra:(NSDictionary *)extraValue{
    
    [self.monitor hmdTrackService:serviceName status:status extra:extraValue];
}


#pragma mark -- 打点聚合

- (void)event:(NSString *)type label:(NSString *)label count:(NSUInteger)count needAggregate:(BOOL)needAggr
{
    [self.monitor event:type label:label count:count needAggregate:needAggr];
    
}

- (void)event:(NSString *)type label:(NSString *)label needAggregate:(BOOL)needAggr
{
    [self.monitor event:type label:label needAggregate:needAggr];
    
}

- (void)event:(NSString *)type label:(NSString *)label duration:(float)duration needAggregate:(BOOL)needAggr
{
    [self.monitor event:type label:label duration:duration needAggregate:needAggr];
    
}

- (void)storeEvent:(NSString *)type label:(NSString *)label value:(float)value
{
    [self.monitor storeEvent:type label:label value:value];
    
}

- (void)debugRealEvent:(NSString *)type label:(NSString *)label traceCode:(NSString *)traceCode
{

    [self debugRealEvent:type label:label traceCode:traceCode userInfo:nil];
}

- (void)debugRealEvent:(NSString *)event label:(NSString *)label traceCode:(NSString *)traceCode userInfo:(NSDictionary *)userInfo{
    
    [self.monitor debugRealEvent:event label:label traceCode:traceCode userInfo:userInfo];
}

#pragma mark -- notify

- (void)reportDNSList{
    [self.monitor reportDNSList];
    return;// 不在统计dns
}

#pragma mark -- oom monitor

// For OOM Detection, 需要外部通知程序上次启动是否 crash 了
+ (void)setAppCrashFlagForLastTimeLaunch
{
    [HMDTTMonitor setAppCrashFlagForLastTimeLaunch];
}


@end
