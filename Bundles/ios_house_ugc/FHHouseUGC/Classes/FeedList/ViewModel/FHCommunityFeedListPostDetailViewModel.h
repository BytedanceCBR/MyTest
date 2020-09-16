//
//  FHCommunityFeedListPostDetailViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/24.
//

#import "FHCommunityFeedListBaseViewModel.h"
#import "FHCommunityFeedListController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityFeedListPostDetailViewModel : FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController;

//圈子id
@property(nonatomic, copy) NSString *socialGroupId;
//分类的key
@property(nonatomic, copy) NSString *tabName;

@end

NS_ASSUME_NONNULL_END
