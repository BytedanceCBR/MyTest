//
//  FHHouseListRedirectTipView.m
//  Pods
//
//  Created by 张静 on 2019/1/9.
//

#import "FHHouseListRedirectTipView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"

@interface FHHouseListRedirectTipView ()

@property(nonatomic,strong)UIButton *closeBtn;
@property(nonatomic,strong)UILabel *leftLabel;
@property(nonatomic,strong)UIButton *rightBtn;

@end

@implementation FHHouseListRedirectTipView

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
    self.backgroundColor = [UIColor themeRed2];
    [self addSubview:self.closeBtn];
    [self addSubview:self.leftLabel];
    [self addSubview:self.rightBtn];
    self.closeBtn.hidden = YES;
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(16);
    }];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.closeBtn.mas_right).mas_offset(10);
        make.right.mas_equalTo(self.rightBtn.mas_left).mas_offset(-5);
    }];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-20);
        make.centerY.mas_equalTo(self);
    }];
    [self.rightBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.closeBtn addTarget:self action:@selector(closeBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightBtn addTarget:self action:@selector(rightBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setText:(NSString *)text
{
    self.leftLabel.text = text;
    [self setNeedsLayout];
}

- (void)setText1:(NSString *)text1
{
    [self.rightBtn setTitle:text1 forState:UIControlStateNormal];
    [self.rightBtn setTitle:text1 forState:UIControlStateHighlighted];
    [self setNeedsLayout];
}

-(void)setHidden:(BOOL)hidden {
    
    [super setHidden:hidden];
    self.closeBtn.hidden = hidden;
}

- (void)closeBtnDidClick:(UIButton *)btn
{
    if (self.clickCloseBlock) {
        self.clickCloseBlock();
    }
}

- (void)rightBtnDidClick:(UIButton *)btn
{
    if (self.clickRightBlock) {
        self.clickRightBlock();
    }
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc]init];
        [_closeBtn setImage:[UIImage imageNamed:@"house_list_close_blue"] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:@"house_list_close_blue"] forState:UIControlStateHighlighted];
    }
    return _closeBtn;
}

- (UILabel *)leftLabel
{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc]init];
        _leftLabel.textColor = [UIColor themeGray3];
        _leftLabel.font = [UIFont themeFontRegular:14];
    }
    return _leftLabel;
}

- (UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc]init];
        [_rightBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateHighlighted];
        _rightBtn.titleLabel.font = [UIFont themeFontRegular:14];
    }
    return _rightBtn;
}

@end
