//
//  FHDetailNewAddressInfoCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailBaseCell.h"
@class FHDetailNewSurroundingInfo;

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNewAddressInfoCell : FHDetailBaseCell

@end

@interface FHDetailNewAddressInfoCellModel : FHDetailBaseModel

@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *courtId;
@property(nonatomic, copy, nullable) NSString *gaodeLng;
@property(nonatomic, copy, nullable) NSString *gaodeLat;
@property (nonatomic, copy, nullable) NSString *courtAddress;
@property (nonatomic, copy, nullable) NSString *courtAddressIcon;

@end

NS_ASSUME_NONNULL_END
