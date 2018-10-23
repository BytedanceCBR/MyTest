//
//  TTMonitorTracker.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/29.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTMonitorTracker.h"
#import "TTMonitorLogIDGenerator.h"
#import "TTMonitorTrackItem.h"
#import <UIKit/UIKit.h>
#import "TTMonitorPersistenceStore.h"
#import "TTExtensions.h"
#import "TTDebugRealMonitorManager.h"
#import "TTMonitorConfiguration.h"

#define kMaxTrackCount 5000

@interface TTMonitorTracker()

@property(nonatomic, strong)NSMutableArray<TTMonitorTrackItem *> * trackers;

@end

@implementation TTMonitorTracker

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        NSArray<TTMonitorTrackItem *> * tracks = [TTMonitorPersistenceStore unarchiveTrackers];
        BOOL isValide = [self isValideDataForTracks:tracks];
        if (isValide) {
            self.trackers = [[NSMutableArray alloc] initWithArray:tracks];
        }
        else {
            self.trackers = [[NSMutableArray alloc] initWithCapacity:100];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}


- (BOOL)isValideDataForTracks:(NSArray<TTMonitorTrackItem *> *)trackers
{
    if (![trackers isKindOfClass:[NSArray class]] || [trackers count] == 0) {
        return NO;
    }
    for (TTMonitorTrackItem * tracker in trackers) {
        if (![tracker isKindOfClass:[TTMonitorTrackItem class]]) {
            return NO;
        }
    }
    return YES;
}

- (void)removeTrackItems:(NSArray<TTMonitorTrackItem *> *)trackItems
{
    if ([trackItems count] > 0) {
        [_trackers removeObjectsInArray:trackItems];
    }
}

- (void)addTrackItems:(NSArray<TTMonitorTrackItem *> *)trackItems
{
    if ([trackItems count] > 0) {
        [_trackers addObjectsFromArray:trackItems];
    }
}

- (void)addImageMonitorItems:(NSArray<TTMonitorTrackItem *> *)trackItems{
    if ([trackItems count] > 0) {
        [_trackers addObjectsFromArray:trackItems];
    }
}

- (NSUInteger)trackItemsCount
{
    return [_trackers count];
}

- (NSArray<TTMonitorTrackItem *> *)monitorTrackers
{
    return _trackers;
}

- (void)trackData:(NSDictionary *)data type:(TTMonitorTrackerType)type
{
    BOOL dataValid = [data isKindOfClass:[NSDictionary class]] && [data count] > 0;
    if (!dataValid) {
        //数据无效
        return;
    }
    
    NSString * logTypeStr = [TTMonitorTracker logTypeStrForType:type];
    [self trackData:data logType:logTypeStr];
}

- (void)trackData:(NSDictionary *)data logType:(NSString *)logTypeStr{
    if (!([logTypeStr isKindOfClass:[NSString class]] &&
          [logTypeStr length] > 0)) {
        return;
    }
    
    @try {
        NSMutableDictionary * tmpDat = [[NSMutableDictionary alloc] initWithDictionary:data];
        [tmpDat setValue:logTypeStr forKey:@"log_type"];
        [tmpDat setValue:[TTMonitorLogIDGenerator generateALogID] forKey:@"log_id"];
        if (![tmpDat valueForKey:@"network_type"]) {
            [tmpDat setValue:@([TTMonitorConfiguration shareManager].networkStatus) forKey:@"network_type"];
        }
        
        TTMonitorTrackItem * item = [[TTMonitorTrackItem alloc] init];
        item.track = tmpDat;
        item.retryCount = 0;
        [_trackers addObject:item];
        
        /**
         *  超过kMaxTrackCount，丢弃队首。
         *  测试kMaxTrackCount条大概增加2M左右的内存使用，这种情况能出现都是极端情况，
         *  因为服务不是无损的，所以这种情况将最早进入队列的数据直接丢弃。
         */
        if ([_trackers count] >= kMaxTrackCount) {
            [_trackers removeObjectAtIndex:0];
        }
    }
    @catch (NSException *exception) {
        [_trackers removeAllObjects];
    }
    @finally {
        
    }
    
}
- (void)debugRealEvent:(NSString *)event label:(NSString *)label traceCode:(NSString *)traceCode userInfo:(NSDictionary *)userInfo{
    NSString * logTypeStr = [TTMonitorTracker logTypeStrForType:TTMonitorTrackerTypeDebug];
    @try {
        NSMutableDictionary * tmpDat = [[NSMutableDictionary alloc] init];
        [tmpDat setValue:logTypeStr forKey:@"log_type"];
        [tmpDat setValue:event forKey:@"d_key"];
        [tmpDat setValue:label forKey:@"value"];
        [tmpDat setValue:[TTMonitorLogIDGenerator generateALogID] forKey:@"log_id"];
        [tmpDat setValue:traceCode forKey:@"trace_code"];
        if (userInfo && [userInfo isKindOfClass:[NSDictionary class]] && userInfo.count>0) {
            [tmpDat addEntriesFromDictionary:userInfo];
        }
        TTMonitorTrackItem * item = [[TTMonitorTrackItem alloc] init];
        item.track = tmpDat;
        item.retryCount = 0;
        [_trackers addObject:item];
        /**
         *  超过kMaxTrackCount，丢弃队首。
         *  测试kMaxTrackCount条大概增加2M左右的内存使用，这种情况能出现都是极端情况，
         *  因为服务不是无损的，所以这种情况将最早进入队列的数据直接丢弃。
         */
        if ([_trackers count] >= kMaxTrackCount) {
            [_trackers removeObjectAtIndex:0];
        }
    }
    @catch (NSException *exception) {
        [_trackers removeAllObjects];
    }
    @finally {
    }
}

#pragma mark -- util

/**
 *  根据type返回发送给server的字符串, OC暂时不支持字符串枚举，未来迁到swift，应把这种转换都去掉
 *
 *  @param type 定义的tracker的类型
 *
 *  @return 发送给server的字符串,如果是未知类型，返回nil
 */
+ (NSString *)logTypeStrForType:(TTMonitorTrackerType)type
{
    NSString * logTypeStr = nil;
    switch (type) {
        case TTMonitorTrackerTypeAPIError:
        {
            logTypeStr = @"api_error";
        }
            break;
        case TTMonitorTrackerTypeAPISample:
        {
            logTypeStr = @"api_sample";
        }
            break;
        case TTMonitorTrackerTypeDNSReport:
        {
            logTypeStr = @"dns_report";
        }
            break;
        case TTMonitorTrackerTypeDebug:
        {
            logTypeStr = @"debug_real";
        }
            break;
        case TTMonitorTrackerTypeAPIAll:
        {
            logTypeStr = @"api_all";
        }
            break;
        case TTMonitorTrackerTypeHTTPHiJack:
        {
            logTypeStr = @"ss_sign_sample";
        }
            break;
        case TTMonitorTrackerTypeLocalLog:
        {
            logTypeStr = @"log_exception";
        }
            break;
        default:
        {
            logTypeStr = nil;
        }
            break;
    }
    return logTypeStr;
}

#pragma mark -- receiveNotification

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [TTDebugRealMonitorManager cacheDevLogWithEventName:@"app_willterminate" params:nil];
    [TTMonitorPersistenceStore archiveTrackItems:self.trackers];
}

- (void)clear{
    [_trackers removeAllObjects];
}
@end
