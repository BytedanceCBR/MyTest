    //
//  TTLocationManager.m
//  Article
//
//  Created by SunJiangting on 15-4-22.
//
//

#import "TTLocationManager.h"
#import "TTNetworkManager.h"
#import "TTNetworkUtilities.h"
#import "SSCommonLogic.h"
#import "TTThemedAlertController.h"

#import "TTArticleCategoryManager.h"
#import "SSDebugViewController.h"

#import "SSLocationPickerController.h"
#import "TTAuthorizeManager.h"
#import "NewsUserSettingManager.h"
#import "ExploreExtenstionDataHelper.h"
#import "TTFastCoding.h"
#import "TTLocator.h"
#import "TTGeocoder.h"
#import "TTModuleBridge.h"
#import "TTAmapGeocoder.h"
#import "NSDataAdditions.h"
#import "TTArticleTabBarController.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "TTTabBarProvider.h"
#import "TTLocationTransform.h"

NSString *const TTLocationManagerCityDidChangedNotification = @"kArticleCityDidChangedNotification";

//#define kTestLocation
NSString *const TTLocationLastRequestTime = @"last_time";//上次网络请求时间
NSString *const TTLocationOperationResult = @"op_type";//1 或 0,具体操作结果，针对命令号 cmd1: 1表示自动切换，0没有切换 cmd2:1表示已经提示弹窗，0表示没有弹窗
NSString *const TTLocationOperationTime = @"op_time";//操作时间
NSString *const TTLocationID = @"loc_id";
NSString *const TTLocationLastInterval = @"last_interval";
NSString *const TTLocationOperationCMD = @"cmd";

NSString *const TTLocationOperationTimeOld = @"Date";
NSString *const TTLocationIDOld = @"ID";

@interface TTLocationFeedback : TTFastCoding
@property(nonatomic, strong) NSDate *last_time;
@property(nonatomic, copy) NSString *loc_id;
@property(nonatomic, strong) NSDate *op_time;
@property(nonatomic, assign) TTLocationCommandResult op_type;
@property(nonatomic, assign) TTLocationCommandType cmd;
@property(nonatomic, assign) BOOL  isOperationed;//该状态是否成功执行需要本地保存,1.服务器返回cmd=2,本地没有执行success = NO,在无网情况下,执行了success = YES,那么在有网之前,这个状态是不能在修改为NO
@property(nonatomic, strong) NSDate *delayAlertLastShowTime;
@property(nonatomic, strong) NSDate *changeLocationAlertLastShowTime;
@end

@implementation TTLocationFeedback

@end



@interface TTLocationManager (LocalMethod)
- (void)processLocationCommandIfNeededFromNetWork;
@end

@interface TTPlacemarkItem ()

@property(nonatomic, copy) NSString *fieldName;

@end

@implementation TTPlacemarkItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.timestamp = [dictionary tt_doubleValueForKey:@"timestamp"];
        self.address = [dictionary tt_stringValueForKey:@"address"];
        self.province = [dictionary tt_stringValueForKey:@"province"];
        self.city = [dictionary tt_stringValueForKey:@"city"];
        NSDictionary *coordinateDict = [dictionary tt_dictionaryValueForKey:@"coordinateValues"];
        double longitude = [coordinateDict tt_doubleValueForKey:@"longitude"];
        double latitude = [coordinateDict tt_doubleValueForKey:@"latitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:6];
    [dictionary setValue:@(self.timestamp) forKey:@"timestamp"];
    [dictionary setValue:self.address forKey:@"address"];
    [dictionary setValue:self.province forKey:@"province"];
    [dictionary setValue:self.city forKey:@"city"];
    NSDictionary *coordinateDictionary = @{@"longitude":@(self.coordinate.longitude), @"latitude":@(self.coordinate.latitude)};
    dictionary[@"coordinateValues"] = coordinateDictionary;
    
    return dictionary;
}

- (NSDictionary *)toFormDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:4];
    [result setValue:self.province forKey:@"province"];
    [result setValue:self.city forKey:@"city"];
    [result setValue:self.address forKey:@"address"];
    [result setValue:@(self.timestamp) forKey:@"loc_time"];
    [result setValue:@(self.coordinate.longitude) forKey:@"longitude"];
    [result setValue:@(self.coordinate.latitude) forKey:@"latitude"];
    return [result copy];
}

@end

@implementation TTLocationCommandItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.commandType = [dictionary tt_integerValueForKey:TTLocationOperationCMD];
        self.currentCity = [dictionary tt_stringValueForKey:@"curr_city"];
        self.userCity = [dictionary tt_stringValueForKey:@"user_city"];
        self.alertTitle = [dictionary tt_stringValueForKey:@"alert_title"];
        self.identifier = [dictionary tt_stringValueForKey:TTLocationID];
    }
    return self;
}

