//
//  FHUGCVotePublishCell.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import <UIKit/UIKit.h>
#import "FHUGCVotePublishModel.h"
#import "TTUGCTextView.h"

NS_ASSUME_NONNULL_BEGIN

#define PADDING            20
#define CELL_HEIGHT        44
#define TITLE_VIEW_HEIGHT  70
#define DESC_VIEW_HEIGHT   65
#define OPTION_CELL_HEIGHT 62

@class FHUGCVotePublishScopeView;
@class FHUGCVotePublishVoteTypeView;
@class FHUGCVotePublishDatePickView;
@class FHUGCVotePublishTitleView;
@class FHUGCVotePublishDescriptionView;
@class FHUGCVotePublishOptionCell;

@protocol FHUGCVotePublishBaseViewDelegate <NSObject>
@optional
- (void)voteScopeView:(FHUGCVotePublishScopeView *)scopeView tapAction:(UITapGestureRecognizer *)tap;
- (void)voteTypeView:(FHUGCVotePublishVoteTypeView *)scopeView tapAction:(UITapGestureRecognizer *)tap;
- (void)voteDatePickView:(FHUGCVotePublishDatePickView *)scopeView tapAction:(UITapGestureRecognizer *)tap;

- (void)voteTitleView:(FHUGCVotePublishTitleView *)titleView didInputText: (NSString *)text;
- (void)voteTitleView:(FHUGCVotePublishTitleView *)titleView didChangeHeight: (CGFloat)newHeight;
- (void)voteTitleViewDidBeginEditing:(FHUGCVotePublishTitleView *)titleView;

- (void)descriptionView:(FHUGCVotePublishDescriptionView *)descriptionView didInputText: (NSString *)text;
- (void)descriptionView:(FHUGCVotePublishDescriptionView *)descriptionView didChangeHeight: (CGFloat)newHeight;
- (void)descriptionViewDidBeginEditing:(FHUGCVotePublishDescriptionView *)descriptionView;
@end

@interface FHUGCVotePublishBaseView: UIView

@property (nonatomic, weak) id<FHUGCVotePublishBaseViewDelegate> delegate;

@property (nonatomic, assign) BOOL hideBottomLine;

@end

@interface FHUGCVotePublishScopeView: FHUGCVotePublishBaseView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UIImageView *rightArrow;
@end

@interface FHUGCVotePublishVoteTypeView: FHUGCVotePublishBaseView<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong, readonly) NSArray<NSString *> *types;
@property (nonatomic, strong) UIImageView *rightArrow;

- (void)updateWithVoteType:(VoteType) type;
@end

@interface FHUGCVotePublishDatePickView: FHUGCVotePublishBaseView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong, readonly)NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIImageView *rightArrow;

- (void)toggleDatePicker;
@end

@interface FHUGCVotePublishTitleView: FHUGCVotePublishBaseView<UITextViewDelegate>
@property (nonatomic, strong) TTUGCTextView  *contentTextView;
@end

@interface FHUGCVotePublishDescriptionView: FHUGCVotePublishBaseView <UITextViewDelegate>
@property (nonatomic, strong) TTUGCTextView  *contentTextView;
@end


@protocol FHUGCVotePublishOptionCellDelegate <NSObject>
- (void)optionCell:(FHUGCVotePublishOptionCell *)optionCell didInputText: (NSString*)text;
- (void)deleteOptionCell: (FHUGCVotePublishOptionCell *)optionCell;
- (void)optionCellDidBeginEditing:(FHUGCVotePublishOptionCell *)optionCell;
@end

@interface FHUGCVotePublishOptionCell: UITableViewCell<FHUGCVotePublishOptionCellDelegate>
@property (nonatomic, weak  ) id<FHUGCVotePublishOptionCellDelegate> delegate;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UITextField *optionTextField;

+(NSString *)reusedIdentifier;

- (void)updateWithOption:(FHUGCVotePublishOption *)option;
@end
NS_ASSUME_NONNULL_END
