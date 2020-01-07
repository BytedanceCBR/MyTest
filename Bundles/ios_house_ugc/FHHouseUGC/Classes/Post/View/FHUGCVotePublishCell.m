//
//  FHUGCVotePublishCell.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import "FHUGCVotePublishCell.h"
#import <Masonry.h>
#import <UIColor+Theme.h>
#import <UIFont+House.h>
#import <ReactiveObjC.h>
#import <FHCommonDefines.h>
#import <FHUGCCategoryHelper.h>

#define TITLE_TEXTVIEW_MIN_HEIGHT 47
#define DESC_TEXTVIEW_MIN_HEIGHT  42

@interface FHUGCVotePublishBaseView()
@property (nonatomic, strong) UIView *bottomLineView;
@end

@implementation FHUGCVotePublishBaseView

- (UIView *)bottomLineView {
    if(!_bottomLineView) {
        _bottomLineView = [UIView new];
        _bottomLineView.backgroundColor = [UIColor themeGray4];
    }
    return _bottomLineView;
}

- (void)setHideBottomLine:(BOOL)hideBottomLine {
    _hideBottomLine = hideBottomLine;
    self.bottomLineView.hidden = hideBottomLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor themeWhite];
        [self addSubview:self.bottomLineView];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(PADDING);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapAction: (UITapGestureRecognizer *)tap {}

@end

// MARK: 城市选择
@implementation FHUGCVotePublishScopeView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.cityLabel];
        [self addSubview:self.rightArrow];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(PADDING);
        }];
        
        [self.cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self.rightArrow.mas_left).offset(-10);
        }];
        
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self).offset(-PADDING);
        }];
    }
    return self;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"选择可见范围";
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeGray1];
        
    }
    return _titleLabel;
}

- (UILabel *)cityLabel {
    if(!_cityLabel) {
        _cityLabel = [UILabel new];
        _cityLabel.font = [UIFont themeFontRegular:16];
        _cityLabel.text = @"未设置";
        _cityLabel.textColor = [UIColor themeGray3];
    }
    return _cityLabel;
}

- (UIImageView *)rightArrow {
    if(!_rightArrow) {
        _rightArrow = [UIImageView new];
        _rightArrow.image = [UIImage imageNamed:@"fh_ugc_vote_publish_right_arrow"];
    }
    return _rightArrow;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    if([self.delegate respondsToSelector:@selector(voteScopeView:tapAction:)]) {
        [self.delegate voteScopeView:self tapAction:tap];
    }
}
@end

// MARK: 投票类型
@interface FHUGCVotePublishVoteTypeView()
@property (nonatomic, strong) NSArray<NSString *> *types;
@end

@implementation FHUGCVotePublishVoteTypeView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.typeLabel];
        [self addSubview:self.rightArrow];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(PADDING);
            make.right.equalTo(self.typeLabel.mas_left).offset(-10);
            make.height.mas_equalTo(CELL_HEIGHT);
        }];
        
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.titleLabel);
            make.right.equalTo(self.rightArrow.mas_left).offset(-10);
            
        }];
        
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self).offset(-PADDING);
        }];
    }
    return self;
}

- (NSArray<NSString *> *)types {
    if(!_types) {
        _types = [NSArray arrayWithArray:@[@"单选", @"多选"]];
    }
    return _types;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.text = @"投票类型";
    }
    return _titleLabel;
}

- (UILabel *)typeLabel {
    if(!_typeLabel) {
        _typeLabel = [UILabel new];
        _typeLabel.textColor = [UIColor themeGray1];
        _typeLabel.font = [UIFont themeFontRegular:16];
        _typeLabel.text = self.types.firstObject;
    }
    return _typeLabel;
}

- (void)updateWithVoteType:(VoteType) type {
    NSUInteger index = MAX(type - VoteType_SingleSelect, 0);
    self.typeLabel.text = self.types[index];
}

- (UIImageView *)rightArrow {
    if(!_rightArrow) {
        _rightArrow = [UIImageView new];
        _rightArrow.image = [UIImage imageNamed:@"fh_ugc_vote_publish_right_arrow"];
    }
    return _rightArrow;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    if([self.delegate respondsToSelector:@selector(voteTypeView:tapAction:)]) {
        [self.delegate voteTypeView:self tapAction:tap];
    }
}
@end



// MARK: 投票日期选择
@interface FHUGCVotePublishDatePickView()
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@end

@implementation FHUGCVotePublishDatePickView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.dateLabel];
        [self addSubview:self.rightArrow];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(PADDING);
            make.right.equalTo(self.dateLabel.mas_left).offset(-PADDING);
            make.height.mas_equalTo(CELL_HEIGHT);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.titleLabel);
            make.right.equalTo(self.rightArrow.mas_left).offset(-10);
        }];
        
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self).offset(-PADDING);
        }];
    }
    return self;
}

- (NSDateFormatter *)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    return _dateFormatter;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.text = @"截止日期";
    }
    return _titleLabel;
}

