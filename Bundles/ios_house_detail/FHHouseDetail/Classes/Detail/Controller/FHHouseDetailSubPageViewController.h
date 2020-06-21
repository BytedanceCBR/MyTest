//
//  FHHouseDetailSubPageViewController.h
//  Pods
//
//  Created by 张静 on 2019/2/22.
//

#import "FHBaseViewController.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailSubPageViewController : FHBaseViewController

@property (nonatomic , strong) FHHouseDetailBaseViewModel *viewModel;

- (void)setNavBarTitle:(NSString *)navTitle;
//获取导航bar
- (UIView *)getNaviBar;

//获取底部bar
- (UIView *)getBottomBar;

- (NSDictionary *)subPageParams;
- (NSString *)pageTypeString;

- (FHHouseDetailContactViewModel *)getContactViewModel;

@end

NS_ASSUME_NONNULL_END
