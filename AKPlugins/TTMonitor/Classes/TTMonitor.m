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

//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self stopFlushTimer];
//}

+ (TTMonitor *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[TTMonitor alloc] init];
    });
    return s_manager;
}

//- (id)init
//{
//    self = [super init];
//    if (self) {
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
//    }
//    return self;
//}

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

//- (void)setMonitorConfiguration:(Class<TTMonitorConfigurationProtocol>)configurationClass
//{
//    self.configurationClass = configurationClass;
//    [self.reporter setMonitorConfiguration:configurationClass];
//    _flushInterval = [_configurationClass reportPollingInterval];
//}

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

-(HMDTTMonitor *)monitor
{
    if (!_monitor) {
        _monitor = [[HMDTTMonitor alloc] initMonitorWithAppID:@"100"];//@"100"
    }
    return _monitor;
}

HMDTTMonitorTrackerType convertType(TTMonitorTrackerType type)
{
    return (HMDTTMonitorTrackerType)type;
}

#pragma mark -- 监控日志

- (void)trackData:(NSDictionary *)data
             type:(TTMonitorTrackerType)type
{
    [[HMDTTMonitor defaultManager] hmdTrackData:data type:convertType(type)];
    /*
    if (self.stopMonitor) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        [_tracker trackData:data type:type];
        [self tracksCountChanged];
    });
     */
}


- (void)trackData:(NSDictionary *)data
       logTypeStr:(NSString *)logType
{
    [self.monitor hmdTrackData:data logTypeStr:logType];
    
    /*
    if (self.stopMonitor) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        if ([self.configurationClass isEnabledForLogType:@"enable_debugreal_monitor"] && [self.configurationClass isEnabledForServiceType:@"debugreal_logtype"]) {
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary * newData = [[NSMutableDictionary alloc] initWithDictionary:data];
                [newData setValue:logType forKey:@"display_name"];
                __block BOOL containOtherTypes = NO;
                if (![data valueForKey:@"network_type"]) {
                    [newData setValue:@([TTMonitorConfiguration shareManager].networkStatus) forKey:@"network_type"];
                }
                [newData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![obj isKindOfClass:[NSString class]] || ![obj isKindOfClass:[NSNumber class]]) {
                        containOtherTypes = YES;
                        *stop = YES;
                    }
                }];
                
                if (!containOtherTypes) {
                    [[TTDebugRealStorgeService sharedInstance] insertMonitorItem:data storeId:[[NSUUID UUID] UUIDString]];
                }
            }
        }
        if ([self.configurationClass isEnabledForLogType:logType]) {
            [_tracker trackData:data logType:logType];
            [self tracksCountChanged];
        }
    });
     */
}


- (void)trackService:(NSString *)serviceName value:(id)value extra:(NSDictionary *)extraValue
{
    [self.monitor hmdTrackService:serviceName value:value extra:extraValue];
    
    /*
    if (self.stopMonitor) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        if ([self.configurationClass isEnabledForLogType:@"enable_debugreal_monitor"]) {
            NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
            [data setValue:value forKey:@"value"];
            [data setValue:serviceName forKey:@"service"];
            [data setValue:serviceName forKey:@"display_name"];
            double currentMem = memory_now();
            if (currentMem>0) {
                [data setValue:@(currentMem) forKey:@"current_mem"];
            }
            [data setValue:@([[NSDate date] timeIntervalSince1970]*1000) forKey:@"timestamp"];
            if (extraValue && [NSJSONSerialization isValidJSONObject:extraValue]) {
                [data setValue:extraValue forKey:@"extra_value"];
            }
            [data setValue:@"service_monitor" forKey:@"log_type"];
            if (![data valueForKey:@"network_type"]) {
                [data setValue:@([TTMonitorConfiguration shareManager].networkStatus) forKey:@"network_type"];
            }
            [[TTDebugRealStorgeService sharedInstance] insertMonitorItem:data storeId:[[NSUUID UUID] UUIDString]];
        }
        if ([self.configurationClass isEnabledForLogType:@"service_monitor"] &&
            [self.configurationClass isEnabledForServiceType:serviceName]) {
            NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
            double currentMem = memory_now();
            if (currentMem>0) {
                [data setValue:@(currentMem) forKey:@"current_mem"];
            }
            if ([value isKindOfClass:[NSDictionary class]]) {//如果是字典
                NSDictionary * valueDict = (NSDictionary *)value;
                if ([valueDict valueForKey:@"status"]) {
                    [data setValue:[valueDict valueForKey:@"status"] forKey:@"status"];
                }else{
                    [data setValue:@(0) forKey:@"status"];
                }
                [data setValue:value forKey:@"value"];
            }else{////如果不是字典
                [data setValue:@(0) forKey:@"status"];
                if (extraValue && [NSJSONSerialization isValidJSONObject:extraValue]) {
                    NSMutableDictionary * valueDict = [[NSMutableDictionary alloc] init];
                    if ([extraValue isKindOfClass:[NSDictionary class]]) {
                        [valueDict addEntriesFromDictionary:extraValue];
                        [valueDict setValue:value forKey:@"value"];
                    }
                    [data setValue:valueDict forKey:@"value"];
                }else{
                    [data setValue:value forKey:@"value"];
                }
            }
            
            
            [data setValue:serviceName forKey:@"service"];
            [data setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time_interval"];
            [_tracker trackData:data logType:@"service_monitor"];
            [self tracksCountChanged];
        }
    });
     */
}