-(UILabel *)dateLabel {
    if(!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.font = [UIFont themeFontRegular:16];
        _dateLabel.textColor = [UIColor themeGray1];
    }
    return _dateLabel;
}

- (UIImageView *)rightArrow {
    if(!_rightArrow) {
        _rightArrow = [UIImageView new];
        _rightArrow.image = [UIImage imageNamed:@"fh_ugc_vote_publish_right_arrow"];
    }
    return _rightArrow;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    if([self.delegate respondsToSelector:@selector(voteDatePickView:tapAction:)]) {
        [self.delegate voteDatePickView:self tapAction:tap];
    }
}
@end

// MARK: 投票标题
@interface FHUGCVotePublishTitleView() <TTUGCTextViewDelegate>
@end
@implementation FHUGCVotePublishTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self addSubview:self.contentTextView];
    }
    return self;
}

- (TTUGCTextView *)contentTextView {
    if(!_contentTextView) {
        // TTUGCTextView 配置
        _contentTextView  = [[TTUGCTextView alloc] initWithFrame:CGRectMake(PADDING, 15, SCREEN_WIDTH - 2 * PADDING, TITLE_TEXTVIEW_MIN_HEIGHT)];
        _contentTextView.textViewFontSize = 22;
        _contentTextView.typingAttributes = @{
                                              NSForegroundColorAttributeName: [UIColor themeGray1],
                                              NSFontAttributeName: [UIFont themeFontRegular:_contentTextView.textViewFontSize]
                                              };
        _contentTextView.delegate = self;
        _contentTextView.textLenDelegate = self;
        _contentTextView.clipsToBounds = YES;
        
        // 伸缩视图配置
        _contentTextView.internalGrowingTextView.placeholder = @"投票标题";
        _contentTextView.internalGrowingTextView.placeholderColor = [UIColor themeGray3];
        _contentTextView.internalGrowingTextView.font = [UIFont themeFontRegular:_contentTextView.textViewFontSize];
        _contentTextView.internalGrowingTextView.tintColor = [UIColor themeRed1];
        _contentTextView.internalGrowingTextView.minNumberOfLines = 1;
        _contentTextView.internalGrowingTextView.maxNumberOfLines = 10;
        _contentTextView.internalGrowingTextView.minHeight = TITLE_TEXTVIEW_MIN_HEIGHT;
        _contentTextView.internalGrowingTextView.maxHeight = CGFLOAT_MAX;
    }
    return _contentTextView;
}

- (void)textViewDidChange:(TTUGCTextView *)textView {
    
    [textView textViewDidChangeLimitTextLength:TITLE_LENGTH_LIMIT];
    
    NSString *textViewContent = textView.text;
    if([textViewContent containsString:@"\n"]) {
        textViewContent = [textViewContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    if(textViewContent.length > TITLE_LENGTH_LIMIT) {
        textView.text = [textViewContent substringToIndex: TITLE_LENGTH_LIMIT];
    }
    
    if([self.delegate respondsToSelector:@selector(voteTitleView:didInputText:)]) {
        [self.delegate voteTitleView:self didInputText:textView.text];
    }
}

- (void)textView:(TTUGCTextView *)textView didChangeHeight:(float)height withDiffHeight:(CGFloat)diffHeight {
    
    CGFloat measureHeight = textView.internalGrowingTextView.measureHeight;
    
    CGRect frame = textView.frame;
    frame.size.height = measureHeight;
    textView.frame = frame;
    
    CGFloat ret = measureHeight + (TITLE_VIEW_HEIGHT - textView.internalGrowingTextView.minHeight);
    
    if([self.delegate respondsToSelector:@selector(voteTitleView:didChangeHeight:)]) {
        [self.delegate voteTitleView:self didChangeHeight:ret];
    }
}

- (void)textViewDidBeginEditing:(TTUGCTextView *)textView {
    if([self.delegate respondsToSelector:@selector(voteTitleViewDidBeginEditing:)]) {
        [self.delegate voteTitleViewDidBeginEditing:self];
    }
}

- (BOOL)textView:(TTUGCTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *replacedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return ![text isEqualToString:@"\n"] && replacedString.length <= TITLE_LENGTH_LIMIT;
    
}

@end
// MARK: 投票描述
@interface FHUGCVotePublishDescriptionView() <TTUGCTextViewDelegate>
@end
@implementation FHUGCVotePublishDescriptionView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self addSubview:self.contentTextView];
    }
    return self;
}
 
