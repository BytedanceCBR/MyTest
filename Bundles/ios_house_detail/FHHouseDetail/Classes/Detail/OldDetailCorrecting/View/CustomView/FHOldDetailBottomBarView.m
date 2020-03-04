//
//  FHOldDetailBottomBarView.m
//  Pods
//
//  Created by 张静 on 2019/2/12.
//

#import "FHOldDetailBottomBarView.h"
#import "FHLoadingButton.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "Masonry.h"
#import "BDWebImage.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHHouseBase/FHCommonDefines.h>
#import "FHUIAdaptation.h"
#import "FHUtils.h"

@interface FHOldDetailBottomBarView ()

@property(nonatomic , strong) UIControl *leftView;
@property(nonatomic , strong) UIImageView *avatarView;
//@property(nonatomic , strong) UIImageView *identifyView;
@property(nonatomic , strong) UILabel *nameLabel;
@property(nonatomic , strong) UILabel *agencyLabel;
@property(nonatomic , strong) FHLoadingButton *contactBtn;
@property(nonatomic , strong) UIButton *licenceIcon;
@property(nonatomic , strong) UIButton *imChatBtn;
@property(nonatomic , assign) CGFloat imBtnWidth;
@property(nonatomic , assign) BOOL instantHasShow;

@end

@implementation FHOldDetailBottomBarView

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
//    [self.leftView addSubview:self.identifyView];
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
        make.width.height.mas_equalTo(48);
    }];
    CGFloat ratio = 0;
//    [self.identifyView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.avatarView).mas_offset(2);
//        make.centerX.mas_equalTo(self.avatarView);
//        make.height.mas_equalTo(14);
//        make.width.mas_equalTo(14 * ratio);
//    }];
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
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(2);
        make.right.mas_equalTo(self.leftView);
    }];

    [self addSubview:self.contactBtn];
    
    [self.contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.mas_equalTo(self).offset(-20);
        make.width.mas_equalTo(AdaptOffset(88));
        make.height.mas_equalTo(44);
    }];
    [self addSubview:self.imChatBtn];
    [self.imChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.mas_equalTo(self.contactBtn.mas_left).offset(-10);
        make.width.mas_equalTo(AdaptOffset(88));
        make.height.mas_equalTo(44);
    }];
    
    CGFloat btnBetween = 10;
    CGFloat btnRightMargin = -20;
    if ([TTDeviceHelper is568Screen]) {
        btnBetween = 5;
        btnRightMargin = -15;
    }

    
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

    BOOL showIM = NO;
    if ((contactPhone.unregistered && contactPhone.imLabel.length > 0) || !isEmptyString(contactPhone.imOpenUrl) ){
        showIM = YES;
    }
    self.showIM = showIM;

    self.leftView.hidden = contactPhone.showRealtorinfo == 1 ? NO : YES;
    self.imChatBtn.hidden = !showIM;

    [self.avatarView bd_setImageWithURL:[NSURL URLWithString:contactPhone.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];

    FHDetailContactImageTagModel *tag = contactPhone.imageTag;
//    [self refreshIdentifyView:self.identifyView withUrl:tag.imageUrl];

    NSString *realtorName = contactPhone.realtorName;
    if (contactPhone.realtorName.length > 0) {
        if (contactPhone.realtorName.length > 4) {
            realtorName = [NSString stringWithFormat:@"%@...",[contactPhone.realtorName substringToIndex:4]];
            self.nameLabel.text = realtorName;
        }else {
            self.nameLabel.text = realtorName;
        }
    }else {
        self.nameLabel.text = @"经纪人";
    }
    CGFloat nameLabelwidth = [realtorName boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.nameLabel.font} context:nil].size.width + 1;
    NSMutableArray *licenseViews = @[].mutableCopy;
    if (contactPhone.businessLicense.length > 0 || contactPhone.certificate.length > 0) {
        [self displayLicense:YES];
        nameLabelwidth += 24;
    }else {
        [self displayLicense:NO];
    }

    if (contactPhone.agencyName.length > 0) {
        self.agencyLabel.text = contactPhone.agencyName;
        self.agencyLabel.hidden = NO;
    }else {
        self.agencyLabel.hidden = YES;
    }
    CGFloat maxAgencyLabelWidth = [UIScreen mainScreen].bounds.size.width - 300;
    CGFloat agencyLabelWidth = [contactPhone.agencyName boundingRectWithSize:CGSizeMake(maxAgencyLabelWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.agencyLabel.font} context:nil].size.width + 1;
    CGFloat realtorContentWidth = 0;
    if ([TTDeviceHelper is568Screen]) {
        realtorContentWidth = [UIScreen mainScreen].bounds.size.width - 178;
    } else {
        CGFloat labelWidth = MAX(nameLabelwidth, agencyLabelWidth);
        CGFloat avatarWidth = 48;
        CGFloat avatarLeftMargin = 20;
        CGFloat avatarLabelMargin = 10;
        realtorContentWidth = labelWidth + avatarWidth + avatarLabelMargin + avatarLeftMargin;
    }

    CGFloat leftWidth = contactPhone.showRealtorinfo == 1 ? realtorContentWidth : 0;

    if (!showIM) {

        if (contactPhone.showRealtorinfo != 1)  {
            
        // 阴影颜色
            _contactBtn.layer.shadowColor = [UIColor colorWithHexStr:@"#ff9629"].CGColor;
            _contactBtn.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
            [self.contactBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.right.mas_equalTo(self).offset(-20);
                make.height.mas_equalTo(44);
                make.left.mas_equalTo(self.leftView.mas_right).offset(20);
            }];
        }
    }
    void (^updateBlock)() = ^{
        [self.leftView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(leftWidth);
        }];