@end

NSString *const TTLocationLastUpdateTimeDate = @"TTLocationLastUpdateTimeDate";
NSString *const TTPlacemarkCacheKey = @"TTPlacemarkCacheKey";
NSString *const TTLocationCommandItemCacheKey = @"TTLocationCommandItemCacheKey";
NSString *const TTLocationCommandProcessCacheKey = @"TTLocationCommandProcessCacheKey";
NSString *const TTLocationCityCacheKey = @"TTLocationCityCacheKey";
NSString *const TTLocationProvinceCacheKey = @"TTLocationProvinceCacheKey";

@interface TTLocationManager () {
    
}

@property(nonatomic, strong) NSMutableArray      *latestPlacemarks;
@property(nonatomic, strong) NSDate         *lastUpdateDate;


@property(nonatomic, strong) NSMutableDictionary   *geocoders;
@property(nonatomic, strong) TTLocationFeedback  *feedback;
@property(nonatomic, strong) TTLocationCommandItem  *commandItem;
@property(nonatomic, strong) TTLocationCommandItem  *preCommandItem;//先前cmd不等于0,op_type = 0的时候的commandItem,当前要显示alert,但是没有显示,保存下来,等待用户进入主页面的时候显示.
@property(nonatomic, weak) NSObject  *alertController;
//@property(nonatomic, strong) NSDate  *lastRequestTime;
@end

@implementation TTLocationManager

static TTLocationManager *_sharedManager;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

+ (void)load
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTLocationCoordinate" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
        if(placemarkItem.coordinate.longitude > 0) {
            [dic setValue:@(placemarkItem.coordinate.latitude) forKey:@"latitude"];
            [dic setValue:@(placemarkItem.coordinate.longitude) forKey:@"longitude"];
        }
        
        return dic;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.geocoders = [NSMutableDictionary dictionaryWithCapacity:3];
        self.latestPlacemarks = [NSMutableArray arrayWithCapacity:2];
        
        NSArray *cachedPlacemarks = [self _loadPlacemarksFromCache];
        if (!SSIsEmptyArray(cachedPlacemarks)) {
            [self.latestPlacemarks addObjectsFromArray:cachedPlacemarks];
        }
        self.lastUpdateDate = [[NSUserDefaults standardUserDefaults] valueForKey:TTLocationLastUpdateTimeDate];
        
        _feedback = [TTLocationFeedback read];
        if (!_feedback) {
            _feedback = [[TTLocationFeedback alloc] init];
            [self settingFeedbackFromUserDefault];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [self registerGeocoder:[TTGeocoder sharedGeocoder] forKey:@"TTGeocoder"];
       // [self registerGeocoder:[TTBaiduGeocoder sharedGeocoder] forKey:@"TTBaiduGeocoder"];
        [self registerGeocoder:[TTAmapGeocoder sharedGeocoder] forKey:@"TTAmapGeocoder"];
    }
    return self;
}

- (void)settingFeedbackFromUserDefault
{
    NSDictionary *commandHandlers = [[NSUserDefaults standardUserDefaults] valueForKey:TTLocationCommandProcessCacheKey];
    [commandHandlers enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            if ([key integerValue] != TTLocationCommandTypeNone && [key integerValue] != TTLocationCommandTypeChangeCityAutomatically) {
                NSDate *op_time = [obj valueForKey:@"Date"];//op_time
                NSString *loc_id = [obj valueForKey:TTLocationIDOld];
                _feedback.op_time = op_time;
                _feedback.loc_id = loc_id;
                _feedback.cmd = [key integerValue];
                _feedback.op_type = TTLocationCommandResultSuccess;
            }
        }
    }];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TTLocationCommandProcessCacheKey];//清除不在使用就数据结构.
}

- (void)registerGeocoder:(id<TTGeocodeProtocol>)geocoder forKey:(NSString *)key {
    [self.geocoders setValue:geocoder forKey:key];
}

- (void)unregisterGeocoderForKey:(NSString *)key {
    [self.geocoders removeObjectForKey:key];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self reportLocationIfNeeded];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self reportLocationIfNeeded];
    [self processLocationCommandIfNeeded];
}

