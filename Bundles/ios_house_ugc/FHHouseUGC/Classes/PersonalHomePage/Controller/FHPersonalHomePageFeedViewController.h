//
//  FHPersonalHomePageFeedViewController.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHBaseViewController.h"
#import "FHPersonalHomePageTabListModel.h"
#import "HMSegmentedControl.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageFeedViewController : FHBaseViewController
@property(nonatomic,strong) HMSegmentedControl *headerView;
- (void)updateWithHeaderViewMdoel:(FHPersonalHomePageTabListModel *)model;
@property(nonatomic,assign) BOOL enableScroll;
@end

NS_ASSUME_NONNULL_END
