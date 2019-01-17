//
//  FHHouseEnvContextBridge.h
//  Pods
//
//  Created by 谷春晖 on 2018/11/19.
//

#ifndef FHHouseEnvContextBridge_h
#define FHHouseEnvContextBridge_h

@import CoreLocation;

@protocol FHHouseEnvContextBridge <NSObject>

-(NSString *)currentMapSelect;

-(void)setTraceValue:(NSString *)value forKey:(NSString *)key;

-(NSDictionary *)homePageParamsMap;

-(void)recordEvent:(NSString *)key params:(NSDictionary *)params;


-(NSString *)currentCityName;

-(NSString *)currentProvince;

-(BOOL)locationSameAsChooseCity;

-(CLLocationCoordinate2D)currentLocation;

-(NSDictionary *)appConfig;

-(NSDictionary *)appConfigRentOpData;

-(void)showToast:(NSString *)toast duration:(CGFloat)duration inView:(UIView *)view;

@end


#endif /* FHHouseEnvContextBridge_h */
