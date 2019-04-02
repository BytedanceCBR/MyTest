//
//  FHHouseFindResultViewController.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindHelpBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindResultViewController : FHHouseFindHelpBaseViewController

- (void)refreshContentOffset:(CGPoint)contentOffset;

- (void)setNaviBarTitle:(NSString *)stringTitle;

@end

NS_ASSUME_NONNULL_END
