//
//  SSADManager.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-13.
//
//

#import "ArticleDetailHeader.h"
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import "SSADActionManager.h"
#import "SSADFetchInfoManager.h"
#import "SSADManager.h"
#import "SSADModel.h"
#import "SSADSplashControllerView.h"
#import "SSADSplashDownloadManager.h"
#import "SSActionManager.h"
#import "SSCommonLogic.h"
#import "SSSimpleCache.h"
#import "SSWebViewController.h"
#import "TTAdManager.h"
#import "TTAdMonitorManager.h"
#import "TTAppLinkManager.h"
#import "TTRoute.h"
#import "TTStringHelper.h"
#import "TTThemedAlertController.h"
#import <objc/runtime.h>
#import <TTTracker/TTTrackerProxy.h>
//#import "SSADManager_Private.h"
#import "VVeboImage.h"
#import "TTLocationManager.h"
#import "TTAdAppDownloadManager.h"

#define splashADActionTypeWeb @"web"
#define splashADActionTypeApp @"app"

#define kUDSSADManagerSplashModelsKey @"kUDSSADManagerSplashModelsKeyV4"//保存area广告modelskey， 目前api5.0版本
#define kUDSSADManagerModelsKey @"kUDSSADManagerModelsKeyV4" //保存广告key， 目前api5.0版本, model版本兼容老版本。
#define kSSADRecentlyEnterBackgroudTimeKey @"kSSADRecentlyEnterBackgroudTimeKey"//保存最近一次退到后台的时间
#define kSSADRecentlyShowSplashADTimeKey @"kSSADRecentlyShowSplashADTimeKey"//保存最近一次展示splash广告的时间
#define kSSADRecentlyTrackInfoKey @"kSSADRecentlyTrackInfoKey" //保存最近一次的trackInfo
#define kSSADRecentlyTrackInfoListKey @"kSSADRecentlyTrackInfoListKey" //保存最近一次的trackInfo
                                                    

//调用didbecomeAcitve允许的最小间隔
#define kInvokeDidBecomeActiveMinInterval 20
const static NSInteger minShowInterval  = 600; // 开屏广告最小展示间隔 10 min = 600s
const static NSInteger minLeaveInterval = 30; // 开屏广告最小离开前台间隔 30s
const static NSInteger callbackPatience = 30000; // 从第三方app召回最长忍耐时间 30 000ms

#if 0
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...)
#endif

NSString *const kSSADShowFinish = @"kSSADShowFinish";

// 用来标识本轮广告计划是否轮空
NSString *const kSSADSplashEmptyKey = @"kSSADSplashEmptyKey";
NSString *const kSSADPickedModelKey = @"kSSADPickedModelKey";
NSString *const kSSADPickedReadyResultKey = @"kSSADPickedReadyResultKey";
NSString *const kTTADSplashTodayShowIdentify = @"kTTADSplashTodayShowIdentify";  //保存开屏的 今日标识： 2017-01-03


typedef BOOL(^CheckArea)(SSADModel *model);

@interface SSADManager()<SSADSplashControllerViewDelegate>
{
    /**
     *  记录成功的时间
     */
    NSTimeInterval _latelyDidBecomeActiveTimeInterval;
}

@property(nonatomic, strong)SSADSplashDownloadManager * splashDownloadManager;
@property(nonatomic, strong)SSADSplashControllerView * controllerView;

@end

@implementation SSADManager

@synthesize splashDownloadManager = _splashDownloadManager;

+ (void)initialize
{
    DLog(@"AD: SSADManager life begin");
    [SSADManager clearSSADRecentlyEnterBackgroundTime];
    [SSADManager clearSSADRecentlyShowSplashTime];
}

+ (SSADManager *)shareInstance
{
    static SSADManager * adManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adManager = [[self alloc] init];
    });
    return adManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _adShow = NO;
        _finishCheck = NO;
        _splashADShowType = SSSplashADShowTypeShow;
        _resouceType = SSAdSplashResouceType_None;
        _showByForground = NO;
        _latelyDidBecomeActiveTimeInterval = 0;
        // 默认是NO，本轮不轮空
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{kSSADSplashEmptyKey : @NO}];
    }
    return self;
}

- (void)dealloc
{
    DLog(@"AD: SSADManager instance life end");
}

#pragma mark - First-Splash

+ (BOOL)checkoutFirstLaunch {
    BOOL isFirstLaunch = NO;
    NSString *todayIdentity = [TTBusinessManager onlyDateStringSince:[[NSDate date] timeIntervalSince1970]];// 2017-01-04
    NSString *historyIdentity = [[NSUserDefaults standardUserDefaults] stringForKey:kTTADSplashTodayShowIdentify];
    if ([todayIdentity isEqualToString:historyIdentity]) {
        isFirstLaunch = NO;
    } else {
        isFirstLaunch = YES;
    }
    return  isFirstLaunch;
}

