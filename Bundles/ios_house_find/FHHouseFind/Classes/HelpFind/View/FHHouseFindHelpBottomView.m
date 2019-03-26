//
//  FHHouseFindHelpBottomView.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/26.
//

#import "FHHouseFindHelpBottomView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry.h>

@interface FHHouseFindHelpBottomView ()

@property(nonatomic, strong)UIButton *resetBtn;
@property(nonatomic, strong)UIButton *confirmBtn;

@end

@implementation FHHouseFindHelpBottomView

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
    [self addSubview:self.resetBtn];
    [self addSubview:self.confirmBtn];
    [self.resetBtn addTarget:self action:@selector(resetBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmBtn addTarget:self action:@selector(confirmBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(40);
    }];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.resetBtn.mas_right).mas_offset(20);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(40);
        make.right.mas_equalTo(-20);
        make.width.mas_equalTo(self.resetBtn);
    }];
}

- (void)resetBtnDidClick
{
    if (self.resetBlock) {
        self.resetBlock();
    }
}

- (void)confirmBtnDidClick
{
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

- (UIButton *)resetBtn
{
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc]init];
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [_resetBtn setTitle:@"重置" forState:UIControlStateHighlighted];
        [_resetBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [_resetBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateHighlighted];
        _resetBtn.backgroundColor = [UIColor themeGray7];
        _resetBtn.layer.cornerRadius = 4;
    }
    return _resetBtn;
}

- (UIButton *)confirmBtn
{
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc]init];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateHighlighted];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _confirmBtn.backgroundColor = [UIColor themeRed1];
        _confirmBtn.layer.cornerRadius = 4;
    }
    return _confirmBtn;
}

@end