- (void)reportLocationIfNeeded {
    BOOL needReport = NO;
    if (!self.lastUpdateDate) {
        needReport = YES;
    } else {
        NSTimeInterval timeElasped = [[NSDate date] timeIntervalSinceDate:self.lastUpdateDate];
        NSTimeInterval minimumTimeInterval = [SSCommonLogic minimumLocationUploadTimeInterval];
        if (timeElasped < minimumTimeInterval) {
            NSTimeInterval delay = minimumTimeInterval - timeElasped;
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reportLocation) object:nil];
            [self performSelector:@selector(reportLocation) withObject:nil afterDelay:delay];
        } else {
            needReport = YES;
        }

    }
    if (!needReport) {
        return;
    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reportLocation) object:nil];
    [self reportLocation];
}

- (void)_reverseLocation:(CLLocation *)location completionHandler:(void(^)(NSArray *placemarks))completionHandler {
    NSDictionary *geocoders = [NSDictionary dictionaryWithDictionary:self.geocoders];
    NSMutableArray *tempPlacemarks = [NSMutableArray arrayWithCapacity:self.geocoders.count];
    __block NSInteger callbackCount = 0;
    TTGeocodeHandler handler = ^(id<TTGeocodeProtocol> geocoder, TTPlacemarkItem *item, NSError *error) {
        callbackCount ++;
        if (item) {
            [tempPlacemarks addObject:item];
            if (item.coordinate.longitude * item.coordinate.latitude == 0) {
                item.coordinate = location.coordinate;
            }
            item.timestamp = [location.timestamp timeIntervalSince1970];
            NSString *fieldName = nil;
            if ([geocoder respondsToSelector:@selector(uploadFieldName)]) {
                fieldName = [geocoder uploadFieldName];
            }
            if (isEmptyString(fieldName)) {
                fieldName = @"lbs_known";
            }
            item.fieldName = fieldName;
        }
        if (callbackCount == geocoders.count) {
            [self.latestPlacemarks removeAllObjects];
            NSArray *placemarks = [tempPlacemarks copy];
            if (!SSIsEmptyArray(placemarks)) {
                [self.latestPlacemarks addObjectsFromArray:placemarks];
            }
            if (completionHandler) {
                completionHandler(placemarks);
            }
        }
    };
    [geocoders enumerateKeysAndObjectsUsingBlock:^(id key, id<TTGeocodeProtocol> obj, BOOL *stop) {
        if([obj isGeocodeSupported]) {
            [obj reverseGeocodeLocation:location timeoutInterval:[SSCommonLogic locateTimeoutInterval] completionHandler:handler];
        } else {
            NSError *error = [NSError errorWithDomain:@"com.ss.iphone.article" code:1001 userInfo:@{@"description":@"TT Denied Geocoder"}];
            handler(obj, nil, error);
        }
    }];
}

- (void)reportLocation {
    __weak TTLocationManager *weakSelf = self;
    void (^completionHandler)(NSArray *placemarks) = ^(NSArray *placemarks) {
#ifdef kTestLocation
        for (TTPlacemarkItem *item in placemarks) {
            NSLog(@"TTPlacemarkItem %@ %@",item.province,item.city);
        }
#endif
        weakSelf.lastUpdateDate = [NSDate date];
        [weakSelf _savePlacemarksToCache:placemarks];
        [weakSelf _uploadUserLocationWithCompletionHandler:^(id resultObject, NSError *error) {
            [weakSelf performSelector:@selector(reportLocation) withObject:nil afterDelay:[SSCommonLogic minimumLocationUploadTimeInterval]];
        }];
    };
    CLLocationCoordinate2D coordinate = [SSLocationPickerController cachedFakeLocationCoordinate];
#if INHOUSE
    if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemFakeLocation] && coordinate.longitude * coordinate.latitude != 0) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self _reverseLocation:location completionHandler:completionHandler];
    }
    else {
        [self regeocodeWithCompletionHandler:completionHandler];
    }
#else
    [self regeocodeWithCompletionHandler:completionHandler];
#endif
}

- (NSMutableDictionary *)_feedbackParameters
{
    NSMutableDictionary *feedbacks = [NSMutableDictionary dictionary];
    if (_feedback) {
        if (_feedback.op_time) {
            [feedbacks setValue:@((NSUInteger)[_feedback.op_time timeIntervalSince1970]) forKey:TTLocationOperationTime];
        }
        else
        {
            [feedbacks setValue:@(0) forKey:TTLocationOperationTime];
        }
        [feedbacks setValue:@(_feedback.op_type) forKey:TTLocationOperationResult];
        if (_feedback.last_time) {
            [feedbacks setValue:@((NSUInteger)[_feedback.last_time timeIntervalSince1970]) forKey:TTLocationLastRequestTime];
        }
        else
        {
            [feedbacks setValue:@(0) forKey:TTLocationLastRequestTime];
        }

        [feedbacks setValue:@(_feedback.cmd) forKey:TTLocationOperationCMD];
        [feedbacks setValue:_feedback.loc_id forKey:TTLocationID];
        if (_feedback.op_time)
        {
            [feedbacks setValue:@((NSUInteger)[[NSDate date] timeIntervalSinceDate:_feedback.op_time]) forKey:TTLocationLastInterval];
        }
        else
        {
            [feedbacks setValue:@(0) forKey:TTLocationLastInterval];
        }
        
        _feedback.last_time = [NSDate date];
    }
#ifdef kTestLocation
    NSLog(@"feedbacks ===\n %@",feedbacks);
#endif
    return feedbacks;
}

