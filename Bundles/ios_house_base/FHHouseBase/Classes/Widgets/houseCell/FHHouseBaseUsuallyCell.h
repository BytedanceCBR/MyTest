//
//  FHHouseBaseUsuallyCell.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/26.
//

#import "FHHouseBaseCell.h"
#import "FHHouseListBaseItemModel.h"

NS_ASSUME_NONNULL_BEGIN
//房源卡片基类 业务代码可继承，不可直接使用基类
@interface FHHouseBaseUsuallyCell : FHHouseBaseCell

@property (nonatomic, strong) CAShapeLayer *topLeftTagMaskLayer;

- (void)configTopLeftTagWithTagImages:(NSArray<FHImageModel> *)tagImages;

- (void)layoutTopLeftTagImageView;

- (NSAttributedString *)originPriceAttr:(NSString *)originPrice;

@end

NS_ASSUME_NONNULL_END
