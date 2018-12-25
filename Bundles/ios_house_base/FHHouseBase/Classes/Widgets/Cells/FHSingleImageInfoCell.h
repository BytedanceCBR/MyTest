//
//  FHSingleImageInfoCell.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/*
 * 二手房列表页等 显示单张图的cell
 */

@class FHSingleImageInfoCellModel;

@interface FHSingleImageInfoCell : UITableViewCell

-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel;
    
-(void)refreshTopMargin:(CGFloat)top;

-(void)refreshBottomMargin:(CGFloat)bottom;

@end

NS_ASSUME_NONNULL_END
