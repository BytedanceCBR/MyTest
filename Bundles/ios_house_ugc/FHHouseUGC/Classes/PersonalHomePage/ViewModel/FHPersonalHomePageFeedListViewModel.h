//
//  FHPersonalHomePageFeedListViewModel.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import <Foundation/Foundation.h>
#import "FHPersonalHomePageFeedListViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageFeedListViewModel : NSObject
- (instancetype)initWithController:(FHPersonalHomePageFeedListViewController *)viewController tableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
