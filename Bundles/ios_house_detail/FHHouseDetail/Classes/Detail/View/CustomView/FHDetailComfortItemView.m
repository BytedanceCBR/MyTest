//
//  FHDetailComfortItemView.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/21.
//

#import "FHDetailComfortItemView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "Masonry.h"
#import <TTBaseLib/TTDeviceHelper.h>

@implementation FHDetailComfortItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.icon];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
    CGFloat leftMargin = 20;
    if (![TTDeviceHelper isScreenWidthLarge320]) {
        leftMargin = 15;
    }
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftMargin);
        make.top.mas_equalTo(20);
        make.top.mas_equalTo(0);
        make.width.height.mas_equalTo(20);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon);
        make.top.mas_equalTo(self.icon.mas_bottom).mas_offset(4);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(0);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(1);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (UIImageView *)icon
{
    if (!_icon) {
        _icon = [[UIImageView alloc]init];
    }
    return _icon;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 14 : 13;
        _titleLabel.font = [UIFont themeFontMedium:fontSize];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 12 : 11;
        _subtitleLabel.font = [UIFont themeFontRegular:fontSize];
        _subtitleLabel.textColor = [UIColor themeGray3];
    }
    return _subtitleLabel;
}

@end
