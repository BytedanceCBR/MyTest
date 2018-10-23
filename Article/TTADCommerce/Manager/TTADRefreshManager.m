   //
//  TTADRefreshManager.m
//  Article
//
//  Created by ranny_90 on 2017/3/20.
//
//

#import "TTADRefreshManager.h"
#import "TTNetworkManager.h"
#import <TTAdModule/TTADImageDownloadManager.h>
#import "TTArticleCategoryManager.h"
#import "SSSimpleCache.h"
#import "TTURLTracker.h"
#import "NetworkUtilities.h"
#import "TTAdCommonUtil.h"
#import "TTPersistence.h"
#import "TTAdTrackManager.h"
#import <TTTracker/TTTrackerProxy.h>
#import <TTImage/TTImageInfosModel.h>
#import <TTAdModule/TTPhotoDetailAdModel.h>
#import <TTAdModule/TTAdMonitorManager.h>
#import "TTSettingsManager.h"

#define TTNewAdRefreshManageFileName @"TTNewAdRefreshManageFileName.plist"
#define TTNewAdRefreshManagerModelKey @"TTNewAdRefreshManagerModelKey" //保存下拉刷新广告key
#define TTNewAdRefreshShowLimitModelKey @"TTNewAdRefreshShowLimitModelKey" //保存下拉刷新广告showlimitModel的key

@interface TTADRefreshManager ()

@property (nonatomic,strong) TTAdRefreshRelateModel *refreshAdModel;

@property (nonatomic,strong) TTADRefreshShowTimeModel *showLimitModel;

@property(nonatomic, strong)TTPersistence *persistence;

@end

@implementation TTADRefreshManager

#pragma 初始化

+ (void)load
{
    [[TTAdSingletonManager sharedManager] registerSingleton:[TTADRefreshManager sharedManager] forKey:NSStringFromClass([self class])];
}

+ (instancetype)sharedManager{
    static TTADRefreshManager *_adRefreshManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _adRefreshManager = [[self alloc] init];
    });
    return _adRefreshManager;
}

-(id)init{
    self = [super init];
    if (self) {
        _lauchType = TTAppLaunchType_FirstLauch;
        
        id archivedADModels = [[NSUserDefaults standardUserDefaults] objectForKey:@"kRefreshADModels"];
        if (archivedADModels) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kRefreshADModels"];
        }
        
        id archivedAdOlodModels = [[NSUserDefaults standardUserDefaults] objectForKey:@"TTAdRefreshManagerModelKey"];
        if (archivedAdOlodModels) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TTAdRefreshManagerModelKey"];
        }
        
        id archiveAdOldShowLimitModels = [[NSUserDefaults standardUserDefaults] objectForKey:@"TTAdRefreshShowLimitModelKey"];
        if (archiveAdOldShowLimitModels) {
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TTAdRefreshShowLimitModelKey"];
        }
        
        self.refreshAdModel = nil;
        self.showLimitModel = nil;
    }
    
    return self;
}

-(TTPersistence *)persistence{
    @synchronized (self) {
        if (_persistence == nil) {
            TTPersistenceOption* option = [[TTPersistenceOption alloc] init];
            option.supportNSCoding = YES;
            _persistence = [TTPersistence persistenceWithName:TTNewAdRefreshManageFileName option:option];
        }
    }
    return _persistence;
}

-(TTAdRefreshRelateModel *)refreshAdModel{
    
    @synchronized (self) {
        if (_refreshAdModel == nil) {
            _refreshAdModel = [self getCachedADModel];
            if (_refreshAdModel) {
                [_refreshAdModel updateAdItemsDictionary];
            }
        }
    }
    return _refreshAdModel;
    
}

-(TTADRefreshShowTimeModel *)showLimitModel{
    
    @synchronized (self) {
        if (_showLimitModel == nil) {
            _showLimitModel = [self getCachedShowLimitADModel];
            if (!_showLimitModel) {
                _showLimitModel = [[TTADRefreshShowTimeModel alloc] init];
            }
        }
    }
    return _showLimitModel;
}


