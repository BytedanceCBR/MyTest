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
#define DATEPICKER_HEIGHT 200
#define CELL_HEIGHT 60
#define VOTE_TYPE_PICKTER_VIEW_HEIGHT 200

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
- (void)voteTypeCell:(FHUGCVotePublishVoteTypeCell *)voteTypeCell didSelectedType:(VoteType)type;
- (void)voteTypeCell:(FHUGCVotePublishVoteTypeCell *)voteTypeCell toggleTypeStatus:(BOOL)isHidden;
- (void)datePickerCell:(FHUGCVotePublishDatePickCell *)datePickerCell didSelectedDate:(NSDate *)date;
- (void)datePickerCell:(FHUGCVotePublishDatePickCell *)datePickerCell toggleWithStatus:(BOOL)isHidden;
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

@interface FHUGCVotePublishTitleCell: FHUGCVotePublishBaseCell
@property (nonatomic, strong) UITextField *contentTextField;
@end

@interface FHUGCVotePublishDescriptionCell: FHUGCVotePublishBaseCell
@property (nonatomic, strong) UITextField *contentTextField;
@end

@interface FHUGCVotePublishOptionCell: FHUGCVotePublishBaseCell
@property (nonatomic, strong) UIImageView *deleteImageView;
@property (nonatomic, strong) UITextField *optionTextField;
@end

@interface FHUGCVotePublishVoteTypeCell: FHUGCVotePublishBaseCell<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong, readonly) NSArray<NSString *> *types;

- (void)toggleTypePicker;
@end

@interface FHUGCVotePublishDatePickCell: FHUGCVotePublishBaseCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong, readonly)NSDateFormatter *dateFormatter;

- (void)toggleDatePicker;
@end

NS_ASSUME_NONNULL_END
