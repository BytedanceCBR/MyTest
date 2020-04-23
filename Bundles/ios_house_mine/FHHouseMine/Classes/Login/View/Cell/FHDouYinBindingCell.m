//
//  FHDouYinBindingCell.m
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import "FHDouYinBindingCell.h"
#import "TTAccountManager.h"
#import "AccountManager.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "Masonry.h"

@interface FHDouYinBindingCell()

@property (nonatomic, strong) UISwitch *switchButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation FHDouYinBindingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.switchButton];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(self.contentView);
    }];
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(50);
    }];
}

- (void)refreshSwitch{
    if (_delegate && [self.delegate respondsToSelector:@selector(hasDouYinAccount)]) {
        _switchButton.on = [_delegate hasDouYinAccount];
    }
    
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = @"抖音";
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeBlack];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UISwitch *)switchButton {
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        _switchButton.onTintColor = [UIColor themeOrange4];
        [_switchButton addTarget:self action:@selector(accountSwitchButtonDidTap:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _switchButton;
}

- (void)accountSwitchButtonDidTap:(UISwitch *)sender {
    NSArray<TTAccountPlatformEntity *> *connects = [[TTAccount sharedAccount] user].connects;
    NSLog(@"%ld,luowentao",[connects count]);
    NSLog(@"%@,luowentao",[connects firstObject].userID);
    NSLog(@"%@,luowentao",[connects firstObject].platformUID);
    NSLog(@"%@,luowentao",[connects firstObject].platform);
    NSLog(@"%@,luowentao",[connects firstObject].platformScreenName);
    NSLog(@"%@,luowentao",[connects firstObject].expiredTime);
    
    if (_delegate && [self.delegate respondsToSelector:@selector(transformDouYinAccount:)]) {
        [_delegate transformDouYinAccount:sender.isOn];
    }
}

@end
