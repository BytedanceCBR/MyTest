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
#import <BDWebImage.h>

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
        make.right.mas_equalTo(self.leftView);
    }];

    [self addSubview:self.contactBtn];
    [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(self.leftView.mas_right).offset(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(44);
    }];
    [self.contactBtn addTarget:self action:@selector(contactBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.licenceIcon addTarget:self action:@selector(licenseBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.leftView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jump2RealtorDetail)];
    [self.leftView addGestureRecognizer:tap];
}

- (void)contactBtnDidClick:(UIButton *)btn
{
    if (self.bottomBarContactBlock) {
        self.bottomBarContactBlock();
    }
}

- (void)licenseBtnDidClick:(UIButton *)btn
{
    if (self.bottomBarLicenseBlock) {
        self.bottomBarLicenseBlock();
    }
}

- (void)jump2RealtorDetail
{
    if (self.bottomBarRealtorBlock) {
        self.bottomBarRealtorBlock();
    }
}

- (void)displayLicense:(BOOL)isDisplay
{
    self.licenceIcon.hidden = !isDisplay;
    if (isDisplay) {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(10);
            make.top.mas_equalTo(self.avatarView).offset(2);
            make.right.mas_equalTo(self.licenceIcon.mas_left).mas_offset(-4);
        }];
    } else {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(10);
            make.top.mas_equalTo(self.avatarView).offset(2);
            make.right.mas_equalTo(self);
        }];
    }
}

- (void)refreshBottomBar:(FHDetailContactModel *)contactPhone contactTitle:(NSString *)contactTitle
{
    [self.contactBtn setTitle:contactTitle forState:UIControlStateNormal];
    [self.contactBtn setTitle:contactTitle forState:UIControlStateHighlighted];

    self.leftView.hidden = contactPhone.showRealtorinfo == 1 ? NO : YES;
    CGFloat leftWidth = contactPhone.showRealtorinfo == 1 ? 160 : 0;
    [self.avatarView bd_setImageWithURL:[NSURL URLWithString:contactPhone.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
    if (contactPhone.realtorName.length > 0) {
        if (contactPhone.realtorName.length > 4) {
            NSString *realtorName = [NSString stringWithFormat:@"%@...",[contactPhone.realtorName substringToIndex:4]];
            self.nameLabel.text = realtorName;
        }else {
            self.nameLabel.text = contactPhone.realtorName;
        }
    }else {
        self.nameLabel.text = @"经纪人";
    }
    if (contactPhone.agencyName.length > 0) {
        self.agencyLabel.text = contactPhone.agencyName;
        self.agencyLabel.hidden = NO;
    }else {
        self.agencyLabel.hidden = YES;
    }
    NSMutableArray *licenseViews = @[].mutableCopy;
    if (contactPhone.businessLicense.length > 0 || contactPhone.certificate.length > 0) {
        [self displayLicense:YES];
    }else {
        [self displayLicense:NO];
    }
    [self.leftView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(leftWidth);
    }];
}

- (void)startLoading
{
    [self.contactBtn startLoading];
}

- (void)stopLoading
{
    [self.contactBtn stopLoading];
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
        _nameLabel.textColor = [UIColor themeGray1];
    }
    return _nameLabel;
}

- (UILabel *)agencyLabel
{
    if (!_agencyLabel) {
        _agencyLabel = [[UILabel alloc]init];
        _agencyLabel.font = [UIFont themeFontRegular:12];
        _agencyLabel.textColor = [UIColor themeGray1];
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


