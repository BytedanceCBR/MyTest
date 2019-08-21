//
//  FHMapAreaHouseListViewController.h
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/6.
//

#import "FHBaseViewController.h"
#import "FHMapAreaHouseListViewModel.h"

extern NSString *const COORDINATE_ENCLOSURE;
extern NSString *const NEIGHBORHOOD_IDS ;

NS_ASSUME_NONNULL_BEGIN
//画圈、地铁 等圈定范围的房源列表页
@interface FHMapAreaHouseListViewController : FHBaseViewController

@property(nonatomic , strong , readonly) FHMapAreaHouseListViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
