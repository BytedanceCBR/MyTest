//
//  FHMyJoinViewController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHBaseViewController.h"
#import "FHMyJoinNeighbourhoodView.h"
#import "FHCommunityFeedListController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMyJoinViewController : FHBaseViewController

@property(nonatomic, strong) FHMyJoinNeighbourhoodView *neighbourhoodView;
@property(nonatomic, strong) FHCommunityFeedListController *feedListVC;

@end

NS_ASSUME_NONNULL_END
