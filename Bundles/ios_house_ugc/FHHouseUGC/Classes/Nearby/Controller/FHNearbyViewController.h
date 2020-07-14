//
//  FHNearbyViewController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHBaseViewController.h"
#import "FHCommunityFeedListController.h"
#import "FHNearbyHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNearbyViewController : FHBaseViewController

@property(nonatomic ,strong) FHCommunityFeedListController *feedVC;
@property(nonatomic, strong) FHNearbyHeaderView *headerView;
@property(nonatomic, assign) CGFloat headerViewHeight;
//新的发现页面
@property(nonatomic, assign) BOOL isNewDiscovery;

- (void)viewWillAppear;

- (void)viewWillDisappear;

@end

NS_ASSUME_NONNULL_END
