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

@implementation FHUGCVotePublishTextView
@end

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
        _contentTextField = [[UITextField alloc] initWithFrame:CGRectMake(PADDING, 23, SCREEN_WIDTH - 2 * PADDING, 32)];
        _contentTextField.placeholder = @"投票标题";
        [_contentTextField setValue:[UIColor themeGray3] forKeyPath:@"_placeholderLabel.textColor"];
        _contentTextField.font = [UIFont themeFontRegular:22];
        _contentTextField.textColor = [UIColor themeGray1];
        _contentTextField.clipsToBounds = YES;
        [_contentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _contentTextField;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.contentTextField];
    }
    return self;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if(textField.text.length > TITLE_LENGTH_LIMIT) {
        textField.text = [textField.text substringToIndex:TITLE_LENGTH_LIMIT];
    }
    
    if([self.delegate respondsToSelector:@selector(voteTitleCell:didInputText:)]) {
        [self.delegate voteTitleCell:self didInputText:textField.text];
    }

}
@end
// MARK: 投票描述Cell
@implementation FHUGCVotePublishDescriptionCell

-(UITextField *)contentTextField {
    if(!_contentTextField) {
        _contentTextField = [[UITextField alloc] initWithFrame:CGRectMake(PADDING, 20, SCREEN_WIDTH - 2 * PADDING, 33)];
        _contentTextField.placeholder = @"补充描述(选填)";
        _contentTextField.clipsToBounds = YES;
        [_contentTextField setValue:[UIColor themeGray3] forKeyPath:@"_placeholderLabel.textColor"];
        _contentTextField.textAlignment = NSTextAlignmentLeft;
        _contentTextField.font = [UIFont themeFontRegular:18];
        _contentTextField.textColor = [UIColor themeGray1];
        [_contentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _contentTextField;
}

- (void)textFieldDidChange: (UITextField *)textField {
    if(textField.text.length > DESCRIPTION_LENGTH_LIMIT) {
        textField.text = [textField.text substringToIndex:DESCRIPTION_LENGTH_LIMIT];
    }
    
    if([self.delegate respondsToSelector:@selector(descriptionCell:didInputText:)]) {
        [self.delegate descriptionCell:self didInputText:textField.text];
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.contentTextField];
    }
    return self;
}
@end

// MARK: 投票选项Cell
@implementation FHUGCVotePublishOptionCell

-(UIButton *)deleteButton {
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
        [_optionTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _optionTextField;
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if(textField.text.length > OPTION_LENGTH_LIMIT) {
        textField.text = [textField.text substringToIndex:OPTION_LENGTH_LIMIT];
    }
    
    if([self.delegate respondsToSelector:@selector(optionCell:didInputText:)]) {
        [self.delegate optionCell:self didInputText:textField.text];
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:self.optionTextField];
        
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_offset(40);
            make.left.equalTo(self.contentView).offset(PADDING - 11);
            make.centerY.equalTo(self.optionTextField);
        }];
        
        [self.optionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.deleteButton.mas_right).offset(8);
            make.top.equalTo(self.contentView).offset(24);
            make.bottom.equalTo(self.contentView).offset(-16);
            make.right.equalTo(self.contentView).offset(-PADDING);
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

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.rightArrow];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(PADDING);
            make.right.equalTo(self.typeLabel.mas_left).offset(-10);
            make.height.mas_equalTo(CELL_HEIGHT);
        }];
        
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.titleLabel);
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



// MARK: 投票日期选择Cell
@interface FHUGCVotePublishDatePickCell()
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@end

@implementation FHUGCVotePublishDatePickCell

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

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.rightArrow];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(PADDING);
            make.right.equalTo(self.dateLabel.mas_left).offset(-PADDING);
            make.height.mas_equalTo(CELL_HEIGHT);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.titleLabel);
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