#pragma mark -- 根据上次网络加载时间间隔判断是否进行网络加载

//本地无上次广告数据情况下进行默认时间间隔判断
#define TTAdRefreshLastFetchResourceTime @"TTAdRefreshLastFetchResourceTime" //上次获取网络数据的时间,供本地没有获取到上次请求的广告数据使用


//热启动时进行网络加载广告数据的条件
-(BOOL)isHotLaunchSuitableToFetchData{
    
    NSTimeInterval lastTimeFretchData = [[NSUserDefaults standardUserDefaults] doubleForKey:TTAdRefreshLastFetchResourceTime];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970] - lastTimeFretchData;
    
    NSTimeInterval requestAfterInterval = 0;
    
    if (!self.refreshAdModel || !self.refreshAdModel.request_after || self.refreshAdModel.request_after.longValue < 0) {
        
        requestAfterInterval = [SSCommonLogic refreshDefaultAdFetchInterval];
    }
    
    else {
        requestAfterInterval = self.refreshAdModel.request_after.longValue;
    }
    
    if (timeInterval >= requestAfterInterval) {
        return YES;
    }
    
    return NO;

}

- (void)saveCurrentTimestamp
{
    [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970]
                                              forKey:TTAdRefreshLastFetchResourceTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -- 获取用户已订阅频道列表
- (NSString *)subscribedCategoriesJSONString
{
    NSArray *categoryModels = [[TTArticleCategoryManager sharedManager] subScribedCategories];
    NSMutableArray *categoryIDs = [NSMutableArray arrayWithCapacity:categoryModels.count];
    NSMutableArray *categoryconccernIDs = [NSMutableArray arrayWithCapacity:categoryModels.count];
    [categoryModels enumerateObjectsUsingBlock:^(TTCategory * _Nonnull categoryModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (categoryModel && [categoryModel isKindOfClass:[TTCategory class]]) {
            if (categoryModel.categoryID) {
                [categoryIDs addObject:categoryModel.categoryID];
            }
            
            if (categoryModel.concernID) {
                [categoryconccernIDs addObject:categoryModel.concernID];
            }
        }
        
    }];
    NSData *tempData = [NSJSONSerialization dataWithJSONObject:categoryIDs options:kNilOptions error:nil];
    return [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
}


#pragma mark -- 获取广告网络数据

-(void)fetchRefreshADModelsWithCompleteBlock:(TTRefreshPrefetcheCompletedBlock)completion{
    
    TTRefreshPrefetcheCompletedBlock tempBlock = [completion copy];
    
    if (!TTNetworkConnected()  || [SSCommonLogic RefreshADDisable]) {
        return;
    }
    
    if (self.lauchType == TTAppLaunchType_Other) {
        return;
    }
    
    if (self.lauchType == TTAppLaunchType_HotLaunch) {
        if (![self isHotLaunchSuitableToFetchData]) {
            return;
        }
    }
    
    self.lauchType = TTAppLaunchType_Other;
    
    [self saveCurrentTimestamp];
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    NSString *categoriesJSONString = [self subscribedCategoriesJSONString];
    
    [parameterDict setValue:categoriesJSONString forKey:@"channels"];
    
    [self downloadRefreshADModelsWithExtraParameters:parameterDict withCompleteBlock:^(id jsonObj, NSError *error) {
        
        if (tempBlock) {
            tempBlock(jsonObj,error);
        }
        
    }];
    
    
}


//获取广告元数据
-(void)downloadRefreshADModelsWithExtraParameters:(NSDictionary *)extra withCompleteBlock:(TTRefreshPrefetcheCompletedBlock)completion{
    
    TTRefreshPrefetcheCompletedBlock tempBlock = [completion copy];
    
    NSString * url = [CommonURLSetting refreshADURLString];
    
    NSMutableDictionary * parameterDict = [[TTAdCommonUtil  generalDeviceInfo] mutableCopy];
    if (!SSIsEmptyDictionary(extra)) {
        [parameterDict addEntriesFromDictionary:extra];
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameterDict method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {

        if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self processWithObj:jsonObj WithError:error];
            });
        }else{
            [self processWithObj:jsonObj WithError:error];
        }
        
        if (tempBlock) {
            tempBlock(jsonObj,error);
        }
    }];
}

