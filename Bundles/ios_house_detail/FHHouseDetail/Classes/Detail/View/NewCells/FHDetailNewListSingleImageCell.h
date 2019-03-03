//
//  FHDetailNewListSingleImageCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/21.
//

#import "FHDetailBaseCell.h"
#import <UIKit/UIKit.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN
/*
 * 二手房列表页等 显示单张图的cell
 */

@class FHSingleImageInfoCellModel;
@class FHHomeHouseDataItemsModel;

@interface FHDetailNewListSingleImageCell : FHDetailBaseCell

-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel;

-(void)updateHomeHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType;

-(void)refreshTopMargin:(CGFloat)top;

-(void)refreshBottomMargin:(CGFloat)bottom;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;

@end

NS_ASSUME_NONNULL_END