//
//  FHMineFocusCell.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineBaseCell.h"
#import "FHMineFavoriteItemView.h"
#import "FHHouseType.h"

@protocol FHMineFocusCellDelegate <NSObject>

- (void)goToFocusDetail:(FHHouseType)type;

@end

NS_ASSUME_NONNULL_BEGIN

@interface FHMineFocusCell : FHMineBaseCell

- (void)setItemTitles:(NSArray *)itemTitles;

@property(nonatomic , weak) id<FHMineFocusCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
