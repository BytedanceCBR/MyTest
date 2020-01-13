//
//  TTUGCImageRecordManager.m
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/10/10.
//

#import "TTUGCImageRecordManager.h"
#import <pthread/pthread.h>
#import "TTMonitor.h"
#import <TTKitchenExtension/TTKitchenExtension.h>
#import <TTKitchen.h>
#import <FRImageInfoModel.h>
#import <BDWebImageManager.h>
#import "TTUGCImageView.h"
#import "TTUGCImageHelper.h"

#import <TTUserSettingsManager+NetworkTraffic.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <NSTimer+Additions.h>
#import "TTUGCImageKitchen.h"

@implementation TTUGCImageRecordModel

@end

@interface TTUGCImageRecordManager ()

@property (nonatomic, assign) BOOL stopRecordThumb;
@property (nonatomic, assign) BOOL stopRecordGif;

@end

@implementation TTUGCImageRecordManager {
    pthread_mutex_t _lock;
    NSMutableDictionary *_mutDict;
    NSMutableArray *_mutArray;
    NSMutableArray *_costMutArray;
    NSUInteger _statusRecCount;
    
    NSMutableDictionary *_gifDict;
    pthread_mutex_t _gifLock;
    
    NSTimer *_gifTimer;
    NSUInteger _gifTrackCount;
    NSUInteger _gifTimerCount;
}

+ (instancetype)sharedInstance {
    static TTUGCImageRecordManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTUGCImageRecordManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        _mutDict = [NSMutableDictionary dictionaryWithCapacity:100];
        _mutArray = [NSMutableArray arrayWithCapacity:50];
        _costMutArray = [NSMutableArray arrayWithCapacity:10];
        _statusRecCount = 0;
        _stopRecordThumb = NO;
        
        pthread_mutex_init(&_gifLock, NULL);
        _gifDict = [NSMutableDictionary dictionaryWithCapacity:10];
        
        _gifTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(onGifTimerFired) userInfo:nil repeats:YES];
        _gifTrackCount = 0;
        _gifTimerCount = 0;
        
        [self configBDFilter];
        //得把BD的设置了，否则不准。
    }
    return self;
}

