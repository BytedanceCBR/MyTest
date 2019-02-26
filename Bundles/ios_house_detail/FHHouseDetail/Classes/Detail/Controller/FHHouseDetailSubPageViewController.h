//
//  FHHouseDetailSubPageViewController.h
//  Pods
//
//  Created by 张静 on 2019/2/22.
//

#import "FHBaseViewController.h"
#import "FHHouseDetailContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailSubPageViewController : FHBaseViewController

- (void)setNavBarTitle:(NSString *)navTitle;
//获取导航bar
- (UIView *)getNaviBar;

//获取底部bar
- (UIView *)getBottomBar;

- (NSDictionary *)subPageParams;
- (NSString *)pageTypeString;

@end

NS_ASSUME_NONNULL_END
