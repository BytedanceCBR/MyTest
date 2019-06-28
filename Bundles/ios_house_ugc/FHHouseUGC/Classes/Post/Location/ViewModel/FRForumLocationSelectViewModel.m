//
//  FRForumLocationSelectViewModel.m
//  Article
//
//  Created by 王霖 on 15/7/14.
//
//

#import "FRForumLocationSelectViewModel.h"
//#import "TTPostThreadBridge.h"

#import "TTGoogleMapGeocoder.h"
#import "TTGoogleMapService.h"
#import "TTPlacemarkItem+GoogleAPI.h"
#import <AMapFoundationKit/AMapUtility.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTUGCFoundation/FRLocationEntity.h>
#import <AMapFoundationKit/AMapServices.h>
#import <TTMonitor/TTMonitor.h>
#import <TTLocationManager/TTLocationTransformer.h>

@interface FRForumLocationSelectViewModel ()<AMapSearchDelegate>

@property (nonatomic, strong)NSArray *locationItems;
@property (nonatomic, strong)CLLocation *lastLocation;
@property (nonatomic, strong)TTPlacemarkItem * lastPlacemark;
@property (nonatomic, strong)FRForumLocationLoadCompletion loadCompletionHandle;
@property (nonatomic, strong)AMapSearchAPI *search;

@property (nonatomic, assign)NSInteger currentPage;
@property (nonatomic, assign)BOOL isQuery;
@property (nonatomic, assign)BOOL hasMore;
@property (nonatomic, assign)BOOL isLastLoadError;

@property (nonatomic, strong)FRLocationEntity *temporaryLocation;
@property (nonatomic, copy)NSArray<TTPlacemarkItem *> *placemarks;

@property (nonatomic, copy) NSString *continueToken;// for Google Api

@property (nonatomic, copy) NSString *keyword;

@end

@implementation FRForumLocationSelectViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentPage = 1;
        self.isQuery = NO;
        self.hasMore = YES;
        self.isLastLoadError = NO;
        
        // 外部已经设置过了 apiKey add by zyk
//        [AMapServices sharedServices].apiKey = [[TTPostThreadBridge sharedInstance] amapKey];
        
        [AMapServices sharedServices].crashReportEnabled = NO;
    }
    return self;
}
- (void)lastPlacemarks:(NSArray<TTPlacemarkItem *> *)placemarks {
    self.placemarks = [placemarks copy];
}

- (void)insertLocation:(FRLocationEntity*)location atIndex:(NSUInteger)index {
    NSMutableArray *mutableLocationItems = [NSMutableArray arrayWithArray:_locationItems];
    if ([mutableLocationItems count]> index) {
        [mutableLocationItems insertObject:location atIndex:index];
    } else {
        [mutableLocationItems addObject:location];
    }
    self.locationItems = [NSArray arrayWithArray:mutableLocationItems];
}

