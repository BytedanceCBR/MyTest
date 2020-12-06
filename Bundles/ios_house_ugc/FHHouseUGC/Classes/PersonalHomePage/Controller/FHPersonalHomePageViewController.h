//
//  FHPersonalHomePageViewController.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHBaseViewController.h"
#import "FHPersonalHomePageProfileInfoModel.h"
#import "FHPersonalHomePageTabListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageViewController : FHBaseViewController
- (void)updateProfileInfoViewWithMdoel:(FHPersonalHomePageProfileInfoModel *)model;
- (void)updateFeedViewControllerWithMdoel:(FHPersonalHomePageTabListModel *)model;
@end

NS_ASSUME_NONNULL_END
