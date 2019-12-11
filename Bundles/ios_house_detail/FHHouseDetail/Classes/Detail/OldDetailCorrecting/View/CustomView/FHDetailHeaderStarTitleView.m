//
//  FHDetailHeaderStarTitleView.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/19.
//

#import "FHDetailHeaderStarTitleView.h"
#import "FHDetailStarsCountView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry.h>
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
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).mas_offset(AdaptOffset(16));
        make.top.mas_equalTo(AdaptOffset(10));
        make.centerY.equalTo(self.bgView);
    }];
    [self.starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(AdaptOffset(4));
        make.centerY.mas_equalTo(self.titleLabel).mas_offset(AdaptOffset(-1));
    }];
    [self.starNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.starImageView.mas_right).offset(4);
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

- (UIImageView *)starImageView
{
    if (!_starImageView) {
        _starImageView = [[UIImageView alloc]init];
        UIImage *img = ICON_FONT_IMG(18, @"\U0000e6b2", [UIColor colorWithHexStr:@"#ffa227"]);
        _starImageView.image = img;
    }
    return _starImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (UILabel *)starNumLabel {
    if (!_starNumLabel) {
        _starNumLabel = [[UILabel alloc]init];
        _starNumLabel.font = [UIFont themeFontMedium:18];
        _starNumLabel.textColor = [UIColor colorWithHexStr:@"#ffb365"];
    }
    return _starNumLabel;
}

@end
