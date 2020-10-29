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

@property (nonatomic, strong) YYLabel *tagInformation;
@property (nonatomic, strong) CAShapeLayer *topLeftTagMaskLayer;

- (void)configTopLeftTagWithTagImages:(id)data;

- (void)layoutTopLeftTagImageView;

@end

NS_ASSUME_NONNULL_END