-(void)processWithObj:(id)jsonObj WithError:(NSError *)error{
    
    if (error) {
           [TTAdMonitorManager trackService:@"adrefresh_api_error" status:0 extra:nil];
    }
    
    if (!jsonObj) {
        return;
    }
    
    if (![jsonObj isKindOfClass:[NSDictionary class]] || ![(NSDictionary *)jsonObj objectForKey:@"data"]) {
        return;
    }
    
    id data = [(NSDictionary *)jsonObj objectForKey:@"data"];
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSDictionary *dataDic = (NSDictionary *)data;
    
    NSError* jsonError = nil;
    
    TTAdRefreshRelateModel *adRelateModel = [[TTAdRefreshRelateModel alloc] initWithDictionary:dataDic error:&jsonError];
    if (!adRelateModel || !adRelateModel.ad_item || adRelateModel.ad_item.count <= 0) {
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        if (jsonError&&!isEmptyString(jsonError.description)) {
            [dict setValue:jsonError.description forKey:@"apijsonerror"];
        }
        [TTAdMonitorManager trackService:@"adrefresh_api_error" status:1 extra:dict];
        return;
    }
    
    if (adRelateModel.ad_item) {
        [adRelateModel.ad_item enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj && [obj isKindOfClass:[TTAdRefreshItemModel class]]) {
                TTAdRefreshItemModel *adItemModel = (TTAdRefreshItemModel *)obj;
                [adItemModel updateDisplayDate];
            }
            
        }];
    }
    
    if (adRelateModel) {
        
        self.refreshAdModel = adRelateModel;
        [self cacheADModel:adRelateModel];
        
        [self.refreshAdModel updateAdItemsDictionary];
        
        [self predownloadADImageDataWithADModel:adRelateModel];
    }
}


#pragma mark -- 广告图片资源获取

-(void)predownloadADImageDataWithADModel:(TTAdRefreshRelateModel *)adModel{
    
    if (!adModel || !adModel.ad_item || adModel.ad_item.count <= 0) {
        return;
    }
    
    for (TTAdRefreshItemModel *adItemModel in adModel.ad_item) {
        
        [self predowunloadADImageWithADItemModel:adItemModel];
    }
    
}

-(void)predowunloadADImageWithADItemModel:(TTAdRefreshItemModel *)adItemModel{
    
    if (!adItemModel || !adItemModel.image_list || adItemModel.image_list.count <= 0) {
        return;
    }
    
    TTNetworkFlags flag = TTAdNetworkGetFlags();
    if (!(flag & adItemModel.predownload.integerValue)){
        return;
    }
    
    if (adItemModel.image_list&&adItemModel.image_list.count>0) {
        
        for (TTAdImageModel *ttImageModel in adItemModel.image_list) {
            TTImageInfosModel* ssImageModel = [[TTImageInfosModel alloc] initWithDictionary:[ttImageModel toDictionary]];
            
            if (ssImageModel) {
                [[TTADImageDownloadManager sharedManager] startDownloadImageWithImageInfoModel:ssImageModel];
            }
        }
    }
    
}

#pragma mark -- 下拉刷新广告动画的展示逻辑

-(UIView *)createAnimateViewWithFrame:(CGRect)frame WithLoadingText:(NSString *)loadingText WithPullLoadingHeight:(CGFloat)pullLoadingHeight{
    
    TTADRefreshAnimationView *adRefreshAnimateView = [[TTADRefreshAnimationView alloc] initWithFrame:frame WithLoadingHeight:pullLoadingHeight WithLoadingText:loadingText];
    return adRefreshAnimateView;
}

