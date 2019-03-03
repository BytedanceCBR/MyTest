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

- (void)setMessageTabBadgeNumber:(NSInteger)number;
//设置频道红点
- (void)updateNotifyBadgeNumber:(NSString *)categoryId isShow:(BOOL)isShow;

//首页推荐红点请求时间间隔
- (NSInteger)getCategoryBadgeTimeInterval;

//获取频道红点请求
- (NSString *)getRefreshTipURLString;

//获取当前频道
- (NSString *)getCurrentSelectCategoryId;

//获取当前默认频道
- (NSString *)getFeedStartCategoryName;

@end


#endif /* FHHouseEnvContextBridge_h */
