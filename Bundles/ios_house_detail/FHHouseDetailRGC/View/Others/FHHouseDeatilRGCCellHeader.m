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

@interface FHHouseDeatilRGCCellHeader ()
@property (weak, nonatomic) UIImageView *headerIma;
@property (weak, nonatomic) UILabel *nameLab;
@property (weak, nonatomic) UIImageView *companyBac;
@property (weak, nonatomic) UIImageView *idIma;
@property (weak, nonatomic) UILabel *companyNameLab;
@property (weak, nonatomic) UILabel *infoLab;
@property (weak, nonatomic) UIButton *iMBtn;
@property (weak, nonatomic) UIButton *phoneBtn;
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
    [self.headerIma mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerIma.mas_right).offset(10);
        make.top.equalTo(self.headerIma).offset(2);
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
    [self.idIma mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.companyBac.mas_right).offset(4);
        make.centerY.equalTo(self.nameLab);
        make.top.bottom.equalTo(self.companyBac);
        make.height.mas_offset(16);
        
    }];
    [self.phoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-15);
        make.centerY.equalTo(self.headerIma);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.iMBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.phoneBtn.mas_left).offset(-20);
        make.centerY.equalTo(self.headerIma);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.infoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLab);
        make.bottom.equalTo(self.headerIma.mas_bottom).offset(-2);
        make.right.equalTo(self.iMBtn.mas_left).offset(-20);
    }];
}

- (UIImageView *)headerIma {
    if (!_headerIma) {
        UIImageView *headerIma = [[UIImageView alloc]init];
        headerIma.layer.cornerRadius = 17;
        headerIma.layer.masksToBounds = YES;
        headerIma.backgroundColor = [UIColor themeGray7];
        headerIma.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:headerIma];
        _headerIma = headerIma;
    }
    return _headerIma;
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

- (UIImageView *)idIma {
    if (!_idIma) {
        UIImageView *idIma = [[UIImageView alloc]init];
        idIma.image = [UIImage imageNamed:@"detail_contact"];
        [self addSubview:idIma];
        _idIma = idIma;
    }
    return _idIma;
}

- (UILabel *)infoLab {
    if (!_infoLab) {
        UILabel *infoLab = [[UILabel alloc]init];
        infoLab.text = @"带看本房源1次 2019.06.22带看过 ";
        infoLab.font = [UIFont themeFontMedium:10];
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
        [iMBtn setBackgroundImage:[UIImage imageNamed:@"detail_agent_message_press_new"] forState:UIControlStateNormal];
        [self addSubview:iMBtn];
        _iMBtn = iMBtn;
    }
    return _iMBtn;
}

- (UIButton *)phoneBtn {
    if (!_phoneBtn) {
        UIButton *phoneBtn = [[UIButton alloc]init];
        [phoneBtn addTarget:self action:@selector(phoneAction:) forControlEvents:UIControlEventTouchDown];
        [phoneBtn setBackgroundImage:[UIImage imageNamed:@"detail_agent_call_press_new"] forState:UIControlStateNormal];
        [self addSubview:phoneBtn];
        _phoneBtn = phoneBtn;
    }
    return _phoneBtn;
}

- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel {
    _cellModel = cellModel;
    if (cellModel.realtor.avatarUrl) {
        [self.headerIma bd_setImageWithURL:[NSURL URLWithString:cellModel.realtor.avatarUrl]];
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
    self.infoLab.text = cellModel.realtor.desc;
}

- (void)imAction:(UIButton *)sender {
    if (self.imClick) {
        self.imClick();
    }
}

- (void)phoneAction:(UIButton *)sender {
    if (self.phoneCilck) {
        self.phoneCilck();
    }
}
@end
