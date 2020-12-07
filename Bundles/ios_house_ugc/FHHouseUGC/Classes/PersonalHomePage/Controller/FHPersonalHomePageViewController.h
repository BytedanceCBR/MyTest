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
- (void)updateProfileInfoWithMdoel:(FHPersonalHomePageProfileInfoModel *)profileInfoModel tabListWithMdoel:(FHPersonalHomePageTabListModel *)tabListModel;
@end

NS_ASSUME_NONNULL_END