- (void)_uploadUserLocationWithCompletionHandler:(void(^)(id resultObject, NSError *error))completionHandler {
    NSMutableDictionary *parameters = [[TTNetworkUtilities commonURLParameters] mutableCopy];
    NSMutableDictionary *locationParameters = [NSMutableDictionary dictionaryWithCapacity:5];
    [self.latestPlacemarks enumerateObjectsUsingBlock:^(TTPlacemarkItem *obj, NSUInteger idx, BOOL *stop) {
        if (!isEmptyString(obj.fieldName)) {
            [locationParameters setValue:[obj toFormDictionary] forKey:obj.fieldName];
        }
    }];
    NSMutableDictionary *feedbacks = [self _feedbackParameters];
#ifdef kTestLocation
    NSLog(@"locationParameters \n city %@ %@",[locationParameters valueForKeyPath:@"amap_location.province"],[locationParameters valueForKeyPath:@"amap_location.address"]);
#endif
    locationParameters[@"location_feedback"] = feedbacks;
    locationParameters[@"location_setting"] = [[self class] isLocationServiceEnabled]?@(1):@(0);
    locationParameters[@"location_mode"] = [[self class] isLocationServiceEnabled]?@(1):@(0);
    locationParameters[@"submit_time"] = @([[NSDate date] timeIntervalSince1970]);

    NSString *dwinfo = [locationParameters tt_base64StringWithFingerprintType:TTFingerprintTypeXOR];
    if (!isEmptyString(dwinfo)) {
         parameters[@"dwinfo"] = dwinfo;
    }
    
    NSString * url = [[NSURL tt_URLWithString:[CommonURLSetting uploadLocationURLString] parameters:@{@"timestamp": @([[NSDate date] timeIntervalSince1970])}] absoluteString];

    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameters method:@"POST" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
        if (!error) {
            [self _processLocationUploadResponse:jsonObj];
        } else {
            LOGE(@"update location error: %@", error);
        }
        if (completionHandler) {
            completionHandler(jsonObj, error);
        }
    }];
}

- (void)_processLocationUploadResponse:(id)resultObject {
    if ([resultObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = [resultObject tt_dictionaryValueForKey:@"data"];
#ifdef kTestLocation
        NSLog(@"jsonObj %@  curr_city %@ user_city %@",data ,[data objectForKey:@"curr_city"] ,[data objectForKey:@"user_city"]);
#endif
        
        self.commandItem = [[TTLocationCommandItem alloc] initWithDictionary:data];
        self.commandItem.date = [NSDate date];
        [self processLocationCommandIfNeededFromNetWork];
    }
}

- (void)setLastUpdateDate:(NSDate *)lastUpdateDate {
    _lastUpdateDate = lastUpdateDate;
    [[NSUserDefaults standardUserDefaults] setValue:lastUpdateDate forKey:TTLocationLastUpdateTimeDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)_loadPlacemarksFromCache {
    NSArray *cachedArray = [[NSUserDefaults standardUserDefaults] valueForKey:TTPlacemarkCacheKey];
    NSMutableArray *placemarks = [NSMutableArray arrayWithCapacity:2];
    if (!SSIsEmptyArray(cachedArray)) {
        [cachedArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [placemarks addObject:[[TTPlacemarkItem alloc] initWithDictionary:obj]];
            }
        }];
        return placemarks;
    }
    return nil;
}

