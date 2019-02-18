//
//  FHMineFocusCell.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineBaseCell.h"
#import "FHMineFavoriteItemView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMineFocusCell : FHMineBaseCell

- (void)setItems:(NSArray<FHMineFavoriteItemView *> *)items;

@end

NS_ASSUME_NONNULL_END