+ (void)setFirstLaunch {
    NSString *todayIdentity = [TTBusinessManager onlyDateStringSince:[[NSDate date] timeIntervalSince1970]];// 2017-01-04
    [[NSUserDefaults standardUserDefaults] setObject:todayIdentity forKey:kTTADSplashTodayShowIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)checkoutFirstSplashEnable {
    // 1 检查 setting 开关
    if (![SSCommonLogic isFirstSplashEnable]) {
        DLog(@"AD: %@  reason =  %@", NSStringFromSelector(_cmd), @"Switch Off");
        return NO;
    }
    // 2 是否当天 第一次
    BOOL isFirstLaunch = [self checkoutFirstLaunch];
    DLog(@"AD: %@  is First =  %d", NSStringFromSelector(_cmd), isFirstLaunch);
    return isFirstLaunch;
}

#pragma mark - pick Model

/**
 *  挑选适合的splash model策略
 *  1.采用FirstLaunch or Non的广告模型
 *  2.model是否过期， 是否没有达到预期时间
 *  3.是否超过上次启动时间间隔(记录用户退到后台的时间T1，当用户非杀死状态回到前台的时候T2， 比较T2与T1的时间间隔是否大于display_interval。如果用户杀死状态进入的应用，则清除T1（不进行display_interval判断)
 *  4.分辨率是否正确(Pad)
 *  5.图片是否下载成功
 */

+ (SSADModel *)pickedFitSplashModelWithTrackInfoList:(SSADTrackInfoList *)trackList
{
    DLog(@"AD: %@", NSStringFromSelector(_cmd));
    BOOL isEmptyOrder = [[NSUserDefaults standardUserDefaults] boolForKey:kSSADSplashEmptyKey];
    if (isEmptyOrder) {
        return nil;
    }
    
    NSArray *models = [SSADManager getADControlSplashModels];
    if (SSIsEmptyArray(models)) {
        return nil;
    }
    DLog(@"AD: begin select models<%@>", models);
    SSADModel *suitableADModel = nil;
    if ([self checkoutFirstSplashEnable]) {
        suitableADModel = [self checkoutFirstLaunchModel:models with:trackList];
    } else {
        suitableADModel = [self checkoutNonfirstLaunchModel:models with:trackList];
    }
    return suitableADModel;
}

+ (SSADModel *)checkoutNonfirstLaunchModel:(NSArray<SSADModel *> *) splashModels with:(SSADTrackInfoList *) trackList {
    DLog(@"AD: %@", NSStringFromSelector(_cmd));
    if (SSIsEmptyArray(splashModels)) {
        return nil;
    }
    
    SSADModel *suitableADModel = nil;
    // 1. 关闭首刷逻辑，检查所有广告类型 2. 开启首刷逻辑，检查GD CPT广告
    BOOL isFirstSplashEnable = [SSCommonLogic isFirstSplashEnable];
    if (isFirstSplashEnable) {
        suitableADModel = [self pickKindOfModel:splashModels with:trackList area:^BOOL(SSADModel *model) {
            return model.commerceType != TTSplashADCommerceTypeFirst;
        }];
    } else {
        suitableADModel = [self pickKindOfModel:splashModels with:trackList area:^BOOL(SSADModel *model) {
            return YES;
        }];
    }
    return suitableADModel;
}

/**
 * 1 查找符合 开屏首刷的广告
 * 2 副作用 消耗一次尝试开屏尝试计数
 */
+ (SSADModel *)checkoutFirstLaunchModel:(NSArray<SSADModel *> *) models with:(SSADTrackInfoList *) trackList {
    if (SSIsEmptyArray(models)) {
        return nil;
    }

    SSADModel *suitableADModel = nil;
    suitableADModel = [self pickKindOfModel:models with:trackList area:^BOOL(SSADModel *model) {
        return model.commerceType == TTSplashADCommerceTypeFirst;
    }];
    if (suitableADModel) {
        [self setFirstLaunch];
        return suitableADModel;
    }
    suitableADModel = [self pickKindOfModel:models with:trackList area:^BOOL(SSADModel *model) {
        return model.commerceType == TTSplashADCommerceTypeGD;
    }];
    if (suitableADModel) {
        [self setFirstLaunch];
        return suitableADModel;
    }
    
    // not suitableADModel now
    suitableADModel = [self pickKindOfModel:models with:nil area:^BOOL(SSADModel *model) {
        return model.commerceType == TTSplashADCommerceTypeCPT || model.commerceType == TTSplashADCommerceTypeDefault;
    }];
    if (suitableADModel) {
        DLog(@"AD: fist launch cost without show");
        [self setFirstLaunch];
    }
    return nil;
}

+ (SSADModel *)pickKindOfModel:(NSArray<SSADModel *> *) splashModels with:(SSADTrackInfoList *) trackList area:(CheckArea)checkArea {
    DLog(@"AD: %@", NSStringFromSelector(_cmd));
    if (SSIsEmptyArray(splashModels)) {
        return nil;
    }
    __block SSADModel *suitableADModel = nil;
    __block SSSplashADReadyType type = SSSplashADReadyTypeUnknow;
    
    [splashModels enumerateObjectsUsingBlock:^(SSADModel *adModel, NSUInteger idx, BOOL *stop) {
        [adModel.intervalCreatives enumerateObjectsUsingBlock:^(SSADModel *icADModel, NSUInteger idx, BOOL *internalStop) {
            if (checkArea(icADModel)) {
                if ([self isSuitableSplashADModel:icADModel readyType:&type isIntervalCreatives:YES]) {
                    suitableADModel = icADModel;
                    *internalStop = YES;
                    DLog(@"suitabel intervalModel <%p %@ %@>", icADModel, icADModel.splashID, @(type));
                }
                if (icADModel.splashID) {
                    SSADTrackInfoLog *infoLog = [[SSADTrackInfoLog alloc] initWithLogID:icADModel.splashID];
                    SSADTrackInfoHistory *history = [SSADTrackInfoHistory new];
                    history.statue = type;
                    history.count = 1;
                    history.logID = icADModel.splashID;
                    [infoLog addHistory:history];
                    [trackList addInfoLog:infoLog];
                }
            } else {
                // 过滤当前类型广告
            }
        }];
        
        if (suitableADModel) {
            *stop = YES;
        } else {
            if (checkArea(adModel)) {
                if ([self isSuitableSplashADModel:adModel readyType:&type isIntervalCreatives:NO]) {
                    suitableADModel = adModel;
                    *stop = YES;
                    DLog(@"suitabel Model <%p %@ %@>", adModel, adModel.splashID, @(type));
                }
                if (adModel.splashID) {
                    SSADTrackInfoLog *infoLog = [[SSADTrackInfoLog alloc] initWithLogID:adModel.splashID];
                    SSADTrackInfoHistory *history = [SSADTrackInfoHistory new];
                    history.statue = type;
                    history.count = 1;
                    history.logID = adModel.splashID;
                    [infoLog addHistory:history];
                    [trackList addInfoLog:infoLog];
                }
            } else {
                 // 过滤当前类型广告
            }
        }
    }];
    return suitableADModel;
}

#pragma mark - validate Model

+ (BOOL)isSuitableSplashADModel:(SSADModel *)model readyType:(SSSplashADReadyType *)type isIntervalCreatives:(BOOL)isIntervalCreatives
{
    return [self isSuitableADModel:model show4TTCover:NO readyType:type isIntervalCreatives:isIntervalCreatives];
}

+ (BOOL)isSuitableTTCoverSplashADModel:(SSADModel *)model isIntervalCreatives:(BOOL)isIntervalCreatives
{
    return [self isSuitableADModel:model show4TTCover:YES readyType:nil isIntervalCreatives:isIntervalCreatives];
}

+ (BOOL)isSuitableADModel:(SSADModel *)model show4TTCover:(BOOL)show4TTCover readyType:(SSSplashADReadyType *)type isIntervalCreatives:(BOOL)isIntervalCreatives
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    // 1 广告是否过期
    NSTimeInterval expireTime = model.splashExpireSeconds + model.requestTimeInterval + model.splashDisplayAfterSecond;
    if (currentTime > expireTime) {
        if (type) {
            *type = SSSplashADReadyTypeExpired;
            DLog(@" AD: expired (expireTime : %zd, current: %f)", model.splashExpireSeconds, currentTime);
        }
        return NO;
    }
    
    //2  头条封面展示当天广告
    NSTimeInterval deadlineTime = currentTime;
    if (show4TTCover && !isIntervalCreatives) {
        NSDate *currentDate = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:currentDate];
        [components setHour:24-components.hour];
        [components setMinute:-components.minute];
        [components setSecond:-components.second];
        deadlineTime = [[cal dateByAddingComponents:components toDate:currentDate options:0] timeIntervalSince1970];
        //deadlineTime设置为当天23:59:59
        deadlineTime -= 5;
    }
    NSTimeInterval startTime = model.requestTimeInterval + model.splashDisplayAfterSecond;
    
    if (deadlineTime < startTime) {
        if (type) {
            *type = SSSplashADReadyTypeNonArrival;
            DLog(@" AD: Early (request :%f, after: %ld begin: %f, now : %f)",model.requestTimeInterval, (long)model.splashDisplayAfterSecond, startTime ,deadlineTime);
        }
        return NO;
    }
    
    if (!show4TTCover) {
        
        //3 离开时间，和展示间隔时间是否满足条件
        //最小展示间隔10min
        NSTimeInterval recentShowTime = [SSADManager recentlySSADShowSplashTime];
        NSTimeInterval modelDisplayInterval = MAX(model.splashInterval, minShowInterval);
        BOOL showTimeFit = currentTime > (recentShowTime + modelDisplayInterval);
        
        if (!showTimeFit) {
            if (type) {
                *type = SSSplashADReadyTypeIntervalFromLastNotMatch;
            }
            DLog(@" AD: Show Interval (last Show :%f, interval: %f , now : %f)",recentShowTime , modelDisplayInterval, currentTime);
            return NO;
        }
        
        //最小离开间隔30秒
        NSTimeInterval recentEnterBgTime = [SSADManager recentlySSADEnterBackgroundTime];
        NSTimeInterval modelLeaveInterval = MAX(model.splashLeaveInterval, minLeaveInterval);
        BOOL enterBgTimeFit = currentTime > (modelLeaveInterval + recentEnterBgTime);
        
        if (!enterBgTimeFit) {
            if (type) {
                *type = SSSplashADReadyTypeIntervalFromBGNotMach;
            }
            DLog(@" AD: Leave Interval (Goto bg :%f, interval: %f now : %f)",recentEnterBgTime, modelLeaveInterval, currentTime);
            return NO;
        }
    }
    
    //4 图片或视频广告是否已预加载，即缓存到本地
    if (![self isCacheExistWithADModel:model readyType:type]) {
        DLog(@" AD: no Cache model = %@", model.splashID);
        return NO;
    }
    
    //5 wifi_only  只有wifi才展示
    if ([model.splashShowOnWifiOnly intValue] == 1 && !TTNetworkWifiConnected()) {
        if (type) {
            *type = SSSplashADReadyTypeHide;
        }
        DLog(@" AD: not Wifi model = %@", model.splashID);
        return NO;
    }
    
    //6 hide if exists
    if ([model.splashHideIfExist intValue] == 1 &&
        [model.splashActionType isEqualToString:splashADActionTypeApp] &&
        !isEmptyString(model.splashOpenURL)) {
        if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:model.splashOpenURL]]) {
            if (type) {
                *type = SSSplashADReadyTypeHide;
            }
            DLog(@" AD: Model error model = %@",model.splashID);
            return NO;
        }
    }
    
    if (type) {
        *type = SSSplashADReadyTypeSuccess;
    }
    return YES;
}

