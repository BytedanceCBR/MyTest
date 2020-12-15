//
//  FHEntranceItemCell.h
//  FHHouseHome
//
//  Created by CYY RICH on 2020/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHConfigDataOpDataItemsModel;

@interface FHHomeEntranceItemCell : UICollectionViewCell

- (void)bindModel:(FHConfigDataOpDataItemsModel *)model;

@end

NS_ASSUME_NONNULL_END
