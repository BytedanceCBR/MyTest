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
#import "UIColor+Theme.h"

@interface FHDetailBottomBarView ()

@property(nonatomic , strong) UIControl *leftView;
@property(nonatomic , strong) UIImageView *avatarView;
@property(nonatomic , strong) UILabel *nameLabel;
@property(nonatomic , strong) UILabel *agencyLabel;
@property(nonatomic , strong) FHLoadingButton *contactBtn;
@property(nonatomic , strong) UIButton *licenceIcon;
@property(nonatomic , strong) UIButton *imChatBtn;
@property(nonatomic , assign) CGFloat imBtnWidth;

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
        make.width.mas_equalTo(160);
    }];
    self.leftView.hidden = YES;
    [self.leftView addSubview:self.avatarView];
    [self.leftView addSubview:self.nameLabel];
    [self.leftView addSubview:self.agencyLabel];
    [self.leftView addSubview:self.licenceIcon];
    
    CGFloat avatarLeftMargin = 20;
    if ([TTDeviceHelper is568Screen]) {
        avatarLeftMargin = 15;
    }
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(avatarLeftMargin);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(42);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(10);
        make.top.mas_equalTo(self.avatarView).offset(2);
    }];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(4);
        make.height.width.mas_equalTo(20);
        make.centerY.mas_equalTo(self.nameLabel);
        make.right.mas_lessThanOrEqualTo(self.leftView).offset(0);
    }];

    [self.agencyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom);
        make.right.mas_equalTo(self.leftView);
    }];

    _imBtnWidth = 0;
    [self addSubview:self.imChatBtn];
    [self.imChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(self.leftView.mas_right).offset(10);
        make.right.mas_equalTo(self.leftView.mas_right).offset(10 + _imBtnWidth);
        make.height.mas_equalTo(44);
    }];
    
    CGFloat btnBetween = 10;
    CGFloat btnRightMargin = -20;
    if ([TTDeviceHelper is568Screen]) {
        btnBetween = 5;
        btnRightMargin = -15;
    }
    [self addSubview:self.contactBtn];
    
    [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(self.imChatBtn.mas_right).offset(btnBetween);
        make.right.mas_equalTo(btnRightMargin);
        make.height.mas_equalTo(44);
    }];
    
    [self.contactBtn addTarget:self action:@selector(contactBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.licenceIcon addTarget:self action:@selector(licenseBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.imChatBtn addTarget:self action:@selector(imBtnClick:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)imBtnClick:(UIButton *)btn {
    if (self.bottomBarImBlock) {
        self.bottomBarImBlock();
    }
}

- (void)displayLicense:(BOOL)isDisplay
{
    self.licenceIcon.hidden = !isDisplay;
    if (isDisplay) {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(10);
            make.top.mas_equalTo(self.avatarView).offset(2);
        }];
        [self.licenceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_right).offset(4);
            make.height.width.mas_equalTo(20);
            make.centerY.mas_equalTo(self.nameLabel);
        }];
    } else {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(10);
            make.top.mas_equalTo(self.avatarView).offset(2);
            make.right.mas_equalTo(0);
        }];
    }
}

- (void)refreshBottomBar:(FHDetailContactModel *)contactPhone contactTitle:(NSString *)contactTitle chatTitle:(NSString *)chatTitle
{
    [self.contactBtn setTitle:contactTitle forState:UIControlStateNormal];
    [self.contactBtn setTitle:contactTitle forState:UIControlStateHighlighted];
    
    [self.imChatBtn setTitle:chatTitle forState:UIControlStateNormal];
    [self.imChatBtn setTitle:chatTitle forState:UIControlStateHighlighted];

    self.leftView.hidden = contactPhone.showRealtorinfo == 1 ? NO : YES;
    self.imChatBtn.hidden = !isEmptyString(contactPhone.imOpenUrl) ? NO : YES;
    
    CGFloat offset = 228;
    if ([TTDeviceHelper is568Screen]) {
        offset = 178;
    }
    
    CGFloat leftWidth = contactPhone.showRealtorinfo == 1 ? [UIScreen mainScreen].bounds.size.width - offset : 0;
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

    if (!isEmptyString(contactPhone.imOpenUrl)) {
        CGFloat leftMargin = 10;
        if (contactPhone.showRealtorinfo == 1) {
            if ([TTDeviceHelper is568Screen]) {
                _imBtnWidth = 74;
            } else {
                _imBtnWidth = 94;
            }
            [self.imChatBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(_imBtnWidth);
                make.right.mas_equalTo(self.leftView.mas_right).offset(10 + _imBtnWidth);
            }];
        } else {
            _imBtnWidth = ([UIScreen mainScreen].bounds.size.width - 50) / 2;
            [self.imChatBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(20);
                make.width.mas_equalTo(_imBtnWidth);
                make.right.mas_equalTo(self.leftView.mas_right).offset(10 + _imBtnWidth);
            }];
        }
        
    } else {
        if (contactPhone.showRealtorinfo == 1) {
            [self.contactBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.leftView.mas_right).offset(10);
            }];
        } else {
            [self.contactBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.leftView.mas_right).offset(20);
            }];
        }
    }
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
        if ([TTDeviceHelper is568Screen]) {
            _contactBtn.titleLabel.font = [UIFont themeFontRegular:14];
        } else {
            _contactBtn.titleLabel.font = [UIFont themeFontRegular:16];
        }
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
        [_contactBtn setTitle:@"电话咨询" forState:UIControlStateHighlighted];
        _contactBtn.layer.cornerRadius = 4;
        _contactBtn.backgroundColor = [UIColor themeRed1];
    }
    return _contactBtn;
}

- (UIButton *)imChatBtn {
    if (!_imChatBtn) {
        _imChatBtn = [[UIButton alloc] init];
        _imChatBtn.layer.cornerRadius = 4;
        _imChatBtn.backgroundColor = [UIColor themeIMOrange];
        if ([TTDeviceHelper is568Screen]) {
            _imChatBtn.titleLabel.font = [UIFont themeFontRegular:14];
        } else {
            _imChatBtn.titleLabel.font = [UIFont themeFontRegular:16];
        }
        [_imChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_imChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_imChatBtn setTitle:@"在线联系" forState:UIControlStateNormal];
        [_imChatBtn setTitle:@"在线联系" forState:UIControlStateHighlighted];
    }
    return _imChatBtn;
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


