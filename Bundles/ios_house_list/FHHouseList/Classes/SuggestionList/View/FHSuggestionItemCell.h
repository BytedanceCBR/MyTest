//
//  FHSuggestionItemCell.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionItemCell : UITableViewCell

@end

@interface FHSuggestionNewHouseItemCell : UITableViewCell

@end

@interface FHSuggectionTableView : UITableView

@property (nonatomic, copy)     dispatch_block_t       handleTouch;

@end

NS_ASSUME_NONNULL_END
