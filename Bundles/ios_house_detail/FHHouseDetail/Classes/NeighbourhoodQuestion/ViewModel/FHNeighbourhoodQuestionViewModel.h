//
//  FHNeighbourhoodQuestionViewModel.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/2/7.
//

#import "FHCommunityFeedListBaseViewModel.h"
#import "FHNeighbourhoodQuestionController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighbourhoodQuestionViewModel : FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHNeighbourhoodQuestionController *)viewController;

@end

NS_ASSUME_NONNULL_END
