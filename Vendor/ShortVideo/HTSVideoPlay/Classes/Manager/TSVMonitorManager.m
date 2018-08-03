//
//  TSVMonitorManager.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/9/21.
//

#import "TSVMonitorManager.h"
#import "TTMonitor.h"
#import "TTShortVideoModel.h"
#import "AWEVideoConstants.h"
#import "IESVideoPlayerDefine.h"
#import "TTMemoryUsageMonitorRecorder.h"
#import "IESVideoPlayer.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTNetworkHelper.h"

@interface TSVMonitorManager()

@property (nonatomic, strong) NSDictionary *networkServiceNameMapping;
@property (nonatomic, strong) NSMutableDictionary *startTimeDict;
@property (nonatomic, assign) BOOL inShortVideoTab;
@property (nonatomic, assign) BOOL batteryRecordingEnabled;
@property (nonatomic, assign) float batteryRecordingBeginLevel;
@property (nonatomic, assign) CFTimeInterval batteryRecordingBeginTime;
@property (nonatomic, assign) double maxMemoryUsage;

@end

NS_INLINE NSString *IESVideoPlayerTypeStr()
{
    if (IESVideoPlayerTypeSpecify == IESVideoPlayerTypeSystem) {
        return @"Sys";
    } else {
        return @"Own";
    }
}

@implementation TSVMonitorManager

#pragma mark - Public Method

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static TSVMonitorManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[TSVMonitorManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIDeviceBatteryStateDidChangeNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             
             if ([self isBatteryInChargingState]) {
                 self.batteryRecordingEnabled = NO;
             }
         }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             
             [self beginRecordBatteryLevelIfNeeded];
         }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             
             [self endRecordBatteryLevelIfNeeded];
             [self sendMaxMemoryUsage];
             [self sendDiskUsage];
         }];
    }
    return self;
}

- (NSString *)startMonitorNetworkService:(TSVMonitorNetworkService)service key:(id<NSCopying>)key
{    
    NSString *identifier = [NSString stringWithFormat:@"%ld - %f - %@", service, CACurrentMediaTime(), key];
    
    [self.startTimeDict setValue:@(CACurrentMediaTime() * 1000.0) forKey:identifier];
    
    return identifier;
}

- (void)endMonitorNetworkService:(TSVMonitorNetworkService)service identifier:(NSString *)identifier error:(NSError *)error
{
    NSParameterAssert(identifier != nil);
    
    if (!identifier) {
        return;
    }
    
    CFTimeInterval endTime = CACurrentMediaTime() * 1000;
    
    NSString *serviceName = self.networkServiceNameMapping[@(service)];
    
    NSAssert(serviceName, @"TSVMonitor, servicename must not be nil!");
    
    if (!serviceName) {
        return;
    }
    
    NSNumber *startTime = self.startTimeDict[identifier];
    
    NSAssert(startTime, @"TSVMonitor, startTime must not be nil!");
    if (!startTime) {
        return;
    }
    
    [self.startTimeDict removeObjectForKey:identifier];
    
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    if (!error) {
        [mutDict setValue:@(0) forKey:@"status"];
    } else {
        [mutDict setValue:@(1) forKey:@"status"];
        [mutDict setValue:@(error.code) forKey:@"err_code"];
    }
    
    [mutDict setValue:@(endTime - [startTime doubleValue]) forKey:@"time_interval"];
    
    [[TTMonitor shareManager] trackService:serviceName value:[mutDict copy] extra:nil];
}

- (void)trackVideoPlayStatus:(TSVMonitorVideoPlayStatus)status model:(TTShortVideoModel *)model error:(NSError *)error
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    
    [mutDict setValue:@(status) forKey:@"status"];
    [mutDict setValue:IESVideoPlayerTypeStr() forKey:@"player_type"];
    
    if (status == TSVMonitorVideoPlayFailed) {
        [mutDict setValue:@(error.code) forKey:@"err_code"];
        [mutDict setValue:error.localizedDescription forKey:@"err_des"];
        [mutDict setValue:model.itemID forKey:@"mediaId"];
        [mutDict setValue:model.video.playAddr.uri forKey:@"videoUri"];
    }
    
    [[TTMonitor shareManager] trackService:@"tsv_media_service" value:[mutDict copy] extra:nil];
}

- (void)didEnterShortVideoTab
{
    self.inShortVideoTab = YES;
    
    [self beginRecordBatteryLevelIfNeeded];
}

- (void)didLeaveShortVideoTab
{
    self.inShortVideoTab = NO;
    
    [self endRecordBatteryLevelIfNeeded];
}

- (void)recordCurrentMemoryUsage
{
    self.maxMemoryUsage = MAX(self.maxMemoryUsage, memory_now());
}

- (void)sendMaxMemoryUsage
{
    if (self.maxMemoryUsage <= 0) {
        return;
    }
    
    [[TTMonitor shareManager] trackService:@"tsv_memory_usage" value:@(self.maxMemoryUsage) extra:nil];
}

- (void)trackDetailLoadingCellShowWithExtraInfo:(NSDictionary *)extraInfo
{
    [[TTMonitor shareManager] trackService:@"tsv_detail_loading_cell_show" status:0 extra:extraInfo];
}

