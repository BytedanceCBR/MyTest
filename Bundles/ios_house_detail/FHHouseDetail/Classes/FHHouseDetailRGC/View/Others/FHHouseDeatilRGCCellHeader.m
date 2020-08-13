//
//  FHHouseDeatilRGCCellHeader.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/15.
//

#import "FHHouseDeatilRGCCellHeader.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "Masonry.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <FHhousebase/FHRealtorAvatarView.h>

@interface FHHouseDeatilRGCCellHeader ()
@property (strong, nonatomic) FHRealtorAvatarView *avatarView;
@property (weak, nonatomic) UILabel *nameLab;
@property (weak, nonatomic) UIImageView *companyBac;
@property (weak, nonatomic) UILabel *companyNameLab;
@property (weak, nonatomic) UILabel *infoLab;
@property (weak, nonatomic) UIButton *iMBtn;
@property (weak, nonatomic) UIButton *phoneBtn;
@property(nonatomic , strong) UIButton *licenceIcon;
@end
@implementation FHHouseDeatilRGCCellHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(10);
        make.top.equalTo(self.avatarView);
    }];
    
    [self.companyBac mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab.mas_right).offset(4);
        make.centerY.equalTo(self.nameLab);
        make.height.mas_offset(16);
    }];
    [self.companyNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.companyBac).offset(5);
        make.right.equalTo(self.companyBac).offset(-5);
        make.centerY.equalTo(self.companyBac);
    }];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.companyBac.mas_right).offset(4);
        make.centerY.equalTo(self.nameLab);
        make.height.width.mas_offset(20);
    }];
    [self.phoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-8);
        make.centerY.equalTo(self.avatarView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.iMBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.phoneBtn.mas_left).offset(-30);
        make.centerY.equalTo(self.avatarView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.infoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab);
        make.bottom.equalTo(self.avatarView.mas_bottom).offset(2);
        make.right.equalTo(self.iMBtn.mas_left).offset(-20);
    }];
}

- (FHRealtorAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[FHRealtorAvatarView alloc] init];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
        [_avatarView.avatarImageView addGestureRecognizer:tapGesture];
        [self addSubview:_avatarView];
    }
    return _avatarView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        UILabel *nameLab = [[UILabel alloc]init];
        nameLab.font = [UIFont themeFontMedium:14];
        nameLab.textColor = [UIColor themeGray1];
        [self addSubview:nameLab];
        _nameLab = nameLab;
    }
    return _nameLab;
}

- (UIImageView *)companyBac {
    if (!_companyBac) {
        UIImageView *companyBac = [[UIImageView alloc]init];
        companyBac.image = [UIImage imageNamed:@"identify_bac_image"];
        [self addSubview:companyBac];
        _companyBac = companyBac;
    }
    return _companyBac;
}

- (UILabel *)companyNameLab {
    if (!_companyNameLab) {
        UILabel *companyNameLab = [[UILabel alloc]init];
        companyNameLab.font = [UIFont themeFontMedium:10];
        companyNameLab.textColor = [UIColor colorWithHexStr:@"#929292"];
        [self.companyBac addSubview:companyNameLab];
        _companyNameLab = companyNameLab;
    }
    return _companyNameLab;
}


- (UILabel *)infoLab {
    if (!_infoLab) {
        UILabel *infoLab = [[UILabel alloc]init];
        infoLab.font = [UIFont themeFontMedium:10];
        infoLab.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        infoLab.textColor = [UIColor themeGray3];
        [self addSubview:infoLab];
        _infoLab = infoLab;
    }
    return _infoLab;
}

- (UIButton *)iMBtn {
    if (!_iMBtn) {
        UIButton *iMBtn = [[UIButton alloc]init];
        [iMBtn addTarget:self action:@selector(imAction:) forControlEvents:UIControlEventTouchDown];
        [iMBtn setBackgroundImage:[UIImage imageNamed:@"detail_agent_message_normal_new"] forState:UIControlStateNormal];
        [self addSubview:iMBtn];
        _iMBtn = iMBtn;
    }
    return _iMBtn;
}

- (UIButton *)phoneBtn {
    if (!_phoneBtn) {
        UIButton *phoneBtn = [[UIButton alloc]init];
        [phoneBtn addTarget:self action:@selector(phoneAction:) forControlEvents:UIControlEventTouchDown];
        [phoneBtn setBackgroundImage:[UIImage imageNamed:@"detail_agent_call_normal_new"] forState:UIControlStateNormal];
        [self addSubview:phoneBtn];
        _phoneBtn = phoneBtn;
    }
    return _phoneBtn;
}

- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel {
    _cellModel = cellModel;
    
    [self.avatarView updateAvatarWithUGCCellModel:cellModel];

    if (cellModel.realtor.certificationIcon.length>0) {
        self.licenceIcon.hidden = NO;
    }else {
        self.licenceIcon.hidden = YES;
    }
    self.nameLab.text = cellModel.realtor.realtorName;
    if (cellModel.realtor.agencyName.length>0) {
        self.companyNameLab.text = cellModel.realtor.agencyName;
    }else {
        [self.companyBac mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLab.mas_right).offset(0);
            make.centerY.equalTo(self.nameLab);
            make.height.mas_offset(16);
            make.width.mas_offset(0);
        }];
    }
    if (cellModel.realtor.desc) {
        self.infoLab.text = [NSString stringWithFormat:@"%@ %@",cellModel.realtor.desc,cellModel.createTime];
    }else {
        self.infoLab.text = [NSString stringWithFormat:@"%@",cellModel.createTime];
    }
    
}

- (void)imAction:(UIButton *)sender {
    if (self.imClick) {
        self.imClick();
    }
}

- (void)clickImage {
    if (self.headerClick) {
        self.headerClick();
    }
}

- (void)phoneAction:(UIButton *)sender {
    if (self.phoneCilck) {
        self.phoneCilck();
    }
}

- (UIButton *)licenceIcon
{
    if (!_licenceIcon) {
        _licenceIcon = [[UIButton alloc]init];
        UIImage *img = SYS_IMG(@"detail_contact");
        [_licenceIcon setImage:img forState:UIControlStateNormal];
        [_licenceIcon setImage:img forState:UIControlStateHighlighted];
        [_licenceIcon addTarget:self action:@selector(licenseBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_licenceIcon];
    }
    return _licenceIcon;
}
- (void)licenseBtnDidClick:(UIButton *)btn
{
//    if (self.headerLicenseBlock) {
//        self.headerLicenseBlock();
//    }
}
- (void)hiddenConnectBtn:(BOOL)hidden {
    self.phoneBtn.hidden = hidden;
    self.iMBtn.hidden = hidden;
}
@end