- (void)_savePlacemarksToCache:(NSArray *)placemarks {
    if (SSIsEmptyArray(placemarks)) {
        return;
    }
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:2];
    [self.latestPlacemarks enumerateObjectsUsingBlock:^(TTPlacemarkItem *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TTPlacemarkItem class]]) {
            id dict = [obj toDictionary];
            if (dict) {
                [result addObject:dict];
            }
        }
    }];
    [[NSUserDefaults standardUserDefaults] setValue:result forKey:TTPlacemarkCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation TTLocationManager (TTConvinceAccess)

- (NSArray *)placemarks {
    return [self.latestPlacemarks copy];
}


//- (void)regeocodeWithCompletionHandler:(void(^)(NSArray *placemarks))completionHandler {
//    [[TTLocator sharedLocator] locateWithTimeoutInterval:[SSCommonLogic locateTimeoutInterval] completionHandler:^(CLLocation *location, NSError *error) {
//        if (completionHandler) {
//            if (error) {
//                completionHandler(nil);
//            } else {
//                [self _reverseLocation:location completionHandler:^(NSArray *placemarks) {
//                    completionHandler(placemarks);
//                }];
//            }
//        }
//    }];
//}

//有位置服务的请求，通过TTAuthorizeLocationObj判断是否可以
- (void)regeocodeWithCompletionHandler:(void (^)(NSArray *))completionHandler{
    [[TTAuthorizeManager sharedManager].locationObj filterAuthorizeStrategyWithCompletionHandler:completionHandler authCompleteBlock:^(TTAuthorizeLocationArrayParamBlock arrayParamBlock) {
       [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:arrayParamBlock];
    } sysAuthFlag:0];//显示系统弹窗前显示自有弹窗的逻辑下掉，0代表直接显示系统弹窗，1代表先自有弹窗，再系统弹窗
}

//授权完成后调用
- (void)regeocodeWithCompletionHandlerAfterAuthorization:(void (^)(NSArray *))completionHandler{
    [[TTLocator sharedLocator] locateWithTimeoutInterval:[SSCommonLogic locateTimeoutInterval] completionHandler:^(CLLocation *location, NSError *error) {
        if (completionHandler) {
            if (error) {
                completionHandler(nil);
            } else {
                [self _reverseLocation:location completionHandler:^(NSArray *placemarks) {
                    completionHandler(placemarks);
                }];
            }
        }
    }];
}

- (NSString *)province {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:TTLocationProvinceCacheKey]) {
        return [[NSUserDefaults standardUserDefaults] valueForKey:TTLocationProvinceCacheKey];
    } else {
        __block NSString *province = self.placemarkItem.province;
        if (isEmptyString(province)) {
            [self.placemarks enumerateObjectsUsingBlock:^(TTPlacemarkItem *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[TTPlacemarkItem class]] && !isEmptyString(obj.province)) {
                    province = obj.province;
                    *stop = YES;
                }
            }];
        }
        return province;
    }
}

- (NSString *)city {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:TTLocationCityCacheKey]) {
        return [[NSUserDefaults standardUserDefaults] valueForKey:TTLocationCityCacheKey];
    } else {
        __block NSString *city = self.placemarkItem.city;
        if (isEmptyString(city)) {
            [self.placemarks enumerateObjectsUsingBlock:^(TTPlacemarkItem *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[TTPlacemarkItem class]] && !isEmptyString(obj.city)) {
                    city = obj.city;
                    *stop = YES;
                }
            }];
        }
        return city;
    }
}

- (TTPlacemarkItem *)placemarkItem {
    return [self _placemarkItemWithFieldName:@"sys_location"];
}

- (TTPlacemarkItem *)baiduPlacemarkItem {
    return [self _placemarkItemWithFieldName:@"baidu_location"];
}

- (TTPlacemarkItem *)amapPlacemarkItem {
    return [self _placemarkItemWithFieldName:@"amap_location"];
}