- (void)loadNearbyLocationsWithCompletionHandle:(FRForumLocationLoadCompletion)completionHandle {
    if (_isQuery)
        return;
    self.isQuery = YES;
    self.isLastLoadError = NO;
    self.loadCompletionHandle = completionHandle;
    
    __weak typeof(self) weakSelf = self;
    if (_currentPage == 1) {
        
        void(^regecodeHandler)(NSArray *) = ^(NSArray *placemarks) {
            TTPlacemarkItem * placemarkItem = [TTLocationManager sharedManager].placemarkItemInCoordinateGCJ02;
            FRLocationEntity *entity = [weakSelf.locationItems firstObject];
            if ([weakSelf.locationItems firstObject] == nil || entity.locationType != FRLocationEntityTypeCity) {
                //城市信息不存在，构造城市信息
                if (!isEmptyString(placemarkItem.city)) {
                    FRLocationEntity * location = [[FRLocationEntity alloc] init];
                    location.locationType = FRLocationEntityTypeCity;
                    location.latitude = placemarkItem.coordinate.latitude;
                    location.longitude = placemarkItem.coordinate.longitude;
                    location.city = placemarkItem.city;
                    if (!isEmptyString(placemarkItem.district)) {
                        location.locationName = placemarkItem.district;
                    }
                    weakSelf.temporaryLocation = location;
                } else if (!isEmptyString(placemarkItem.province)){
                    FRLocationEntity * location = [[FRLocationEntity alloc] init];
                    location.locationType = FRLocationEntityTypeCity;
                    location.latitude = placemarkItem.coordinate.latitude;
                    location.longitude = placemarkItem.coordinate.longitude;
                    location.city = placemarkItem.province;
                    if (!isEmptyString(placemarkItem.district)) {
                        location.locationName = placemarkItem.district;
                    }
                    weakSelf.temporaryLocation = location;
                }
            }
            CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:placemarkItem.coordinate.latitude longitude:placemarkItem.coordinate.longitude];
            weakSelf.lastLocation = userLocation;
            [weakSelf loadNearbyPOIWithLocation:userLocation];
        };
        
        //判断上次的定位信息是否可用（十分钟之内看做可用）
        if (!SSIsEmptyArray(_placemarks) && !_isLastLoadError &&
            [(TTPlacemarkItem *)_placemarks.firstObject timestamp] - [[NSDate date] timeIntervalSince1970] < 10.0 * 60) {
            //可用，使用上次定位信息
            regecodeHandler(_placemarks);
            //定位，以便之后能快速用到新的定位信息
            [[TTLocationManager sharedManager] startGeolocatingWithCompletionHandler:nil];
        } else {
            //不可用，重新定位
            [[TTLocationManager sharedManager] startGeolocatingWithCompletionHandler:^(NSArray *placemarks) {
                if (placemarks == nil || [placemarks count] == 0) {
                    //定位失败
                    weakSelf.isQuery = NO;
                    weakSelf.isLastLoadError = YES;
                    if (weakSelf.loadCompletionHandle) {
                        weakSelf.loadCompletionHandle(nil, nil, [NSError errorWithDomain:@"kCommonErrorDomain" code:0 userInfo:nil]);
                    }
                } else {
                    //定位成功，获取附近POI
                    regecodeHandler(placemarks);
                }
            }];
        }
    } else {
        [self loadNearbyPOIWithLocation:_lastLocation];
    }
}

- (void)loadNearbyPOIWithLocation:(CLLocation *)location{
    if ([self isAMapSupportLocation:location.coordinate]) {
        if (_search == nil) {
            self.search = [[AMapSearchAPI alloc] init];
            self.search.delegate = self;
        }
        AMapPOIAroundSearchRequest *poiRequest = [[AMapPOIAroundSearchRequest alloc] init];
        
        AMapGeoPoint *searchLocation = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        
        poiRequest.requireExtension = YES;
        poiRequest.location = searchLocation;
        poiRequest.sortrule = 0;
        poiRequest.page = self.currentPage;
        
        [_search AMapPOIAroundSearch:poiRequest];
    } else {
        [self p_gMapRoundSearch];
    }
}


