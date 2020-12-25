//
// Created by fengbo on 2019-10-28.
//

#import <Masonry/View+MASAdditions.h>
#import <FHCommonUI/UILabel+House.h>
#import "FHNeighbourhoodAgencyCardCell.h"
#import "FHSearchHouseModel.h"
#import "FHDetailBaseModel.h"
#import <BDWebImage/BDWebImage.h>
#import "FHDetailAgentListCell.h"
#import "FHHousePhoneCallUtils.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <TTThemed/SSViewBase.h>
#import <TTThemed/UIColor+TTThemeExtension.h>
#import "UIImage+FIconFont.h"
#import "TTAccountManager.h"
#import <FHHouseBase/FHHouseRealtorAvatarView.h>

@interface FHNeighbourhoodAgencyCardCell ()


@property(nonatomic, strong) UIView *containerView;

@property(nonatomic, strong) UIView *topInfoView;
@property(nonatomic, strong) UILabel *mainTitleLabel; //小区名称
@property(nonatomic, strong) UILabel *pricePerSqmLabel; //房源价格
@property(nonatomic, strong) UILabel *countOnSale; //在售套数
@property(nonatomic, strong) UIImageView *rightArrow;

@property(nonatomic, strong) UIView *bottomInfoView;
@property(nonatomic, strong) UIView *lineView;
@property(nonatomic, strong) FHHouseRealtorAvatarView *avatarView;
@property(nonatomic, strong) UIButton *licenceIcon;
@property(nonatomic, strong) UIButton *callBtn;
@property(nonatomic, strong) UIButton *imBtn;
@property(nonatomic, strong) UILabel *name;
@property(nonatomic, strong) UILabel *agency;
@property (nonatomic, strong) UILabel     *score;
@property (nonatomic, strong) UILabel     *scoreDescription;