- (void)configBDFilter {
    static dispatch_once_t onceTokenBDFilter;
    dispatch_once(&onceTokenBDFilter, ^{
        BDWebImageURLFilter *originFilter = [BDWebImageManager sharedManager].urlFilter;
        if ([originFilter isKindOfClass:[TTUGCBDWebImageURLFilter class]]) {
            return;
        }
        BDWebImageURLFilter *newFilter = [[TTUGCBDWebImageURLFilter alloc] initWithOriginFilter:originFilter];
        [BDWebImageManager sharedManager].urlFilter = newFilter;
    });
    
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

- (BOOL)shouldRecordForKey:(NSString *)key {
    if (self.stopRecordThumb == YES) {
        return NO;
    }
    
    
    
    //这个方法也没想清楚
    pthread_mutex_lock(&_lock);
    BOOL result;
    TTUGCImageRecordModel *model = [_mutDict valueForKey:key];
    if (model && model.status != TTUGCImageRecordStatusStart) {
        result = NO;
    } else {
        result = YES;
    }
    pthread_mutex_unlock(&_lock);
    return result;
}

- (void)startRecordForKey:(NSString *)key {
    if (self.stopRecordThumb == YES) {
        return;
    }
    
    
    pthread_mutex_lock(&_lock);
    
    if (![_mutDict valueForKey:key]) {
        //已经还没有给这个key建档，需要开始统计。
        TTUGCImageRecordModel *model = [[TTUGCImageRecordModel alloc] init];
        model.key = key;
        model.startTime = CFAbsoluteTimeGetCurrent();
        model.status = TTUGCImageRecordStatusStart;
        [_mutDict setValue:model forKey:key];
    }
    
    pthread_mutex_unlock(&_lock);
}

- (void)recordAlreadyForKey:(NSString *)key {
    if (self.stopRecordThumb == YES) {
        return;
    }
        
    pthread_mutex_lock(&_lock);
    TTUGCImageRecordModel *model = [_mutDict valueForKey:key];
    if (model && model.status == TTUGCImageRecordStatusStart) {
        model.status = TTUGCImageRecordStatusAlready;
        [self tryMonitorStatusWithModel:model];
    }
    pthread_mutex_unlock(&_lock);
}

- (void)recordCostForKey:(NSString *)key {
    if (self.stopRecordThumb == YES) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    TTUGCImageRecordModel *model = [_mutDict valueForKey:key];
    if (model && model.status == TTUGCImageRecordStatusStart) {
        model.status = TTUGCImageRecordStatusCostTime;
        model.endTime = CFAbsoluteTimeGetCurrent();
        model.costTime = model.endTime - model.startTime;
        
        if (model.costTime < 0.15) {
            model.status = TTUGCImageRecordStatusAlready;
        } else {
            [self tryRecordCostWithModel:model];
        }
        
        [self tryMonitorStatusWithModel:model];
    }
    pthread_mutex_unlock(&_lock);
    
}

- (void)recordFailForKey:(NSString *)key {
    if (self.stopRecordThumb == YES) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    TTUGCImageRecordModel *model = [_mutDict valueForKey:key];
    if (model && model.status == TTUGCImageRecordStatusStart) {
        model.status = TTUGCImageRecordStatusFailed;
        [self tryMonitorStatusWithModel:model];
    }
    pthread_mutex_unlock(&_lock);
    
}

- (void)tryMonitorStatusWithModel:(TTUGCImageRecordModel *)model {
    [_mutArray addObject:model];
    if ([_mutArray count] >= 20) {
        double totalNum = (double)[_mutArray count];
        __block double alreadyNum = 0, costNum = 0, failNum = 0;
        [_mutArray enumerateObjectsUsingBlock:^(TTUGCImageRecordModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            switch (obj.status) {
                case TTUGCImageRecordStatusAlready: {
                    alreadyNum += 1.0;
                }
                    break;
                case TTUGCImageRecordStatusCostTime: {
                    costNum += 1.0;
                }
                    break;
                case TTUGCImageRecordStatusFailed: {
                    failNum += 1.0;
                }
                    break;
                default:
                    break;
            }
        }];
        double alreadyPercent = 0.0, costPercent = 0.0, failPercent = 0.0;
        alreadyPercent = alreadyNum/totalNum;
        costPercent = costNum/totalNum;
        failPercent = failNum/totalNum;
        NSMutableDictionary *trackDict = @{}.mutableCopy;
        NSString *prefix = @"bd";
        prefix = [prefix stringByAppendingString: TTNetworkWifiConnected() ? @"_wifi":@"_notwifi"];

        [trackDict setValue:@(alreadyPercent) forKey:[NSString stringWithFormat:@"%@-already",prefix]];
        [trackDict setValue:@(costPercent) forKey:[NSString stringWithFormat:@"%@-cost",prefix]];
        [trackDict setValue:@(failPercent) forKey:[NSString stringWithFormat:@"%@-fail",prefix]];
        [[TTMonitor shareManager] trackService:@"ugc_pic_load_status" attributes:trackDict];

        [_mutArray removeAllObjects];
        
        _statusRecCount++;
        if (_statusRecCount >=3) {
            _stopRecordThumb = YES;
        }

    }
}

- (void)tryRecordCostWithModel:(TTUGCImageRecordModel *)model {
    //改了吧，按个数统计。加个采样。
    CGFloat sample = [TTKitchen getFloat:kTTKUGCPicRecordCostTimeSample];
    if (model.endTime - (long)(model.endTime) < sample) {
        NSMutableDictionary *trackDict = @{}.mutableCopy;
        NSString *prefix = @"bd";
        prefix = [prefix stringByAppendingString: TTNetworkWifiConnected() ? @"_wifi":@"_notwifi"];
        [trackDict setValue:@(model.costTime) forKey:[NSString stringWithFormat:@"%@-cost",prefix]];
        [[TTMonitor shareManager] trackService:@"ugc_pic_show_time" attributes:trackDict];
    }
}



#pragma mark - 这些是封装的时机方法
- (void)trackWillAppearForImageModel:(FRImageInfoModel *)imageModel {
    if (self.stopRecordThumb == YES) {
        return;
    }
    
    NSURL *imageURL = [imageModel.url ttugc_feedImageURL];
    //bd
    NSString *key = [[BDWebImageManager sharedManager] requestKeyWithURL:imageURL];
    if (!isEmptyString(key)) {
        [self startRecordForKey:key];
        if ([self shouldRecordForKey:key]) {
            //思考了下，memory的算already，disk的走cost
            if ([[BDImageCache sharedImageCache] containsImageForKey:key type:BDImageCacheTypeMemory]) {
                [self recordAlreadyForKey:key];
            }
        }
    }
        
}

- (void)trackDidDisappearForImageModel:(FRImageInfoModel *)imageModel {
    if (self.stopRecordThumb) {
        return;
    }
    
    NSURL *imageURL = [imageModel.url ttugc_feedImageURL];
    NSString *key;
    //bd
    key = [[BDWebImageManager sharedManager] requestKeyWithURL:imageURL];
    if (!isEmptyString(key)) {
        [self recordFailForKey:key];
    }
}

- (void)trackSetImageForImageModel:(FRImageInfoModel *)imageModel {
    NSString *urlStr = imageModel.url;
    [self trackSetImageForURLStr:urlStr];
}

- (void)trackSetImageForURLStr:(NSString *)urlStr {
    NSURL *imageURL = [urlStr ttugc_feedImageURL];
    [self trackSetImageForURL:imageURL];
}

- (void)trackSetImageForURL:(NSURL *)url {
    if (self.stopRecordThumb) {
        return;
    }
    NSString *key;
    //bd
    key = [[BDWebImageManager sharedManager] requestKeyWithURL:url];
    if (!isEmptyString(key)) {
        [self recordCostForKey:key];
    }
    
}

#pragma mark - gif相关
- (void)trackAlreadyForGifKey:(NSString *)gifKey {
    if (self.stopRecordGif == YES || isEmptyString(gifKey)) {
        return;
    }
    
    pthread_mutex_lock(&_gifLock);
    TTUGCImageRecordModel *model = [_gifDict valueForKey:gifKey];
    if (!model) {
        //没有才记录，有就直接过了。
        model = [[TTUGCImageRecordModel alloc] init];
        model.status = TTUGCImageRecordStatusAlready;
        [self tryMonitorGifWithModel:model];
        [_gifDict setObject:model forKey:gifKey];
    }
    pthread_mutex_unlock(&_gifLock);
}

- (void)trackWaitingForGifKey:(NSString *)gifKey {
    if (self.stopRecordGif == YES || isEmptyString(gifKey)) {
        return;
    }
    pthread_mutex_lock(&_gifLock);
    TTUGCImageRecordModel *model = [_gifDict valueForKey:gifKey];
    if (!model) {
        model = [[TTUGCImageRecordModel alloc] init];
        model.status = TTUGCImageRecordStatusStart;
        model.startTime = CFAbsoluteTimeGetCurrent();
        [_gifDict setObject:model forKey:gifKey];
    }
    pthread_mutex_unlock(&_gifLock);
}

- (void)trackWaitingSuccessForGifModel:(FRImageInfoModel *)gifModel {
    if (self.stopRecordGif == YES) {
        return;
    }
    NSString *key;
    NSURL *url = [gifModel.url ttugc_feedImageURL];
    key = [[BDWebImageManager sharedManager] requestKeyWithURL:url];
    [self trackWaitingSuccessForGifKey:key];
}

- (void)trackWaitingSuccessForGifKey:(NSString *)gifKey {
    if (self.stopRecordGif == YES || isEmptyString(gifKey)) {
        return;
    }
    pthread_mutex_lock(&_gifLock);
    TTUGCImageRecordModel *model = [_gifDict valueForKey:gifKey];
    if (model && model.status == TTUGCImageRecordStatusStart) {
        model.status = TTUGCImageRecordStatusCostTime;
        model.endTime = CFAbsoluteTimeGetCurrent();
        model.costTime = model.endTime - model.startTime;
        [self tryMonitorGifWithModel:model];

    }
    pthread_mutex_unlock(&_gifLock);
    
}

- (void)onGifTimerFired {
    if (self.stopRecordGif) {
        return;
    }
    _gifTimerCount++;

    if ([_gifDict count]) {
        pthread_mutex_lock(&_gifLock);
        [_gifDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TTUGCImageRecordModel * _Nonnull model, BOOL * _Nonnull stop) {
            if (model.status == TTUGCImageRecordStatusStart && CFAbsoluteTimeGetCurrent() - model.startTime > 30.0) {
                model.status = TTUGCImageRecordStatusFailed;
                [self tryMonitorGifWithModel:model];
            }
        }];
        pthread_mutex_unlock(&_gifLock);
    }
    if (_gifTimerCount >= 20) {
        _stopRecordGif = YES;
        [_gifTimer invalidate];
    }
}

