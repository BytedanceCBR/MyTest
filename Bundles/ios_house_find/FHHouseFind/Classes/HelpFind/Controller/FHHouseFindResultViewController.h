//
//  FHHouseFindResultViewController.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseFindRecommendDataModel;
@interface FHHouseFindResultViewController : FHBaseViewController

- (void)refreshContentOffset:(CGPoint)contentOffset;

- (void)setNaviBarTitle:(NSString *)stringTitle;

- (FHHouseFindRecommendDataModel *)getRecommendModel;

@end

NS_ASSUME_NONNULL_END
