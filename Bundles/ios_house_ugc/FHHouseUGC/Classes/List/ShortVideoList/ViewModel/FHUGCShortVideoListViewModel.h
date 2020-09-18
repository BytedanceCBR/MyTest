//
//  FHUGCShortVideoListViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/18.
//

#import "FHCommunityFeedListBaseViewModel.h"
#import "FHCommunityFeedListController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCShortVideoListViewModel : FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController;

@end

NS_ASSUME_NONNULL_END
