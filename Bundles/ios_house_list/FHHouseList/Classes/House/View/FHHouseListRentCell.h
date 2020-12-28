//
//  FHHouseListRentCell.h
//  FHHouseList
//
//  Created by xubinbin on 2020/10/28.
//

#import "FHHouseBaseUsuallyCell.h"
#import "FHHouseCardStatusManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListRentCell : FHHouseBaseUsuallyCell<FHHouseCardReadStateProtocol>

@property (nonatomic, strong) id model;

@end

NS_ASSUME_NONNULL_END
