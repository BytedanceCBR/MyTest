//
//  FHBaseMainListViewController.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/8.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
//二手房 租房 大类页

@interface FHBaseMainListViewController : FHBaseViewController

@property(nonatomic , strong , readonly) UITableView *tableView;

-(UIView *)topBannerView; //顶部运营view




@end

NS_ASSUME_NONNULL_END