- (void)searchNearbyLocationsWithKeyword:(NSString*)keyword CompletionHandle:(FRForumLocationLoadCompletion)completionHandle {
    if (isEmptyString(keyword)) {
        return;
    }
    
    if (_isQuery) {
        [self.search cancelAllRequests];
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
    
    if (![keyword isEqualToString:self.keyword]) {
        [self clearLocationItems];
    }
    self.keyword = keyword;
    self.isQuery = YES;
    self.isLastLoadError = NO;
    self.loadCompletionHandle = completionHandle;
    
    __weak typeof(self) weakSelf = self;
    if (_currentPage == 1) {
        [[TTLocationManager sharedManager] startGeolocatingWithCompletionHandler:^(NSArray *placemarks) {
            if (placemarks == nil || [placemarks count] == 0) {
                //定位失败
                weakSelf.isQuery = NO;
                weakSelf.isLastLoadError = YES;
                if (weakSelf.loadCompletionHandle) {
                    weakSelf.loadCompletionHandle(nil, nil, [NSError errorWithDomain:@"kCommonErrorDomain" code:0 userInfo:nil]);
                }
            } else {
                //定位成功，获取附近POITheater
                TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItemInCoordinateGCJ02;
                weakSelf.lastPlacemark = placemarkItem;
                [weakSelf searchPOIWithPlacemark:weakSelf.lastPlacemark andKeyword:keyword];
            }
        }];
    } else {
        [weakSelf searchPOIWithPlacemark:_lastPlacemark andKeyword:keyword];
    }
}

- (void)searchPOIWithPlacemark:(TTPlacemarkItem *)placemark andKeyword:(NSString *)keyword{
    if ([self isAMapSupportCurrentLocation]) {
        if (_search == nil) {
            self.search = [[AMapSearchAPI alloc] init];
            self.search.delegate = self;
        }
        AMapPOIKeywordsSearchRequest *poiRequest = [[AMapPOIKeywordsSearchRequest alloc] init];
        
        poiRequest.requireExtension = YES;
        
        poiRequest.keywords = keyword;
        poiRequest.city = placemark.city;
        
        poiRequest.sortrule = 0;
        poiRequest.page = self.currentPage;
        
        [_search AMapPOIKeywordsSearch:poiRequest];
    } else {
        [self p_gMapKeywordsRoundSearchWithKeywords:keyword];
    }
}

#pragma mark- AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    self.isQuery = NO;
    self.hasMore = NO;
    self.isLastLoadError = YES;
    self.temporaryLocation = nil;
    if (_loadCompletionHandle) {
        _loadCompletionHandle(nil, nil, error);
    }
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    self.isQuery = NO;
    self.isLastLoadError = NO;
    
    if (_temporaryLocation != nil) {
        [self insertLocation:_temporaryLocation atIndex:0];
    }
    FRLocationEntity * temporaryLocation = _temporaryLocation;
    self.temporaryLocation = nil;
    
    NSArray *filterPOIs = [self poiFilter:response.pois];
    if (filterPOIs == nil || [filterPOIs count] == 0) {
        self.hasMore = NO;
        if (_loadCompletionHandle) {
            _loadCompletionHandle(temporaryLocation, nil, nil);
        }
        return;
    }
    self.currentPage ++;
    
    NSArray *responeLocationItems = [self locationItemsFromPOI:filterPOIs];
    
    NSMutableArray *locationItems = [NSMutableArray arrayWithArray:_locationItems];
    [locationItems addObjectsFromArray:responeLocationItems];
    self.locationItems = [NSArray arrayWithArray:locationItems];
    
    if (_loadCompletionHandle) {
        _loadCompletionHandle(temporaryLocation, responeLocationItems, nil);
    }
}

#pragma mark - Google map

- (BOOL)isAMapSupportCurrentLocation {
    return AMapDataAvailableForCoordinate([TTLocationTransformer transformToGCJ02LocationWithWGS84LocationV2:[[TTLocationManager sharedManager] systemPlacemarkItem].coordinate]);
}

- (BOOL)isAMapSupportLocation:(CLLocationCoordinate2D)coordinate {
    return AMapDataAvailableForCoordinate([TTLocationTransformer transformToGCJ02LocationWithWGS84LocationV2:coordinate]);
}