+ (BOOL)isCacheExistForADModel:(SSADModel *)model
{
    ///...
//    TTImageInfosModel *imageInfo = [[TTImageInfosModel alloc] initWithDictionary:model.imageInfo];
//    return [[SSSimpleCache sharedCache] isCacheExist:model.splashURLString] || [[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageInfo];
    return [self isCacheExistWithADModel:model readyType:nil];
}

///...
+ (BOOL)isCacheExistWithADModel:(SSADModel *)model readyType:(SSSplashADReadyType *)readyType
{
    SSSplashADReadyType type = SSSplashADReadyTypeSuccess;
    
    BOOL hasImage = NO;
    if (SSSplashADTypeVideoFullscreen != model.splashADType) {
        
        if (![TTDeviceHelper isPadDevice]) {
            TTImageInfosModel *imageInfo = [[TTImageInfosModel alloc] initWithDictionary:model.imageInfo];
            hasImage = [[SSSimpleCache sharedCache] isCacheExist:model.splashURLString] || [[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageInfo];
        }
        else {
            //iPad需要 横竖屏2张图都成功才行
            TTImageInfosModel *imageInfo = [[TTImageInfosModel alloc] initWithDictionary:model.imageInfo];
            TTImageInfosModel *landscapeImageInfo = [[TTImageInfosModel alloc] initWithDictionary:model.landscapeImageInfo];

            hasImage = [[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageInfo];
            hasImage =  hasImage ? [[SSSimpleCache sharedCache] isImageInfosModelCacheExist:landscapeImageInfo] : NO;
        }
    }
    
    BOOL hasVideo = NO;
    if (SSSplashADTypeVideoFullscreen == model.splashADType) {
        hasVideo = [SSSimpleCache isVideoCacheExistWithVideoId:model.videoId];
    } else if (SSSplashADTypeVideoCenterFit_16_9 == model.splashADType) {
        hasVideo = [SSSimpleCache isVideoCacheExistWithVideoId:model.videoId];
    }
    
    switch (model.splashADType) {
        case SSSplashADTypeImage:
            if (!hasImage) {
                type = SSSplashADReadyTypeImageEmpty;
            }
            break;
          
        case SSSplashADTypeVideoFullscreen:
            if (!hasVideo) {
                type = SSSplashADReadyTypeFullscreenVideoEmpty;
            }
            break;
            
        case SSSplashADTypeVideoCenterFit_16_9:
            if (!hasImage && hasVideo) {
                type = SSSplashADReadyTypeVideoReadyWithoutImage;
            } else if (hasImage && !hasVideo) {
                type = SSSplashADReadyTypeImageReadyWithoutVideo;
            } else if (!hasImage && !hasVideo) {
                type = SSSplashADReadyTypeVideoImageAllEmpty;
            }
            break;
        case SSSplashADTypeImage_ninebox:
            if (!hasImage) {
                type = SSSplashADReadyTypeImageEmpty;
            }
            break;
        default:
            break;
    }
    
    if (SSSplashADReadyTypeSuccess != type) {
        if (readyType) {
            *readyType = type;
        }
        return NO;
    }
    
    return YES;
}

+ (void)updateADControlInfoModels:(NSArray *)models modelSaveKey:(NSString *)key
{
    if ([models count] == 0) {
        NSMutableDictionary * mutableDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kUDSSADManagerModelsKey]];
        [mutableDict removeObjectForKey:key];
        
        if (mutableDict != nil) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:mutableDict] forKey:kUDSSADManagerModelsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        return;
    }
    if ([key isEqualToString:kUDSSADManagerSplashModelsKey]) {
//        NSLog(@">>>> replace splash mode %@",models);
 
    }
    NSMutableArray * archiveModels = [NSMutableArray arrayWithCapacity:models.count];
    for (int i = 0; i < models.count; i ++) {
        @try {
             [archiveModels addObject:[NSKeyedArchiver archivedDataWithRootObject:[models objectAtIndex:i]]];
        } @catch (NSException *exception) {
            [archiveModels removeAllObjects];
            break;
        } @finally {
        }
    }
    
    NSDictionary * oriDict = [[NSUserDefaults standardUserDefaults] objectForKey:kUDSSADManagerModelsKey];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:oriDict];
    [dict setObject:[NSArray arrayWithArray:archiveModels] forKey:key];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:dict] forKey:kUDSSADManagerModelsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateADControlInfoForSplashModels:(NSArray *)models
{
    DLog(@"AD: %@ models<%@>", NSStringFromSelector(_cmd), models);
    if (models.count > 0) {
        [SSADManager updateADControlInfoModels:models modelSaveKey:kUDSSADManagerSplashModelsKey];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSSADSplashEmptyKey];
        
        if (!_splashDownloadManager) {
            self.splashDownloadManager = [[SSADSplashDownloadManager alloc] init];
        }
        [_splashDownloadManager fetchADResourceWithModels:models];
    } else { // 如果轮空，不清除本地数据，因为还要用于Cover显示
        DLog(@"AD >>> 轮空 ");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSSADSplashEmptyKey];
    }
}

