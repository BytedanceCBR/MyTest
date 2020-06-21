//
//  FHDetailStarHeaderView.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/19.
//

#import "FHDetailStarHeaderView.h"
#import "FHDetailStarsCountView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "Masonry.h"

@interface FHDetailStarHeaderView ()

@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) FHDetailStarsCountView *starView;

@end

@implementation FHDetailStarHeaderView

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
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.icon];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.starView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).mas_offset(2);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(26);
    }];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.titleLabel);
    }];
    [self.starView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.width.mas_equalTo(110);
        make.right.mas_equalTo(-20);
    }];
}

- (void)updateStarsCount:(NSInteger)scoreValue
{
    if (scoreValue > 0) {
        [self.starView updateStarsCountWithoutLabel:scoreValue];
        self.starView.hidden = NO;
    }else {
        [self.starView updateStarsCountWithoutLabel:0];
        self.starView.hidden = YES;
    }
}

- (void)updateTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.userInteractionEnabled = NO;
//        _bgView.backgroundColor = [UIColor colorWithHexString:@"#fff2ed" alpha:0.3];
    }
    return _bgView;
}

- (UIImageView *)icon
{
    if (!_icon) {
        _icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"detail_header_icon"]];
    }
    return _icon;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (FHDetailStarsCountView *)starView
{
    if (!_starView) {
        _starView = [[FHDetailStarsCountView alloc]init];
    }
    return _starView;
}

@end
