//
//  FHHouseTableView.h
//  FHHouseList
//
//  Created by bytedance on 2020/11/30.
//

#import "FHBaseTableView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseNewComponentViewModelProtocol;
@protocol FHHouseTableViewDataSource <UITableViewDataSource>

- (NSArray<NSArray<id<FHHouseNewComponentViewModelProtocol>> *> *)fhHouse_dataList;

//{ViewModelClassName: CellClassName}
- (NSDictionary<NSString *, NSString *> *)fhHouse_supportCellStyles;

@end


@protocol FHHouseTableViewDelegate <UITableViewDelegate>

@end

@interface FHHouseTableView : FHBaseTableView

@property (nonatomic, weak) id<FHHouseTableViewDataSource> fhHouse_dataSource;
@property (nonatomic, weak) id<FHHouseTableViewDelegate> fhHouse_delegate;

@end

NS_ASSUME_NONNULL_END
