//
//  FHHouseListRentCell.h
//  FHHouseList
//
//  Created by xubinbin on 2020/10/28.
//

#import "FHHouseBaseCommonCell.h"
#import "FHHouseCardStatusManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListRentCell : FHHouseBaseCommonCell<FHHouseCardReadStateProtocol, FHHouseCardTouchAnimationProtocol>

@property (nonatomic, strong) id model;

@end

NS_ASSUME_NONNULL_END
