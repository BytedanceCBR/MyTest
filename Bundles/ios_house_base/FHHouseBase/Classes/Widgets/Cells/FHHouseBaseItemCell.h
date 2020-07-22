//
//  FHHouseBaseItemCell.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/3/5.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"
#import "FHListBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
//当图图片cell
@class FHSingleImageInfoCellModel;
@class FHHomeHouseDataItemsModel;
@class FHHouseBaseItemCell;

@protocol FHHouseBaseItemCellDelegate <NSObject>

@optional
//dislike确认
- (void)dislikeConfirm:(FHHomeHouseDataItemsModel *)model cell:(FHHouseBaseItemCell *)cell;
//dislike按钮点击前
- (BOOL)canDislikeClick;

@end

@interface FHHouseBaseItemCell : FHListBaseCell

@property(nonatomic , weak) id<FHHouseBaseItemCellDelegate> delegate;
@property(nonatomic, strong) UIImageView *mainImageView;

-(void)initUI;

-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel;

-(void)updateWithOldHouseDetailCellModel:(FHSingleImageInfoCellModel *)cellModel;

-(void)updateHomeHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType;

-(void)refreshTopMargin:(CGFloat)top;

-(void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast;

-(void)refreshIndexCorner:(BOOL)isFirst withLast:(BOOL)isLast;

-(void)updateHomeSmallImageHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType;

+(CGFloat)recommendReasonHeight;

- (void)updateFakeHouseImageWithUrl:(NSString *)urlStr andSourceStr:(NSString *)sourceStr;

- (void)updateThirdPartHouseSourceStr:(NSString *)sourceStr;

- (void)resumeVRIcon;

- (void)hiddenCloseBtn;
- (void)updateHouseStatus:(id)data;

@end

NS_ASSUME_NONNULL_END
