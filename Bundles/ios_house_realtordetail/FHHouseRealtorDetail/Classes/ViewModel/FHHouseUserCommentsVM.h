//
//  FHHouseUserCommentsVM.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import <Foundation/Foundation.h>
#import "FHHouseUserCommentsVC.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseUserCommentsVM : NSObject
- (instancetype)initWithController:(FHHouseUserCommentsVC *)viewController tableView:(UITableView *)tableView tracerDic:(NSDictionary *)tracerDic realtorInfo:(NSDictionary *)realtorInfo;
@end

NS_ASSUME_NONNULL_END
