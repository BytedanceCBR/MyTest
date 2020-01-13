//
//  TTUGCImageMonitor.m
//  TTUGCFeature
//
//  Created by SongChai on 2018/3/5.
//

#import "TTUGCImageMonitor.h"
#import <pthread.h>
#import <mach/mach_time.h>
#import "TTTrackerWrapper.h"
#import "NetworkUtilities.h"
#import "TTMonitor.h"
#import "TTUGCImageHelper.h"

@interface TTUGCImageMonitorModel : NSObject
@property (nonatomic, assign) uint64_t startTime;
@property (nonatomic, strong) FRImageInfoModel *imageModel;
@end

@implementation TTUGCImageMonitorModel
@end

@implementation TTUGCImageMonitor
static pthread_mutex_t stopWatchMutex = PTHREAD_MUTEX_INITIALIZER;

+ (NSMutableDictionary *)watches {
    static NSMutableDictionary *Watches = nil;
    static dispatch_once_t OnceToken;
    dispatch_once(&OnceToken, ^{
        Watches = @{}.mutableCopy;
    });
    return Watches;
}

+ (long)millisecondsFromMachTime:(uint64_t)time {
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time * (double)timebase.numer /
    (double)timebase.denom / 1e6;
}

+ (void)startWithImageModel:(FRImageInfoModel *)imageModel {
    if (imageModel == nil) {
        return;
    }
    NSURL *URL = [imageModel.url ttugc_feedImageURL];
    if (URL == nil) {
        return;
    }
    pthread_mutex_lock(&stopWatchMutex);
    
    TTUGCImageMonitorModel *model = [[TTUGCImageMonitorModel alloc] init];
    model.imageModel = imageModel;
    model.startTime = mach_absolute_time();
    [self.watches setObject:model forKey:URL];
    
    pthread_mutex_unlock(&stopWatchMutex);
}

+ (void)inCacheImageModel:(FRImageInfoModel *)imageModel {
    [self recordImageModel:imageModel inCache:YES result:@"success"];
}

+ (void)requestCompleteWithImageModel:(FRImageInfoModel *)imageModel withSuccess:(BOOL)success {
    [self recordImageModel:imageModel inCache:NO result:success? @"success": @"fail"];
}

+ (void)stopWithImageModel:(FRImageInfoModel *)imageModel {
    [self recordImageModel:imageModel inCache:NO result:@"cancel"];
}

+ (void)recordImageModel:(FRImageInfoModel *)imageModel inCache:(BOOL)inCache result:(NSString *)result {
    if (imageModel == nil) {
        return;
    }
    NSURL *URL = [imageModel.url ttugc_feedImageURL];
    if (URL == nil) {
        return;
    }
    pthread_mutex_lock(&stopWatchMutex);
    
    TTUGCImageMonitorModel *model = [self.watches objectForKey:URL];
    if (model) {
        uint64_t end = mach_absolute_time();
        long interval = [self millisecondsFromMachTime:end - model.startTime];
        NSString *netState = @"other";
        if (TTNetworkWifiConnected()) {
            netState = @"wifi";
        } else if (TTNetowrkCellPhoneConnected()) {
            netState = @"cellular";
        }
        
        [TTTracker eventV3:@"ugc_image_firstframe_monitor" params:@{@"time": @(interval),
                                                                    @"is_cache": @(inCache),
                                                                    @"format": @(model.imageModel.type),
                                                                    @"net_state": netState,
                                                                    @"result": result
                                                                    }];
        [self.watches removeObjectForKey:URL];
    }
    
    pthread_mutex_unlock(&stopWatchMutex);
}

#pragma mark - gif下载统计
+ (void)trackGifDownloadSucceed:(BOOL)succeed index:(NSUInteger)index costTimeInterval:(NSTimeInterval)costTimeInterval {
    [[TTMonitor shareManager] trackService:@"ugc_gif_download" status:succeed?0:1 extra:@{@"costTime":@(costTimeInterval)}];
}

@end
