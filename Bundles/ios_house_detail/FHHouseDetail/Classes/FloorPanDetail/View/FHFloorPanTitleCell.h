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

@property (nonatomic, copy)     NSString       *title;
@property (nonatomic, copy)     NSString       *pricing;
@property (nonatomic, copy)     NSString       *pricingPerSqm;

@end
NS_ASSUME_NONNULL_END
