//
//  FHUGCVotePublishCell.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import <UIKit/UIKit.h>
#import "FHUGCVotePublishModel.h"

NS_ASSUME_NONNULL_BEGIN

#define PADDING 20
#define CELL_HEIGHT 44

@class FHUGCVotePublishTitleCell;
@class FHUGCVotePublishDescriptionCell;
@class FHUGCVotePublishOptionCell;
@class FHUGCVotePublishVoteTypeCell;
@class FHUGCVotePublishDatePickCell;

@protocol FHUGCVotePublishBaseCellDelegate <NSObject>

@optional
- (void)voteTitleCell:(FHUGCVotePublishTitleCell *)titleCell didInputText: (NSString *)text;
- (void)descriptionCell:(FHUGCVotePublishDescriptionCell *)descriptionCell didInputText: (NSString *)text;
- (void)optionCell:(FHUGCVotePublishOptionCell *)optionCell didInputText: (NSString*)text;
- (void)deleteOptionCell: (FHUGCVotePublishOptionCell *)optionCell;
@end

@interface FHUGCVotePublishTextView: UITextView
@property (nonatomic, copy)NSString *placeholder;
@end

@interface FHUGCVotePublishBaseCell: UITableViewCell

@property (nonatomic, weak) id<FHUGCVotePublishBaseCellDelegate> delegate;

+ (NSString *)reusedIdentifier;
@end

@interface FHUGCVotePublishCityCell: FHUGCVotePublishBaseCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UIImageView *rightArrow;
@end

@interface FHUGCVotePublishTitleCell: FHUGCVotePublishBaseCell<UITextViewDelegate>
@property (nonatomic, strong) UITextView  *contentTextView;
@property (nonatomic, strong) UITextField *contentTextField;
@end

@interface FHUGCVotePublishDescriptionCell: FHUGCVotePublishBaseCell <UITextViewDelegate>
@property (nonatomic, strong) UITextField *contentTextField;
@end

@interface FHUGCVotePublishOptionCell: FHUGCVotePublishBaseCell
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UITextField *optionTextField;

- (void)updateWithOption:(FHUGCVotePublishOption *)option;
@end

@interface FHUGCVotePublishVoteTypeCell: FHUGCVotePublishBaseCell<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong, readonly) NSArray<NSString *> *types;
@property (nonatomic, strong) UIImageView *rightArrow;

- (void)updateWithVoteType:(VoteType) type;
@end

@interface FHUGCVotePublishDatePickCell: FHUGCVotePublishBaseCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong, readonly)NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIImageView *rightArrow;

- (void)toggleDatePicker;
@end

NS_ASSUME_NONNULL_END