- (void)tryMonitorGifWithModel:(TTUGCImageRecordModel *)gifModel {
    NSString *result;
    switch (gifModel.status) {
        case TTUGCImageRecordStatusAlready:
            result = @"already";
            break;
        case TTUGCImageRecordStatusCostTime:
            result = @"costTime";
            break;
        case TTUGCImageRecordStatusFailed:
            result = @"notPlay";
            break;
        case TTUGCImageRecordStatusStart:
        default:
            result = @"invalid";
            break;
    }
    NSString *statusKey = @"bd_2";
    
    NSMutableDictionary *trackDict = @{}.mutableCopy;
    if (gifModel.status == TTUGCImageRecordStatusCostTime) {
        [trackDict setValue:@(gifModel.costTime) forKey:[statusKey stringByAppendingString:@"_cost_time"]];
    }
    [trackDict setValue:result forKey:statusKey];
    [[TTMonitor shareManager] trackService:@"ugc_pic_gif_play" attributes:trackDict];
    _gifTrackCount++;
    if (_gifTrackCount >= 20) {
        _stopRecordGif = YES;
    }
}



#pragma mark - Getter
- (BOOL)stopRecordThumb {
    return _stopRecordThumb
    || [TTUserSettingsManager networkTrafficSetting]  == TTNetworkTrafficSave
    || ![TTKitchen getBOOL:kTTKUGCPicRecordThumbEnabled];
}

- (BOOL)stopRecordGif {
    return _stopRecordGif
    || !TTNetworkWifiConnected()
    || ![TTKitchen getBOOL:kTTKUGCPicRecordGifEnabled];
}

@end








