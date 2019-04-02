//
//  FHHouseFindHelpViewController.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindHelpBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseFindRecommendDataModel;
@interface FHHouseFindHelpViewController : FHHouseFindHelpBaseViewController

- (FHHouseFindRecommendDataModel *)getRecommendModel;
- (void)refreshRecommendModel:(FHHouseFindRecommendDataModel *)recommendModel;

@end

NS_ASSUME_NONNULL_END
