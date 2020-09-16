//
//  FHCommunityFeedListCustomViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/21.
//

#import "FHCommunityFeedListBaseViewModel.h"
#import "FHCommunityFeedListController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityFeedListCustomViewModel : FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController;

@end

NS_ASSUME_NONNULL_END
