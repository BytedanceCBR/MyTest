//
//  FHHouseFindPriceCell.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//找房价格输入cell
@protocol FHHouseFindPriceCellDelegate;
@interface FHHouseFindPriceCell : UICollectionViewCell

@property(nonatomic , weak) id<FHHouseFindPriceCellDelegate> delegate;

-(void) updateWithLowerPrice:(NSNumber *)lowPrice higherPrice:(NSNumber *)highPrice;

@end

@protocol FHHouseFindPriceCellDelegate <NSObject>

@required

-(void)updateLowerPrice:(NSString *)price inCell:(FHHouseFindPriceCell *)cell;

-(void)updateHigherPrice:(NSString *)price inCell:(FHHouseFindPriceCell *)cell;

@end

NS_ASSUME_NONNULL_END
