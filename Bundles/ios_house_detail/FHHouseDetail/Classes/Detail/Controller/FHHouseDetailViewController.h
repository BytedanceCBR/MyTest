//
//  FHHouseDetailViewController.h
//  FHHouseDetail
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailViewController : FHBaseViewController

- (void)refreshContentOffset:(CGPoint)contentOffset;

- (UIView *)getNaviBar;

- (UIView *)getBottomBar;

@end

NS_ASSUME_NONNULL_END
