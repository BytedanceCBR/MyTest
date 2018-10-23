//
//  TTImageMonitorManager.m
//  Pods
//
//  Created by 苏瑞强 on 2017/6/8.
//
//

#import "TTImageMonitorManager.h"
//#import "TTHttpResponseAFNetworking.h"
#import "TTNetworkDefine.h"
#import "TTNetworkMonitorRecorder.h"
#import "TTNetworkMonitorRecorder.h"
#import "TTNetworkMonitorTransaction.h"
#import "TTHttpResponseChromium.h"
#import "TTMonitorTrackItem.h"
#import "TTMonitorTracker.h"
#import "TTMonitorConfiguration.h"
#import "TTExtensions.h"
#import "TTMonitorLogIDGenerator.h"

#define kTraceCodeKey @"X-TT-LOGID"
#define kTraceXCache @"X-Cache"
#define kImageMonitor @"image_monitor"
#define kPollingInterval @"pollingInterval"

@interface TTImageMonitorManager ()
@property (nonatomic, strong) dispatch_queue_t image_queue;

@end

@implementation TTImageMonitorManager

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)isImageRequest:(NSString *)url{
    return NO;
}

- (id)init{
    self = [super init];
    if (self) {
        self.image_queue = dispatch_queue_create("com.imagemonitor.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}


+ (instancetype)sharedImageMonitor{
    static TTImageMonitorManager *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [[[self class] alloc] init];
    });
    return defaultRecorder;
}

- (void)setPollingInterval:(NSInteger)pollingInterval{
    [[NSUserDefaults standardUserDefaults] setInteger:pollingInterval forKey:kPollingInterval];
}

-(NSInteger)pollingInterval{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kPollingInterval];
}

- (void)recordIfNeed:(TTNetworkMonitorTransaction *)transaction{
    if (!transaction.requestUrl) {
        return;
    }
    if (![TTMonitorConfiguration isEnabledForLogType:kImageMonitor]){
        return;
    }
    NSURL * requestUrl = [NSURL URLWithString:transaction.requestUrl];
    NSString * schema = requestUrl.scheme;
    NSString * host = requestUrl.host;
    NSString * key = [NSString stringWithFormat:@"%@_%@_%d", schema,host, transaction.status];
    if (!self.imageTrackers) {
        self.imageTrackers = [[NSMutableDictionary alloc] init];
    }
    __block NSMutableDictionary * storeItem;
    dispatch_sync(self.image_queue, ^{
        storeItem = [self.imageTrackers valueForKey:key];
    });
    if (storeItem) {
        [self updateItem:transaction storeKey:key];
    }else{
        [self insertItem:transaction storeKey:key];
    }
}

- (void)insertItem:(TTNetworkMonitorTransaction *)transaction storeKey:(NSString *)storeKey{
    NSMutableDictionary * track = [NSMutableDictionary dictionaryWithCapacity:10];
    if (transaction.startTime) {
        [track setValue:@((NSInteger)([transaction.startTime timeIntervalSince1970] * 1000)) forKey:@"timestamp"];//毫秒
    }
    
    [track setValue:@(transaction.status) forKey:@"status"];
    if (transaction.response && [transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
        
    }
    
    if (transaction.error && [transaction.error isKindOfClass:[NSError class]]) {
        [track setValue:transaction.error.description forKey:@"error_desc"];//没有traceCode就传空值
    }
    
    NSDictionary * pickTrackParams = [[TTNetworkMonitorRecorder defaultRecorder] pickTrackParams];
    if ([pickTrackParams isKindOfClass:[NSDictionary class]] &&
        [pickTrackParams count] > 0) {
        [track addEntriesFromDictionary:pickTrackParams];
    }
    [track setValue:@"image_monitor" forKey:@"log_type"];

    if (transaction.requestUrl) {
        [track setValue:transaction.requestUrl forKey:@"uri"];
    }else{
        [track setValue:@"invalidUrl" forKey:@"uri"];
    }
    [track setValue:[TTMonitorLogIDGenerator generateALogID] forKey:@"log_id"];
    [track setValue:@([TTMonitorConfiguration shareManager].networkStatus) forKey:@"network_type"];

    NSURL * url = [NSURL URLWithString:transaction.requestUrl];
    NSString *IPAddress = [TTExtensions addressOfHost:[url host]];
    [track setValue:IPAddress forKey:@"ip"];

    if (transaction.hasTriedTimes>0) {
        [track setValue:@(transaction.hasTriedTimes) forKey:@"httpIndex"];
    }
    [track setValue:@((int)(transaction.duration * 1000)) forKey:@"duration"];//ms
    [track setValue:@(1) forKey:@"count"];//ms
    dispatch_barrier_async(self.image_queue, ^{
        [self.imageTrackers setValue:track forKey:storeKey];
    });

}

- (void)updateItem:(TTNetworkMonitorTransaction *)transaction storeKey:(NSString *)storeKey{
    __block NSMutableDictionary * storeItem;
    dispatch_sync(self.image_queue, ^{
        storeItem = [self.imageTrackers valueForKey:storeKey];
    });
    if ([storeItem isKindOfClass:[NSMutableDictionary class]]) {
        NSInteger number = [[storeItem valueForKey:@"count"] integerValue];
        number++;
        [storeItem setValue:@(number) forKey:@"count"];
        double duration = [[storeItem valueForKey:@"duration"] longLongValue] + transaction.duration * 1000;
        [storeItem setValue:@(duration) forKey:@"duration"];
    }
}

#define kTTmonitorConfigurationImageMonitorTimestampKey @"kTTmonitorConfigurationImageMonitorTimestampKey"

//判断是否需要更新配置
+(BOOL)_needPollingImageMonitorDataz
{
    NSTimeInterval latelyTimestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:kTTmonitorConfigurationImageMonitorTimestampKey] doubleValue];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if ((now - latelyTimestamp) > [TTImageMonitorManager sharedImageMonitor].pollingInterval) {
        return YES;
    }
    return NO;
}

/**
 *  更新最近更新配置时间
 */
+ (void)_updateLatelyUpdateTimestamp
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setValue:@(now) forKey:kTTmonitorConfigurationImageMonitorTimestampKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)packageImageMonitorData{
    if (![TTImageMonitorManager _needPollingImageMonitorDataz]) {
        return nil;
    }
    NSMutableArray * imageMonitorItems = [[NSMutableArray alloc] init];
    [self.imageTrackers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        TTMonitorTrackItem * item = [[TTMonitorTrackItem alloc] init];
        item.track = obj;
        item.retryCount = 0;
        if (item) {
            [imageMonitorItems addObject:item];
        }
    }];
    [TTImageMonitorManager _updateLatelyUpdateTimestamp];
    dispatch_barrier_async(self.image_queue, ^{
       [self.imageTrackers removeAllObjects];
    });
    return [imageMonitorItems copy];
}

@end
