//
//  FHNearbyViewController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHBaseViewController.h"
#import "FHCommunityFeedListController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNearbyViewController : FHBaseViewController

@property(nonatomic ,strong) FHCommunityFeedListController *feedVC;

- (void)viewWillAppear;

- (void)viewWillDisappear;

@end

NS_ASSUME_NONNULL_END
