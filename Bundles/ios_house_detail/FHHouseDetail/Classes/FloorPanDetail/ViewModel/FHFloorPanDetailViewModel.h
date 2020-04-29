//
//  FHFloorPanDetailViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseDetailSubPageViewController;
@interface FHFloorPanDetailViewModel : FHHouseDetailBaseViewModel

@property (nonatomic, strong)   NSDictionary       *logPB;
-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController tableView:(UITableView *)tableView floorPanId:(NSString *)floorPanId;

- (void)startLoadData;

- (NSString *)pageTypeString;
@end

NS_ASSUME_NONNULL_END
