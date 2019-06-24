//
//  FHUGCSearchListCell.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import <UIKit/UIKit.h>
#import "FHUGCBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCSearchListCell : FHUGCBaseCell

@property (nonatomic, copy)     NSString       *highlightedText;

@end

@interface FHUGCSuggectionTableView : UITableView

@property (nonatomic, copy)     dispatch_block_t       handleTouch;

@end

NS_ASSUME_NONNULL_END
