//
//  FHMineMutiItemCell.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/20.
//

#import "FHMineBaseCell.h"
#import "FHMineFavoriteItemView.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHMineFocusCellDelegate <NSObject>

- (void)didItemClick:(FHMineConfigDataIconOpDataMyIconItemsModel *)model;

@end

@interface FHMineMutiItemCell : FHMineBaseCell

- (void)setItemTitles:(NSArray *)itemTitles;

@property(nonatomic , weak) id<FHMineFocusCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
