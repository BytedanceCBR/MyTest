//
//  FHSuggestionItemCell.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/23.
//

#import <UIKit/UIKit.h>
#import "FHSuggestionListModel.h"
#import "YYLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionItemCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   UILabel       *secondaryLabel;

@end

@interface FHGuessYouWantCell : UITableViewCell

- (void)refreshData:(id)data;

@end

@interface FHSuggestionNewHouseItemCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   UILabel       *oldNameLabel;
@property (nonatomic, strong)   YYLabel       *secondaryLabel;
@property (nonatomic, strong)   UILabel       *subLabel;
@property (nonatomic, strong)   UILabel       *secondarySubLabel;
@property (nonatomic, strong)   UIView        *sepLine;
@property (nonatomic, strong)   YYLabel       *propertyManagementLabel;


- (void)refreshData:(id)data;

@end

@interface FHFindHouseHelpEntryView : UIView

@property (nonatomic, copy) void (^jumpButtonAction)(NSString *);

- (void)refreshData:(FHGuessYouWantExtraInfoModel *)data;

@end

@interface FHSuggestHeaderViewCell : UITableViewCell

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, copy)     void (^entryTapAction)(NSString *);

- (void)refreshData:(FHGuessYouWantExtraInfoModel *)data;

@end

@interface FHSuggectionTableView : UITableView

@property (nonatomic, copy)     dispatch_block_t       handleTouch;

@end

@interface FHRecommendtHeaderViewCell : UITableViewCell

@property (nonatomic, strong)  UILabel       *label;

@end

NS_ASSUME_NONNULL_END
