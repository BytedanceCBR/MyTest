//
//  FHPersonalHomePageFeedListViewController.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHBaseViewController.h"
#import "FHPersonalHomePageManager.h"
#import "FHPersonalHomePageFeedCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageFeedListViewController : FHBaseViewController
@property(nonatomic,weak) FHPersonalHomePageManager *homePageManager;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,copy) NSString *tabName;
@property(nonatomic,assign) NSInteger index;
- (void)firstLoadData;
@end

NS_ASSUME_NONNULL_END