- (void)trackService:(NSString *)serviceName
          attributes:(NSDictionary *)attributes
{
    [self.monitor hmdTrackService:serviceName attributes:attributes];
    
    /*
    if (self.stopMonitor) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        if ([self.configurationClass isEnabledForLogType:@"enable_debugreal_monitor"]) {
            NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
            [data setValue:attributes forKey:@"value"];
            [data setValue:serviceName forKey:@"display_name"];
            [data setValue:@"service_monitor" forKey:@"debugreal_type"];
            double currentMem = memory_now();
            if (currentMem>0) {
                [data setValue:@(currentMem) forKey:@"current_mem"];
            }
            [data setValue:@([[NSDate date] timeIntervalSince1970] * 1000) forKey:@"timestamp"];
            if (![data valueForKey:@"network_type"]) {
                [data setValue:@([TTMonitorConfiguration shareManager].networkStatus) forKey:@"network_type"];
            }
            [[TTDebugRealStorgeService sharedInstance] insertMonitorItem:data storeId:[[NSUUID UUID] UUIDString]];
        }
        if ([self.configurationClass isEnabledForLogType:@"service_monitor"] &&
            [self.configurationClass isEnabledForServiceType:serviceName]) {
            NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
            
            if ([attributes isKindOfClass:[NSDictionary class]]) {
                [data setValue:attributes forKey:@"value"];
                if (![attributes valueForKey:@"status"]) {
                    [data setValue:@(0) forKey:@"status"];
                }
            }
            [data setValue:serviceName forKey:@"service"];
            double currentMem = memory_now();
            if (currentMem>0) {
                [data setValue:@(currentMem) forKey:@"current_mem"];
            }
            [data setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time_interval"];
            [_tracker trackData:data logType:@"service_monitor"];
            [self tracksCountChanged];
        }
    });
     */
}

- (void)trackService:(NSString *)serviceName status:(NSInteger)status extra:(NSDictionary *)extraValue{
    
    [self.monitor hmdTrackService:serviceName status:status extra:extraValue];
    
    /*
    if (self.stopMonitor) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        if ([self.configurationClass isEnabledForLogType:@"enable_debugreal_monitor"]) {
            NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
            [data setValue:@(status) forKey:@"status"];
            [data setValue:serviceName forKey:@"display_name"];
            [data setValue:@([[NSDate date] timeIntervalSince1970] * 1000) forKey:@"timestamp"];
            if (extraValue && [NSJSONSerialization isValidJSONObject:extraValue]) {
                [data setValue:extraValue forKey:@"extra_value"];
            }
            double currentMem = memory_now();
            if (currentMem>0) {
                [data setValue:@(currentMem) forKey:@"current_mem"];
            }
            [data setValue:@"service_monitor" forKey:@"debugreal_type"];
            if (![data valueForKey:@"network_type"]) {
                [data setValue:@([TTMonitorConfiguration shareManager].networkStatus) forKey:@"network_type"];
            }
            
            [[TTDebugRealStorgeService sharedInstance] insertMonitorItem:data storeId:[[NSUUID UUID] UUIDString]];
        }
        if ([self.configurationClass isEnabledForLogType:@"service_monitor"] &&
            [self.configurationClass isEnabledForServiceType:serviceName]) {
            NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
            [data setValue:@(status) forKey:@"status_monitor"];
            [data setValue:serviceName forKey:@"service"];
            double currentMem = memory_now();
            if (currentMem>0) {
                [data setValue:@(currentMem) forKey:@"current_mem"];
            }
            [data setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"time_interval"];
            if (extraValue && [NSJSONSerialization isValidJSONObject:extraValue]) {
                NSMutableDictionary * valueDict = [[NSMutableDictionary alloc] init];
                if ([extraValue isKindOfClass:[NSDictionary class]]) {
                    [valueDict addEntriesFromDictionary:extraValue];
                }
                [valueDict setValue:@(status) forKey:@"status"];
                [data setValue:valueDict forKey:@"value"];
            }else{
                [data setValue:@(status) forKey:@"status"];
            }
            [_tracker trackData:data logType:@"service_monitor"];
            [self tracksCountChanged];
        }
    });
     */
}


