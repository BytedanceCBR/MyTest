//
//  FHFloorTimeLineViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorTimeLineViewModel : FHHouseDetailBaseViewModel

-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView courtId:(NSString *)courtId;

- (void)startLoadData;

@end

NS_ASSUME_NONNULL_END
