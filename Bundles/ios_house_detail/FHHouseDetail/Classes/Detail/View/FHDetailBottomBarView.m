//
//  FHDetailBottomBarView.m
//  Pods
//
//  Created by 张静 on 2019/2/12.
//

#import "FHDetailBottomBarView.h"
#import "FHLoadingButton.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "Masonry.h"

@interface FHDetailBottomBarView ()

@property(nonatomic , strong) UIControl *leftView;
@property(nonatomic , strong) UIImageView *avatarView;
@property(nonatomic , strong) UILabel *nameLabel;
@property(nonatomic , strong) UILabel *agencyLabel;
@property(nonatomic , strong) FHLoadingButton *contactBtn;
@property(nonatomic , strong) UIButton *licenceIcon;

@end

@implementation FHDetailBottomBarView

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
    UIView *topLine = [[UIView alloc]init];
    topLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    [self addSubview:self.leftView];
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(0);
    }];
    
    [self.leftView addSubview:self.avatarView];
    [self.leftView addSubview:self.nameLabel];
    [self.leftView addSubview:self.agencyLabel];
    [self.leftView addSubview:self.licenceIcon];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(42);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.avatarView).offset(2);
        make.right.mas_equalTo(self.licenceIcon.mas_left);
    }];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(4);
        make.height.width.mas_equalTo(20);
        make.centerY.mas_equalTo(self.nameLabel);
        make.right.mas_lessThanOrEqualTo(self.leftView).offset(-4);
    }];
    [self.agencyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom);
        make.right.mas_equalTo(self);
    }];

    [self addSubview:self.contactBtn];
    [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(self.leftView.mas_right).offset(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(44);
    }];
}

- (void)displayLicense:(BOOL)isDisplay
{
    self.licenceIcon.hidden = !isDisplay;
    if (isDisplay) {
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(10);
            make.top.mas_equalTo(self.avatarView).offset(2);
            make.right.mas_equalTo(self.licenceIcon.mas_left);
        }];
    } else {
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(10);
            make.top.mas_equalTo(self.avatarView).offset(2);
            make.right.mas_equalTo(self);
        }];
    }
}

- (UIControl *)leftView
{
    if (!_leftView) {
        _leftView = [[UIControl alloc]init];
    }
    return _leftView;
}

- (UIImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc]init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.layer.cornerRadius = 21;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont themeFontRegular:16];
        _nameLabel.textColor = [UIColor themeBlack];
    }
    return _nameLabel;
}

- (UILabel *)agencyLabel
{
    if (!_agencyLabel) {
        _agencyLabel = [[UILabel alloc]init];
        _agencyLabel.font = [UIFont themeFontRegular:12];
        _agencyLabel.textColor = [UIColor themeGray];
    }
    return _agencyLabel;
}

- (FHLoadingButton *)contactBtn
{
    if (!_contactBtn) {
        _contactBtn = [[FHLoadingButton alloc]init];
        [_contactBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contactBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _contactBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateHighlighted];
        _contactBtn.layer.cornerRadius = 4;
        _contactBtn.backgroundColor = [UIColor colorWithHexString:@"#299cff"];
    }
    return _contactBtn;
}

- (UIButton *)licenceIcon
{
    if (!_licenceIcon) {
        _licenceIcon = [[UIButton alloc]init];
        [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateNormal];
        [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateHighlighted];
    }
    return _licenceIcon;
}

@end