- (void)trackCategoryResponseWithCategoryID:(NSString *)categoryID listEntrance:(NSString *)listEntrance count:(NSInteger)count error:(NSError *)error
{
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    
    [extra setValue:categoryID forKey:@"tsv_category_id"];
    [extra setValue:listEntrance forKey:@"list_entrance"];
    [extra setValue:@(count) forKey:@"count"];
    
    if (error) {
        [extra setValue:@(error.code) forKey:@"err_code"];
        [extra setValue:error.localizedDescription forKey:@"err_des"];
    }
    
    NSInteger status;
    
    if (count == 0) {//刷新返回条数等于0条，无数据
        status = 1;
    } else if (count <= 6) {//刷新返回条数少于等于6条，过少
        status = 2;
    } else if (count >= 14) {//刷新返回条数大于等于14条，过多
        status = 3;
    } else {
        status = 0;
    }
    
    [[TTMonitor shareManager] trackService:@"tsv_categorylist_data_count" status:status extra:[extra copy]];
}

- (void)trackPictureServiceWithDuration:(CFTimeInterval)duration
                                  error:(nullable NSError *)error
                                 cached:(BOOL)cached
                        isAnimatedImage:(BOOL)isAnimatedImage
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    
    [mutDict setValue:@(duration * 1000) forKey:@"duration"];
    
    [mutDict setValue:[TTNetworkHelper connectMethodName] forKey:@"app_network_type"];

    NSString *serviceName;
    if (isAnimatedImage) {
        serviceName = @"shortvideo_list_animaed_image_failure_rate";
    } else {
        serviceName = @"shortvideo_list_still_image_failure_rate";
    }
    
    if (!error) {
        if (!cached) {
            [[TTMonitor shareManager] trackService:serviceName status:0 extra:[mutDict copy]];
        } else {
            [[TTMonitor shareManager] trackService:serviceName status:1 extra:[mutDict copy]];
        }
    } else {
        [mutDict setValue:@(error.code) forKey:@"err_code"];
        [mutDict setValue:error.localizedDescription forKey:@"err_des"];
        
        [[TTMonitor shareManager] trackService:serviceName status:2 extra:[mutDict copy]];
    }
}

#pragma mark - Private Method

- (void)beginRecordBatteryLevelIfNeeded
{
    if (!self.inShortVideoTab || [self isBatteryInChargingState]) {
        return;
    }
    
    self.batteryRecordingEnabled = YES;
    self.batteryRecordingBeginLevel = [UIDevice currentDevice].batteryLevel;
    self.batteryRecordingBeginTime = CACurrentMediaTime();
}

- (void)endRecordBatteryLevelIfNeeded
{
    if (!self.batteryRecordingEnabled) {
        return;
    }
    
    self.batteryRecordingEnabled = NO;
    
    float batteryUsage = self.batteryRecordingBeginLevel - [UIDevice currentDevice].batteryLevel;
    double duration = (CACurrentMediaTime() - self.batteryRecordingBeginTime) / 60;
    
    if (batteryUsage >= 0 && duration > 0) {
         [[TTMonitor shareManager] trackService:@"tsv_battery_usage" value:@(batteryUsage / duration) extra:nil];
    }
}

- (BOOL)isBatteryInChargingState
{
    UIDeviceBatteryState batteryState = [[UIDevice currentDevice] batteryState];
    
    if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) {
        return YES;
    } else {
        return NO;
    }
}

- (void)sendDiskUsage
{
    id<IESVideoCacheProtocol> shortVideoCache = [IESVideoCache cacheWithType:IESVideoPlayerTypeSpecify];
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    }];
    
    if (bgTask == UIBackgroundTaskInvalid) {
        return;
    }
    
    [shortVideoCache getCacheSizeWithCompletion:^(CGFloat shortVideoCacheSize) {
        [[TTMonitor shareManager] trackService:@"tsv_disk_usage" value:@(shortVideoCacheSize) extra:nil];
        
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    }];
}

#pragma mark - Property

- (NSMutableDictionary *)startTimeDict
{
    if (!_startTimeDict) {
        _startTimeDict = [NSMutableDictionary dictionary];
    }
    return _startTimeDict;
}

- (NSDictionary *)networkServiceNameMapping
{
    if (!_networkServiceNameMapping) {
        _networkServiceNameMapping = @{@(TSVMonitorNetworkServiceCommentList)   : @"tsv_network_commentlist",
                                    @(TSVMonitorNetworkServicePostComment)   : @"tsv_network_postcomment",
                                    @(TSVMonitorNetworkServiceDeleteComment) : @"tsv_network_deletecomment",
                                    @(TSVMonitorNetworkServiceReportComment) : @"tsv_network_reportcomment",
                                    @(TSVMonitorNetworkServiceDiggComment)   : @"tsv_network_diggcomment",
                                    @(TSVMonitorNetworkServiceProfile)       : @"tsv_network_profile",
                                    @(TSVMonitorNetworkServiceFollow)        : @"tsv_network_follow",
                                    @(TSVMonitorNetworkServiceUnfollow)      : @"tsv_network_unfollow"
                                   };
    }
    return _networkServiceNameMapping;
}

@end