#pragma mark -- 打点聚合

- (void)event:(NSString *)type label:(NSString *)label count:(NSUInteger)count needAggregate:(BOOL)needAggr
{
    [self.monitor event:type label:label count:count needAggregate:needAggr];
    
    /*
    if (self.stopMonitor) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        if ([self.configurationClass isEnabledForLogType:@"enable_debugreal_monitor"] &&
            [self.configurationClass isEnabledForServiceType:@"debugreal_performance"]) {
            NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
            [data setValue:@(count) forKey:@"count"];
            [data setValue:[NSString stringWithFormat:@"%@_%@",type,label] forKey:@"display_name"];
            [data setValue:@"performance_monitor" forKey:@"debugreal_type"];

            [[TTDebugRealStorgeService sharedInstance] insertMonitorItem:data storeId:[[NSUUID UUID] UUIDString]];
        }
        if (![self.configurationClass isEnabledForMetricsType:type]) {
            return;
        }
        [_aggregater event:type label:label count:count needAggregate:needAggr];
    });
     */
}

- (void)event:(NSString *)type label:(NSString *)label needAggregate:(BOOL)needAggr
{
    [self.monitor event:type label:label needAggregate:needAggr];
    
    /*
    if (self.stopMonitor) {
        return;
    }
    if (![self.configurationClass isEnabledForMetricsType:type]) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        [_aggregater event:type label:label needAggregate:needAggr];
    });
     */
}

- (void)event:(NSString *)type label:(NSString *)label duration:(float)duration needAggregate:(BOOL)needAggr
{
    [self.monitor event:type label:label duration:duration needAggregate:needAggr];
    
    /*
    if (self.stopMonitor) {
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        if ([self.configurationClass isEnabledForLogType:@"enable_debugreal_monitor"] &&
            [self.configurationClass isEnabledForServiceType:@"debugreal_performance"]) {
            NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
            [data setValue:@(duration) forKey:@"count"];
            [data setValue:[NSString stringWithFormat:@"%@_%@",type,label] forKey:@"display_name"];
            [data setValue:@"performance_monitor" forKey:@"debugreal_type"];
            [[TTDebugRealStorgeService sharedInstance] insertMonitorItem:data storeId:[[NSUUID UUID] UUIDString]];
        }
        if (![self.configurationClass isEnabledForMetricsType:type]) {
            return;
        }
        [_aggregater event:type label:label duration:duration needAggregate:needAggr];
    });
     
     */
}

- (void)storeEvent:(NSString *)type label:(NSString *)label value:(float)value
{
    [self.monitor storeEvent:type label:label value:value];
    
    /*
    if (self.stopMonitor) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        [_aggregater storeEvent:type label:label value:value];
    });
     */
}

- (void)debugRealEvent:(NSString *)type label:(NSString *)label traceCode:(NSString *)traceCode{
//    if (self.stopMonitor) {
//        return;
//    }
    [self debugRealEvent:type label:label traceCode:traceCode userInfo:nil];
}

- (void)debugRealEvent:(NSString *)event label:(NSString *)label traceCode:(NSString *)traceCode userInfo:(NSDictionary *)userInfo{
    
    [self.monitor debugRealEvent:event label:label traceCode:traceCode userInfo:userInfo];
    
    /*
    if (self.stopMonitor) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        [_tracker debugRealEvent:event label:label traceCode:traceCode userInfo:userInfo];
        [self tracksCountChanged];
    });
     */
}

#pragma mark -- notify

