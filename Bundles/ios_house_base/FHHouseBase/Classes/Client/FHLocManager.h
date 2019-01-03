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

+(instancetype)sharedInstance;

- (void)requestCurrentLocation:(BOOL)showAlert;

- (void)checkUserLocationStatus

- (void)setUpLocManagerLocalInfo;

@end


NS_ASSUME_NONNULL_END