//获取下拉刷新合适的广告数据并进行刷新动画的替换
-(void)configureAnimateViewWithChannelId:(NSString *)channelId WithRefreshView:(TTRefreshView *)refreshView WithRefreshAnimateView:(UIView *)refreshAnimateAdView{
    
    
    __weak typeof(refreshView) weakRefreshView = refreshView;
    if (isEmptyString(channelId)) {
        if (refreshView) {
            [self configureDefaultAnimateViewForRefreshView:refreshView];
        }
        return;
    }
    
    if (!refreshView || !refreshAnimateAdView || ![refreshAnimateAdView isKindOfClass:[TTADRefreshAnimationView class]]) {
        if (refreshView) {
            [self configureDefaultAnimateViewForRefreshView:refreshView];
        }
        return;
    }
    
    TTADRefreshAnimationView *refreshAnimateView = (TTADRefreshAnimationView *)refreshAnimateAdView;
    
    if ([SSCommonLogic RefreshADDisable]) {
        if (refreshView) {
            [self configureDefaultAnimateViewForRefreshView:refreshView];
        }
        return;
    }
    
    //找出符合展示时间的adItemModel
    TTAdRefreshItemModel *adItemModel = [self getSuitableRefreshAdModelWithChannelID:channelId];
    
    if (adItemModel && !isEmptyString(adItemModel.channel_id) && [channelId isEqualToString:adItemModel.channel_id]) {
        
        //判断此频道的展示次数是否达到此adItemModel的上限show_limit
        BOOL isSuitable = [self isSuitableShowTimesdWithChannelId:channelId WithAdModel:adItemModel];
        
        if (!isSuitable) {
            if (refreshView) {
                [self configureDefaultAnimateViewForRefreshView:refreshView];
            }
            return;
        }
        
        //获取展示图片
        NSData *adImageData =  [self getSuitableRefreshAdImageWithAdItemModel:adItemModel];
        
        if (!adImageData) {
            
            [TTAdMonitorManager trackService:@"adrefresh_get_adimagedata_error" status:1 extra:nil];
            if (refreshView) {
                [self configureDefaultAnimateViewForRefreshView:refreshView];
            }
            return;
        }
        
        //广告下拉刷新控件替换
        refreshAnimateView.channelId = channelId;
        refreshAnimateView.adItemModel = adItemModel;
        BOOL isImageSucess = [refreshAnimateView configureAdImageData:adImageData];
        if (isImageSucess) {
            
            if (refreshView) {
                [refreshView reConfigureWithRefreshAnimateView:refreshAnimateView WithConfigureSuccessCompletion:^(BOOL isSucess) {
                    if (isSucess) {
                        __strong typeof(weakRefreshView) refreshView = weakRefreshView;
                        refreshView.secondsNeedScrollToLoading = KTTSecondsNeedScrollToLoading/2;
                    }
                }];
            }
        }
        
        else {
            
            [TTAdMonitorManager trackService:@"adrefresh_get_adimagedata_error" status:2 extra:nil];
            
            if (refreshView) {
                [self configureDefaultAnimateViewForRefreshView:refreshView];
            }
        }
       
    }
    
    else {
        if (refreshView) {
            [self configureDefaultAnimateViewForRefreshView:refreshView];
        }
        return;
    }
    
}

-(void)configureDefaultAnimateViewForRefreshView:(TTRefreshView *)refreshView{
    
    if (!refreshView) {
        return;
    }
    
    __weak typeof(refreshView) weakRefreshView = refreshView;
    
    [refreshView resetWithDefaultAnimateViewWithConfigureSuccessCompletion:^(BOOL isSucess) {
        if (isSucess) {
            __strong typeof(weakRefreshView) refreshView = weakRefreshView;
            refreshView.secondsNeedScrollToLoading = KTTSecondsNeedScrollToLoading;
        }
    }];
}


