//
// Created by zhulijun on 2019-07-03.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailBlankLineCell : FHDetailBaseCell

@end

// 模型
@interface FHDetailBlankLineModel : FHDetailBaseModel

@property(nonatomic, assign) CGFloat lineHeight;
@property(nonatomic, strong) UIColor *lineColor;
@end


NS_ASSUME_NONNULL_END
