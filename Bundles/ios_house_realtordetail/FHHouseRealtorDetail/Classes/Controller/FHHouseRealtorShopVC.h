//
//  FHHouseRealtorShopVC.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "FHBaseViewController.h"
#import "FHHouseRealtorDetailHeaderView.h"
#import "FHRealtorDetailBottomBar.h"
#import "FHBlackmailRealtorBottomBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorShopVC : FHBaseViewController
@property (strong, nonatomic) FHHouseRealtorDetailHeaderView *headerView;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) FHRealtorDetailBottomBar *bottomBar;
@property (nonatomic, strong) FHBlackmailRealtorBottomBar *blackmailReatorBottomBar;
- (void)showBottomBar:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