- (TTPlacemarkItem *)getPlacemarkItem {

    TTPlacemarkItem *placemarkItem = nil;
    if ([self amapPlacemarkItem]) {

        CLLocationCoordinate2D coordinate2D = [TTLocationTransform transformToGCJ02LocationWithWGS84Location:[[self amapPlacemarkItem] coordinate]];
        placemarkItem = [[TTPlacemarkItem alloc] init];
        placemarkItem.coordinate = coordinate2D;
        placemarkItem.timestamp = [[self amapPlacemarkItem] timestamp];
        placemarkItem.address = [[self amapPlacemarkItem] address];
        placemarkItem.province = [[self amapPlacemarkItem] province];
        placemarkItem.city = [[self amapPlacemarkItem] city];
        placemarkItem.district = [[self amapPlacemarkItem] district];

    } else if ([self baiduPlacemarkItem]) {

        CLLocationCoordinate2D coordinate2D = [TTLocationTransform transformB09ToGCJ02WithLocation:[[self baiduPlacemarkItem] coordinate]];
        placemarkItem = [[TTPlacemarkItem alloc] init];
        placemarkItem.coordinate = coordinate2D;
        placemarkItem.timestamp = [[self baiduPlacemarkItem] timestamp];
        placemarkItem.address = [[self baiduPlacemarkItem] address];
        placemarkItem.province = [[self baiduPlacemarkItem] province];
        placemarkItem.city = [[self baiduPlacemarkItem] city];
        placemarkItem.district = [[self baiduPlacemarkItem] district];

    } else if ([self placemarkItem]) {
        CLLocationCoordinate2D coordinate2D = [TTLocationTransform transformToGCJ02LocationWithWGS84Location:[[self placemarkItem] coordinate]];
        placemarkItem = [[TTPlacemarkItem alloc] init];
        placemarkItem.coordinate = coordinate2D;
        placemarkItem.timestamp = [[self placemarkItem] timestamp];
        placemarkItem.address = [[self placemarkItem] address];
        placemarkItem.province = [[self placemarkItem] province];
        placemarkItem.city = [[self placemarkItem] city];
        placemarkItem.district = [[self placemarkItem] district];
    }

    if (placemarkItem == nil) {
        return nil;
    }

    if (isEmptyString(placemarkItem.city) && isEmptyString(placemarkItem.province)) {
        return nil;
    }

    return placemarkItem;
}

- (TTPlacemarkItem *)_placemarkItemWithFieldName:(NSString *)fieldName {
    if (SSIsEmptyArray(self.placemarks) || isEmptyString(fieldName)) {
        return nil;
    }
    __block TTPlacemarkItem *item = nil;
    [self.placemarks enumerateObjectsUsingBlock:^(TTPlacemarkItem *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TTPlacemarkItem class]]) {
            if ([obj.fieldName isEqualToString:fieldName]) {
                item = obj;
                *stop = YES;
            }
        }
    }];
    return item;
}

@end

@implementation TTLocationManager (TTCityUpload)

- (void)uploadUserCityWithName:(NSString *)name completionHandler:(void(^)(NSError *))completionHandler {
    NSMutableDictionary *parameters = [[TTNetworkUtilities commonURLParameters] mutableCopy];
    NSMutableDictionary *cityParameters = [NSMutableDictionary dictionaryWithCapacity:2];
    if (!isEmptyString(name)) {
        cityParameters[@"city_name"] = name;
    }
    cityParameters[@"submit_time"] = @([[NSDate date] timeIntervalSince1970]);
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:cityParameters options:NSJSONWritingPrettyPrinted error:&error];
    if (!error && JSONData.length > 0) {
        NSString *csinfo = [[JSONData tt_dataWithFingerprintType:(TTFingerprintTypeXOR)] ss_base64EncodedString];
        if (!isEmptyString(csinfo)) {
            parameters[@"csinfo"] = csinfo;
        }
    }
    
    NSString * url = [[NSURL tt_URLWithString:[CommonURLSetting uploadUserCityURLString] parameters:@{@"timestamp": @([[NSDate date] timeIntervalSince1970])}] absoluteString];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameters method:@"POST" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

@end

@implementation TTLocationManager (TTStatus)

+ (BOOL)isLocationServiceEnabled {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined ||
        status == kCLAuthorizationStatusRestricted ||
        status == kCLAuthorizationStatusDenied) {
        return NO;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        if (status == kCLAuthorizationStatusAuthorizedAlways ||
            status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            return YES;
        }
    } else {
        if (status == kCLAuthorizationStatusAuthorizedAlways) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)currentLBSStatus {
    NSString *LBSStatus = @"unknown";
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            LBSStatus = @"not_determine";
            break;
        case kCLAuthorizationStatusDenied:
            LBSStatus = @"deny";
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            LBSStatus = @"authroize";
            break;
        case kCLAuthorizationStatusRestricted:
            LBSStatus = @"restrict";
            break;
        default:
            break;
    }
    if([TTDeviceHelper OSVersionNumber] >= 8.0) {
        if(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            LBSStatus = @"authroize";
        }
    }
    return LBSStatus;
}

+ (CLLocationAccuracy)desiredAccuracy {
    //采用best, 3km的精度可能只用基站定位, best时会综合多种定位方式, 同时delegate的调用是逼近式的, 会通过多次回调来逼近best精度, 不用担心定位速度.
    return kCLLocationAccuracyBest;
}

+ (BOOL)isValidLocation:(CLLocation *)location {
    if (!location) {
        return NO;
    }
    //检测时间是为了屏蔽缓存位置点, 系统为了快速给出点, 往往头两个点是系统缓存点, 可能存在问题, 比如从A地移动到B地, 初始的两个点很大可能依旧在A地;
    NSTimeInterval locationDuration = fabs([location.timestamp timeIntervalSinceNow]);
    return (locationDuration < 10.0 && location.horizontalAccuracy < 3000.0);
}

