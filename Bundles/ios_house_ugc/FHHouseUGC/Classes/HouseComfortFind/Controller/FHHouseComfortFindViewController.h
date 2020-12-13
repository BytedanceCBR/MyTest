//
//  FHHouseComfortFindViewController.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/22.
//

#import "FHBaseViewController.h"
#import "FHCommunityFeedListController.h"
#import "FHHouseComfortFindHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseComfortFindViewController : FHBaseViewController

@property(nonatomic ,strong) FHCommunityFeedListController *feedVC;

- (void)viewWillAppear;
- (void)viewWillDisappear;

@end

NS_ASSUME_NONNULL_END