#pragma mark -- 下拉刷新时获取广告数据

//获取适合展示的广告item数据
-(TTAdRefreshItemModel *)getSuitableRefreshAdModelWithChannelID:(NSString *)channelId{

    if ( isEmptyString(channelId)) {
        return nil;
    }

    if (!self.refreshAdModel || SSIsEmptyArray(self.refreshAdModel.ad_item)) {
        return nil;
    }
    
    __block TTAdRefreshItemModel *suitableADModel = nil;
    
    id channalAdArrayData = [self.refreshAdModel.adItemsDictionary objectForKey:channelId];
    if (channalAdArrayData && [channalAdArrayData isKindOfClass:[NSArray class]]) {
        NSArray *channalAdArray = (NSArray *)channalAdArrayData;
        if (!SSIsEmptyArray(channalAdArray)) {
            [channalAdArray enumerateObjectsUsingBlock:^(TTAdRefreshItemModel * _Nonnull adModelItem, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (adModelItem && [adModelItem isKindOfClass:[TTAdRefreshItemModel class]]) {
                    if (!isEmptyString(adModelItem.channel_id) && [adModelItem.channel_id isEqualToString:channelId]) {
                        NSDate *currentDate = [NSDate date];
                        
                        if (adModelItem.is_preview == YES) {
                            suitableADModel = adModelItem;
                            *stop = YES;
                        }
                        else {
                            if ([adModelItem isSuitableTimeToDisplayWithDate:currentDate]) {
                                suitableADModel = adModelItem;
                                *stop = YES;
                            }
                        }
                        
                    }
                    
                }
                
            }];
        }
    }
    
    
    return suitableADModel;
}


//获取广告图片数据
-(NSData *)getSuitableRefreshAdImageWithAdItemModel:(TTAdRefreshItemModel *)adItemModel{
    
    if (!adItemModel || isEmptyString(adItemModel.channel_id)) {
        return nil;
    }
    
    
    if (SSIsEmptyArray(adItemModel.image_list))  {
        return nil;
    }
    
    NSData *imageData;
    if (adItemModel.image_list && adItemModel.image_list.count > 0) {
        
        TTAdImageModel *suitableDayModeImageModel = nil;
        for (TTAdImageModel *ttImageModel in adItemModel.image_list) {
            
            TTThemeMode curThemMode = [[TTThemeManager sharedInstance_tt] currentThemeMode];
            if ((curThemMode == TTThemeModeDay && ttImageModel.day_mode.longLongValue == 1) || (curThemMode == TTThemeModeNight && ttImageModel.day_mode.longLongValue == 0)) {
                suitableDayModeImageModel = ttImageModel;
                break;
            }
            
        }
        
        if (suitableDayModeImageModel) {
            TTImageInfosModel* imageModel = [[TTImageInfosModel alloc] initWithDictionary:[suitableDayModeImageModel toDictionary]];
            if (!imageModel) {
                return nil;
            }
            imageData = [[SSSimpleCache sharedCache] dataForImageInfosModel:imageModel];
            
            if (!imageData) {
                return nil;
            }
        }
        else{
            return nil;
        }
        
    }
    
    return imageData;
}


#pragma mark -- 广告数据本地存取、删除

-(void)cacheADModel:(TTAdRefreshRelateModel *)adModel{
    
    if (!adModel) {
        return;
    }
    
    TTAdRefreshRelateModel *cachedModel = [[TTAdRefreshRelateModel alloc] init];
    cachedModel.request_after = adModel.request_after;
    if (!SSIsEmptyArray(adModel.ad_item)) {
        cachedModel.ad_item = [adModel.ad_item copy];
    }
    
    [self.persistence setValue:cachedModel forKey:TTNewAdRefreshManagerModelKey];
    [self.persistence save];
    
}