@end

@implementation TTLocationManager (TTCommandProcess)

- (void)processLocationCommandIfNeededFromNetWork
{
    [self processLocationCommandIfNeededFromNetWork:YES];
}

- (void)processLocationCommandIfNeededFromNetWork:(BOOL)fromNetwork
{
    TTLocationCommandItem *commandItem = self.commandItem;
    if (fromNetwork) { //在非网络的情况下不能初始化,会导致数据错误. 有网络数据请求回来,是一个新的命令,需要初始化.
        _feedback.isOperationed = NO;
#ifdef kTestLocation
        NSLog(@"初始化 isOperationed");
#endif
    }
    else
    {
        commandItem = self.preCommandItem;
    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(processLocationCommand:) object:nil];
    
    [self performSelector:@selector(processLocationCommand:) withObject:commandItem afterDelay:0.1];
}

- (void)processLocationCommandIfNeeded
{
    [self processLocationCommandIfNeededFromNetWork:NO];
}

//last_time:(NSDate *)last_time 单独存

- (void)saveLastOp_timeWithCommandItem:(TTLocationCommandItem *)commandItem showAlertSuccess:(BOOL)success
{
    if (commandItem.commandType != TTLocationCommandTypeNone) {
        if (success)
        {
            [self saveLastOp_time:[NSDate date] op_type:TTLocationCommandResultSuccess commandItem:commandItem];
            self.commandItem = nil;
            self.preCommandItem = nil;
                
        }
        else
        {
            [self saveLastOp_time:[NSDate date] op_type:TTLocationCommandResultFailed commandItem:commandItem];
        }
    }
}

- (void)saveLastOp_time:(NSDate *)op_time
                op_type:(TTLocationCommandResult )result
            commandItem:(TTLocationCommandItem *)commandItem
{
    _feedback.cmd = commandItem.commandType;
    _feedback.op_type = result;
    _feedback.op_time = op_time;
    _feedback.loc_id = commandItem.identifier;
    if (result == TTLocationCommandResultSuccess) { //存储相应的alert显示的时间,2个小时之内不在显示相应的alert
        if (commandItem.commandType == TTLocationCommandTypeChangeCityWithAlertConfirm)
        {
            _feedback.changeLocationAlertLastShowTime = [NSDate date];
        }
        else if (commandItem.commandType == TTLocationCommandTypePermissionDenied)
        {
            _feedback.delayAlertLastShowTime = [NSDate date];
        }
    }
    [_feedback save];
#ifdef kTestLocation
    NSLog(@"save ========\n optime %@ \n cmd %d \n locid %@ \n optype %d",op_time,_feedback.cmd,_feedback.loc_id,result);
#endif
}

- (void)changeCityAutomatically
{
    TTArticleCategoryManager *manager = [TTArticleCategoryManager sharedManager];
    manager.localCategory.name = self.commandItem.currentCity;
    [manager save];
    [[NSNotificationCenter defaultCenter] postNotificationName:TTLocationManagerCityDidChangedNotification object:self];
}

- (void)permissionDenied
{
//    self.alertController = [[TTAuthorizeManager sharedManager].locationObj showAlertWhenLocationChanged:NULL authCompleteBlock:^(TTAuthorizeLocationArrayParamBlock arrayParamBlock) {
//        //连续弹窗
//        [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:arrayParamBlock];
//    } sysAuthFlag:0];
}

- (void)changeCityWithAlertConfirm:(TTLocationCommandItem *)commandItem
{
    NSString *message = commandItem.alertTitle;
    if (isEmptyString(message)) {
        message = [NSString stringWithFormat:@"自动切换至当前城市「%@」，智能推荐当地资讯", commandItem.currentCity];
    }
    TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"切换城市" message:message preferredType:TTThemedAlertControllerTypeAlert];
    [alertController addActionWithTitle:@"切换" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        NSString *cityName = commandItem.currentCity;
        [[TTLocationManager sharedManager] uploadUserCityWithName:cityName completionHandler:^(NSError *error) {
            if (!error) {
                TTArticleCategoryManager *manager = [TTArticleCategoryManager sharedManager];
                manager.localCategory.name = cityName;
                [manager save];
                [NewsUserSettingManager setNeedLoadDataFromStart:YES];
                [TTArticleCategoryManager setUserSelectedLocalCity];
                [ExploreExtenstionDataHelper saveSharedUserSelectCity:cityName];
                [[NSNotificationCenter defaultCenter] postNotificationName:TTLocationManagerCityDidChangedNotification object:self];
            }
        }];
        wrapperTrackEvent(@"pop", @"locate_change_category_open");
    }];
    [alertController addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        wrapperTrackEvent(@"pop", @"locate_change_category_cancel");
        if (!isEmptyString(commandItem.identifier)) {
            NSMutableDictionary *parameters = [[TTNetworkUtilities commonURLParameters] mutableCopy];
            [parameters setValue:commandItem.identifier forKey:TTLocationID];
            
            NSString * url = [[NSURL tt_URLWithString:[CommonURLSetting locationCancelURLString] parameters:@{@"timestamp": @([[NSDate date] timeIntervalSince1970])}] absoluteString];
            [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameters method:@"POST" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
                // do nothing
            }];
        }
    }];
    [alertController showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
    wrapperTrackEvent(@"pop", @"locate_change_category_show");
    self.alertController = alertController;
}

