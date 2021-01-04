//
//  FHFindHouseAreaSelectionCell.m
//  FHHouseFind
//
//  Created by wangxinyu on 2021/1/4.
//

#import "FHFindHouseAreaSelectionCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@implementation FHFindHouseAreaSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setFont:[UIFont themeFontRegular:14]];
    [_nameLabel setTextColor:HEXRGBA(@"333333")];
    _nameLabel.numberOfLines = 3;
    [self.contentView addSubview:_nameLabel];

    _checkboxBtn = [[UIButton alloc] init];
    //透传点击事件到tableview的delegate,修复筛选模块点击按钮无响应的问题
    _checkboxBtn.userInteractionEnabled = NO;
    [self.contentView addSubview:_checkboxBtn];
    [_checkboxBtn setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
    [_checkboxBtn setBackgroundImage:[UIImage imageNamed:@"checkbox-checked"] forState:UIControlStateSelected];
    [_checkboxBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self->_nameLabel);
        make.width.height.mas_equalTo(14);
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(-10);
        make.right.mas_lessThanOrEqualTo(self->_checkboxBtn.mas_left).mas_offset(-3);
    }];

    _redDot = [[UIView alloc] init];
    _redDot.layer.cornerRadius = 2.5;
    _redDot.backgroundColor = HEXRGBA(@"fe5500");
    [self.contentView addSubview:_redDot];
    [_redDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self->_nameLabel).mas_offset(4);
        make.left.mas_equalTo(self->_nameLabel.mas_right).offset(1);
        make.height.width.mas_equalTo(5);
    }];

}

-(void)showCheckbox:(BOOL)showCheckBox {
    [_checkboxBtn setHidden:!showCheckBox];
    [_checkboxBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        if (showCheckBox) {
            make.right.mas_equalTo(-15);
        } else {
            make.right.mas_equalTo(0);
        }
    }];
}

-(void)setCellSelected:(BOOL)isSelected {
    [_checkboxBtn setSelected:isSelected];
    if (isSelected) {
        _nameLabel.textColor = HEXRGBA(@"fe5500");
    } else {
        _nameLabel.textColor = HEXRGBA(@"333333");
    }
}

@end
