//
//  FHSingleImageInfoCellModel.h
//  FHHouseBase
//
//  Created by 张静 on 2018/12/25.
//

#import <Foundation/Foundation.h>
#import "FHSearchHouseModel.h"
#import "FHNewHouseItemModel.h"
#import "FHHouseRentModel.h"
#import "FHHouseNeighborModel.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSingleImageInfoCellModel : NSObject

@property (nonatomic, assign) FHHouseType houseType;
@property (nonatomic, copy , nullable) NSString *houseId;

@property (nonatomic, strong , nullable) FHNewHouseItemModel *houseModel;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsModel *secondModel;
@property (nonatomic, strong , nullable) FHHouseRentDataItemsModel *rentModel;
@property (nonatomic, strong , nullable) FHHouseNeighborDataItemsModel *neighborModel;

@property (nonatomic, assign) CGSize titleSize;

@property (nonatomic, strong , nullable, readonly) NSAttributedString *tagsAttrStr;

@end

NS_ASSUME_NONNULL_END
