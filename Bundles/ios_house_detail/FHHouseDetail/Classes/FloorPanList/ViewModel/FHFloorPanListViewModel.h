//
//  FHFloorPanListViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailNewModel.h"
#import <HMSegmentedControl.h>

NS_ASSUME_NONNULL_BEGIN

@class FHHouseDetailSubPageViewController;
@interface FHFloorPanListViewModel : FHHouseDetailBaseViewModel

-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController tableView:(UITableView *)tableView houseType:(FHHouseType)houseType andLeftScrollView:(UIScrollView *)leftScrollView andSegementView:(UIView *)segmentView andItems:(NSMutableArray <FHDetailNewDataFloorpanListListModel *> *)allItems andCourtId:(NSString *)courtId ;

@end

NS_ASSUME_NONNULL_END
