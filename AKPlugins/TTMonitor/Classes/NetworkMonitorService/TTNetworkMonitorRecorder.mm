//
//  TTNetworkMonitorRecorder.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/9.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTNetworkMonitorRecorder.h"
#import "TTNetworkMonitorTransaction.h"
#import "TTMonitor.h"
#import "TTExtensions.h"
#import "TTNetworkManager.h"
#import "TTDebugRealStorgeService.h"
#import "TTHttpResponseChromium.h"
//#import "TTHttpResponseAFNetworking.h"
#import "TTNetworkDefine.h"
#import "TTImageMonitorManager.h"
#import "TTMonitorConfiguration.h"
#import "TTNetworkMonitorManager.h"

#define kTraceCodeKey @"X-TT-LOGID"
#define kTraceXCache @"X-Cache"


@interface TTNetworkMonitorRecorder ()

@property (nonatomic, strong) NSMutableDictionary *networkTransactionsForRequestIdentifiers;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSObject<TTNetworkMonitorRecorderConfigurationProtocol> * configration;

@end

@implementation TTNetworkMonitorRecorder

- (void)dealloc
{
    self.trackParamsblock = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.networkTransactionsForRequestIdentifiers = [NSMutableDictionary dictionary];
        
        // Serial queue used because we use mutable objects that are not thread safe
        self.queue = dispatch_queue_create("com.bytedance.TTNetworkMonitorRecorder", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)defaultRecorder
{
    static TTNetworkMonitorRecorder *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [[[self class] alloc] init];
    });
    return defaultRecorder;
}

#pragma mark - Public Data Access

- (void)setConfigurationClass:(Class<TTNetworkMonitorRecorderConfigurationProtocol>)configuration
{
    self.configration = [configuration shareManager];
}

- (NSDictionary *)networkTransactions
{
    __block NSDictionary *transactions = nil;
    dispatch_sync(self.queue, ^{
        transactions = [self.networkTransactionsForRequestIdentifiers copy];
    });
    return transactions;
}

- (void)clearRecordedActivity
{
    dispatch_async(self.queue, ^{
        [self.networkTransactionsForRequestIdentifiers removeAllObjects];
    });
}

#pragma mark - Network Events

- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID
                                     request:(TTHttpRequest *)request
                                   startDate:(NSDate *)startDate
                               hasTriedTimes:(NSInteger)hasTriedTimes
{
    dispatch_async(self.queue, ^{
        TTNetworkMonitorTransaction *transaction = [[TTNetworkMonitorTransaction alloc] init];
        transaction.requestID = requestID;
        transaction.request = request;
        transaction.requestUrl = request.URL.absoluteString;
        transaction.hasTriedTimes = hasTriedTimes;
        transaction.startTime = startDate;
        
        [self.networkTransactionsForRequestIdentifiers setValue:transaction forKey:requestID];
    });
}

- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID
                              responseBody:(id)responseBody
                                  response:(TTHttpResponse *)response
                              finishedDate:(NSDate *)finishedDate
{
    dispatch_async(self.queue, ^{
        TTNetworkMonitorTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];
        if ([responseBody isKindOfClass:[NSData class]]) {
            BOOL isContainedInBlackList = [_configration debugRealItemContainedInBlackList:transaction];
            if (!isContainedInBlackList) {
                NSDictionary * headerFields = response.allHeaderFields;
                NSString * contentType = [headerFields valueForKey:@"Content-Type"];
                if ([contentType isKindOfClass:[NSString class]] && [contentType rangeOfString:@"application/json"].location!=NSNotFound) {
                    if ([responseBody isKindOfClass:[NSData class]] && [(NSData *)responseBody length]<1024*100) {
                        NSString * requestDate = [[TTExtensions _dateformatter] stringFromDate:transaction.startTime];
                        [[TTDebugRealStorgeService sharedInstance] saveData:responseBody storeId:requestDate];
                    }
                }
            }
        }
        transaction.response = response;
        NSInteger scode = [TTNetworkMonitorTransaction statusCodeForResponse:transaction.response];
        if (scode != NSNotFound) {
            transaction.status = scode;
        }
        else {
            transaction.status = 200;
        }
        [self recordIfNeed:transaction isFail:NO];
        [_networkTransactionsForRequestIdentifiers removeObjectForKey:requestID];
    });
}

