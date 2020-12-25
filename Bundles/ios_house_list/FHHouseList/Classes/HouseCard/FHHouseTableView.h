//
//  FHHouseTableView.h
//  FHHouseList
//
//  Created by bytedance on 2020/11/30.
//

#import "FHBaseTableView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseCardCellViewModelProtocol;
@protocol FHHouseTableViewDataSource <NSObject>

- (NSArray<NSArray<id<FHHouseCardCellViewModelProtocol>> *> *)fhHouse_dataList;

//{ViewModelClassName: CellClassName}
- (NSDictionary<NSString *, NSString *> *)fhHouse_supportCellStyles;

@end

@protocol FHHouseTableViewDelegate <UIScrollViewDelegate>

@end


@interface FHHouseTableView : FHBaseTableView

@property (nonatomic, weak) id<FHHouseTableViewDataSource> fhHouse_dataSource;

@property (nonatomic, weak) id<FHHouseTableViewDelegate> fhHouse_delegate;

- (void)registerCellStyles;

- (void)handleAppWillEnterForground;

- (void)handleAppDidEnterBackground;

@end

NS_ASSUME_NONNULL_END
