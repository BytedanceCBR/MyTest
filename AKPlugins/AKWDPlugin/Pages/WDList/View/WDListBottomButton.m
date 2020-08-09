//
//  WDListBottomButton.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/14.
//

#import "WDListBottomButton.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "UIImage+FIconFont.h"

@interface WDListBottomButton()

@property(nonatomic ,strong) UIView *sepLine;
@property (nonatomic, strong)   WDListBottomButtonView       *buttonView;
@property (nonatomic, strong) UIButton *writeBtn;

@end

@implementation WDListBottomButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    self.sepLine = [[UIView alloc] init];
    self.sepLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:self.sepLine];
//    self.buttonView = [[WDListBottomButtonView alloc] init];
//    [self addSubview:self.buttonView];
//    self.buttonView.userInteractionEnabled = NO;
    self.writeBtn.userInteractionEnabled = NO;
    [self addSubview:self.writeBtn];
    [self setupConstraints];
}

- (UIButton *)writeBtn {
    if (!_writeBtn) {
        _writeBtn = [[UIButton alloc]init];
        _writeBtn.backgroundColor = [UIColor themeOrange4];
        [_writeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_writeBtn setTitle:@"写回答" forState:UIControlStateNormal];
        _writeBtn.titleLabel.font = [UIFont themeFontRegular:16];
        _writeBtn.layer.cornerRadius = 20;
        _writeBtn.layer.masksToBounds = YES;
    }
    return _writeBtn;
}

- (void)setupConstraints {
    [self.sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
//    [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self);
//        make.top.mas_equalTo(self).offset(1);
//        make.height.mas_equalTo(48);
//    }];
    [self.writeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
                make.top.mas_equalTo(self).offset(10);
                make.height.mas_equalTo(40);
    }];
}

@end

@interface WDListBottomButtonView ()

@property (nonatomic, strong)   UIImageView       *iconImageView;
@property (nonatomic, strong)   UILabel       *titleLabel;

@end

@implementation WDListBottomButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
//    self.backgroundColor = [UIColor red]
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.image = ICON_FONT_IMG(24, @"\U0000e6b3", [UIColor themeOrange1]);
    [self addSubview:_iconImageView];
    self.titleLabel = [self labelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeOrange1]];
    [self addSubview:_titleLabel];
    self.titleLabel.text = @"写回答";
    self.titleLabel.font = [UIFont themeFontRegular:16];
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.width.height.mas_equalTo(24);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(5);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(self);
    }];
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
