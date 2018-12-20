//
//  FHNeighborListViewController.h
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHBaseViewController.h"

typedef enum : NSUInteger {
    FHNeighborListVCTypeErshouSameNeighbor              = 1,         // 二手房-同小区房源
    FHNeighborListVCTypeErshouNearBy                    = 2,         // 二手房-周边房源
    FHNeighborListVCTypeNeighborOnSales                 = 3,         // 小区-在售房源
    FHNeighborListVCTypeNeighborOnRent                  = 4,         // 小区-在租房源
    FHNeighborListVCTypeNeighborErshou                  = 5,         // 小区-小区房源-二手房
    FHNeighborListVCTypeNeighborRent                    = 6,         // 小区-小区房源-租房
    FHNeighborListVCTypeRentSameNeighbor                = 7,         // 租房-同小区房源
    FHNeighborListVCTypeRentNearBy                      = 8,         // 租房-周边房源
} FHNeighborListVCType;

NS_ASSUME_NONNULL_BEGIN

// 周边房源、同小区房源、在售房源、在租房源、小区房源
@interface FHNeighborListViewController : FHBaseViewController

@end

NS_ASSUME_NONNULL_END