+ (NSArray *)getADControlInfoModelsForSaveKey:(NSString *)key
{
    if ([key length] == 0) {
        return nil;
    }
    NSArray * archiveModels = [(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:kUDSSADManagerModelsKey] objectForKey:key];
    if ([archiveModels count] == 0) {
        return nil;
    }
    NSMutableArray * unArchivedModels = [NSMutableArray arrayWithCapacity:[archiveModels count]];
    
    for (int i = 0; i < [archiveModels count]; i ++) {
        @try {
            [unArchivedModels addObject:[NSKeyedUnarchiver unarchiveObjectWithData:[archiveModels objectAtIndex:i]]];
        } @catch (NSException *exc) {
            NSMutableDictionary *condition = [NSMutableDictionary dictionary];
            condition[@"exception"] = exc.name;
            condition[@"userInfo"] = [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__];
            [TTAdMonitorManager trackService:@"ad_splash_error" status:0 extra:condition];
            [unArchivedModels removeAllObjects];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUDSSADManagerModelsKey];
            break;
        }
        
    }
    
    return [NSArray arrayWithArray:unArchivedModels];
}

+ (NSArray *)getADControlSplashModels
{
    return [self getADControlInfoModelsForSaveKey:kUDSSADManagerSplashModelsKey];
}

