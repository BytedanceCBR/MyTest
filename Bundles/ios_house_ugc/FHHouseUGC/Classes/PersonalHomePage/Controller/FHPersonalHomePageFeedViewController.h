//
//  FHPersonalHomePageFeedViewController.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHBaseViewController.h"
#import "FHPersonalHomePageTabListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageFeedViewController : FHBaseViewController
- (void)updateWithHeaderViewMdoel:(FHPersonalHomePageTabListModel *)model;
@end

NS_ASSUME_NONNULL_END
