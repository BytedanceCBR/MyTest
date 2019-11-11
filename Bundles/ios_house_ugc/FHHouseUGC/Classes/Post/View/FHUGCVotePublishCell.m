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

@implementation FHUGCVotePublishBaseCell
+ (NSString *)reusedIdentifier {
    return NSStringFromClass(self.class);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
@end

// MARK: 城市选择Cell

@implementation FHUGCVotePublishCityCell
- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"选择可见范围: ";
        _titleLabel.font = [UIFont themeFontLight:16];
        _titleLabel.textColor = [UIColor themeGray3];
        
    }
    return _titleLabel;
}

- (UILabel *)cityLabel {
    if(!_cityLabel) {
        _cityLabel = [UILabel new];
        _cityLabel.font = [UIFont themeFontLight:16];
        _cityLabel.textColor = [UIColor themeGray3];
    }
    return _cityLabel;
}

- (UIImageView *)rightArrow {
    if(!_rightArrow) {
        _rightArrow = [UIImageView new];
        _rightArrow.image = [UIImage imageNamed:@"fh_ugc_arrow_feed"];
    }
    return _rightArrow;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.cityLabel];
        [self.contentView addSubview:self.rightArrow];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(PADDING);
        }];
        
        [self.cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self.rightArrow.mas_left).offset(-10);
        }];
        
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self.contentView).offset(-PADDING);
        }];
    }
    return self;
}
@end

// MARK: 投票标题Cell
@implementation FHUGCVotePublishTitleCell
-(UITextField *)contentTextField {
    if(!_contentTextField) {
        _contentTextField = [UITextField new];
        _contentTextField.placeholder = @"投票标题";
        _contentTextField.textAlignment = NSTextAlignmentLeft;
        _contentTextField.font = [UIFont themeFontMedium:20];
        _contentTextField.textColor = [UIColor themeBlack];
    }
    return _contentTextField;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.contentTextField];
        
        [self.contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(PADDING);
            make.top.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-PADDING);
        }];
        
        @weakify(self);
        [[[[[self.contentTextField rac_textSignal] distinctUntilChanged] throttle:0.5] deliverOnMainThread] subscribeNext:^(NSString * _Nullable text) {
            @strongify(self);
            if([self.delegate respondsToSelector:@selector(voteTitleCell:didInputText:)]) {
                [self.delegate voteTitleCell:self didInputText:text];
            }
        }];
        
    }
    return self;
}
@end
// MARK: 投票描述Cell
@implementation FHUGCVotePublishDescriptionCell
-(UITextField *)contentTextField {
    if(!_contentTextField) {
        _contentTextField = [UITextField new];
        _contentTextField.placeholder = @"补充描述(选填)";
        _contentTextField.textAlignment = NSTextAlignmentLeft;
        _contentTextField.font = [UIFont themeFontMedium:18];
        _contentTextField.textColor = [UIColor themeBlack];
    }
    return _contentTextField;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.contentTextField];
        
        [self.contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(PADDING);
            make.right.equalTo(self.contentView).offset(-PADDING);
        }];
        
        @weakify(self);
        [[[[[self.contentTextField rac_textSignal] distinctUntilChanged] throttle:0.5] deliverOnMainThread] subscribeNext:^(NSString * _Nullable text) {
            @strongify(self);
            if([self.delegate respondsToSelector:@selector(descriptionCell:didInputText:)]) {
                [self.delegate descriptionCell:self didInputText:text];
            }
        }];
    }
    return self;
}
@end

// MARK: 投票选项Cell
@implementation FHUGCVotePublishOptionCell


-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.optionTextField.text = @"";
}

- (UIImageView *)deleteImageView {
    if(!_deleteImageView) {
        _deleteImageView = [UIImageView new];
        _deleteImageView.userInteractionEnabled = YES;
        _deleteImageView.backgroundColor = [UIColor themeRed2];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteOptionAction:)];
        [_deleteImageView addGestureRecognizer:tap];
    }
    return _deleteImageView;
}

- (UITextField *)optionTextField {
    if(!_optionTextField) {
        _optionTextField = [UITextField new];
        _optionTextField.placeholder = @"选填";
        _optionTextField.textAlignment = NSTextAlignmentLeft;
        _optionTextField.font = [UIFont themeFontLight:16];
        _optionTextField.textColor = [UIColor themeBlack];
    }
    return _optionTextField;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.deleteImageView];
        [self.contentView addSubview:self.optionTextField];
        
        
        [self.deleteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_offset(50);
            make.left.equalTo(self.contentView).offset(PADDING);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.optionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.deleteImageView.mas_right).offset(5);
            make.top.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-PADDING);
        }];
        
        @weakify(self);
        [[[[[self.optionTextField rac_textSignal] distinctUntilChanged] throttle:0.5] deliverOnMainThread] subscribeNext:^(NSString * _Nullable text) {
            @strongify(self);
            if([self.delegate respondsToSelector:@selector(optionCell:didInputText:)]) {
                [self.delegate optionCell:self didInputText:text];
            }
        }];
    }
    return self;
}