- (TTHttpTask *)p_gMapRoundSearch {
    
    if (_currentPage == 1) {
        CLLocationCoordinate2D coordinate;
        TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].validPlacemarkItemInLocalizedCoordinate;
        coordinate.latitude = placemarkItem.coordinate.latitude;
        coordinate.longitude = placemarkItem.coordinate.longitude;
        
        __weak typeof(self) weakSelf = self;
        return [TTGoogleMapService requestNearbyLocationWithCoordinate:coordinate completionBlock:^(NSArray<TTPlacemarkItem *> * _Nonnull placemarkItems, BOOL hasMore, NSString * _Nonnull continueToken, NSError * _Nonnull error) {
            weakSelf.isQuery = NO;
            weakSelf.isLastLoadError = error ? YES : NO;
            weakSelf.hasMore = hasMore;
            weakSelf.continueToken = continueToken;
            
            NSArray *locations = [self locationItemsFromGMapResult:placemarkItems];
            
            weakSelf.currentPage ++;
            NSMutableArray *locationItems = [NSMutableArray arrayWithArray:_locationItems];
            [locationItems addObjectsFromArray:locations];
            weakSelf.locationItems = [NSArray arrayWithArray:locationItems];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_loadCompletionHandle) {
                    _loadCompletionHandle(nil, locations, error);
                }
            });
            
            // Monitor
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setValue:@([self isAMapSupportCurrentLocation]) forKey:@"inChina"];
            [dic setValue:@(coordinate.latitude) forKey:@"lat"];
            [dic setValue:@(coordinate.longitude) forKey:@"lng"];
            [dic setValue:@"gmap" forKey:@"geocoder"];
            
            NSMutableDictionary *extraDic = [NSMutableDictionary new];
            [extraDic setValue:@(placemarkItems.count) forKey:@"location_count"];
            [extraDic setValue:@(hasMore) forKey:@"has_more"];
            if (error) {
                NSMutableDictionary *errorDiscription = [NSMutableDictionary new];
                [errorDiscription setValue:error.domain forKey:@"domain"];
                [errorDiscription setValue:@(error.code) forKey:@"code"];
                [errorDiscription setValue:error.userInfo forKey:@"user_info"];
                [extraDic setValue:errorDiscription forKey:@"error"];
            }
            [dic setValue:[extraDic copy] forKey:@"extra_dic"];
            // geocode = 0, nearby = 1, search = 2
            [[TTMonitor shareManager] trackService:@"geocode_service" status:1 extra:[dic copy]];
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        return [TTGoogleMapService continueSearchWithContinueToken:self.continueToken completionBlock:^(NSArray<TTPlacemarkItem *> * _Nonnull placemarkItems, BOOL hasMore, NSString * _Nonnull continueToken, NSError * _Nonnull error) {
            weakSelf.isQuery = NO;
            weakSelf.isLastLoadError = error ? YES : NO;
            weakSelf.hasMore = hasMore;
            weakSelf.continueToken = continueToken;
            
            NSArray *locations = [self locationItemsFromGMapResult:placemarkItems];
            
            weakSelf.currentPage ++;
            NSMutableArray *locationItems = [NSMutableArray arrayWithArray:_locationItems];
            [locationItems addObjectsFromArray:locations];
            weakSelf.locationItems = [NSArray arrayWithArray:locationItems];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_loadCompletionHandle) {
                    _loadCompletionHandle(nil, locations, error);
                }
            });
            
            // Monitor
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setValue:@([self isAMapSupportCurrentLocation]) forKey:@"inChina"];
            [dic setValue:@"gmap" forKey:@"geocoder"];
            
            NSMutableDictionary *extraDic = [NSMutableDictionary new];
            [extraDic setValue:@(placemarkItems.count) forKey:@"location_count"];
            [extraDic setValue:@(hasMore) forKey:@"has_more"];
            if (error) {
                NSMutableDictionary *errorDiscription = [NSMutableDictionary new];
                [errorDiscription setValue:error.domain forKey:@"domain"];
                [errorDiscription setValue:@(error.code) forKey:@"code"];
                [errorDiscription setValue:error.userInfo forKey:@"user_info"];
                [extraDic setValue:errorDiscription forKey:@"error"];
            }
            [dic setValue:[extraDic copy] forKey:@"extra_dic"];
            // geocode = 0, nearby = 1, search = 2
            [[TTMonitor shareManager] trackService:@"geocode_service" status:1 extra:[dic copy]];
        }];
    }
}

- (TTHttpTask *)p_gMapKeywordsRoundSearchWithAMapParam:(AMapPOIKeywordsSearchRequest *)aMapParam {
    
    return [self p_gMapKeywordsRoundSearchWithKeywords:aMapParam.keywords];
}