- (TTUGCTextView *)contentTextView {
    if(!_contentTextView) {
        // TTUGCTextView 配置
        _contentTextView  = [[TTUGCTextView alloc] initWithFrame:CGRectMake(PADDING, 15, SCREEN_WIDTH - 2 * PADDING, DESC_TEXTVIEW_MIN_HEIGHT)];
        _contentTextView.textViewFontSize = 18;
        _contentTextView.typingAttributes = @{
                                              NSForegroundColorAttributeName: [UIColor themeGray1],
                                              NSFontAttributeName: [UIFont themeFontRegular:_contentTextView.textViewFontSize]
                                              };
        _contentTextView.delegate = self;
        _contentTextView.textLenDelegate = self;
        _contentTextView.clipsToBounds = YES;
        
        // 伸缩视图配置
        _contentTextView.internalGrowingTextView.placeholder = @"补充描述(选填)";
        _contentTextView.internalGrowingTextView.placeholderColor = [UIColor themeGray3];
        _contentTextView.internalGrowingTextView.font = [UIFont themeFontRegular:_contentTextView.textViewFontSize];
        _contentTextView.internalGrowingTextView.tintColor = [UIColor themeRed1];
        _contentTextView.internalGrowingTextView.minNumberOfLines = 1;
        _contentTextView.internalGrowingTextView.maxNumberOfLines = 10;
        _contentTextView.internalGrowingTextView.minHeight = DESC_TEXTVIEW_MIN_HEIGHT;
        _contentTextView.internalGrowingTextView.maxHeight = CGFLOAT_MAX;
    }
    return _contentTextView;
}

- (void)textViewDidChange:(TTUGCTextView *)textView {
    
    [textView textViewDidChangeLimitTextLength:DESCRIPTION_LENGTH_LIMIT];
    
    NSString *textViewContent = textView.text;
    if([textViewContent containsString:@"\n"]) {
        textViewContent = [textViewContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    if(textViewContent.length > DESCRIPTION_LENGTH_LIMIT) {
        textView.text = [textViewContent substringToIndex: DESCRIPTION_LENGTH_LIMIT];
    }
    
    if([self.delegate respondsToSelector:@selector(descriptionView:didInputText:)]) {
        [self.delegate descriptionView:self didInputText:textView.text];
    }
}

- (void)textView:(TTUGCTextView *)textView didChangeHeight:(float)height withDiffHeight:(CGFloat)diffHeight {

    CGFloat measureHeight = textView.internalGrowingTextView.measureHeight;
    
    CGRect frame = textView.frame;
    frame.size.height = measureHeight;
    textView.frame = frame;
    
    CGFloat ret = measureHeight  + (DESC_VIEW_HEIGHT - textView.internalGrowingTextView.minHeight);
    
    if([self.delegate respondsToSelector:@selector(descriptionView:didChangeHeight:)]) {
        [self.delegate descriptionView:self didChangeHeight:ret];
    }
}

- (void)textViewDidBeginEditing:(TTUGCTextView *)textView {
    if([self.delegate respondsToSelector:@selector(descriptionViewDidBeginEditing:)]) {
        [self.delegate descriptionViewDidBeginEditing:self];
    }
}

- (BOOL)textView:(TTUGCTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *replacedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return ![text isEqualToString:@"\n"] && replacedString.length <= DESCRIPTION_LENGTH_LIMIT;
    
}
@end

// MARK: 投票选项Cell
@interface FHUGCVotePublishOptionCell()<UITextFieldDelegate>
@end
@implementation FHUGCVotePublishOptionCell

+ (NSString *)reusedIdentifier {
    return NSStringFromClass(self.class);
}

- (UIButton *)deleteButton {
    if(!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.userInteractionEnabled = YES;
        [_deleteButton setImage:[UIImage imageNamed:@"fh_ugc_vote_publish_delete_option_invalid"] forState:UIControlStateDisabled];
        [_deleteButton setImage:[UIImage imageNamed:@"fh_ugc_vote_publish_delete_option_valid"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteOptionAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UITextField *)optionTextField {
    if(!_optionTextField) {
        _optionTextField = [UITextField new];
        _optionTextField.placeholder = @"选项";
        [_optionTextField setValue:[UIColor themeGray3] forKeyPath:@"_placeholderLabel.textColor"];
        _optionTextField.font = [UIFont themeFontRegular:16];
        _optionTextField.textColor = [UIColor themeGray1];
        _optionTextField.clipsToBounds = YES;
        _optionTextField.tintColor = [UIColor themeRed1];
        _optionTextField.delegate = self;
        [_optionTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _optionTextField;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    [textField textFieldDidChangeLimitTextLength:OPTION_LENGTH_LIMIT];
    
    if([self.delegate respondsToSelector:@selector(optionCell:didInputText:)]) {
        [self.delegate optionCell:self didInputText:textField.text];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.deleteButton];
        [self addSubview:self.optionTextField];
        
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_offset(40);
            make.left.equalTo(self).offset(PADDING - 11);
            make.centerY.equalTo(self.optionTextField);
        }];
        
        [self.optionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.deleteButton.mas_right).offset(8);
            make.top.equalTo(self).offset(24);
            make.bottom.equalTo(self).offset(-16);
            make.right.equalTo(self).offset(-PADDING);
        }];
    }
    return self;
}

- (void)deleteOptionAction: (UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(deleteOptionCell:)]) {
        [self.delegate deleteOptionCell:self];
    }
}

- (void)updateWithOption:(FHUGCVotePublishOption *)option {
    self.optionTextField.text = option.content;
    self.deleteButton.enabled = option.isValid;
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(optionCellDidBeginEditing:)]) {
        [self.delegate optionCellDidBeginEditing:self];
    }
}
@end
