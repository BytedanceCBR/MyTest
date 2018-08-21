//
//  TTLocationManager.h
//  Article
//
//  Created by SunJiangting on 15-4-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TTPlacemarkItemProtocol.h"

extern NSString *const TTLocationManagerCityDidChangedNotification;

@class TTPlacemarkItem;
typedef void(^TTLocateHandler) (CLLocation *location, NSError *error);

@protocol TTGeocodeProtocol;
typedef void(^TTGeocodeHandler) (id<TTGeocodeProtocol> geocoder, TTPlacemarkItem *placemarkItem, NSError *error);

@protocol TTGeocodeProtocol <NSObject>

- (void)reverseGeocodeLocation:(CLLocation *)location
               timeoutInterval:(NSTimeInterval)timeoutInterval
             completionHandler:(TTGeocodeHandler)completionHandler;

- (NSString *)uploadFieldName;
- (BOOL)isGeocodeSupported;
+ (BOOL)isGeocodeSupported;
@optional
- (void)cancel;
- (CLLocationCoordinate2D)convertToCustomCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@interface TTPlacemarkItem : NSObject <TTPlacemarkItemProtocol>

@property(nonatomic) CLLocationCoordinate2D coordinate;
@property(nonatomic) NSTimeInterval  timestamp;
@property(nonatomic, copy) NSString  *address;
@property(nonatomic, copy) NSString  *province;
@property(nonatomic, copy) NSString  *city;
@property(nonatomic, copy) NSString  *district;

@end

typedef NS_ENUM(NSInteger, TTLocationCommandType) {
    TTLocationCommandTypeNone,
    TTLocationCommandTypeChangeCityAutomatically,
    TTLocationCommandTypeChangeCityWithAlertConfirm,
    TTLocationCommandTypePermissionDenied,
};

typedef NS_ENUM(NSInteger, TTLocationCommandResult) {
    TTLocationCommandResultFailed = 0,//没有执行
    TTLocationCommandResultSuccess = 1//成功执行
};

@interface TTLocationCommandItem : NSObject
@property(nonatomic) TTLocationCommandType    commandType;
@property(nonatomic, strong) NSDate           *date;
@property(nonatomic, copy) NSString           *identifier;
@property(nonatomic, copy) NSString           *userCity;
@property(nonatomic, copy) NSString           *currentCity;
@property(nonatomic, copy) NSString           *alertTitle;

@end


@interface TTLocationManager : NSObject

+ (instancetype)sharedManager;

- (void)registerGeocoder:(id<TTGeocodeProtocol>)geocoder forKey:(NSString *)key;
- (void)unregisterGeocoderForKey:(NSString *)key;

- (void)reportLocationIfNeeded;

/// 服务器下发命令
@property(nonatomic, strong, readonly) TTLocationCommandItem  *commandItem;
/// locations /* TTLocationItem */
@end

@interface TTLocationManager (TTConvinceAccess)
@property(nonatomic, strong, readonly) NSArray/*TTPlacemarkItem*/ *placemarks;

- (NSString *)province;
- (NSString *)city;
- (TTPlacemarkItem *)placemarkItem;
- (TTPlacemarkItem *)baiduPlacemarkItem;
- (TTPlacemarkItem *)amapPlacemarkItem;

- (TTPlacemarkItem *)getPlacemarkItem;


- (void)regeocodeWithCompletionHandler:(void(^)(NSArray *placemarks))completionHandler;

//通过TTAuthorizeLocationObj判断位置授权成功后调用
- (void)regeocodeWithCompletionHandlerAfterAuthorization:(void(^)(NSArray *placemarks))completionHandler;

@end

@interface TTLocationManager (TTCityUpload)

- (void)uploadUserCityWithName:(NSString *)name
             completionHandler:(void(^)(NSError *))completionHandler;

@end

@interface TTLocationManager (TTStatus)

+ (BOOL)isLocationServiceEnabled;
+ (NSString *)currentLBSStatus;
+ (CLLocationAccuracy)desiredAccuracy;
+ (BOOL)isValidLocation:(CLLocation *)location;

@end

@interface TTLocationManager (TTCommandProcess)

- (void)processLocationCommandIfNeeded;

@end

@interface TTLocationManager (TTMainListView)

/// 很恶心的一块逻辑，收到定位结果后，需要判断是否在频道列表页，如果在频道列表页，则直接处理
- (BOOL)isInMainListView;

@end