-(TTAdRefreshRelateModel *)getCachedADModel{
    
    
    TTAdRefreshRelateModel* model = [self.persistence objectForKey:TTNewAdRefreshManagerModelKey];
    
    if (model && [model isKindOfClass:[TTAdRefreshRelateModel class]]) {
        
        TTAdRefreshRelateModel *cachedModel = [[TTAdRefreshRelateModel alloc] init];
        cachedModel.request_after = model.request_after;
        if (!SSIsEmptyArray(model.ad_item)) {
            cachedModel.ad_item = [model.ad_item copy];
        }
        
        return cachedModel;
    }
    
    return nil;
    
}

-(void)clearADRefreshCache{
    
    [self.persistence setValue:nil forKey:TTNewAdRefreshManagerModelKey];
    [self.persistence setValue:nil forKey:TTNewAdRefreshShowLimitModelKey];
    [self.persistence save];
    
    self.refreshAdModel = nil;
    self.showLimitModel = nil;
    
}


#pragma mark -- 实时回收下拉刷新广告数据

- (void)realTimeRemoveAd:(NSArray<NSString *> *)adIDs {
    if (SSIsEmptyArray(adIDs)) {
        return;
    }
    
    if (!self.refreshAdModel || SSIsEmptyArray(self.refreshAdModel.ad_item)) {
        return;
    }
    
    NSMutableArray *checkedModels = [[NSMutableArray alloc] initWithCapacity:self.refreshAdModel.ad_item.count];
    [self.refreshAdModel.ad_item enumerateObjectsUsingBlock:^(TTAdRefreshItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj && [obj isKindOfClass:[TTAdRefreshItemModel class]]) {
            NSString *adID4Model = [NSString stringWithFormat:@"%@", obj.adID];
            if (![adIDs containsObject:adID4Model]) {
                [checkedModels addObject:obj];
            }
        }
    }];
    
    if (checkedModels.count) {
        
        self.refreshAdModel.ad_item = [checkedModels copy];
        [self.refreshAdModel updateAdItemsDictionary];
        [self cacheADModel:self.refreshAdModel];
    } else {
        [self clearADRefreshCache];
    }
    
}


#pragma mark -- Track事件统计

//show事件
- (void)trackAdFreshShowWithChannelId:(NSString *)channelId WithADItemModel:(TTAdRefreshItemModel *)adItemModel{
    
    if (isEmptyString(channelId)) {
        return;
    }
    
    if (!adItemModel || isEmptyString(adItemModel.channel_id) || ![channelId isEqualToString:adItemModel.channel_id]) {
        return;
    }
    
    
    [self configureShowTimesdWithChannelId:channelId];
    if (self.showLimitModel) {
        TTADRefreshChannelShowTimeModel *channelShowModel = [self getChannelShowTimeModelWitChannelId:channelId];
        
        if (channelShowModel && [channelShowModel isKindOfClass:[TTADRefreshChannelShowTimeModel class]]) {
            
            //上报网络统计埋点
            [self trackRefreshAdWithTag:@"embeded_ad" label:@"show" WithAdItemModel:adItemModel];
            TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adItemModel.adID logExtra:adItemModel.log_extra];
            ttTrackURLsModel(adItemModel.track_url_list, trackModel);
            //本地show_limit次数统计更新
            [self cacheShowLimitADModel:self.showLimitModel];
            
        }
        
    }
    
    
}

//广告动画展示时长事件
- (void)trackAdFreshShowIntervalWithChannelId:(NSString *)channelId WithADItemModel:(TTAdRefreshItemModel *)adItemModel WithTimeInteval:(NSTimeInterval)inteval{
    
    if (isEmptyString(channelId)) {
        return;
    }
    
    if (!adItemModel || isEmptyString(adItemModel.channel_id) || ![channelId isEqualToString:adItemModel.channel_id]) {
        return;
    }
    
    NSInteger intTimeInteval = (NSInteger)(inteval * 1000);
    
    if (adItemModel&&!isEmptyString(adItemModel.channel_id)) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:adItemModel.log_extra forKey:@"log_extra"];
        [dict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [dict setValue:[NSNumber numberWithLong:intTimeInteval] forKey:@"duration"];
        [TTAdTrackManager trackWithTag:@"embeded_ad" label:@"show_over" value:adItemModel.adID extraDic:dict];
    }
    
    
}


