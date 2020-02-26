//
//  TTMonitorReporter.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/28.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//


#import "TTMonitorReporter.h"
#import "TTMonitorDefine.h"
#import "TTMonitorConfigurationProtocol.h"
#import "TTExtensions.h"
#import "TTMonitorConfiguration.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTMonitorReporterResponse.h"

#define kMonitorReportURLPath @"/monitor/collect/"
#define kWatchDogReportURLPath @"https://abn.snssdk.com/collect/"

static NSTimeInterval nextAviaibleTimeInterval = -1;//-1 就不设限 未来的永久
static NSTimeInterval currentSleepValueForException = -1;//-1 就不设限 未来的永久

static Class<TTMonitorConfigurationProtocol> tt_configurationClass;
static NSString * tt_recommendHost;
static NSArray * tt_allHosts;
static NSLock *tt_Lock;
@interface TTMonitorReporter()
@end

@interface TTMonitorReporter()

@property (atomic, copy) NSString *defaultHost;

@end

@implementation TTMonitorReporter

+ (void)initialize
{
    if (self == [TTMonitorReporter class]) {
        if (!tt_Lock) {
            tt_Lock = [NSLock new];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithConfiguration:(Class<TTMonitorConfigurationProtocol>)configurationClass
{
    self = [super init];
    if (self) {
        tt_configurationClass = configurationClass;

        if (tt_configurationClass) {
            [self refreshConfig];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveConfigUpdatdNotification:)
                                                     name:kTTMonitorConfigurationUpdatedNotification
                                                   object:nil];
    }
    return self;
}

- (id)init
{
    return [self initWithConfiguration:[TTMonitorConfiguration class]];
}

- (void)refreshConfig
{
    [tt_Lock lock];
    tt_allHosts = [tt_configurationClass reportHosts];
    [tt_Lock unlock];
    
    [self refreshRecommendHostConfig];
}

- (void)setMonitorConfiguration:(Class<TTMonitorConfigurationProtocol>)configurationClass
{
    if (![tt_configurationClass isEqual:configurationClass]) {
        tt_configurationClass = configurationClass;
        [self refreshConfig];
    }
}

#pragma mark -- URL 相关
- (void)refreshRecommendHostConfig {
    [tt_Lock lock];

    if ([tt_allHosts count] > 0) {
        tt_recommendHost = tt_allHosts[0];
    } else {
        tt_recommendHost = [self localURLPath];//下发Host列表出现问题或者第一次启动的默认值
    }
    [tt_Lock unlock];
}
/**
 *  根据参数和是否需要，刷新当前发送的Host。
 *
 *  @param force YES:刷新。NO:如果为空刷新，否则不动
 *
 *  @return YES:更换了一个, NO设置初始值或者没有更换
 */
- (BOOL)refreshRecommendHostForce:(BOOL)force
{
    [tt_Lock lock];

    BOOL result = NO;
    BOOL recommendHostIsEmpty = [self isRecommendHostEmpty];
    if (!recommendHostIsEmpty && !force) {
        //do nothing...
    }
    else {
        if (recommendHostIsEmpty) {//为空的时候的赋值
            if ([tt_allHosts count] > 0) {
                tt_recommendHost = tt_allHosts[0];
            }
        }
        else {//尝试更换Host
            if ([tt_allHosts count] <= 1) {
                result = NO;
            }
            else {
                NSString * originHost = tt_recommendHost;
                NSUInteger index = [tt_allHosts indexOfObject:originHost];
                if (index == NSNotFound) {
                    index = 0;
                }
                else {
                    if (index >= ([tt_allHosts count] - 1)) {
                        index = 0;
                    }
                    else {
                        index ++;
                    }
                }
                tt_recommendHost = tt_allHosts[index];
                if (![tt_recommendHost isEqualToString:originHost]) {
                    result = YES;
                }
            }
        }
        
        if ([self isRecommendHostEmpty]) {
            tt_recommendHost = [self localURLPath];//下发Host列表出现问题或者第一次启动的默认值
        }
    }
    [tt_Lock unlock];

    return result;
}

- (BOOL)isRecommendHostEmpty
{
    [tt_Lock lock];
    BOOL result = !([tt_recommendHost isKindOfClass:[NSString class]] && [tt_recommendHost length] > 0);
    [tt_Lock unlock];
    
    return result;
}

- (NSString *)reportURLStrForReportType:(TTReportDataType)dataType
{
    [tt_Lock lock];
    NSString * originUrl = tt_recommendHost;
    [tt_Lock unlock];
    if (dataType==TTReportDataTypeWatchDog) {
        originUrl = kWatchDogReportURLPath;
    }
    if ([TTMonitor shareManager].urlTransformBlock) {
        return [[TTMonitor shareManager].urlTransformBlock([NSURL URLWithString:originUrl]) absoluteString];
    }else{
        return originUrl;
    }
    
}

#pragma mark -- 发送相关

- (TTMonitorReporterResponse *)reportForData:(NSDictionary *)data reportType:(TTReportDataType)dataType
{
    if (nextAviaibleTimeInterval !=-1 && [[NSDate date] timeIntervalSince1970] < nextAviaibleTimeInterval) {
        return nil;
    }
    static NSInteger maxRetryCount = 2;//最多尝试重试2.
    TTMonitorReporterResponse * respsonse = [self _reportForData:data reportType:dataType];
    if (respsonse.serverCrashed) {
        nextAviaibleTimeInterval = [[NSDate date] timeIntervalSince1970] + 60*30;//休息半小时
        maxRetryCount = 2;
        return respsonse;
    }
    if (!respsonse.error) {
        maxRetryCount = 2;
    }
    if (respsonse.error) {
        NSInteger errorCode = respsonse.error.code;
        if (kTTMonitorErrorCodeServerException==errorCode) {
            NSInteger statusCode = respsonse.statusCode;
            if (statusCode>=500) {
                if (currentSleepValueForException==-1) {
                    nextAviaibleTimeInterval = [[NSDate date] timeIntervalSince1970] + 5*60;//休息5分钟
                    currentSleepValueForException = 5;
                }else
                if (currentSleepValueForException==5) {
                    nextAviaibleTimeInterval = [[NSDate date] timeIntervalSince1970] + 15*60;//休息15分钟
                    currentSleepValueForException = 15;
                }else
                if (currentSleepValueForException==15 || currentSleepValueForException==30) {
                    nextAviaibleTimeInterval = [[NSDate date] timeIntervalSince1970] + 30*60;//休息30分钟
                    currentSleepValueForException = 30;
                }
                return respsonse;
            }
        }
        if (dataType!=TTReportDataTypeCommon) {
            return respsonse;
        }
        BOOL hostHasMore=NO;
        MNetworkStatus nt = [TTExtensions networkStatus];
        hostHasMore = [self refreshRecommendHostForce:YES];
        if (!hostHasMore && nt!=MNNotReachable) {
            NSTimeInterval intervalue = [TTMonitorConfiguration retryIntervalIfAllHostFailed];
            nextAviaibleTimeInterval = [[NSDate date] timeIntervalSince1970] + intervalue;//默认休息30分钟 服务器可配置
            return respsonse;
        }
        -- maxRetryCount;
        NSInteger delayBase = 1.0;
        if (hostHasMore && maxRetryCount >= 0) {
            CGFloat delay = ((CGFloat)(arc4random() % 100) / 100.f) + delayBase;//随机延时0-1秒 + delayBase
            if (delay > 0) {
                [NSThread sleepForTimeInterval:delay];
            }
            return [self reportForData:data reportType:dataType];
        }
    }
    return respsonse;
}
/**
 *  如果日志把服务器发挂了，服务器会返回一个is_crash=1的数据，检查此数据，为YES则重新拉配置，并清除未发送的数据
 *
 *  @param userInfo 错误信息
 *
 *  @return 服务器是否挂了
 */
-(BOOL)isServerError:(NSDictionary *)userInfo{
    if (!userInfo) {
        return NO;
    }
    if ([[userInfo valueForKey:@"is_crash"] boolValue]) {
        return YES;
    }
    return NO;
}
/**
 *  实际发送的方法
 *
 *  @param data 待发送的内容
 *
 *  @return 返回值error为nil标示上报完成，否则上报失败
 */
- (TTMonitorReporterResponse *)_reportForData:(NSDictionary *)data reportType:(TTReportDataType)dataType
{
    @try {
        BOOL needEncrypt = [TTMonitorConfiguration needEncrypt];
#ifdef DEBUG
        needEncrypt = NO;
#endif
        NSDictionary * result = [[TTNetworkManager shareInstance]
                                 synchronizedRequstForURL:[self reportURLStrForReportType:dataType]
                                 method:@"POST"
                                 headerField:nil
                                 jsonObjParams:data
                                 needCommonParams:YES needResponse:YES needEncrypt:needEncrypt needContentEncodingAfterEncrypt:needEncrypt];//needEncrypt  和 needContentEncodingAfterEncrypt 永远保持一致
        TTMonitorReporterResponse * response = [[TTMonitorReporterResponse alloc] initWithDict:result];
        return response;

    } @catch (NSException *exception) {
        return nil;
    } @finally {
    }
}

#pragma mark -- kTTMonitorConfigurationUpdatedNotification

- (void)receiveConfigUpdatdNotification:(NSNotification *)notification
{
    [self refreshConfig];
}

- (NSString *)localURLPath {
    NSString *localPath = nil;
    if (self.defaultHost) {
        localPath = [NSString stringWithFormat:@"https://%@%@",self.defaultHost,kMonitorReportURLPath];
    } else {
        localPath = kDefaultTTMonitorURL;
    }
    
    return localPath;
}

@end
