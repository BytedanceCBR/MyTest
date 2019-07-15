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
#import "TTPlacemarkItem.h"
#import <TTLocationManager/TTLocationManager.h>
#import <TTLocationManager/TTLocationCommand.h>

@interface TTLocationManagerAmapInfo : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic, copy)   NSDictionary       *locationDictInfo;

@end

@interface TTLocationManager (FHHouse)

- (void)setUpAmapInfo:(NSDictionary *)locationDict;

- (NSDictionary *)getAmapInfo;

@end
//
@interface TTLocationManager (TTConvinceAccess)

- (TTPlacemarkItem *)placemarkItem;
- (TTPlacemarkItem *)baiduPlacemarkItem;
- (TTPlacemarkItem *)amapPlacemarkItem;

- (TTPlacemarkItem *)getPlacemarkItem;
//通过TTAuthorizeLocationObj判断位置授权成功后调用
- (void)regeocodeWithCompletionHandlerAfterAuthorization:(void(^)(NSArray *placemarks))completionHandler;
//
@end
//
@interface TTLocationManager (TTCityUpload)

- (void)uploadUserCityWithName:(NSString *)name
             completionHandler:(void(^)(NSError *))completionHandler;

@end
//
@interface TTLocationManager (TTStatus)

+ (BOOL)isLocationServiceEnabled;
+ (NSString *)currentLBSStatus;
+ (CLLocationAccuracy)desiredAccuracy;
+ (BOOL)isValidLocation:(CLLocation *)location;

@end
