//
//  FHHouseDetailViewController.h
//  FHHouseDetail
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailViewController : FHBaseViewController

//设置状态栏
- (void)refreshContentOffset:(CGPoint)contentOffset;

//获取导航bar
- (UIView *)getNaviBar;

//获取底部bar
- (UIView *)getBottomBar;

//设置navibar title
- (void)setNavBarTitle:(NSString *)navTitle;

@end

NS_ASSUME_NONNULL_END
