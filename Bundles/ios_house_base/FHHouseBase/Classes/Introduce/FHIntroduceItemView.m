//
//  FHIntroduceItemView.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import "FHIntroduceItemView.h"
#import <Masonry.h>
#import <UIColor+Theme.h>
#import <UIFont+House.h>

@interface FHIntroduceItemView ()

@property (nonatomic , strong) FHIntroduceItemModel *model;
@property (nonatomic , strong) UILabel *titleLabel;
@property (nonatomic , strong) UILabel *subTitleLabel;
@property (nonatomic , strong) UIButton *jumpBtn;
@property (nonatomic , strong) UIButton *enterBtn;

@end

@implementation FHIntroduceItemView

- (instancetype)initWithFrame:(CGRect)frame model:(FHIntroduceItemModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        [self initView];
        [self initConstraints];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontSemibold:28] textColor:[UIColor themeGray1]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = self.model.title;
    [self addSubview:_titleLabel];
    
    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:18] textColor:[UIColor themeGray1]];
    _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    _subTitleLabel.text = self.model.subTitle;
    [self addSubview:_subTitleLabel];
    
    self.jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_jumpBtn setImage:[UIImage imageNamed:@"fh_introduce_jump"] forState:UIControlStateNormal];
    [_jumpBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    _jumpBtn.hidden = !self.model.showJumpBtn;
    [self addSubview:_jumpBtn];
    
    self.enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_enterBtn setImage:[UIImage imageNamed:@"fh_introduce_enter"] forState:UIControlStateNormal];
    [_enterBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    _enterBtn.hidden = !self.model.showEnterBtn;
    [self addSubview:_enterBtn];
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(56);
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.height.mas_equalTo(40);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.height.mas_equalTo(25);
    }];
    
    [self.jumpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(32);
    }];
    
    [self.enterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-14);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(260);
        make.height.mas_equalTo(64);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)close {
    if(self.delegate && [self.delegate respondsToSelector:@selector(close)]){
        [self.delegate close];
    }
}

@end
