//
//  FHDynamicLynxCell.h
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/9/8.
//

#import "FHListBaseCell.h"
#import "FHSearchHouseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDynamicLynxCell : FHListBaseCell

- (void)updateWithCellModel:(FHDynamicLynxCellModel *)cellModel;

@end

NS_ASSUME_NONNULL_END