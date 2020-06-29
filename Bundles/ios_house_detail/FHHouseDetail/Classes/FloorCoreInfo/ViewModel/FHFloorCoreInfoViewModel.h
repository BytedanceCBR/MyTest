//
//  FHFloorCoreInfoViewModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHHouseDetailBaseViewModel.h"
#import "FHHouseDetailSubPageViewController.h"
#import "FHLynxView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorCoreInfoViewModel : FHHouseDetailBaseViewModel

@property(nonatomic , strong) NSMutableDictionary *detailTracerDic;
@property(nonatomic , weak) FHLynxView *lynxView;

-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController tableView:(UITableView *)tableView courtId:(NSString *)courtId houseNameModel:(JSONModel *)model;

- (void)startLoadData;

@end

NS_ASSUME_NONNULL_END
