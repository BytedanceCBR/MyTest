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

@class FHSearchHouseDataItemsModel;
@class FHNewHouseItemModel;
@class FHSearchHouseDataItemsModel;
@class FHHouseRentDataItemsModel;
@class JSONModel;


@interface FHSingleImageInfoCell : UITableViewCell

@property(nonatomic, assign) BOOL isFirstCell;
@property(nonatomic, assign) BOOL isTail;

-(void)updateWithModel:(FHSearchHouseDataItemsModel *)model isLastCell:(BOOL)isLastCell;

-(void)updateWithNewHouseModel:(FHNewHouseItemModel *)model isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell;

-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell;

-(void)updateWithRentHouseModel:(FHHouseRentDataItemsModel *)model  isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell;

-(void)updateWithHouseModel:(JSONModel *)model isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell;

-(void)refreshTopMargin:(CGFloat)top;

-(void)refreshBottomMargin:(CGFloat)bottom;

@end

NS_ASSUME_NONNULL_END