#pragma mark - show Interval && background Interval

//记录最近一次展示splash广告时间
+ (void)saveSSADRecentlyShowSplashADTime
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:kSSADRecentlyShowSplashADTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearSSADRecentlyShowSplashTime
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSSADRecentlyShowSplashADTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//获取最近一次展示splash广告时间
+ (NSTimeInterval)recentlySSADShowSplashTime
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kSSADRecentlyShowSplashADTimeKey] doubleValue];
}

//记录最近一次退到后台的时间
+ (void)saveSSADRecentlyEnterBackgroundTime
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:kSSADRecentlyEnterBackgroudTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearSSADRecentlyEnterBackgroundTime
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSSADRecentlyEnterBackgroudTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//获取最近一次退到后台的时间
+ (NSTimeInterval)recentlySSADEnterBackgroundTime
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kSSADRecentlyEnterBackgroudTimeKey] doubleValue];
}

#pragma mark - TrackInfo
// 记录最近一次的trackinfo
+ (void)saveSSADRecentlyTrackInfo:(NSDictionary *)info
{
    [[NSUserDefaults standardUserDefaults] setValue:info forKey:kSSADRecentlyTrackInfoKey];
}
// 获取最近一次的trackinfo
+ (NSDictionary *)recentlySSADTrackInfo
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSSADRecentlyTrackInfoKey];
}

// 记录最近一次的trackinfoList
+ (void)saveSSADRecentlyTrackInfoList:(SSADTrackInfoList *)info
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:info];
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:kSSADRecentlyTrackInfoListKey];
}
// 获取最近一次的trackinfoList
+ (SSADTrackInfoList *)recentlySSADTrackInfoList
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kSSADRecentlyTrackInfoListKey];
    SSADTrackInfoList *list;
    if (data) {
        list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return list;
}

- (void)fetchADControlInfoWithExtraParameters:(NSDictionary *)extra
{
    [[SSADFetchInfoManager shareInstance] startFetchADInfoWithExtraParameters:extra];
}

- (void)showSplashControllerViewOnKeyWindow:(UIWindow *)keyWindow model:(SSADModel *)model
{
    DLog(@"%@ with model = <%p : %@>", NSStringFromSelector(_cmd), model, model.splashID);
    if (keyWindow == nil) {
        return;
    }
    if ([keyWindow respondsToSelector:@selector(endEditing:)]) {
        [keyWindow endEditing:YES];
    }
    CGRect splashFrame = CGRectMake(0, 0, [TTUIResponderHelper windowSize].width, [TTUIResponderHelper windowSize].height);
    self.controllerView = [[SSADSplashControllerView alloc] initWithFrame:splashFrame model:model];
    self.controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _controllerView.delegate = self;
    [keyWindow addSubview:_controllerView];
    
    /*  此处记录时间， 如果外部调用applicationDidBecomeActive（比如头条2.8.1开始)
     *  如果不在此处记录时间， 用户双击home按钮，不退出， 再返回该应用，此种情况下，如果saveSSADRecentlyEnterBackgroundTime记录的时间超过了display_interval的时间， 则还会显示广告
     *  所以此处记录时间用户上次显示广告的时间作为上次退出应用的时间。
     *  忽略用户双击home，情况下超过display_interval的情况。
     */
    //    [SSADManager saveSSADRecentlyEnterBackgroundTime];
    [SSADManager saveSSADRecentlyShowSplashADTime];
    [TTAdMonitorManager beginTrackIntervalService:@"ad_spalsh_show"];
    self.isSplashADShowed = YES;
}


#pragma mark - Public