-(void)trackRefreshAdWithTag:(NSString*)tag label:(NSString*)label WithAdItemModel:(TTAdRefreshItemModel *)adItemModel
{
    if (isEmptyString(tag) || isEmptyString(label) || !adItemModel) {
        return;
    }
    
    if (adItemModel&&!isEmptyString(adItemModel.channel_id)) {
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:adItemModel.log_extra forKey:@"log_extra"];
        [dict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [TTAdTrackManager trackWithTag:tag label:label value:adItemModel.adID extraDic:dict];
    }
}


#pragma mark -- 关于展示次数show_limit的逻辑


-(BOOL)isSuitableShowTimesdWithChannelId:(NSString *)channelId WithAdModel:(TTAdRefreshItemModel *)adItemModel{
    
    if (isEmptyString(channelId)) {
        return NO;
    }
    
    NSNumber *showLimit = [SSCommonLogic refreshADDefaultShowLimit];
    
    if (adItemModel && !isEmptyString(adItemModel.channel_id) && [adItemModel.channel_id isEqualToString:channelId] && adItemModel.show_limit) {
        
        showLimit = adItemModel.show_limit;
    }
    
    if (!self.showLimitModel || SSIsEmptyDictionary(self.showLimitModel.showLimitDic)) {
        return YES;
    }
    
    __block TTADRefreshChannelShowTimeModel *currentChannelShowLimitModel = nil;
    __block BOOL isSuitable = NO;
    
    [self.showLimitModel.showLimitDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (key && [key isKindOfClass:[NSString class]] && [key isEqualToString:channelId]) {
            {
                if (obj && [obj isKindOfClass:[TTADRefreshChannelShowTimeModel class]]) {
                    
                    currentChannelShowLimitModel = obj;
                    
                    if (currentChannelShowLimitModel.showDate && [self isSameDay:currentChannelShowLimitModel.showDate date2:[NSDate date]]) {
                        
                        if (!currentChannelShowLimitModel.showTimes || currentChannelShowLimitModel.showTimes.longLongValue < 0) {
                            
                            if (showLimit &&  showLimit.longLongValue > 0) {
                                isSuitable = YES;
                            }
                            
                        }
                        
                        else {
                            if (showLimit && currentChannelShowLimitModel.showTimes.longLongValue < showLimit.longLongValue) {
                                isSuitable = YES;
                            }
                        }
                        
                    }
                    
                    else {
                        
                        if (showLimit &&  showLimit.longLongValue > 0) {
                            isSuitable = YES;
                        }
                    }
                    
                    *stop = YES;
                }
            }
            
        }
    }];
    
    if (!currentChannelShowLimitModel) {

        if (showLimit &&  showLimit.longLongValue > 0) {
            isSuitable = YES;
        }
    }
    
    return isSuitable;
}

