//
//  TTBaiduGeocoder.m
//  Article
//
//  Created by SunJiangting on 15-3-11.
//
//

#import "TTBaiduGeocoder.h"

@interface TTBaiduGeocoder () <BMKGeoCodeSearchDelegate>

@property(nonatomic, strong) BMKMapManager    *mapManager;
@property(nonatomic, strong) BMKGeoCodeSearch *codeSearch;
@property(nonatomic) CLLocationCoordinate2D   cooridinate2D;
@property(nonatomic, strong) TTGeocodeHandler completionHandler;

@end

@implementation TTBaiduGeocoder
static TTBaiduGeocoder *_sharedGeocoder;
+ (instancetype)sharedGeocoder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedGeocoder = [[self alloc] init];
    });
    return _sharedGeocoder;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BMKMapManager *)mapManager {
    if (!_mapManager && [self isGeocodeSupported]) {
        _mapManager = [[BMKMapManager alloc] init];
        [_mapManager start:[SSCommonLogic baiduMapKey] generalDelegate:nil];
        self.codeSearch = [[BMKGeoCodeSearch alloc] init];
    }
    return _mapManager;
}

- (void)reverseGeocodeLocation:(CLLocation *)location timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(TTGeocodeHandler)completionHandler {
    timeoutInterval = MAX(15, timeoutInterval);
    self.completionHandler = completionHandler;
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTriggerTimeout) object:nil];
    if (self.mapManager) {
        CLLocationCoordinate2D coordinate2D = TTConvertCoordinateToBaidu(location.coordinate, 0);
        BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
        /// 将系统坐标转换为百度坐标
        reverseGeocodeSearchOption.reverseGeoPoint = coordinate2D;
        self.cooridinate2D = coordinate2D;
        [self.codeSearch reverseGeoCode:reverseGeocodeSearchOption];
        self.codeSearch.delegate = self;
        [self performSelector:@selector(didTriggerTimeout) withObject:nil afterDelay:timeoutInterval];
    } else {
        [self performSelector:@selector(didTriggerTimeout) withObject:nil afterDelay:0.0];
    }
}

- (void)didTriggerTimeout {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTriggerTimeout) object:nil];
    if (self.completionHandler) {
        NSError *error = [NSError errorWithDomain:@"com.ss.article" code:NSURLErrorTimedOut userInfo:@{@"description":@"baidu reverse failed"}];
        self.completionHandler(self, nil, error);
    }
    self.codeSearch.delegate = nil;
    self.completionHandler = nil;
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)errorCode {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTriggerTimeout) object:nil];
    if (self.completionHandler) {
        if (errorCode != BMK_SEARCH_NO_ERROR) {
            NSError *error = [NSError errorWithDomain:@"com.ss.article" code:errorCode userInfo:@{@"description":@"baidu reverse failed"}];
            self.completionHandler(self, nil, error);
        } else {
            TTPlacemarkItem *item = [self _placemarkItemWithDetailResult:result];
            item.coordinate = self.cooridinate2D;
            self.completionHandler(self, item, nil);
        }
    }
    self.completionHandler = nil;
}

- (TTPlacemarkItem *)_placemarkItemWithDetailResult:(BMKReverseGeoCodeResult *)geoCodeResult {
    if (!geoCodeResult) {
        return nil;
    }
    TTPlacemarkItem *placemarkItem = [[TTPlacemarkItem alloc] init];
    placemarkItem.address = geoCodeResult.address;
    placemarkItem.province = geoCodeResult.addressDetail.province;
    placemarkItem.city = geoCodeResult.addressDetail.city;
    placemarkItem.district = geoCodeResult.addressDetail.district;
    return placemarkItem;
}

- (void)cancel {
    self.codeSearch.delegate = nil;
    self.completionHandler = nil;
}

- (BOOL)isGeocodeSupported {
    return [[self class] isGeocodeSupported];
}

+ (BOOL)isGeocodeSupported {
    return !isEmptyString([SSCommonLogic baiduMapKey]);
}

- (NSString *)uploadFieldName {
    return @"baidu_location";
}

@end


extern CLLocationCoordinate2D TTConvertCoordinateToBaidu(CLLocationCoordinate2D coordinate, BMK_COORD_TYPE type) {
    NSDictionary *dictionary = BMKConvertBaiduCoorFrom(coordinate, type);
    return BMKCoorDictionaryDecode(dictionary);
}
