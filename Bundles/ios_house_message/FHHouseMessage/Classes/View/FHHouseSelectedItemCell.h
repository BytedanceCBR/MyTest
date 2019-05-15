//
//  FHHouseSelectedItemCell.h
//  FHHouseMessage
//
//  Created by leo on 2019/4/29.
//

#import "FHHouseBaseItemCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseSelectedItemCell : FHHouseBaseItemCell
-(void)setItemSelected:(BOOL)itemSelected;
-(void)setDisable:(BOOL)isDisable;
@end

NS_ASSUME_NONNULL_END
