//
//  FHFloorPanTitleCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/20.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanTitleCell : FHDetailBaseCell

@end
// 模型

@interface FHFloorPanTitleCellModel : FHDetailBaseModel

@property (nonatomic, copy)     NSString       *totalPrice;
@property (nonatomic, copy)     NSString       *avgPrice;

@end
NS_ASSUME_NONNULL_END