- (BOOL)needAlertWithCommandType:(TTLocationCommandType)type
{
    BOOL needAlert = NO;

    NSDate *lastDate = nil;
    if (type == TTLocationCommandTypeChangeCityWithAlertConfirm) {
        lastDate = _feedback.changeLocationAlertLastShowTime;
    }
    else if (type == TTLocationCommandTypePermissionDenied) {
        lastDate = _feedback.delayAlertLastShowTime;
    }

    if (![lastDate isKindOfClass:[NSDate class]]) {
        needAlert = YES;
    } else {
        NSTimeInterval timeElasped = [[NSDate date] timeIntervalSinceDate:lastDate];
        needAlert = (timeElasped >= [SSCommonLogic minimumLocationAlertTimeInterval]);
        
#ifdef kTestLocation
        NSLog(@"timeElasped %f  minimum %f needAlert %d",timeElasped ,[SSCommonLogic minimumLocationAlertTimeInterval],needAlert);
#endif
    }
    return needAlert;
}

- (NSNumber *)getLocationResult
{
    return @(self.placemarkItem.coordinate.longitude != 0);
}

- (void)processLocationCommand:(TTLocationCommandItem *)commandItem {
    NSDate *date = commandItem.date;
    if (commandItem && date) {
        /// 每个弹框5分钟超时，客户端写死
        if ([[NSDate date] timeIntervalSinceDate:date] < 300) {
            if (commandItem.currentCity)
            {
                [[NSUserDefaults standardUserDefaults] setValue:commandItem.currentCity forKey:TTLocationCityCacheKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                switch (commandItem.commandType) {
                    case TTLocationCommandTypeChangeCityAutomatically:
                        [self changeCityAutomatically];
                        _feedback.isOperationed = YES;
                        break;
                    case TTLocationCommandTypePermissionDenied:
                        if (!self.alertController)
                        {
                            if (![[self class] isLocationServiceEnabled]) {
                                if ([self needAlertWithCommandType:commandItem.commandType]) {
                                    [self permissionDenied];
                                    _feedback.isOperationed = YES;
                                }
                            }
                        }
                        break;
                    case TTLocationCommandTypeChangeCityWithAlertConfirm:
                        if ([self needAlertWithCommandType:commandItem.commandType] && !self.alertController) {
                            if (![[TTArticleCategoryManager sharedManager].localCategory.name isEqualToString:commandItem.currentCity]) {// 两个城市不一样才执行
                                if ([self isInMainListView]) {//在主页面才显示,在详情页面就不显示了
                                    [self changeCityWithAlertConfirm:commandItem];
                                    _feedback.isOperationed = YES;
                                }
                            }
                            
                        }
                        break;
                    default:
                        break;
                }
            }
        }
        else
        {
            self.preCommandItem = nil;
        }
    }
    
    if (self.commandItem.commandType != TTLocationCommandTypeNone
        && !_feedback.isOperationed) {
        self.preCommandItem = self.commandItem;
    }
    [self saveLastOp_timeWithCommandItem:commandItem showAlertSuccess:_feedback.isOperationed];
}

@end


@implementation TTLocationManager (TTMainListView)

- (BOOL)isInMainListView {
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    if (![mainWindow.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        return NO;
    }
    
    TTArticleTabBarController *tabBarController = (TTArticleTabBarController *)mainWindow.rootViewController;
    if ([[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey]) {
        UINavigationController *nav = tabBarController.selectedViewController;
        if ([nav isKindOfClass:[UINavigationController class]]) {
            if ([nav.topViewController isKindOfClass:[ArticleTabBarStyleNewsListViewController class]]) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
