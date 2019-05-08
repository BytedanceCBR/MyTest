//
//  FHFloorPanCorePropertyCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/19.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanCorePropertyCell : FHDetailBaseCell

@end

@interface FHFloorPanCorePropertyCellItemModel : JSONModel

@property (nonatomic, copy , nullable) NSString *propertyName;
@property (nonatomic, copy , nullable) NSString *propertyValue;

@end

@interface FHFloorPanCorePropertyCellModel : JSONModel

@property (nonatomic, strong) NSArray <FHFloorPanCorePropertyCellItemModel *>* list;

@end

NS_ASSUME_NONNULL_END