- (BOOL)applicationDidBecomeActiveShowOnWindow:(UIWindow *)keyWindow splashShowType:(SSSplashADShowType)type
{
    DLog(@"AD: %@  luanch a splash %@", NSStringFromSelector(_cmd), @(type));
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self detectCallbackFromThirdApp];
    });
    
    BOOL succedShow = NO;
    if (type == SSSplashADShowTypeIgnore) {
        self.finishCheck = YES;
        return succedShow;
    }
    
    BOOL needsToRequestAD = YES;
    
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    if (nowTimeInterval - _latelyDidBecomeActiveTimeInterval < kInvokeDidBecomeActiveMinInterval) {
        needsToRequestAD = NO;
    }
    
    SSADTrackInfoList *trackList;
    if (!needsToRequestAD) {
        trackList = [SSADManager recentlySSADTrackInfoList];
    }
    
    if (!trackList) {
        trackList = [SSADTrackInfoList new];
    }
    [SSADManager shareInstance].adShow = NO;
    if (type == SSSplashADShowTypeShow && [self isNowOrientationShowSpalsh]) {
        SSADModel *model = [SSADManager pickedFitSplashModelWithTrackInfoList:trackList];
        if (model) {
            //拿到model后设置下展示的素材类型---为了解决gif图卡顿问题,对Gif做特殊延迟处理
            [self setSplashResouceType:model];
            [self showSplashControllerViewOnKeyWindow:keyWindow model:model];
            succedShow = YES;
            [SSADManager shareInstance].adShow = YES;
        } else {
            self.finishCheck = YES;
        }
    } else {
        self.finishCheck = YES;
    }
    
    NSArray <SSADModel*> *splashModels = [SSADManager getADControlSplashModels];
    NSMutableArray *preloadedModelIDs = [[NSMutableArray alloc] initWithCapacity:splashModels.count];
    
    [splashModels enumerateObjectsUsingBlock:^(SSADModel * _Nonnull adModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [adModel.intervalCreatives enumerateObjectsUsingBlock:^(SSADModel *  _Nonnull icADModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([SSADManager isCacheExistForADModel:icADModel] && icADModel.splashID) {
                [preloadedModelIDs addObject:adModel.splashID];
            }
        }];
        
        if ([SSADManager isCacheExistForADModel:adModel] && adModel.splashID) {
            [preloadedModelIDs addObject:adModel.splashID];
        }
    }];
   
    [trackList setPreloadListArray:preloadedModelIDs];
    
    //发送上一次的trackInfo
    if (needsToRequestAD) {
        SSADTrackInfoList *lastTrack = [SSADManager recentlySSADTrackInfoList];
        NSDictionary *lastTrackInfo = [lastTrack toCustomJSONDictionary];
        
        NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
        if (!SSIsEmptyDictionary(lastTrackInfo)) {
            [paramDic addEntriesFromDictionary:lastTrackInfo];
        }
        
        TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
        if(placemarkItem.coordinate.longitude > 0) {
            [paramDic setValue:@(placemarkItem.coordinate.latitude) forKey:@"latitude"];
            [paramDic setValue:@(placemarkItem.coordinate.longitude) forKey:@"longitude"];
        }
    
        DLog(@"AD:  begin fetch new models");
        [self fetchADControlInfoWithExtraParameters:paramDic];
    }
    
    //保存trackInfo
    trackList.fetchTime = @((NSUInteger)nowTimeInterval);
    [SSADManager saveSSADRecentlyTrackInfoList:trackList];
    
    _latelyDidBecomeActiveTimeInterval = nowTimeInterval;
    
    DLog(@"AD:  %@  to show",(succedShow ? @"succ" : @"failed"));
    return succedShow;
}

- (BOOL)isNowOrientationShowSpalsh {
    if ([TTDeviceHelper isPadDevice]) {
        return YES;
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return YES;
    }
    
    return NO;
}

//通过model获取开屏广告的素材类型 --为区分Gif, 对Gif卡顿做特殊处理
- (void)setSplashResouceType:(SSADModel *)model
{
    if (!model) {
        _resouceType = SSAdSplashResouceType_None;
    }
    else
    {
        if (model.splashADType == SSSplashADTypeImage || model.splashADType == SSSplashADTypeImage_ninebox) {
            _resouceType = [self getResouceType:model];
        }
        else if (model.splashADType == SSSplashADTypeVideoFullscreen|| model.splashADType == SSSplashADTypeVideoCenterFit_16_9)
        {
            _resouceType = SSAdSplashResouceType_Video;
        }
    }
}

- (SSAdSplashResouceType)getResouceType:(SSADModel *)model
{
    TTImageInfosModel *imageInfo = [[TTImageInfosModel alloc] initWithDictionary:model.imageInfo];
    NSData* data = [[SSSimpleCache sharedCache] dataForImageInfosModel:imageInfo];
    
    if (!data) {
        data = [[SSSimpleCache sharedCache] dataForUrl:model.splashURLString];
    }
    
    if (data) {
        VVeboImage* adImage = [VVeboImage gifWithData:data];
        if (adImage) {
            if (adImage.count == 1) {
                return SSAdSplashResouceType_Image;
            }
            else if (adImage.count > 1)
            {
                return SSAdSplashResouceType_Gif;
            }
        }
    }
    return SSAdSplashResouceType_None;
}

