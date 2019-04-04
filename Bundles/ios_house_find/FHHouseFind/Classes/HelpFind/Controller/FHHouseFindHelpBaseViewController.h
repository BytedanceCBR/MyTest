//
//  FHHouseFindHelpBaseViewController.h
//  FHHouseFind
//
//  Created by 张静 on 2019/4/2.
//

#import "FHBaseViewController.h"
#import "FHHouseFindRecommendModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHHouseFindHelpBaseViewController : FHBaseViewController

- (FHHouseFindRecommendDataModel *)getRecommendModel;
- (void)refreshRecommendModel:(FHHouseFindRecommendDataModel *)recommendModel;

@end

NS_ASSUME_NONNULL_END