@property(nonatomic, strong) FHHouseNeighborAgencyModel *modelData;
@property(nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property(nonatomic, strong) NSMutableDictionary *traceParams;


@end

@implementation FHNeighbourhoodAgencyCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

//- (void)updateHeightByIsFirst:(BOOL)isFirst {
//    CGFloat top = 5;
//    if (isFirst) {
//        top = 10;
//    }
//    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self).offset(top);
//    }];
//}

- (void)initUI {

    self.contentView.clipsToBounds = NO;
    self.clipsToBounds = NO;

    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor whiteColor];
    CALayer *layer = _containerView.layer;
    layer.cornerRadius = 10;
    layer.masksToBounds = YES;
    [self.contentView addSubview:_containerView];

    _topInfoView = [[UIView alloc] init];
    _topInfoView.userInteractionEnabled = NO;
    [self.containerView addSubview:_topInfoView];

    _mainTitleLabel = [[UILabel alloc] init];
    _mainTitleLabel.textAlignment = NSTextAlignmentLeft;
    _mainTitleLabel.textColor = [UIColor themeGray1];
    _mainTitleLabel.font = [UIFont themeFontSemibold:16];
    [self.topInfoView addSubview:_mainTitleLabel];

    _pricePerSqmLabel = [[UILabel alloc] init];
    _pricePerSqmLabel.textAlignment = NSTextAlignmentRight;
    _pricePerSqmLabel.textColor = [UIColor themeOrange1];
    _pricePerSqmLabel.font = [UIFont themeFontMedium:16];
    [self.topInfoView addSubview:_pricePerSqmLabel];

    _countOnSale = [[UILabel alloc] init];
    _countOnSale.textAlignment = NSTextAlignmentLeft;
    _countOnSale.textColor = [UIColor themeGray1];
    _countOnSale.font = [UIFont themeFontRegular:12];
    [self.topInfoView addSubview:_countOnSale];
    
    self.rightArrow = [[UIImageView alloc] initWithImage:ICON_FONT_IMG(10, @"\U0000e670", [UIColor themeGray6])];
    _rightArrow.hidden = YES;
    [self.topInfoView addSubview:_rightArrow];

    _bottomInfoView = [[UIView alloc] init];
    _bottomInfoView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:_bottomInfoView];
    
    
    _lineView = [[UIView alloc]init];
    _lineView.backgroundColor = [UIColor themeGray7];
     [self.bottomInfoView addSubview:_lineView];

    self.avatarView = [[FHHouseRealtorAvatarView alloc] init];
    [self.bottomInfoView addSubview:self.avatarView];

    _licenceIcon = [[UIButton alloc] init];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateNormal];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateSelected];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateHighlighted];
    [self.bottomInfoView addSubview:_licenceIcon];

    _callBtn = [[UIButton alloc] init];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_normal_new"] forState:UIControlStateNormal];
    [self.bottomInfoView addSubview:_callBtn];

    _imBtn = [[UIButton alloc] init];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_normal_new"] forState:UIControlStateNormal];
    [self.bottomInfoView addSubview:_imBtn];

    _name = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _name.textColor = [UIColor themeGray1];
    _name.font = [UIFont themeFontMedium:16];
    _name.textAlignment = NSTextAlignmentLeft;
    [self.bottomInfoView addSubview:_name];

    _agency = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _agency.textColor = [UIColor themeGray3];
    _agency.textAlignment = NSTextAlignmentLeft;
    [self.bottomInfoView addSubview:_agency];
    
    _score = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _score.textColor = [UIColor themeGray1];
     _score.font = [UIFont themeFontSemibold:14];
    _score.textAlignment = NSTextAlignmentLeft;
    [self.bottomInfoView addSubview:_score];
    
    _scoreDescription= [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _scoreDescription.textColor = [UIColor colorWithHexStr:@"6d7278"];
    _scoreDescription.textAlignment = NSTextAlignmentLeft;
    [self.bottomInfoView addSubview:_scoreDescription];

    [self.topInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(neighbourhoodInfoClick:)]];
    [self.bottomInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(realtorInfoClick:)]];

    [self.licenceIcon addTarget:self action:@selector(licenseClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.callBtn addTarget:self action:@selector(phoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.imBtn addTarget:self action:@selector(imclick:) forControlEvents:UIControlEventTouchUpInside];


    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(15);
        make.right.mas_equalTo(self).mas_offset(-15);
        make.height.mas_equalTo(165);
        make.bottom.mas_equalTo(self).offset(-5);
    }];

    [self.topInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(73);
    }];

    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topInfoView).offset(16);
        make.left.mas_equalTo(self.topInfoView).offset(15);
        make.height.mas_equalTo(22);
        make.right.mas_lessThanOrEqualTo(self.pricePerSqmLabel.mas_left).offset(-10);
    }];
    
    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topInfoView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.topInfoView);
    }];

    [self.countOnSale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainTitleLabel);
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).offset(2);
        make.height.mas_equalTo(17);
        make.right.mas_lessThanOrEqualTo(self.pricePerSqmLabel.mas_left).offset(-10);
    }];
    
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topInfoView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.topInfoView);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(18);
    }];

    [self.bottomInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topInfoView.mas_bottom);
        make.left.mas_equalTo(self.containerView.mas_left);
        make.right.mas_equalTo(self.containerView.mas_right);
        make.height.mas_equalTo(76);
        make.left.right.mas_equalTo(self.containerView);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomInfoView).offset(15);
        make.right.equalTo(self.bottomInfoView).offset(-15);
        make.top.equalTo(self.bottomInfoView);
        make.height.mas_offset(1);
    }];

    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(46);
        make.left.mas_equalTo(self.bottomInfoView).mas_offset(15);
        make.top.mas_equalTo(self.bottomInfoView).mas_offset(15);
    }];

    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatarView.mas_right).offset(10);
        make.top.mas_equalTo(self.avatarView);
        make.height.mas_equalTo(22);
    }];
    [self.agency mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.name);
        make.height.mas_equalTo(17);
        make.left.mas_equalTo(self.name.mas_right).offset(4);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-4);
    }];
    [self.score mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).offset(8);
        make.left.equalTo(self.name);
    }];
    [self.scoreDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.score.mas_right).offset(3);
        make.centerY.mas_equalTo(self.score);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-4);
    }];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.name.mas_right).offset(5);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-15);
    }];
    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.right.mas_equalTo(self.bottomInfoView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.avatarView);
    }];
    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-30);
        make.centerY.mas_equalTo(self.avatarView);
    }];

}

