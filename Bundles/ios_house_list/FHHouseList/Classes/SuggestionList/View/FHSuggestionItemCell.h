//
//  FHSuggestionItemCell.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionItemCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   UILabel       *secondaryLabel;

@end

@interface FHSuggestionNewHouseItemCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   UILabel       *secondaryLabel;
@property (nonatomic, strong)   UILabel       *subLabel;
@property (nonatomic, strong)   UILabel       *secondarySubLabel;

@end

@interface FHSuggestHeaderViewCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   UIButton       *deleteBtn;

@property (nonatomic, copy)     dispatch_block_t       delClick;

@end

@interface FHSuggectionTableView : UITableView

@property (nonatomic, copy)     dispatch_block_t       handleTouch;

@end

NS_ASSUME_NONNULL_END
