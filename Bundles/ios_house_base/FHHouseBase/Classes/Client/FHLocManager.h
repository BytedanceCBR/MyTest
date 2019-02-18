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

extern NSString * const kFHAllConfigLoadSuccessNotice;
extern NSString * const kFHAllConfigLoadErrorNotice;

@class FHConfigModel;

@interface FHLocManager : NSObject

@property (nonatomic, strong) AMapLocationManager * locMgr;
@property (nonatomic, strong) AMapLocationReGeocode * currentReGeocode;
@property (nonatomic, strong) CLLocation * currentLocaton;
@property (nonatomic, assign) BOOL isSameToLocCity;
@property (nonatomic, assign) BOOL isLocationSuccess;
@property (nonatomic, assign) NSInteger retryConfigCount;
@property (nonatomic, assign) BOOL isShowSwitch;
@property (nonatomic, assign) BOOL isShowSplashAdView;

+(instancetype)sharedInstance;

- (void)requestCurrentLocation:(BOOL)showAlert andShowSwitch:(BOOL)switchCity;

- (void)requestCurrentLocation:(BOOL)showAlert completion:(void(^)(AMapLocationReGeocode * reGeocode))completion;

- (void)requestConfigByCityId:(NSInteger)cityId completion:(void(^)(BOOL isSuccess,FHConfigModel * _Nullable model))completion;

- (void)checkUserLocationStatus;

- (void)setUpLocManagerLocalInfo;

- (void)showCitySwitchAlert:(NSString *)cityName;

- (void)showCitySwitchAlert:(NSString *)cityName openUrl:(NSString *)openUrl;

- (void)updateAllConfig:(FHConfigModel * _Nullable) model isNeedDiff:(BOOL)needDiff;

//开始轮询红点
- (void)startCategoryRedDotRefresh;
//停止轮询红点
- (void)stopCategoryRedDotRefresh;

@end


NS_ASSUME_NONNULL_END