-(void)configureShowTimesdWithChannelId:(NSString *)channelId{
    
    if (isEmptyString(channelId)) {
        return;
    }

    
    __block TTADRefreshChannelShowTimeModel *currentChannelShowLimitModel = nil;
    
    if (self.showLimitModel) {
        [self.showLimitModel.showLimitDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if (key && [key isKindOfClass:[NSString class]] && [key isEqualToString:channelId]) {
                
                if (obj && [obj isKindOfClass:[TTADRefreshChannelShowTimeModel class]]) {
                    
                    currentChannelShowLimitModel = obj;
                    if (currentChannelShowLimitModel.showDate && [self isSameDay:currentChannelShowLimitModel.showDate date2:[NSDate date]]) {
                        
                        if (!currentChannelShowLimitModel.showTimes || currentChannelShowLimitModel.showTimes.longLongValue <= 0) {
                            currentChannelShowLimitModel.showTimes = @(1);
                        }
                        
                        else {
                            currentChannelShowLimitModel.showTimes = @(currentChannelShowLimitModel.showTimes.longLongValue + 1);
                        }
                        
                        currentChannelShowLimitModel.showDate = [NSDate date];
                    }
                    
                    else {
                        
                        currentChannelShowLimitModel.showDate = [NSDate date];
                        currentChannelShowLimitModel.showTimes = @(1);
                    }
                    
                    *stop = YES;
                }
                
            }
            
        }];

        if (!currentChannelShowLimitModel) {
            currentChannelShowLimitModel = [[TTADRefreshChannelShowTimeModel alloc] initWithChannelId:channelId];
            currentChannelShowLimitModel.showTimes = @(1);
            if (self.showLimitModel && self.showLimitModel.showLimitDic) {
                [self.showLimitModel.showLimitDic setValue:currentChannelShowLimitModel forKey:channelId];
            }
        }
    }
}


-(void)cacheShowLimitADModel:(TTADRefreshShowTimeModel *)showLimitAdModel{
    
    if (!showLimitAdModel || SSIsEmptyDictionary(showLimitAdModel.showLimitDic)) {
        return;
    }
    
    TTADRefreshShowTimeModel *cachedShowLimitModel = [[TTADRefreshShowTimeModel alloc] init];
    cachedShowLimitModel.showLimitDic = [showLimitAdModel.showLimitDic copy];
    
    [self.persistence setValue:cachedShowLimitModel forKey:TTNewAdRefreshShowLimitModelKey];
    [self.persistence save];

}

-(TTADRefreshShowTimeModel *)getCachedShowLimitADModel{
    
    TTADRefreshShowTimeModel* model = [self.persistence objectForKey:TTNewAdRefreshShowLimitModelKey];
    
    if (model && [model isKindOfClass:[TTADRefreshShowTimeModel class]] && !SSIsEmptyDictionary(model.showLimitDic)) {
        TTADRefreshShowTimeModel *showLimitModel = [[TTADRefreshShowTimeModel alloc] init];
        [showLimitModel.showLimitDic addEntriesFromDictionary:model.showLimitDic];
        return showLimitModel;
    }
    return nil;
    
}


-(TTADRefreshChannelShowTimeModel *)getChannelShowTimeModelWitChannelId:(NSString *)channelId{
    
    __block TTADRefreshChannelShowTimeModel *currentChannelShowLimitModel = nil;
    
    if (isEmptyString(channelId) || !self.showLimitModel || SSIsEmptyDictionary(self.showLimitModel.showLimitDic)) {
        return nil;
    }
    
    [self.showLimitModel.showLimitDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if (key && [key isKindOfClass:[NSString class]] && [key isEqualToString:channelId]) {
            if (obj && [obj isKindOfClass:[TTADRefreshChannelShowTimeModel class]]) {
                currentChannelShowLimitModel = obj;
                *stop = YES;
            }
        }
        
    }];
    
    return currentChannelShowLimitModel;
}


#pragma mark -- 公用接口逻辑

//判断是否是同一天
- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

//接入task
- (void)applicationDidFinishLaunchingNotification:(NSNotification*)notification{
    
    if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
        dispatch_queue_t concurrentQueue = dispatch_queue_create("ad.refresh.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), concurrentQueue, ^{
            [self fetchRefreshADModelsWithCompleteBlock:nil];
        });
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fetchRefreshADModelsWithCompleteBlock:nil];
        });
    }   
}

- (void)applicationWillEnterForegroundNotification:(NSNotification*)notification{
    self.lauchType = TTAppLaunchType_HotLaunch;
    [self fetchRefreshADModelsWithCompleteBlock:nil];
}

- (void)applicationDidBecomeActiveNotification:(NSNotification*)notification{
    
}


@end
