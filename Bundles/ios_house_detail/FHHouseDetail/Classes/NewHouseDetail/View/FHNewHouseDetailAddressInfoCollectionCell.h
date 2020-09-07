//
//  FHNewHouseDetailAddressInfoCollectionCell.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailAddressInfoCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNewHouseDetailAddressInfoCellModel : NSObject
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *courtId;
@property(nonatomic, copy, nullable) NSString *gaodeLng;
@property(nonatomic, copy, nullable) NSString *gaodeLat;
@property (nonatomic, copy, nullable) NSString *courtAddress;
@property (nonatomic, copy, nullable) NSString *courtAddressIcon;
@end

NS_ASSUME_NONNULL_END
