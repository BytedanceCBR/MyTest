//
//  FHMapNaviBarView.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/1/31.
//

#import "FHDetailMapPageNaviBarView.h"
#import "FHExtendHotAreaButton.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "FHExtendHotAreaButton.h"
#import "TTDeviceHelper.h"
#import "UIImage+FIconFont.h"

@interface FHDetailMapPageNaviBarView ()

@property(nonatomic,strong) FHExtendHotAreaButton *backBtn;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *rightBtn;
@property(nonatomic,strong) UIView *seperatorLine;


@end

@implementation FHDetailMapPageNaviBarView


-(instancetype)init {
    if(self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    // backBtn
    
    CGFloat iphoneXPading = 5;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        iphoneXPading = 0;
    }
    
    _backBtn = [[FHExtendHotAreaButton alloc] init];
    UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
    [_backBtn setImage:blackBackArrowImage forState:UIControlStateNormal];
    [_backBtn setImage:blackBackArrowImage forState:UIControlStateHighlighted];
    [self addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(24);
        make.left.mas_equalTo(self).offset(18);
        make.bottom.mas_equalTo(self).offset(-16 + iphoneXPading);
    }];
    
    [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setTitle:@"导航" forState:UIControlStateNormal];
    [_rightBtn.titleLabel setFont:[UIFont themeFontRegular:16]];
    [_rightBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
    [self addSubview:_rightBtn];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(36);
        make.right.mas_equalTo(self).offset(-12);
        make.bottom.mas_equalTo(self).offset(-12 + iphoneXPading);
    }];
    [_rightBtn addTarget:self action:@selector(naviMapBtnClick) forControlEvents:UIControlEventTouchUpInside];

    
    _titleLabel = [UILabel new];
    _titleLabel.text = @"位置及周边";
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.backBtn);
        make.height.mas_equalTo(28);
        make.width.mas_equalTo(100);
    }];
    
    
    _seperatorLine = [[UIView alloc] init];
    _seperatorLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:_seperatorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)backBtnClick
{
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (void)naviMapBtnClick
{
    if (self.naviMapActionBlock) {
        self.naviMapActionBlock();
    }
}
@end