- (void)didEnterBackground
{
    self.finishCheck = NO;
    [SSADManager saveSSADRecentlyEnterBackgroundTime];
}

- (void)makeKeyAndVisible{
    
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        if ([[[UIApplication sharedApplication].delegate window] respondsToSelector:@selector(makeKeyAndVisible)]) {
            [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
        }
    }
}

#pragma mark -- SSADSplashControllerViewDelegate

//点击banner区域
- (void)splashControllerViewWithAction:(SSADModel *)adModel {
    if ([adModel.displayViewButton integerValue] == TTSplashClikButtonStyleStripAction) {
        [self splashAction:adModel inBanner:YES];
    }
}

//点击普通区域
- (void)splashControllerViewClickBackgroundAction:(SSADModel *)adModel {
    [self splashAction:adModel inBanner:NO];
}

- (void)splashAction:(SSADModel *)adModel inBanner:(BOOL)inBanner
{
    NSString * const sourceTag = @"splash_ad";
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:1];
    [extra setValue:adModel.logExtra forKey:@"log_extra"];
    [extra setValue:@"1" forKey:@"is_ad_event"];
    BOOL result = NO;
    if (inBanner == YES) {
        //用app_open_url去打开三方app
        result = [TTAppLinkManager dealWithWebURL:adModel.splashWebURLStr openURL:adModel.actionURL sourceTag:sourceTag value:adModel.splashID extraDic:extra];
    }
    else{
        //用open_url去打开三方app
        result = [TTAppLinkManager dealWithWebURL:adModel.splashWebURLStr openURL:adModel.splashOpenURL sourceTag:sourceTag value:adModel.splashID extraDic:extra];
    }
    if (result) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self markLaunchThirdApp:adModel];
        });
    }
    if (!result) {
        [self performActionForSplashADModel:adModel];
    }
}

#pragma mark -- action

- (void)performActionForSplashADModel:(SSADModel *)model {
    NSParameterAssert(model != nil);
    if (model == nil) {
        return;
    }
    
    if (!isEmptyString(model.splashOpenURL) && [[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:model.splashOpenURL]]) {
        NSMutableDictionary *conditions = [NSMutableDictionary dictionaryWithCapacity:5];
        [conditions setValue:@"splash" forKey:@"gd_label"];
        [conditions setValue:@(NewsGoDetailFromSourceSplashAD) forKey:kNewsGoDetailFromSourceKey];
        [conditions setValue:model.logExtra forKey:@"log_extra"];
        [conditions setValue:model.splashID forKey:@"ad_id"];

        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:model.splashOpenURL] userInfo:TTRouteUserInfoWithDict(conditions)];
    }
    else if ([model.splashActionType isEqualToString:splashADActionTypeWeb] && !isEmptyString(model.splashWebURLStr)) {
        NSString * title = NSLocalizedString(@"网页浏览", nil);
        if (!isEmptyString(model.splashWebTitle)) {
            title = model.splashWebTitle;
        }
        NSMutableDictionary *conditions = [NSMutableDictionary dictionaryWithCapacity:5];
        [conditions setValue:@"splash" forKey:@"gd_label"];
        [conditions setValue:@(NewsGoDetailFromSourceSplashAD) forKey:kNewsGoDetailFromSourceKey];
        [conditions setValue:model.logExtra forKey:@"log_extra"];
        [conditions setValue:model.splashID forKey:@"ad_id"];

        UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor: nil];
        [SSWebViewController openWebViewForNSURL:[TTStringHelper URLWithURLString:model.splashWebURLStr] title:title navigationController:topController supportRotate:YES conditions:conditions];
    }
    else if ([model.splashActionType isEqualToString:splashADActionTypeApp] && !isEmptyString(model.splashDownloadURLStr)) {
        if (!isEmptyString(model.splashAlertText)) {
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:model.splashAlertText message:@"" preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
            [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                if (model.splashAppleID.length && [SSCommonLogic isAppPreloadEnable]) {
                    [[TTAdAppDownloadManager sharedManager] initStayTrackerWithAd_id:model.splashID log_extra:model.logExtra];
                }
                [self downloadAppForUrl:model.splashDownloadURLStr appleID:model.splashAppleID];
            }];
            [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
        }
        else {
            if (model.splashAppleID.length && [SSCommonLogic isAppPreloadEnable]) {
                [[TTAdAppDownloadManager sharedManager] initStayTrackerWithAd_id:model.splashID log_extra:model.logExtra];
            }
            [self downloadAppForUrl:model.splashDownloadURLStr appleID:model.splashAppleID];
        }
    } else {
        //do nothing
    }
}

- (void)downloadAppForUrl:(NSString *)URLStr appleID:(NSString *)appleID
{
    [[SSActionManager sharedManager] openDownloadURL:URLStr appleID:appleID];
}

- (void)splashControllerViewShowFinished:(SSADSplashControllerView *)view animation:(BOOL)animation {
    DLog(@"AD: %@", NSStringFromSelector(_cmd));
    
    CGFloat duration = 0.4;
    if ([SSCommonLogic shouldUseOptimisedLaunch]) {
        duration = 0.2f;
    }
    
    if (!animation) {
        _controllerView.alpha = 0.f;
        duration = 0.f;
    }
    
    [UIView animateWithDuration:duration animations:^{
        _controllerView.alpha = 0.f;
    } completion:^(BOOL finished) {
        _controllerView.delegate = nil;
        [_controllerView removeFromSuperview];
        [_controllerView didDisappear];
        self.controllerView = nil;
        
        self.isSplashADShowed = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kTTAdSplashShowFinish" object:self];
        self.finishCheck = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kSSADShowFinish object:self];
    }];
    
    [TTAdMonitorManager endTrackIntervalService:@"ad_spalsh_show" extra:nil];
}