//- (void)tracksCountChanged
//{
//    if (self.stopMonitor) {
//        return;
//    }
//    if ([_tracker trackItemsCount] >= [_configurationClass onceReportMaxLogCount]) {
//        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
//        if (now - _latelyFlushInterval < 15) {//限制15秒内不要有因为超过log限制条数而连续发送， 这种情况是极端情况出现的（一直发送失败）
//            return;
//        }
//        [self flushIfNeed];
//    }
//}

//- (void)flushIfNeed
//{
//    if (self.stopMonitor) {
//        return;
//    }
//
//    [_tracker addImageMonitorItems:[[TTImageMonitorManager sharedImageMonitor] packageImageMonitorData]];
//
////    if (self.inBackGroundMode) {
////        return;
////    }
//    [self stopFlushTimer];
//
//    NSInteger maxBatchCount = [_configurationClass onceReportMaxLogCount];
//    NSUInteger batchSize = ([_tracker trackItemsCount] > maxBatchCount) ? maxBatchCount : [_tracker trackItemsCount];
//    NSArray<TTMonitorTrackItem *> *batch = [[_tracker monitorTrackers] subarrayWithRange:NSMakeRange(0, batchSize)];
//
//    BOOL hasError = NO;
//
//    if (!_packClass) {
//        return;
//    }
//    NSDictionary * result = [_packClass packageTrack:batch
//                                   aggregateTimeItem:_aggregater.timerItem
//                                  aggregateCountItem:_aggregater.counterItem
//                                           storeItem:_aggregater.storeItem];
//    if ([result count] != 0) {
//        //发送
//        TTMonitorReporterResponse * response = [_reporter reportForData:result reportType:TTReportDataTypeCommon];
//        if (response.uploadDebugrealCommands) {
//            [[TTDebugRealConfig sharedInstance] configDataCollectPolicy:response.uploadDebugrealCommands];
//        }
//
//        if (response.uploadFileCommands) {
//            [TTMonitorFileUploader uploadIfNeeded:[response.uploadFileCommands valueForKey:@"fileList"]];
//        }
//
//        _latelyFlushInterval = [[NSDate date] timeIntervalSince1970];
//        if (!response.error) {
//            //清除track
//            [_tracker removeTrackItems:batch];
//            //清除聚合
//            [_aggregater clear];
//            [self.configurationClass tryFetchConfigWithForce:NO];
//            if (self.inBackGroundMode) {
//                [TTMonitorPersistenceStore archiveTrackItems:[_tracker monitorTrackers]];
//            }
//        }
//        else {
//            /**
//             *  如果服务器挂了 清空数据， 重新拉配置
//             */
//            if (response.serverCrashed) {
//                [_tracker clear];
//                [_aggregater clear];
//                return;
//            }
//            NSInteger statusCode = response.statusCode;
//            if (statusCode>=500) {
//                [_tracker clear];
//                [_aggregater clear];
//                return;
//            }
//            //处理track失败
//            NSInteger maxRetryCount = [_configurationClass maxReportRetryCount];
//            NSMutableArray * remainItems = [NSMutableArray arrayWithCapacity:10];
//            for (TTMonitorTrackItem * item in batch) {
//                ++ item.retryCount;
//                if ([item.track isKindOfClass:[NSDictionary class]] &&
//                    [item.track count] > 0 &&
//                    item.retryCount < maxRetryCount) {
//                    [remainItems addObject:item];
//                }
//            }
//            if ([batch count] > 0) {
//                [_tracker removeTrackItems:batch];
//            }
//            if ([remainItems count] > 0) {
//                [_tracker addTrackItems:remainItems];
//            }
//
//            //处理聚合失败
//            _aggregater.timerItem.retryCount ++;
//            _aggregater.counterItem.retryCount ++;
//            _aggregater.storeItem.retryCount ++;
//
//            if ([_aggregater.timerItem retryCount] >= maxRetryCount) {
//                [_aggregater.timerItem clear];
//            }
//
//            if ([_aggregater.counterItem retryCount] >= maxRetryCount) {
//                [_aggregater.counterItem clear];
//            }
//
//            if ([_aggregater.storeItem retryCount] >= maxRetryCount) {
//                [_aggregater.storeItem clear];
//            }
//            if (self.inBackGroundMode) {
//                [TTMonitorPersistenceStore archiveTrackItems:[_tracker monitorTrackers]];
//            }
//            hasError = YES;
//        }
//    }
//    else {
//        if ([batch count] > 0) {//本次发送需要打包的log没有有效的
//            [_tracker removeTrackItems:batch];
//        }
//        [_aggregater clear];
//        //如果没有数据需要发送， 也需要检测一下有没有配置需要拉取
//        [self.configurationClass tryFetchConfigWithForce:NO];
//    }
//
//    if (!hasError && [_tracker trackItemsCount] > 0) {//没有发送异常，并且队列中还有要发送的数据,继续发送
//
//        float delay = ((float)(arc4random() % 100) / 100.f) + 1;//随机延时1.n秒
//        if (delay > 0) {
//            [NSThread sleepForTimeInterval:delay];
//        }
//        if (!self.inBackGroundMode) {
//            //后台禁止启动timer逻辑
//            [self flushIfNeed];
//        }
//    }
//    else {
//        if (!self.inBackGroundMode) {
//            [self startFlushTimer];
//            [TTDebugRealMonitorManager sendDebugRealDataIfNeeded];
//
//        }
//    }
//}

