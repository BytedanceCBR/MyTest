//
//  FRForumLocationSelectViewModel.m
//  Article
//
//  Created by 王霖 on 15/7/14.
//
//

#import "FRForumLocationSelectViewModel.h"
#import "FRLocationEntity.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "TTUGCPodBridge.h"
#import "TTBaseMacro.h"

@interface FRForumLocationSelectViewModel ()<AMapSearchDelegate>

@property (nonatomic, strong)NSArray *locationItems;
@property (nonatomic, strong)CLLocation *lastLocation;
@property (nonatomic, strong)id<TTPlacemarkItemProtocol> lastPlacemark;
@property (nonatomic, strong)FRForumLocationLoadCompletion loadCompletionHandle;
@property (nonatomic, strong)AMapSearchAPI *search;

@property (nonatomic, assign)NSInteger currentPage;
@property (nonatomic, assign)BOOL isQuery;
@property (nonatomic, assign)BOOL hasMore;
@property (nonatomic, assign)BOOL isLastLoadError;

@property (nonatomic, strong)FRLocationEntity *temporaryLocation;
@property (nonatomic, copy)NSArray<id<TTPlacemarkItemProtocol>> *placemarks;

@end

@implementation FRForumLocationSelectViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentPage = 1;
        self.isQuery = NO;
        self.hasMore = YES;
        self.isLastLoadError = NO;
    }
    return self;
}
- (void)lastPlacemarks:(NSArray<id<TTPlacemarkItemProtocol>> *)placemarks {
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
            id<TTPlacemarkItemProtocol> placemarkItem = [[TTUGCPodBridge sharedInstance] getPlacemarkItem];
            if ([weakSelf.locationItems firstObject] == nil || [[weakSelf.locationItems firstObject] locationType] != FRLocationEntityTypeCity) {
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
            [(id<TTPlacemarkItemProtocol>)_placemarks.firstObject timestamp] - [[NSDate date] timeIntervalSince1970] < 10.0 * 60) {
            //可用，使用上次定位信息
            regecodeHandler(_placemarks);
            //定位，以便之后能快速用到新的定位信息
            [[TTUGCPodBridge sharedInstance] regeocodeWithCompletionHandler:nil];
        }else {

            //不可用，重新定位
            [[TTUGCPodBridge sharedInstance] regeocodeWithCompletionHandler:^(NSArray *placemarks) {
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
    if (_search == nil) {
        [AMapSearchServices sharedServices].apiKey = [[TTUGCPodBridge sharedInstance] amapKey];
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
}


- (void)searchNearbyLocationsWithKeyword:(NSString*)keyword CompletionHandle:(FRForumLocationLoadCompletion)completionHandle {
    if (isEmptyString(keyword)) {
        return;
    }
    
    if (_isQuery)
        return;
    self.isQuery = YES;
    self.isLastLoadError = NO;
    self.loadCompletionHandle = completionHandle;
    
    __weak typeof(self) weakSelf = self;
    if (_currentPage == 1) {
        [[TTUGCPodBridge sharedInstance] regeocodeWithCompletionHandler:^(NSArray *placemarks) {
            if (placemarks == nil || [placemarks count] == 0) {
                //定位失败
                weakSelf.isQuery = NO;
                weakSelf.isLastLoadError = YES;
                if (weakSelf.loadCompletionHandle) {
                    weakSelf.loadCompletionHandle(nil, nil, [NSError errorWithDomain:@"kCommonErrorDomain" code:0 userInfo:nil]);
                }
            } else {
                //定位成功，获取附近POI
                id<TTPlacemarkItemProtocol> placemarkItem = [[TTUGCPodBridge sharedInstance] getPlacemarkItem];;
                weakSelf.lastPlacemark = placemarkItem;
                [weakSelf searchPOIWithPlacemark:_lastPlacemark andKeyword:keyword];
            }
        }];
    } else {
        [weakSelf searchPOIWithPlacemark:_lastPlacemark andKeyword:keyword];
    }
}

- (void)searchPOIWithPlacemark:(id<TTPlacemarkItemProtocol>)placemark andKeyword:(NSString *)keyword{
    if (_search == nil) {
        [AMapSearchServices sharedServices].apiKey = [[TTUGCPodBridge sharedInstance] amapKey];
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
    AMapPOIKeywordsSearchRequest *poiRequest = [[AMapPOIKeywordsSearchRequest alloc] init];
    
    poiRequest.requireExtension = YES;
    
    poiRequest.keywords = keyword;
    poiRequest.city = placemark.city;
    
    poiRequest.sortrule = 0;
    poiRequest.page = self.currentPage;
    
    [_search AMapPOIAroundSearch:poiRequest];
}


#pragma mark- AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    self.isQuery = NO;
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

- (void)clearLocationItems {
    self.locationItems = nil;
}


//- (TTPlacemarkItem *)getPlacemarkItem:(TTLocationManager *)locationManager{
//    //定位成功，获取附近POI
//    TTPlacemarkItem *placemarkItem = nil;
//    if ([locationManager amapPlacemarkItem]) {
//        //高德的place mark item中的经纬度依然是WGS84(系统定位的坐标）
//        CLLocationCoordinate2D coordinate2D = [TTLocationTransform transformToGCJ02LocationWithWGS84Location:[[locationManager amapPlacemarkItem] coordinate]];
//        placemarkItem = [[TTPlacemarkItem alloc] init];
//        placemarkItem.coordinate = coordinate2D;
//        placemarkItem.timestamp = [[locationManager amapPlacemarkItem] timestamp];
//        placemarkItem.address = [[locationManager amapPlacemarkItem] address];
//        placemarkItem.province = [[locationManager amapPlacemarkItem] province];
//        placemarkItem.city = [[locationManager amapPlacemarkItem] city];
//        placemarkItem.district = [[locationManager amapPlacemarkItem] district];
//    } else if ([locationManager baiduPlacemarkItem]) {
//        //百度的place mark item中的经纬度是B09
//        CLLocationCoordinate2D coordinate2D = [TTLocationTransform transformB09ToGCJ02WithLocation:[[locationManager baiduPlacemarkItem] coordinate]];
//        placemarkItem = [[TTPlacemarkItem alloc] init];
//        placemarkItem.coordinate = coordinate2D;
//        placemarkItem.timestamp = [[locationManager baiduPlacemarkItem] timestamp];
//        placemarkItem.address = [[locationManager baiduPlacemarkItem] address];
//        placemarkItem.province = [[locationManager baiduPlacemarkItem] province];
//        placemarkItem.city = [[locationManager baiduPlacemarkItem] city];
//        placemarkItem.district = [[locationManager baiduPlacemarkItem] district];
//    } else {
//        //系统的place mark item中的经纬度是WGS84
//        CLLocationCoordinate2D coordinate2D = [TTLocationTransform transformToGCJ02LocationWithWGS84Location:[[locationManager placemarkItem] coordinate]];
//        placemarkItem = [[TTPlacemarkItem alloc] init];
//        placemarkItem.coordinate = coordinate2D;
//        placemarkItem.timestamp = [[locationManager placemarkItem] timestamp];
//        placemarkItem.address = [[locationManager placemarkItem] address];
//        placemarkItem.province = [[locationManager placemarkItem] province];
//        placemarkItem.city = [[locationManager placemarkItem] city];
//        placemarkItem.district = [[locationManager placemarkItem] district];
//    }
//
//    return placemarkItem;
//}


@end