+ (BOOL)splashADModelHasAction:(SSADModel *)model
{
    if ([model.splashActionType isEqualToString:splashADActionTypeWeb]) {
        if (!isEmptyString(model.splashOpenURL) || !isEmptyString(model.splashWebURLStr)) {
            return YES;
        }
    }
    else if ([model.splashActionType isEqualToString:splashADActionTypeApp]) {
        if (!isEmptyString(model.splashOpenURL) || !isEmptyString(model.splashDownloadURLStr)) {
            return YES;
        }
    }
    return NO;
}

+ (UIImageView *)adSplashBgImageViewWithFrame:(CGRect)viewFrame
{
    UIImageView *bgImgaeView = [[UIImageView alloc] initWithFrame:viewFrame];
    
    NSString *imgName = @"LaunchImage-800-Portrait-736h@3x.png";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        imgName = @"LaunchImage-800-Portrait-736h@3x.png";
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 &&
        ([UIScreen mainScreen].bounds.size.height == 480)) {
        imgName = @"LaunchImage-700@2x.png";
    }
    bgImgaeView.image = [UIImage imageNamed:imgName];
    bgImgaeView.backgroundColor = [UIColor whiteColor];
    bgImgaeView.contentMode = UIViewContentModeScaleAspectFit;
    return bgImgaeView;
}

#pragma mark --  launch third app

- (void)detectCallbackFromThirdApp {
    NSDictionary *lastGoAwayExtra = [[NSUserDefaults standardUserDefaults] objectForKey:kAdSpalshOpenURLLeave];
    if (lastGoAwayExtra && [lastGoAwayExtra isKindOfClass:[NSDictionary class]]) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval lastGoAway = [lastGoAwayExtra tt_doubleValueForKey:kAdSpalshOpenURLLeave]; //内层key
        NSInteger duration = (NSInteger)((now - lastGoAway) * 1000); //ms
        if (duration > 0 && duration <= callbackPatience) {
            NSMutableDictionary *lastExtra = [lastGoAwayExtra mutableCopy];
            [lastExtra removeObjectForKey:kAdSpalshOpenURLLeave];
            NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:3];
            [extra setValue:@(duration) forKey:@"duration"];
            if (lastExtra) {
                [extra addEntriesFromDictionary:lastExtra];
            }
            [self eventTrack4ImageADActionButtonCallBack:extra];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAdSpalshOpenURLLeave];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)markLaunchThirdApp:(SSADModel *)model {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:3];
    [extra setValue:model.splashID forKey:@"value"];
    [extra setValue:model.logExtra forKey:@"log_extra"];
    [extra setValue:@(now) forKey:kAdSpalshOpenURLLeave];
    [[NSUserDefaults standardUserDefaults] setObject:extra forKey:kAdSpalshOpenURLLeave];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)eventTrack4ImageADActionButtonCallBack:(NSDictionary *)extra {
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:4];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:@"splash_ad" forKey:@"tag"];
    [events setValue:@"open_url_appback" forKey:@"label"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [events setValue:@(connectionType) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    if (!SSIsEmptyDictionary(extra)) {
        [events addEntriesFromDictionary:extra];
    }
    [TTTrackerWrapper eventData:events];
}

@end

@implementation SSADManager (TTAdDiscard)

- (BOOL)discardAd:(NSArray<NSString *> *)adIDs
{
    if (SSIsEmptyArray(adIDs)) {
        return NO;
    }
    NSArray<SSADModel *> *models = [SSADManager getADControlSplashModels];
    if (SSIsEmptyArray(models)) {
        return NO;
    }
    NSSet *hittest = [NSSet setWithArray:adIDs];
    __block BOOL result = NO;
    NSMutableArray<SSADModel *> *remainModels = [[NSMutableArray alloc] initWithCapacity:models.count];
    [models enumerateObjectsUsingBlock:^(SSADModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!SSIsEmptyArray(obj.intervalCreatives)) {
            NSMutableArray<SSADModel *> *remainIntervalModels = [[NSMutableArray alloc] initWithCapacity:obj.intervalCreatives.count];
            [obj.intervalCreatives enumerateObjectsUsingBlock:^(SSADModel  *_Nonnull intervalModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![hittest containsObject:intervalModel.splashID]) {
                    [remainIntervalModels addObject:obj];
                    result = YES;
                }
            }];
            obj.intervalCreatives = [remainIntervalModels copy];
        }
        
        if (![hittest containsObject:obj.splashID]) {
            [remainModels addObject:obj];
            result = YES;
        }
    }];
    
    if (remainModels.count > 0) {
        [SSADManager updateADControlInfoModels:remainModels modelSaveKey:kUDSSADManagerSplashModelsKey];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSSADSplashEmptyKey];
        
    } else { // 如果轮空，不清除本地数据，因为还要用于Cover显示
        DLog(@"AD >>> 轮空 ");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSSADSplashEmptyKey];
    }
    return result;
}

@end