- (TTHttpTask *)p_gMapKeywordsRoundSearchWithKeywords:(NSString *)keywords {
    
    if (_currentPage == 1) {
        CLLocationCoordinate2D coordinate;
        TTPlacemarkItem *sysPlacemarkItem = [TTLocationManager sharedManager].validPlacemarkItemInLocalizedCoordinate;
        coordinate.latitude = sysPlacemarkItem.coordinate.latitude;
        coordinate.longitude = sysPlacemarkItem.coordinate.longitude;
        
        __weak typeof(self) weakSelf = self;
        return [TTGoogleMapService requestSearchNearbyLocationWithCoordinate:coordinate keywords:keywords completionBlock:^(NSArray<TTPlacemarkItem *> * _Nonnull placemarkItems, BOOL hasMore, NSString * _Nonnull continueToken, NSError * _Nonnull error) {
            weakSelf.isQuery = NO;
            weakSelf.isLastLoadError = error ? YES : NO;
            weakSelf.hasMore = hasMore;
            weakSelf.continueToken = continueToken;
            
            NSArray *locations = [self locationItemsFromGMapResult:placemarkItems];
            
            weakSelf.currentPage ++;
            NSMutableArray *locationItems = [NSMutableArray arrayWithArray:_locationItems];
            [locationItems addObjectsFromArray:locations];
            weakSelf.locationItems = [NSArray arrayWithArray:locationItems];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_loadCompletionHandle) {
                    _loadCompletionHandle(nil, locations, error);
                }
            });
            
            // Monitor
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setValue:@([self isAMapSupportCurrentLocation]) forKey:@"inChina"];
            [dic setValue:@(coordinate.latitude) forKey:@"lat"];
            [dic setValue:@(coordinate.longitude) forKey:@"lng"];
            [dic setValue:@"gmap" forKey:@"geocoder"];
            
            NSMutableDictionary *extraDic = [NSMutableDictionary new];
            [extraDic setValue:@(placemarkItems.count) forKey:@"location_count"];
            [extraDic setValue:@(hasMore) forKey:@"has_more"];
            if (error) {
                NSMutableDictionary *errorDiscription = [NSMutableDictionary new];
                [errorDiscription setValue:error.domain forKey:@"domain"];
                [errorDiscription setValue:@(error.code) forKey:@"code"];
                [errorDiscription setValue:error.userInfo forKey:@"user_info"];
                [extraDic setValue:errorDiscription forKey:@"error"];
            }
            [dic setValue:[extraDic copy] forKey:@"extra_dic"];
            // geocode = 0, nearby = 1, search = 2
            [[TTMonitor shareManager] trackService:@"geocode_service" status:2 extra:[dic copy]];
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        return [TTGoogleMapService continueSearchWithContinueToken:self.continueToken completionBlock:^(NSArray<TTPlacemarkItem *> * _Nonnull placemarkItems, BOOL hasMore, NSString * _Nonnull continueToken, NSError * _Nonnull error) {
            weakSelf.isQuery = NO;
            weakSelf.isLastLoadError = error ? YES : NO;
            weakSelf.hasMore = hasMore;
            weakSelf.continueToken = continueToken;
            
            NSArray *locations = [self locationItemsFromGMapResult:placemarkItems];
            
            weakSelf.currentPage ++;
            NSMutableArray *locationItems = [NSMutableArray arrayWithArray:_locationItems];
            [locationItems addObjectsFromArray:locations];
            weakSelf.locationItems = [NSArray arrayWithArray:locationItems];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_loadCompletionHandle) {
                    _loadCompletionHandle(nil, locations, error);
                }
            });
            
            // Monitor
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setValue:@([self isAMapSupportCurrentLocation]) forKey:@"inChina"];
            [dic setValue:@"gmap" forKey:@"geocoder"];
            
            NSMutableDictionary *extraDic = [NSMutableDictionary new];
            [extraDic setValue:@(placemarkItems.count) forKey:@"location_count"];
            [extraDic setValue:@(hasMore) forKey:@"has_more"];
            if (error) {
                NSMutableDictionary *errorDiscription = [NSMutableDictionary new];
                [errorDiscription setValue:error.domain forKey:@"domain"];
                [errorDiscription setValue:@(error.code) forKey:@"code"];
                [errorDiscription setValue:error.userInfo forKey:@"user_info"];
                [extraDic setValue:errorDiscription forKey:@"error"];
            }
            [dic setValue:[extraDic copy] forKey:@"extra_dic"];
            // geocode = 0, nearby = 1, search = 2
            [[TTMonitor shareManager] trackService:@"geocode_service" status:2 extra:[dic copy]];
        }];
    }
}

