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

- (void)isShowTabbarScrollToTop:(BOOL)scrollToTop;
@end

#endif /* FHHomeBridgeProtocol_h */
