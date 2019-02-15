//
//  FHHouseFindHistoryCell.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import <UIKit/UIKit.h>
#import <FHHouseBase/FHHouseType.h>

NS_ASSUME_NONNULL_BEGIN

@class FHHFHistoryDataDataModel;
@protocol FHHouseFindHistoryCellDelegate;

//找房 历史cell
@interface FHHouseFindHistoryCell : UICollectionViewCell

@property(nonatomic , weak) id<FHHouseFindHistoryCellDelegate> delegate;

-(void)updateWithItems:(NSArray *)items;

@end

@protocol FHHouseFindHistoryCellDelegate <NSObject>

@required

-(void)selectHistory:(FHHFHistoryDataDataModel *)model;

-(void)willShowHistory:(FHHFHistoryDataDataModel *)model rank:(NSInteger)rank houseType:(FHHouseType)houseType;

@end

NS_ASSUME_NONNULL_END