- (void)bindData:(FHHouseNeighborAgencyModel *)model traceParams:(NSMutableDictionary *)params {
    if (model) {
        self.modelData = model;
        self.traceParams = params.mutableCopy;

        [self.mainTitleLabel setText:model.neighborhoodName];
        [self.pricePerSqmLabel setText:model.neighborhoodPrice];
        if (model.districtAreaName.length > 0 && model.displayStatusInfo.length > 0) {
            self.countOnSale.text = [NSString stringWithFormat:@"%@/%@",model.districtAreaName,model.displayStatusInfo];
        }else if (model.districtAreaName.length > 0) {
            self.countOnSale.text = model.districtAreaName;
        }else if (model.displayStatusInfo.length > 0) {
            self.countOnSale.text = model.displayStatusInfo;
        }

        if (model.contactModel) {
            self.name.text = model.contactModel.realtorName;
            self.agency.text = model.contactModel.agencyName;
            self.score.text = model.contactModel.realtorScoreDisplay;
            self.scoreDescription.text = model.contactModel.realtorScoreDescription;
            if (IS_EMPTY_STRING(self.scoreDescription.text) || IS_EMPTY_STRING(self.score.text)) {
                [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.avatarView);
                    make.left.mas_equalTo(self.avatarView.mas_right).offset(10);
                    make.height.mas_equalTo(22);
                }];
                self.score.hidden = YES;
                self.scoreDescription.hidden = YES;
                [self.licenceIcon updateConstraintsIfNeeded];
            }
            [self.avatarView updateAvatarWithModel:model.contactModel];
            self.phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeNeighborhood houseId:model.id];
            BOOL isLicenceIconHidden = ![self shouldShowContact:model.contactModel];
            [self.licenceIcon setHidden:isLicenceIconHidden];

            NSMutableDictionary *tracerDict = @{}.mutableCopy;
            if (self.traceParams) {
                [tracerDict addEntriesFromDictionary:self.traceParams];
            }
            self.phoneCallViewModel.tracerDict = tracerDict;
            self.phoneCallViewModel.belongsVC = model.belongsVC;
        } else {
            [self.bottomInfoView setHidden:YES];
        }
        
        if([model.realtorType isEqualToString:@"4"]){
            //小区
            [self.pricePerSqmLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.rightArrow.mas_left).offset(-10);
                make.centerY.mas_equalTo(self.topInfoView);
            }];
            self.topInfoView.userInteractionEnabled = YES;
            self.rightArrow.hidden = NO;
        }else if([model.realtorType isEqualToString:@"5"]){
            //商圈
            [self.pricePerSqmLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.topInfoView.mas_right).offset(-15);
                make.centerY.mas_equalTo(self.topInfoView);
            }];
            self.topInfoView.userInteractionEnabled = NO;
            self.rightArrow.hidden = YES;
        }
        
    }
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHHouseNeighborAgencyModel class]]) {
        FHHouseNeighborAgencyModel *model = (FHHouseNeighborAgencyModel *)data;
        [self bindData:model traceParams:model.tracerDict];
    }
}

+ (CGFloat)heightForData:(id)data
{
    return 175;
}

- (BOOL)shouldShowContact:(FHDetailContactModel *)contact {
    BOOL result = NO;
    if (contact.businessLicense.length > 0) {
        result = YES;
    }
    if (contact.certificate.length > 0) {
        result = YES;
    }
    return result;
}

- (void)imclick:(UIButton *)btn {
    if (self.modelData) {
        FHDetailContactModel *contact = self.modelData.contactModel;
        if (self.phoneCallViewModel) {
            NSMutableDictionary *imExtra = @{}.mutableCopy;
            imExtra[@"realtor_position"] = self.traceParams[@"realtor_position"];
                        
            if(self.modelData.associateInfo) {
                imExtra[kFHAssociateInfo] = self.modelData.associateInfo;
            }
            imExtra[@"im_open_url"] = contact.imOpenUrl;
            [self.phoneCallViewModel imchatActionWithPhone:contact realtorRank:@"0" extraDic:imExtra];
        }
    }

}

