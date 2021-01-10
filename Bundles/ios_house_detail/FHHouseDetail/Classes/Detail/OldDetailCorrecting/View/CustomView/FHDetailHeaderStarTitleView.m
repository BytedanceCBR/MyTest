//
//  FHDetailHeaderStarTitleView.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/19.
//

#import "FHDetailHeaderStarTitleView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "Masonry.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUIAdaptation.h"

@interface FHDetailHeaderStarTitleView ()

@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) UIImageView *starImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *starNumLabel;

@end

@implementation FHDetailHeaderStarTitleView

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
    [self.bgView addSubview:self.starImageView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.starNumLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    // 标题
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.bgView).offset(12);
        make.bottom.equalTo(self.bgView).offset(-12);
    }];
    // 星标图标
    [self.starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(AdaptOffset(4));
        make.centerY.mas_equalTo(self.titleLabel).mas_offset(AdaptOffset(-1));
    }];
    // 分数
    [self.starNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.starImageView.mas_right).offset(3);
        make.centerY.mas_equalTo(self.titleLabel);
    }];
}


- (void)updateStarsCount:(NSInteger)scoreValue
{
    if (scoreValue > 0) {
        self.starNumLabel.text = [NSString stringWithFormat:@"%.1f",(float)scoreValue/10];
    }else {
        self.starNumLabel.text  = @"";
    }
}

- (void)hiddenStarImage {
    self.starImageView.hidden = YES;
}
- (void)hiddenStarNum {
    self.starNumLabel.hidden = YES;
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
    }
    return _bgView;
}

- (UIImageView *)starImageView
{
    if (!_starImageView) {
        _starImageView = [[UIImageView alloc]init];
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e6b2", [UIColor colorWithHexStr:@"#ffa227"]);
        _starImageView.image = img;
    }
    return _starImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontMedium:16];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (UILabel *)starNumLabel {
    if (!_starNumLabel) {
        _starNumLabel = [[UILabel alloc]init];
        _starNumLabel.font = [UIFont themeFontDINAlternateBold:16];
        _starNumLabel.textColor = [UIColor colorWithHexStr:@"#ffb365"];
    }
    return _starNumLabel;
}

@end
