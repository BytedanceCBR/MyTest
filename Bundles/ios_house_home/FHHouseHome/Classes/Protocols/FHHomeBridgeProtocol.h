//
//  FHHomeBridgeProtocol.h
//  Article
//
//  Created by 谢飞 on 2018/12/11.
//

#ifndef FHHomeBridgeProtocol_h
#define FHHomeBridgeProtocol_h

@protocol FHHomeBridgeProtocol <NSObject>

- (NSString *)feedStartCategoryName;

- (NSString *)currentSelectCategoryName;

- (NSString *)baseUrl;

- (void)isShowTabbarScrollToTop:(BOOL)scrollToTop;

- (void)setUpLocationInfo:(NSDictionary *)dict;

- (void)jumpCountryList:(UIViewController *)viewController;

- (void)jumpToTabbarFirst;

- (BOOL)isCurrentTabFirst;

@end

#endif /* FHHomeBridgeProtocol_h */
