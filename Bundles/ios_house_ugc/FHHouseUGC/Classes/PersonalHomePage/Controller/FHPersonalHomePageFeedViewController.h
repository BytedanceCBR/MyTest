//
//  FHPersonalHomePageFeedViewController.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHBaseViewController.h"
#import "FHPersonalHomePageTabListModel.h"
#import "FHPersonalHomePageManager.h"
#import "HMSegmentedControl.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageFeedViewController : FHBaseViewController
@property(nonatomic,weak) FHPersonalHomePageManager *homePageManager;
@property(nonatomic,strong) HMSegmentedControl *headerView;
- (void)updateWithHeaderViewMdoel:(FHPersonalHomePageTabListModel *)model;
@end

NS_ASSUME_NONNULL_END
