//
//  FHFloorTimeLineViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailNewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseDetailSubPageViewController;
@interface FHFloorTimeLineViewModel : FHHouseDetailBaseViewModel

-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController tableView:(UITableView *)tableView courtId:(NSString *)courtId;

@property (nonatomic, strong) FHDetailNewDataTimelineModel *timeLineModel;

- (void)scrollToItemAtRow:(NSInteger)index;

- (void)processDetailData:(FHDetailNewDataTimelineModel *)model;

@end

NS_ASSUME_NONNULL_END
