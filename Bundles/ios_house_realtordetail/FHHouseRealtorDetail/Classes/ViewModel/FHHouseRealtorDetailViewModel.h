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
#import "FHHouseRealtorDetailRgcTabView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailViewModel : NSObject
- (instancetype)initWithController:(FHHouseRealtorDetailController *)viewController tableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
