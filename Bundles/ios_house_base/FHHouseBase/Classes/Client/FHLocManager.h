//
//  FHLocManager.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHLocManager : NSObject

@property (nonatomic, strong) AMapLocationManager * locMgr;
@property (nonatomic, strong) AMapLocationReGeocode * currentReGeocode;
@property (nonatomic, strong) CLLocation * currentLocaton;
@property (nonatomic, assign) BOOL isSameToLocCity;
@property (nonatomic, assign)   BOOL       isLocationSuccess;

+(instancetype)sharedInstance;

- (void)requestCurrentLocation:(BOOL)showAlert;

- (void)requestCurrentLocation:(BOOL)showAlert completion:(void(^)(AMapLocationReGeocode * reGeocode))completion;

- (void)requestConfigByCityId:(NSInteger)cityId completion:(void(^)(BOOL isSuccess))completion;

- (void)checkUserLocationStatus;

- (void)setUpLocManagerLocalInfo;

- (void)showCitySwitchAlert:(NSString *)cityName;

@end


NS_ASSUME_NONNULL_END
