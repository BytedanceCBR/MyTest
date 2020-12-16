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
@property(nonatomic,weak) FHPersonalHomePageManager *homePageManager;
@property(nonatomic,strong) FHErrorView *emptyView;
- (instancetype)initWithController:(FHPersonalHomePageFeedListViewController *)viewController tableView:(UITableView *)tableView;
- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;
@end

NS_ASSUME_NONNULL_END
