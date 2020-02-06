//
//  FHHouseBaseNewHouseCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/11.
//

#import "FHBaseTableViewCell.h"
#import "FHHouseType.h"
#import "FHSearchHouseModel.h"
NS_ASSUME_NONNULL_BEGIN

//当图图片cell
@class FHSingleImageInfoCellModel;
@class FHHomeHouseDataItemsModel;

@protocol FHHouseBaseNewHouseCellDelegate <NSObject>

@optional
- (void)dislikeConfirm:(NSString *)houseId;

@end

@interface FHHouseBaseNewHouseCell : UITableViewCell

@property(nonatomic , weak) id<FHHouseBaseNewHouseCellDelegate> delegate;
@property(nonatomic, strong) UIImageView *mainImageView;

-(void)initUI;

-(void)refreshTopMargin:(CGFloat)top;

- (void)refreshWithData:(id)data;

-(void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast;

-(void)updateHomeNewHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel;

-(void)updateHouseListNewHouseCellModel:(FHSearchHouseItemModel *)commonModel;

+(CGFloat)recommendReasonHeight;

- (void)updateThirdPartHouseSourceStr:(NSString *)sourceStr;

+ (CGFloat)heightForData:(id)data;

@end

NS_ASSUME_NONNULL_END