- (void)recordLoadingFailedWithRequestID:(NSString *)requestID
                                   error:(NSError *)error
                                response:(TTHttpResponse *)response
                            responseBody:(id)responseBody
                            finishedDate:(NSDate *)finishedDate
{
    dispatch_async(self.queue, ^{
        TTNetworkMonitorTransaction *transaction = [self.networkTransactionsForRequestIdentifiers objectForKey:requestID];
        if (!transaction) {
            return;
        }
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];
        if ([responseBody isKindOfClass:[NSData class]]) {
            BOOL isContainedInBlackList = [_configration debugRealItemContainedInBlackList:transaction];
            if (!isContainedInBlackList) {
                NSDictionary * headerFields = response.allHeaderFields;
                NSString * contentType = [headerFields valueForKey:@"Content-Type"];
                if ([contentType isKindOfClass:[NSString class]] && [contentType rangeOfString:@"application/json"].location!=NSNotFound) {
                    if ([responseBody isKindOfClass:[NSData class]] && [(NSData *)responseBody length]<1024*100) {
                        NSString * requestDate = [[TTExtensions _dateformatter] stringFromDate:transaction.startTime];
                        [[TTDebugRealStorgeService sharedInstance] saveData:responseBody storeId:requestDate];
                    }
                }
            }
        }
        
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.response = response;
        transaction.error = error;
        if (error) {
            transaction.status = error.code;
        }else{
            NSInteger scode = [TTNetworkMonitorTransaction statusCodeForResponse:transaction.response];
            if (scode != NSNotFound) {
                transaction.status = scode;
            }else{
                transaction.status = 1;
            }
        }
        //[self recordIfNeed:transaction isFail:YES];
        if (error.code != -999) {
            [self recordIfNeed:transaction isFail:YES];
        }

        [_networkTransactionsForRequestIdentifiers removeObjectForKey:requestID];
    });
}

/**
 *  这个方法一定要在queue中调用， 千万不要在主线程调用
 *
 *  @param transaction 待记录的transaction
 */
