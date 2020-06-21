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
@property(nonatomic , strong, readonly) UIView *containerView;
@property(nonatomic , assign) BOOL iskeyBoardVisible;
@property(nonatomic , assign) BOOL iskeyBoardShowing;
@property(nonatomic , assign) CGFloat originY;

- (void)refreshContentOffset:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
