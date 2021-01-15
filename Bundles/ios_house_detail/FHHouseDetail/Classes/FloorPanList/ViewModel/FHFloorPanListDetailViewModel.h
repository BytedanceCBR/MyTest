//
//  FHFloorPanListDetailViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanListDetailViewModel : NSObject

-(instancetype)initWithTableView:(UITableView *)tableView itemArray:(NSArray *)itemArray subPageParams:(NSDictionary *)subPageParams elementShowCache:(NSMutableDictionary *)elementShowCache;

@end

NS_ASSUME_NONNULL_END
