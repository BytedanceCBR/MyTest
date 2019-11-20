//
//  FHHouseBaseSmallItemCell.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/7/28.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"
#import "FHListBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
//当图图片cell
@class FHSingleImageInfoCellModel;
@class FHHomeHouseDataItemsModel;

@protocol FHHouseBaseSmallItemCellDelegate <NSObject>

@optional
- (void)dislikeConfirm:(NSString *)houseId;

@end

@interface FHHouseBaseSmallItemCell : FHListBaseCell

@property(nonatomic , weak) id<FHHouseBaseSmallItemCellDelegate> delegate;
@property(nonatomic, strong) UIImageView *mainImageView;

-(void)initUI;

-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel;

-(void)updateHomeHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType;

-(void)refreshTopMargin:(CGFloat)top;

-(void)updateHomeSmallImageHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType;

+(CGFloat)recommendReasonHeight;

- (void)updateFakeHouseImageWithUrl:(NSString *)urlStr andSourceStr:(NSString *)sourceStr;

- (void)updateThirdPartHouseSourceStr:(NSString *)sourceStr;

@end

NS_ASSUME_NONNULL_END
