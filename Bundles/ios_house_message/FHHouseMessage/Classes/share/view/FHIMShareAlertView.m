//
//  FHIMShareAlertView.m
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import "FHIMShareAlertView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTUIResponderHelper.h"
#import "TTDeviceHelper.h"
#import "FHIMHouseShareView.h"
#import <FHHouseBase/TTDeviceHelper+FHHouse.h>

@interface FHIMShareAlertView ()
@property (nonatomic , strong) UIView *bgView;
@property (nonatomic, strong) UIView* contentView;
@end

@implementation FHIMShareAlertView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
    [self addSubview:_bgView];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];

    self.contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 6;
    _contentView.clipsToBounds = YES;

    [self addSubview:_contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(295 * [[self class] scaleToScreen375]);
    }];

    self.bgView.alpha = 0;
    self.contentView.alpha = 0;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    self.bgView.userInteractionEnabled = YES;
    [self.bgView addGestureRecognizer:tap];

    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontSemibold:16];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.text = @"发送给:";
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(32);
    }];

    self.avator = [[UIImageView alloc] init];
    _avator.layer.masksToBounds = YES;
    _avator.layer.cornerRadius = 22;
    _avator.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_avator];
    [_avator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(44);
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(6);
    }];

    self.name = [[UILabel alloc] init];
    _name.font = [UIFont themeFontMedium:16];
    _name.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_name];
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avator.mas_right).mas_offset(10);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.avator);
    }];

    UIView* seperateLine = [[UIView alloc] init];
    seperateLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:seperateLine];
    [seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(0.5);
        make.left.mas_offset(20);
        make.right.mas_offset(-20);
        make.top.mas_equalTo(self.avator.mas_bottom).mas_equalTo(15);
    }];

    self.houseView = [[FHIMHouseShareView alloc] init];
    [self.contentView addSubview:_houseView];
    [_houseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(seperateLine.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(100);
    }];

    self.doneBtn = [[UIButton alloc] init];
    [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    _doneBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [_doneBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_doneBtn setTitle:@"发送" forState:UIControlStateHighlighted];
    _doneBtn.layer.cornerRadius = 4;
    _doneBtn.backgroundColor = [UIColor themeOrange4];//RGBA(0xff, 0x58, 0x69, 1);
    [self.contentView addSubview:_doneBtn];
    [_doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.houseView.mas_bottom);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
    }];

    self.closeBtn = [[UIButton alloc] init];

    [self.contentView addSubview:_closeBtn];
    [_closeBtn setImage:[UIImage imageNamed:@"detail_alert_closed"] forState:UIControlStateNormal];
    [_closeBtn setImage:[UIImage imageNamed:@"detail_alert_closed"] forState:UIControlStateHighlighted];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.mas_equalTo(self.contentView).mas_offset(-5);
        make.top.mas_equalTo(self.contentView).mas_offset(5);
    }];

    [self.closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

    [self.doneBtn addTarget:self action:@selector(onClickDone:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)showFrom:(UIView *)parentView
{
    if (!parentView) {
        parentView = [TTUIResponderHelper topmostViewController].view;
    }
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(parentView);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.alpha = 1;
        self.contentView.alpha = 1;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.alpha = 0;
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    [_delegate onCancel];
    _delegate = nil;
}

-(void)onClickDone:(id)sender {
    [_delegate onClickDone];
    _delegate = nil;
    [self dismiss];
}

+ (CGFloat)scaleToScreen375
{
    return [UIScreen mainScreen].bounds.size.width / 375.0f;
}

@end