- (void)phoneClick:(UIButton *)btn {
    if (self.modelData) {
        FHDetailContactModel *contact = self.modelData.contactModel;

        NSMutableDictionary *extraDict = @{}.mutableCopy;
        if (self.traceParams) {
            [extraDict addEntriesFromDictionary:self.traceParams];
        }
        extraDict[@"realtor_id"] = contact.realtorId;
        extraDict[@"realtor_rank"] = @"be_null";
        extraDict[@"realtor_logpb"] = contact.realtorLogpb;
//        extraDict[@"element_from"] = @"neighborhood_expert_card";
//        extraDict[kFHClueEndpoint] = @(FHClueEndPointTypeC);
//        extraDict[kFHCluePage] = @(FHClueCallPageTypeCNeighborhoodAladdin);
        
//        FHHouseContactConfigModel *contactConfig = [[FHHouseContactConfigModel alloc] initWithDictionary:extraDict error:nil];
//        contactConfig.houseType = FHHouseTypeNeighborhood;
//        contactConfig.houseId = self.modelData.id;
//        contactConfig.phone = contact.phone;
//        contactConfig.realtorId = contact.realtorId;
//        contactConfig.pageType = @"old_list";
//        if (self.modelData.logPb) {
//            contactConfig.searchId = self.modelData.logPb[@"search_id"];
//            contactConfig.imprId = self.modelData.logPb[@"impr_id"];
//        }
        
        NSDictionary *associateInfoDict = self.modelData.associateInfo.phoneInfo;
        extraDict[kFHAssociateInfo] = associateInfoDict;
        FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
        associatePhone.reportParams = extraDict;
        associatePhone.associateInfo = associateInfoDict;
        associatePhone.realtorId = contact.realtorId;
        if (self.modelData.logPb) {
            associatePhone.searchId = self.modelData.logPb[@"search_id"];
            associatePhone.imprId = self.modelData.logPb[@"impr_id"];
        }
        associatePhone.houseType = FHHouseTypeNeighborhood;
        associatePhone.houseId = self.modelData.id;
        associatePhone.showLoading = NO;
        [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhone completion:nil];
    }

}

- (void)licenseClick:(id)licenseClick {
    if (self.modelData) {
        if (self.phoneCallViewModel) {
            [self.phoneCallViewModel licenseActionWithPhone:self.modelData.contactModel];
        }
    }
}

- (void)realtorInfoClick:(id)realtorInfoClick {
    if (self.modelData) {
        FHDetailContactModel *contact = self.modelData.contactModel;
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        extraDict[@"realtor_position"] = self.traceParams[@"realtor_position"];
        extraDict[@"element_from"] = self.traceParams[@"realtor_position"];
        extraDict[@"enter_from"] = self.traceParams[@"page_type"];
        extraDict[@"page_type"] = nil;
//        extraDict[@"realtor_rank"] = @"be_null";
//        extraDict[@"realtor_logpb"] = contact.realtorLogpb;
        if (self.phoneCallViewModel) {
            [self.phoneCallViewModel jump2RealtorDetailWithPhone:contact isPreLoad:YES extra:extraDict];
        }
    }
}

- (void)neighbourhoodInfoClick:(id)neighbourhoodInfoClick {
    if (self.modelData) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@", self.modelData.id]];

        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        if (self.traceParams) {
            [tracerDict addEntriesFromDictionary:self.traceParams];
        }
        tracerDict[@"element_from"] = self.traceParams[@"realtor_position"];
        tracerDict[@"enter_from"] = self.traceParams[@"page_type"];
        tracerDict[@"page_type"] = nil;
        NSMutableDictionary *dict = @{@"house_type": @(FHHouseTypeNeighborhood), @"tracer": tracerDict}.mutableCopy;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

@end
