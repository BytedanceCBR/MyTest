//
//  FHHouseRealtorShopVM.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import <Foundation/Foundation.h>
#import "FHHouseRealtorShopVC.h"
#import "FHRealtorDetailBottomBar.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorShopVM : NSObject
- (instancetype)initWithController:(FHHouseRealtorShopVC *)viewController tableView:(UITableView *)tableView realtorDic:(NSDictionary *)realtorDic bottomBar:(FHRealtorDetailBottomBar *)bottomBar;
@end

NS_ASSUME_NONNULL_END