- (void)recordIfNeed:(TTNetworkMonitorTransaction *)transaction isFail:(BOOL)fail
{
    if (!_configration) {
    }
    //采样统计
    BOOL isContainedInDebugList = [_configration debugRealItemContainedInBlackList:transaction];
    if (!isContainedInDebugList) {
        
        NSMutableDictionary * debugRealStoreItem = [[NSMutableDictionary alloc] init];
        [debugRealStoreItem setValue:@((NSInteger)([transaction.startTime timeIntervalSince1970] * 1000)) forKey:@"timestamp"];//毫秒
        if (transaction.error) {
            [debugRealStoreItem setValue:[NSString stringWithFormat:@"%@_%d", transaction.error.domain, transaction.error.code] forKey:@"error_desc"];//没有traceCode就传空值
        }        
        NSURL * url = [NSURL URLWithString:transaction.requestUrl];
        NSString * queryStr = [NSString stringWithFormat:@"%@://%@%@", url.scheme,url.host,url.path];
        [debugRealStoreItem setValue:queryStr forKey:@"display_name"];
        [debugRealStoreItem setValue:@"network_monitor" forKey:@"debugreal_type"];

        [debugRealStoreItem setValue:@(transaction.hasTriedTimes) forKey:@"httpIndex"];
        [debugRealStoreItem setValue:transaction.requestID forKey:@"requestID"];
        [debugRealStoreItem setValue:@((int)(transaction.duration * 1000)) forKey:@"duration"];//ms
        [debugRealStoreItem setValue:@(transaction.status) forKey:@"status"];
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        
        if ([cookies count] > 0) {
            NSString *cookieHeader = nil;
            for (NSHTTPCookie *cookie in cookies) {
                if (!cookieHeader) {
                    cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
                } else {
                    cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
                }
            }
            if (cookieHeader) {
                [debugRealStoreItem setValue:cookieHeader forKey:@"cookie"];//ms
            }
        }
        if ([transaction.response isKindOfClass:[TTHttpResponseChromium class]]) {
            TTHttpResponseChromium *targetResponse = (TTHttpResponseChromium *)transaction.response;
            TTHttpResponseChromiumTimingInfo * timingInfo = targetResponse.timingInfo;
            NSMutableDictionary * chromiumInfo = [[NSMutableDictionary alloc] init];
            [chromiumInfo setValue:@(timingInfo.proxy) forKey:@"timing_proxy"];
            [chromiumInfo setValue:@(timingInfo.dns) forKey:@"timing_dns"];
            [chromiumInfo setValue:@(timingInfo.connect) forKey:@"timing_connect"];
            [chromiumInfo setValue:@(timingInfo.ssl) forKey:@"timing_ssl"];
            [chromiumInfo setValue:@(timingInfo.send) forKey:@"timing_send"];
            [chromiumInfo setValue:@(timingInfo.wait) forKey:@"timing_wait"];
            [chromiumInfo setValue:@(timingInfo.receive) forKey:@"timing_receive"];
            [chromiumInfo setValue:@(timingInfo.total) forKey:@"timing_total"];
            [chromiumInfo setValue:@(timingInfo.receivedResponseContentLength) forKey:@"timing_receivedResponseContentLength"];
            [chromiumInfo setValue:@(timingInfo.totalReceivedBytes) forKey:@"timing_totalReceivedBytes"];
            [chromiumInfo setValue:@(timingInfo.isSocketReused) forKey:@"timing_isSocketReused"];
            [chromiumInfo setValue:@(timingInfo.isCached) forKey:@"timing_isCached"];
            [chromiumInfo setValue:@(timingInfo.isFromProxy) forKey:@"timing_isFromProxy"];
            [chromiumInfo setValue:timingInfo.remoteIP forKey:@"timing_remoteIP"];
            [chromiumInfo setValue:@(timingInfo.remotePort) forKey:@"timing_remotePort"];
            [debugRealStoreItem setValue:chromiumInfo forKey:@"chromium_info"];
        }
        if (fail) {
            NSURL * url = [NSURL URLWithString:transaction.requestUrl];
            NSString *IPAddress = [TTExtensions addressOfHost:[url host]];
            [debugRealStoreItem setValue:IPAddress forKey:@"remoteIP"];
        }

        NSString * requestDate = [[TTExtensions _dateformatter] stringFromDate:transaction.startTime];
        [[TTDebugRealStorgeService sharedInstance] insertNetworkItem:[debugRealStoreItem copy] storeId:requestDate];
        
    }
    //sample不再统计了  代码先保留一个版本 目前是5.6.0
    BOOL needSample = NO;
    BOOL needRecorderFail = fail && [_configration isNeedRecorderErrorURL:transaction];
    BOOL needRecordAllAPI = [_configration isNeedMonitorAllURL:transaction];
    BOOL isImageRequest = [_configration isImageRequestUrl:transaction];
    if (needSample || needRecorderFail || needRecordAllAPI || isImageRequest) {
        BOOL isInBlackRequest = [_configration _isContainedInBlackList:transaction];
        if (isInBlackRequest) {
            return;
        }
        if (isImageRequest) {
               [[TTImageMonitorManager sharedImageMonitor] recordIfNeed:transaction];
            return;
        }
        NSMutableDictionary * track = [NSMutableDictionary dictionaryWithCapacity:10];
        if (transaction.startTime) {
            [track setValue:@((NSInteger)([transaction.startTime timeIntervalSince1970] * 1000)) forKey:@"timestamp"];//毫秒
        }
        
        [track setValue:@(transaction.status) forKey:@"status"];
        if (transaction.response && [transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
          
        }
        if (transaction.response) {
            if ([transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse * r = (NSHTTPURLResponse *)transaction.response;
                [self applyTraceCodeToTrack:track sourceDict:r.allHeaderFields];
            }
//            else if ([transaction.response isKindOfClass:[TTHttpResponseAFNetworking class]]){
//                TTHttpResponseAFNetworking * afResponse = (TTHttpResponseAFNetworking *)transaction.response;
//                NSHTTPURLResponse * r = (NSHTTPURLResponse *)afResponse.response;
//                [self applyTraceCodeToTrack:track sourceDict:r.allHeaderFields];
//            }
            else if ([transaction.response isKindOfClass:[TTHttpResponseChromium class]]){
                TTHttpResponseChromium *targetResponse = (TTHttpResponseChromium *)transaction.response;
                NSDictionary * responseDict = [targetResponse allHeaderFields];
                [self applyTraceCodeToTrack:track sourceDict:responseDict];
            }
        }
        
        if (fail && transaction.error && [transaction.error isKindOfClass:[NSError class]]) {
            [track setValue:transaction.error.description forKey:@"error_desc"];//没有traceCode就传空值
        }
        
        NSDictionary * pickTrackParams = [self pickTrackParams];
        if ([pickTrackParams isKindOfClass:[NSDictionary class]] &&
            [pickTrackParams count] > 0) {
            [track addEntriesFromDictionary:pickTrackParams];
        }
        if (transaction.requestUrl) {
            [track setValue:transaction.requestUrl forKey:@"uri"];
        }else{
            [track setValue:@"invalidUrl" forKey:@"uri"];
        }
        if (transaction.hasTriedTimes>0) {
            [track setValue:@(transaction.hasTriedTimes) forKey:@"httpIndex"];
        }
        [track setValue:@((int)(transaction.duration * 1000)) forKey:@"duration"];//ms
        if ([transaction.response isKindOfClass:[TTHttpResponseChromium class]]) {
            TTHttpResponseChromium *targetResponse = (TTHttpResponseChromium *)transaction.response;
            TTHttpResponseChromiumTimingInfo * timingInfo = targetResponse.timingInfo;
            [track setValue:@(timingInfo.proxy) forKey:@"timing_proxy"];
            [track setValue:@(timingInfo.dns) forKey:@"timing_dns"];
            [track setValue:@(timingInfo.connect) forKey:@"timing_connect"];
            [track setValue:@(timingInfo.ssl) forKey:@"timing_ssl"];
            [track setValue:@(timingInfo.send) forKey:@"timing_send"];
            [track setValue:@(timingInfo.wait) forKey:@"timing_wait"];
            [track setValue:@(timingInfo.receive) forKey:@"timing_receive"];
            [track setValue:@(timingInfo.total) forKey:@"timing_total"];
            [track setValue:@(timingInfo.receivedResponseContentLength) forKey:@"timing_receivedResponseContentLength"];
            [track setValue:@(timingInfo.totalReceivedBytes) forKey:@"timing_totalReceivedBytes"];
            [track setValue:@(timingInfo.isSocketReused) forKey:@"timing_isSocketReused"];
            [track setValue:@(timingInfo.isCached) forKey:@"timing_isCached"];
            [track setValue:@(timingInfo.isFromProxy) forKey:@"timing_isFromProxy"];
            [track setValue:timingInfo.remoteIP forKey:@"timing_remoteIP"];
            [track setValue:@(timingInfo.remotePort) forKey:@"timing_remotePort"];
            
            TTCaseInsenstiveDictionary *allHeaders = targetResponse.allHeaderFields;
            [track setValue:[allHeaders objectForKey:@"TT-Request-Traceid"] forKey:@"ttnet_trace_id"];
        }
        
        if (needRecorderFail) {
            [[TTMonitor shareManager] trackData:track type:TTMonitorTrackerTypeAPIError];
        }
        if (needRecordAllAPI) {
            if (fail && [TTMonitorConfiguration shareManager].networkStatus==MNNotReachable) {
                return;
            }
            [[TTMonitor shareManager] trackData:track type:TTMonitorTrackerTypeAPIAll];
        }
    }
}

- (void)applyTraceCodeToTrack:(NSMutableDictionary *)dstDict sourceDict:(NSDictionary *)r{
    if (r && [[r allKeys] containsObject:kTraceCodeKey]) {
        NSString * tc = [r objectForKey:kTraceCodeKey];
        if ([tc isKindOfClass:[NSString class]] && [tc length] > 0) {
            [dstDict setValue:tc forKey:@"trace_code"];
        }
    }else{
        [dstDict setValue:@"" forKey:@"trace_code"];
    }
    if (r && [[r allKeys] containsObject:kTraceXCache]) {
        NSString * tc = [r objectForKey:kTraceXCache];
        if ([tc isKindOfClass:[NSString class]] && [tc length] > 0) {
            [dstDict setValue:tc forKey:@"trace_cache"];
        }
    }else{
        [dstDict setValue:@"" forKey:@"trace_cache"];
    }
}

#pragma mark -- trackParams

- (NSDictionary *)pickTrackParams
{
    NSDictionary * commonParams = nil;
    if (_trackParamsblock) {
        commonParams = _trackParamsblock();
    }
    if (![commonParams isKindOfClass:[NSDictionary class]] ||
        [commonParams count] == 0) {
        commonParams = nil;
    }
    return commonParams;
}


@end

