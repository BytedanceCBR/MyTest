//
//  FHSuggestionItemCell.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/23.
//

#import "FHSuggestionItemCell.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHSuggestionListNavBar.h"
#import "FHExtendHotAreaButton.h"

@interface FHSuggestionItemCell ()

@end

@implementation FHSuggestionItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.font = [UIFont themeFontRegular:15];
    _label.textColor = [UIColor themeBlue1];
    _label.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(21);
        make.bottom.mas_equalTo(self.contentView);
    }];
    // secondaryLabel
    _secondaryLabel = [[UILabel alloc] init];
    _secondaryLabel.font = [UIFont themeFontRegular:13];
    _secondaryLabel.textColor = [UIColor themeGray4];
    _secondaryLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_secondaryLabel];
    [_secondaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.label.mas_right).offset(6);
        make.centerY.mas_equalTo(self.label);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_greaterThanOrEqualTo(63);
    }];
    [_secondaryLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_secondaryLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

@end

// --
@interface FHSuggestionNewHouseItemCell ()

@property (nonatomic, strong)   UIView       *sepLine;

@end

@implementation FHSuggestionNewHouseItemCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.font = [UIFont themeFontRegular:15];
    _label.textColor = [UIColor themeBlue1];
    _label.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(11);
        make.width.mas_greaterThanOrEqualTo(250);
    }];
    // secondaryLabel
    _secondaryLabel = [[UILabel alloc] init];
    _secondaryLabel.font = [UIFont themeFontRegular:13];
    _secondaryLabel.textColor = [UIColor themeGray4];
    _secondaryLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_secondaryLabel];
    [_secondaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.label.mas_right).offset(5);
        make.top.mas_equalTo(12);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_greaterThanOrEqualTo(63).priorityHigh();
    }];
    [_secondaryLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_secondaryLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    // subLabel
    _subLabel = [[UILabel alloc] init];
    _subLabel.font = [UIFont themeFontRegular:12];
    _subLabel.textColor = [UIColor themeGray4];
    _subLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_subLabel];
    [_subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.label.mas_bottom).offset(6);
        make.height.mas_equalTo(17);
        make.bottom.mas_equalTo(-13);
    }];
    
    [_subLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_subLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    // _secondarySubLabel
    _secondarySubLabel = [[UILabel alloc] init];
    _secondarySubLabel.font = [UIFont themeFontRegular:13];
    _secondarySubLabel.textColor = [UIColor themeGray4];
    _secondarySubLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_secondarySubLabel];
    [_secondarySubLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.subLabel.mas_right).offset(5);
        make.centerY.mas_equalTo(self.subLabel);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    
    // sepLine
    _sepLine = [[UIView alloc] init];
    _sepLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_sepLine];
    CGFloat lineH = UIScreen.mainScreen.scale > 2.5 ? 0.35 : 0.5;
    [_sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(lineH);
    }];
}

@end

// --

@implementation FHSuggestHeaderViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.text = @"历史记录";
    _label.font = [UIFont themeFontMedium:14];
    _label.textColor = [UIColor themeBlue1];
    [self.contentView addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self.contentView);
    }];
    // deleteBtn
    _deleteBtn = [[FHExtendHotAreaButton alloc] init];
    [_deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.label);
    }];
    [_deleteBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick:(UIButton *)btn {
    if (self.delClick) {
        self.delClick();
    }
}

@end

// --

@implementation FHSuggectionTableView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.handleTouch) {
        self.handleTouch();
    }
}

@end
