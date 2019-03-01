//
//  FHHomeBridgeProtocol.h
//  Article
//
//  Created by 谢飞 on 2018/12/11.
//

#ifndef FHHomeBridgeProtocol_h
#define FHHomeBridgeProtocol_h

@protocol FHHomeBridgeProtocol <NSObject>

- (NSString *)getRefreshTipURLString;

- (NSString *)feedStartCategoryName;

- (NSString *)currentSelectCategoryName;

- (NSString *)baseUrl;

- (void)isShowTabbarScrollToTop:(BOOL)scrollToTop;

- (void)setUpLocationInfo:(NSDictionary *)dict;

- (void)jumpCountryList:(UIViewController *)viewController;

- (void)jumpToTabbarFirst;

- (BOOL)isCurrentTabFirst;

- (BOOL)isNeedSwitchCityCompare;

- (void)updateNotifyBadgeNumber:(NSString *)categoryId isShow:(BOOL)isShow;

//首页推荐红点请求时间间隔
- (NSInteger)getCategoryBadgeTimeInterval;

@end

#endif /* FHHomeBridgeProtocol_h */