//        if (!showIM)  {
//            CGFloat offset = 20;
//            if (contactPhone.showRealtorinfo == 1) {
//                offset = 10;
//            }
//            [self.contactBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.centerY.equalTo(self);
//                make.right.mas_equalTo(self).offset(-20);
//                make.height.mas_equalTo(44);
//                make.left.mas_equalTo(self.leftView.mas_right).offset(offset);
//            }];
//        }
    };

    updateBlock();

    if(contactPhone.isInstantData){
        _instantHasShow = YES;
    }
    
}

- (void)refreshIdentifyView:(UIImageView *)identifyView withUrl:(NSString *)imageUrl
{
    if (!identifyView) {
        return;
    }
    if (imageUrl.length > 0) {
        [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:imageUrl] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            if (!error && image) {
                identifyView.image = image;
                CGFloat ratio = 0;
                if (image.size.height > 0) {
                    ratio = image.size.width / image.size.height;
                }
                [identifyView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(14 * ratio);
                }];
            }
        }];
        identifyView.hidden = NO;
    }else {
        identifyView.hidden = YES;
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
        _avatarView.layer.cornerRadius = 24;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

//- (UIImageView *)identifyView
//{
//    if (!_identifyView) {
//        _identifyView = [[UIImageView alloc]init];
//    }
//    return _identifyView;
//}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont themeFontMedium:16];
        _nameLabel.textColor = [UIColor themeGray1];
    }
    return _nameLabel;
}

- (UILabel *)agencyLabel
{
    if (!_agencyLabel) {
        _agencyLabel = [[UILabel alloc]init];
        _agencyLabel.font = [UIFont themeFontRegular:14];
        _agencyLabel.textColor = [UIColor themeGray3];
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
        _contactBtn.layer.cornerRadius = 22;
        // 阴影颜色
        _contactBtn.layer.shadowColor = [UIColor colorWithHexStr:@"#fe5500"].CGColor;
        // 阴影偏移量 默认为(0,3)
        _contactBtn.layer.shadowOffset = CGSizeMake(0, 8);
        // 阴影透明度
        _contactBtn.layer.shadowOpacity = .2;
        _contactBtn.layer.shadowRadius = 6;
        _contactBtn.backgroundColor =[UIColor colorWithHexStr:@"#fe5500"];
     
    }
    return _contactBtn;
}

- (UIButton *)imChatBtn {
    if (!_imChatBtn) {
        _imChatBtn = [[UIButton alloc] init];
        _imChatBtn.layer.cornerRadius = 22;
        _imChatBtn.layer.shadowColor = [UIColor colorWithHexStr:@"#ff9629"].CGColor;
        _imChatBtn.layer.shadowOffset = CGSizeMake(0, 8);
        _imChatBtn.layer.shadowOpacity = .2 ;
        _imChatBtn.layer.shadowRadius = 6;
        _imChatBtn.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
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
        UIImage *img = SYS_IMG(@"detail_contact");
        [_licenceIcon setImage:img forState:UIControlStateNormal];
        [_licenceIcon setImage:img forState:UIControlStateHighlighted];
    }
    return _licenceIcon;
}

@end

