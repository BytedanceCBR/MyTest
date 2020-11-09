//
//  FHHouseBaseUsuallyCell.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/10/26.
//

#import "FHHouseBaseCell.h"
#import "FHHouseListBaseItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseBaseUsuallyCell : FHHouseBaseCell

@property (nonatomic, strong) CAShapeLayer *topLeftTagMaskLayer;

- (void)configTopLeftTagWithTagImages:(NSArray<FHImageModel> *)tagImages;

- (void)layoutTopLeftTagImageView;

- (NSAttributedString *)originPriceAttr:(NSString *)originPrice;

@end

NS_ASSUME_NONNULL_END
