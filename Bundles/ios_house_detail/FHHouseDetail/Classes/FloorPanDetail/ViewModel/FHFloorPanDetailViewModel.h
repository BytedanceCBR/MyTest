//
//  FHFloorPanDetailViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailViewModel : FHHouseDetailBaseViewModel

-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView floorPanId:(NSString *)floorPanId;

- (void)startLoadData;

@end

NS_ASSUME_NONNULL_END
