//
//  FHHouseRealtorDetailHouseViewModel.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import <Foundation/Foundation.h>
#import "FHHouseRealtorDetailHouseVC.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailHouseViewModel : NSObject
- (instancetype)initWithController:(FHHouseRealtorDetailHouseVC *)viewController tableView:(UITableView *)tableView realtorInfo:(NSDictionary *)realtorInfo;
@end

NS_ASSUME_NONNULL_END
