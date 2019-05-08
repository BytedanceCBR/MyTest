//
//  FHMessageListHouseViewModel.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import "FHMessageListBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageListHouseViewModel : FHMessageListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageListViewController *)viewController listId:(NSInteger)listId;

@end

NS_ASSUME_NONNULL_END