- (void)deleteOptionAction: (UITapGestureRecognizer *)tap {
    if([self.delegate respondsToSelector:@selector(deleteOptionCell:)]) {
        [self.delegate deleteOptionCell:self];
    }
}
@end

// MARK: 投票类型Cell
@interface FHUGCVotePublishVoteTypeCell()
@property (nonatomic, strong) NSArray<NSString *> *types;

@end
@implementation FHUGCVotePublishVoteTypeCell

- (NSArray<NSString *> *)types {
    if(!_types) {
        _types = [NSArray arrayWithArray:@[@"单选", @"多选"]];
    }
    return _types;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontLight:16];
        _titleLabel.textColor = [UIColor themeBlack];
        _titleLabel.text = @"投票类型";
    }
    return _titleLabel;
}

- (UILabel *)typeLabel {
    if(!_typeLabel) {
        _typeLabel = [UILabel new];
        _typeLabel.text = self.types.firstObject;
    }
    return _typeLabel;
}

- (UIPickerView *)pickerView {
    if(!_pickerView) {
        _pickerView = [UIPickerView new];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.hidden = YES;
    }
    return _pickerView;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.pickerView];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(PADDING);
            make.right.equalTo(self.typeLabel.mas_left).offset(-10);
            make.height.mas_equalTo(CELL_HEIGHT);
        }];
        
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.titleLabel);
            make.right.equalTo(self.contentView).offset(-PADDING);
            
        }];
        
        [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(VOTE_TYPE_PICKTER_VIEW_HEIGHT);
        }];
    }
    return self;
}
-(void)toggleTypePicker {
    self.pickerView.hidden = !self.pickerView.hidden;
    [self.pickerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.pickerView.hidden ? 0 : VOTE_TYPE_PICKTER_VIEW_HEIGHT);
    }];
    
    if([self.delegate respondsToSelector:@selector(voteTypeCell:toggleTypeStatus:)]) {
        [self.delegate voteTypeCell:self toggleTypeStatus:self.pickerView.hidden];
    }
}

// MARK: UIPickerViewDelegate

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return SCREEN_WIDTH;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *typeLabel = [UILabel new];
    typeLabel.font = [UIFont themeFontLight:18];
    typeLabel.textColor = [UIColor themeBlack];
    typeLabel.text = self.types[row];
    typeLabel.textAlignment = NSTextAlignmentCenter;
    
    return typeLabel;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.typeLabel.text = self.types[row];
    if([self.delegate respondsToSelector:@selector(voteTypeCell:didSelectedType:)]) {
        [self.delegate voteTypeCell:self didSelectedType:(VoteType)row];
    }
}

// MARK: UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}


@end



// MARK: 投票日期选择Cell
@interface FHUGCVotePublishDatePickCell()
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@end

@implementation FHUGCVotePublishDatePickCell

- (NSDateFormatter *)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm";
    }
    return _dateFormatter;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontLight:16];
        _titleLabel.textColor = [UIColor themeBlack];
        _titleLabel.text = @"截止日期";
    }
    return _titleLabel;
}

-(UILabel *)dateLabel {
    if(!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.font = [UIFont themeFontLight:16];
        _dateLabel.textColor = [UIColor themeBlack];
        _dateLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    }
    return _dateLabel;
}

- (UIDatePicker *)datePicker {
    if(!_datePicker) {
        _datePicker = [UIDatePicker new];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.hidden = YES;
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (void)setDelegate:(id<FHUGCVotePublishBaseCellDelegate>)delegate {
    super.delegate = delegate;
    if([self.delegate respondsToSelector:@selector(datePickerCell:didSelectedDate:)]) {
        [self.delegate datePickerCell:self didSelectedDate:self.datePicker.date];
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.datePicker];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(PADDING);
            make.right.equalTo(self.dateLabel.mas_left).offset(-PADDING);
            make.height.mas_equalTo(CELL_HEIGHT);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.titleLabel);
            make.right.equalTo(self.contentView).offset(-PADDING);
        }];
        
        [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom);
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)dateChanged:(UIDatePicker *)datePicker {
    self.dateLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
    if([self.delegate respondsToSelector:@selector(datePickerCell:didSelectedDate:)]) {
        [self.delegate datePickerCell:self didSelectedDate:datePicker.date];
    }
}

- (void)toggleDatePicker {
    
    self.datePicker.hidden = !self.datePicker.hidden;
    [self.datePicker mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.datePicker.hidden ? 0 : DATEPICKER_HEIGHT);
    }];
    
    if([self.delegate respondsToSelector:@selector(datePickerCell:toggleWithStatus:)]) {
        [self.delegate datePickerCell:self toggleWithStatus:self.datePicker.hidden];
    }
}
@end


