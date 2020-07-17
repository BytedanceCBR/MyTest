//
//  FHHouseRealtorDetailViewModel.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/12.
//

#import <Foundation/Foundation.h>
#import "FHHouseRealtorDetailController.h"
#import "FHHouseRealtorDetailRGCCell.h"
#import "FHHouseRealtorDetailInfoModel.h"
#import "FHHouseRealtorDetailBaseCell.h"
#import "FHHouseRealtorDetailBaseCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailViewModel : NSObject
- (instancetype)initWithController:(FHHouseRealtorDetailController *)viewController tableView:(UITableView *)tableView realtorInfo:(NSDictionary *)realtorInfo;
@end

NS_ASSUME_NONNULL_END