#pragma mark - Utils
/**
    过滤poi
 */
- (NSArray *)poiFilter:(NSArray *)pois {
    NSMutableArray *resultPOIs = [NSMutableArray array];
    for (NSInteger i = 0; i<[pois count]; i++) {
        AMapPOI *poi = [pois objectAtIndex:i];
        if (!isEmptyString(poi.address)) {
            [resultPOIs addObject:poi];
        }
    }
    if ([resultPOIs count] == 0) {
        return nil;
    } else {
        return [resultPOIs copy];
    }
}

/**
    把高德poi转成FRForumLocation
 */
- (NSArray *)locationItemsFromPOI:(NSArray *)pois {
    NSMutableArray *responseLocationItems = [NSMutableArray array];
    for (AMapPOI *poi in pois) {
        FRLocationEntity *locationItem = [[FRLocationEntity alloc] init];
        locationItem.locationType = FRLocationEntityTypeNomal;
        locationItem.latitude = poi.location.latitude;
        locationItem.longitude = poi.location.longitude;
        locationItem.city = poi.city;
        locationItem.locationName = poi.name;
        locationItem.locationAddress = poi.address;
        [responseLocationItems addObject:locationItem];
    }
    
    return [NSArray arrayWithArray:responseLocationItems];
}

- (NSArray *)locationItemsFromGMapResult:(NSArray <TTPlacemarkItem *> *)gmapLocations {
    // Google Map 搜索结果没有返回所在城市，所以针对这种情况取地理位置坐标做城市返回
    NSString *city = [[TTLocationManager sharedManager] placemarkItemWithFieldName:[TTGoogleMapGeocoder fieldName]].city;
    
    NSMutableArray *responseLocationItems = [NSMutableArray new];
    for (TTPlacemarkItem *item in gmapLocations) {
        FRLocationEntity *locationItem = [[FRLocationEntity alloc] init];
        locationItem.locationType = ![item iskindOfLocality] ? FRLocationEntityTypeNomal : FRLocationEntityTypeCity;
        locationItem.latitude = item.coordinate.latitude;
        locationItem.longitude = item.coordinate.longitude;
        locationItem.city = city;
        locationItem.locationName = locationItem.locationType == FRLocationEntityTypeCity ? locationItem.city : item.name;
        locationItem.locationAddress = locationItem.locationType == FRLocationEntityTypeCity ? locationItem.city : item.address;
        locationItem.locationAddress = !isEmptyString(locationItem.locationAddress) ? locationItem.locationAddress : locationItem.city;
        [responseLocationItems addObject:locationItem];
    }
    
    return [responseLocationItems copy];
}

- (void)clearLocationItems {
    self.locationItems = nil;
    _currentPage = 1;
}

- (void)cancelPreviousRequest {
    
    self.isQuery = NO;
    self.isLastLoadError = NO;
    self.hasMore = NO;
    if (_loadCompletionHandle) {
        _loadCompletionHandle(_temporaryLocation, nil, nil);
    }
}

- (id)copyWithZone:(NSZone *)zone {
    FRForumLocationSelectViewModel *copyModel = [[FRForumLocationSelectViewModel allocWithZone:zone] init];
    copyModel.locationItems = [_locationItems copyWithZone:zone];
    copyModel.lastLocation = [_lastLocation copyWithZone:zone];
    copyModel.lastPlacemark = _lastPlacemark;
    copyModel.loadCompletionHandle = _loadCompletionHandle;
    copyModel.search = _search;
    copyModel.currentPage = _currentPage;
    copyModel.isQuery = _isQuery;
    copyModel.hasMore = _hasMore;
    copyModel.isLastLoadError = _isLastLoadError;
    copyModel.temporaryLocation = _temporaryLocation;
    copyModel.placemarks = [_placemarks copyWithZone:zone];
    copyModel.continueToken = _continueToken;
    copyModel.keyword = _keyword;
    return  copyModel;
}

@end
