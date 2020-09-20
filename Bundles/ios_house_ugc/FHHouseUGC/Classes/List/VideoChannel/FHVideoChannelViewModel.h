//
//  FHVideoChannelViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/15.
//

#import "FHCommunityFeedListBaseViewModel.h"
#import "FHVideoChannelController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHVideoChannelViewModel : FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHVideoChannelController *)viewController;

@end

NS_ASSUME_NONNULL_END
