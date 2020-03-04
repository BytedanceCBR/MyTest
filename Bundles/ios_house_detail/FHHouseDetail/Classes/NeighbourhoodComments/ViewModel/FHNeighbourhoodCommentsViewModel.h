//
//  FHNeighbourhoodQuestionViewModel.h
//  FHHouseDetail
//
//  Created by 王志舟 on 2020/2/23.
//

#import "FHCommunityFeedListBaseViewModel.h"
#import "FHNeighbourhoodCommentsController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighbourhoodCommentsViewModel : FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHNeighbourhoodCommentsController *)viewController;

@end

NS_ASSUME_NONNULL_END