/**
 *  如果日志把服务器发挂了，服务器会返回一个is_crash=1的数据，检查此数据，为YES则重新拉配置，并清除未发送的数据
 *
 *  @param userInfo 错误信息
 *
 *  @return 服务器是否挂了
 */
//-(BOOL)isServerError:(NSDictionary *)userInfo{
//    if (!userInfo) {
//        return NO;
//    }
//    if ([[userInfo valueForKey:@"is_crash"] boolValue]) {
//        return YES;
//    }
//    return NO;
//}
//#pragma mark -- notify timer
//
//- (void)stopFlushTimer
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.timer) {
//            [self.timer invalidate];
//        }
//        self.timer = nil;
//    });
//}
//
//- (NSUInteger)flushInterval
//{
//    @synchronized(self) {
//        return _flushInterval;
//    }
//}
//
//- (void)setFlushInterval:(NSUInteger)interval
//{
//    @synchronized(self) {
//        _flushInterval = interval;
//    }
//    [self startFlushTimer];
//}
//
//
//- (void)startFlushTimer
//{
//    if (self.stopMonitor) {
//        return;
//    }
//    [self stopFlushTimer];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (_flushInterval > 0) {
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:_flushInterval
//                                                          target:self
//                                                        selector:@selector(timerFire)
//                                                        userInfo:nil
//                                                         repeats:NO];
//        }
//    });
//}
//
//- (void)timerFire
//{
//    //因为 timer 是在主线程，所以需要分发到监控线程
//    dispatch_async(self.serialQueue, ^{
//        [self flushIfNeed];
//    });
//}
//
//#pragma mark -- notification
//
//- (void)receiveEnterForegroundNotification:(NSNotification *)notification
//{
//    self.inBackGroundMode = NO;
//    if (!self.timer) {
//        [self startFlushTimer];
//    }
//    [TTDebugRealMonitorManager cacheDevLogWithEventName:@"enter_foreground" params:nil];
//}
//
//- (void)receiveEnterBackgroundNotification:(NSNotification *)notification
//{
//    [self timerFire];
//    self.inBackGroundMode = YES;
//    [self stopFlushTimer];
//    [TTDebugRealMonitorManager cacheDevLogWithEventName:@"enter_background" params:nil];
//}
//
//#pragma mark -- dns上报
//#define kTTMonitorLastDNSReportIntervalKey @"kTTMonitorLastDNSReportIntervalKey"
//+ (NSTimeInterval)lastDNSReprotTimeInterval{
//    NSTimeInterval result = [[[NSUserDefaults standardUserDefaults] objectForKey:kTTMonitorLastDNSReportIntervalKey] doubleValue];
//    return result;
//}
//
//+ (void)saveLastDNSReprotTimeInterval:(double)reportTimeInterval
//{
//    [[NSUserDefaults standardUserDefaults] setValue:@(reportTimeInterval) forKey:kTTMonitorLastDNSReportIntervalKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
- (void)reportDNSList{
    [self.monitor reportDNSList];
    return;// 不在统计dns
}

#pragma mark -- oom monitor

// For OOM Detection, 需要外部通知程序上次启动是否 crash 了
+ (void)setAppCrashFlagForLastTimeLaunch
{
    [HMDTTMonitor setAppCrashFlagForLastTimeLaunch];
//    [TTSystemMonitorManager setAppCrashFlagForLastTimeLaunch];
}


@end
