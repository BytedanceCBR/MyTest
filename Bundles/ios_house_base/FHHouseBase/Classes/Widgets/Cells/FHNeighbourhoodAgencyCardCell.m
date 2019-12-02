//
// Created by fengbo on 2019-10-28.
//

#import <Masonry/View+MASAdditions.h>
#import <FHCommonUI/UILabel+House.h>
#import "FHNeighbourhoodAgencyCardCell.h"
#import "FHSearchHouseModel.h"
#import "FHDetailBaseModel.h"
#import "BDWebImage.h"
#import "FHDetailAgentListCell.h"
#import "FHExtendHotAreaButton.h"
#import "FHShadowView.h"
#import "FHHousePhoneCallUtils.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <TTThemed/SSViewBase.h>
#import <TTThemed/UIColor+TTThemeExtension.h>

@interface FHNeighbourhoodAgencyCardCell ()


@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *shadowView;

@property(nonatomic, strong) UIView *topInfoView;
@property(nonatomic, strong) UILabel *mainTitleLabel; //小区名称
@property(nonatomic, strong) UILabel *pricePerSqmLabel; //房源价格
@property(nonatomic, strong) UILabel *countOnSale; //在售套数
@property(nonatomic, strong) UIImageView *rightArrow;
@property(nonatomic, strong) UIView *verticleDividerView;


@property(nonatomic, strong) UIView *dividerView;

@property(nonatomic, strong) UIView *bottomInfoView;
@property(nonatomic, strong) UIImageView *avator;
@property(nonatomic, strong) UIButton *licenceIcon;
@property(nonatomic, strong) UIButton *callBtn;
@property(nonatomic, strong) UIButton *imBtn;
@property(nonatomic, strong) UILabel *name;
@property(nonatomic, strong) UILabel *agency;

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

- (void)initUI {

    self.contentView.clipsToBounds = NO;
    self.clipsToBounds = NO;

    _shadowView = [[FHShadowView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_shadowView];

    _containerView = [[UIView alloc] init];
    CALayer *layer = _containerView.layer;
    layer.cornerRadius = 4;
    layer.masksToBounds = YES;
    layer.borderColor =  [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
    layer.borderWidth = 0.5f;
    [self.contentView addSubview:_containerView];

    _topInfoView = [[UIView alloc] init];
    [self.containerView addSubview:_topInfoView];

    _mainTitleLabel = [[UILabel alloc] init];
    _mainTitleLabel.textAlignment = NSTextAlignmentLeft;
    _mainTitleLabel.textColor = [UIColor themeGray1];
    _mainTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
    [self.topInfoView addSubview:_mainTitleLabel];

    _pricePerSqmLabel = [[UILabel alloc] init];
    _pricePerSqmLabel.textAlignment = NSTextAlignmentLeft;
    _pricePerSqmLabel.textColor = [UIColor colorWithHexString:@"#ff5969"];
    _pricePerSqmLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14];
    [self.topInfoView addSubview:_pricePerSqmLabel];

    _countOnSale = [[UILabel alloc] init];
    _countOnSale.textAlignment = NSTextAlignmentLeft;
    _countOnSale.textColor = [UIColor themeGray1];
    _countOnSale.font = [UIFont themeFontRegular:14];
    [self.topInfoView addSubview:_countOnSale];

    _verticleDividerView = [[UIView alloc] init];
    [_verticleDividerView setBackgroundColor:[UIColor colorWithHexString:@"#e8e8e8"]];
    [self.topInfoView addSubview:_verticleDividerView];

    self.rightArrow = [[UIImageView alloc] initWithImage:SYS_IMG(@"arrow_right_setup")];
    [self.topInfoView addSubview:_rightArrow];

    _dividerView = [[UIView alloc] init];
    [_dividerView setBackgroundColor:[UIColor colorWithHexString:@"#e8e8e8"]];
    [self.containerView addSubview:_dividerView];

    _bottomInfoView = [[UIView alloc] init];
    [self.containerView addSubview:_bottomInfoView];

    _avator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_default_avatar"]];
    _avator.layer.cornerRadius = 21;
    _avator.contentMode = UIViewContentModeScaleAspectFill;
    _avator.clipsToBounds = YES;
    [self.bottomInfoView addSubview:_avator];

    _licenceIcon = [[FHExtendHotAreaButton alloc] init];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateNormal];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateSelected];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateHighlighted];
    [self.bottomInfoView addSubview:_licenceIcon];

    _callBtn = [[FHExtendHotAreaButton alloc] init];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_normal"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press"] forState:UIControlStateSelected];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press"] forState:UIControlStateHighlighted];
    [self.bottomInfoView addSubview:_callBtn];

    _imBtn = [[FHExtendHotAreaButton alloc] init];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_normal"] forState:UIControlStateNormal];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press"] forState:UIControlStateSelected];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press"] forState:UIControlStateHighlighted];
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

    [self.topInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(neighbourhoodInfoClick:)]];
    [self.bottomInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(realtorInfoClick:)]];

    [self.licenceIcon addTarget:self action:@selector(licenseClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.callBtn addTarget:self action:@selector(phoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.imBtn addTarget:self action:@selector(imclick:) forControlEvents:UIControlEventTouchUpInside];


    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(20);
        make.right.mas_equalTo(self).mas_offset(-20);
        make.top.mas_equalTo(self).offset(10);
        make.bottom.mas_equalTo(self).offset(-10);
    }];

    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];

    [self.topInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView);
        make.left.mas_equalTo(self.containerView.mas_left);
        make.right.mas_equalTo(self.containerView.mas_right);
        make.width.mas_equalTo(self.containerView);
        make.height.mas_equalTo(79);
    }];

    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topInfoView).offset(20);
        make.left.mas_equalTo(self.topInfoView).offset(20);
        make.right.mas_lessThanOrEqualTo(self.rightArrow.mas_left).offset(-20);
    }];


    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(self.topInfoView).offset(20);
    }];

    [self.verticleDividerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(14);
        make.centerY.mas_equalTo(self.pricePerSqmLabel);
        make.left.mas_equalTo(self.pricePerSqmLabel.mas_right).offset(4);
    }];


    [self.countOnSale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.pricePerSqmLabel);
        make.left.mas_equalTo(self.verticleDividerView.mas_right).offset(4.5);
    }];

    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topInfoView.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.topInfoView);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(18);
    }];

    [self.dividerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.mas_equalTo(self.containerView).offset(20);
        make.right.mas_equalTo(self.containerView).offset(-20);
        make.top.mas_equalTo(self.topInfoView.mas_bottom);
    }];

    [self.bottomInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dividerView.mas_bottom);
        make.left.mas_equalTo(self.containerView.mas_left);
        make.right.mas_equalTo(self.containerView.mas_right);
        make.height.mas_equalTo(69);
        make.left.right.mas_equalTo(self.containerView);
    }];


    [self.avator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(42);
        make.left.mas_equalTo(self.bottomInfoView).mas_offset(20);
        make.top.mas_equalTo(self.bottomInfoView).mas_offset(10);
    }];

    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avator.mas_right).offset(10);
        make.top.mas_equalTo(self.avator);
        make.height.mas_equalTo(22);
    }];
    [self.agency mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.name.mas_bottom);
        make.height.mas_equalTo(17);
        make.left.mas_equalTo(self.avator.mas_right).offset(10);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-20);
    }];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.name.mas_right).offset(5);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-20);
    }];
    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(self.bottomInfoView.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.avator);
    }];
    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-20);
        make.centerY.mas_equalTo(self.avator);
    }];

}

- (void)bindData:(FHHouseNeighborAgencyModel *)model traceParams:(NSMutableDictionary *)params {
    if (model) {
        self.modelData = model;
        self.traceParams = params.mutableCopy;

        [self.mainTitleLabel setText:model.neighborhoodName];
        [self.pricePerSqmLabel setText:model.neighborhoodPrice];
        [self.countOnSale setText:model.displayStatusInfo];

        if (model.contactModel) {
            self.name.text = model.contactModel.realtorName;
            self.agency.text = model.contactModel.agencyName;
            if (IS_EMPTY_STRING(self.agency.text)) {
                [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.avator);
                    make.left.mas_equalTo(self.avator.mas_right).offset(10);
                    make.height.mas_equalTo(22);
                }];

                [self.licenceIcon updateConstraintsIfNeeded];
            }
            if (model.contactModel.avatarUrl.length > 0) {
                [self.avator bd_setImageWithURL:[NSURL URLWithString:model.contactModel.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
            }
            self.phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeNeighborhood houseId:model.id];
            BOOL isLicenceIconHidden = ![self shouldShowContact:model.contactModel];
            [self.licenceIcon setHidden:isLicenceIconHidden];

            NSMutableDictionary *tracerDict = @{}.mutableCopy;
            if (self.traceParams) {
                [tracerDict addEntriesFromDictionary:self.traceParams];
            }
            self.phoneCallViewModel.tracerDict = tracerDict;
            //TODO fengbo  check this, seems like there`s no need to add view_controller?
            self.phoneCallViewModel.belongsVC = model.belongsVC;
        } else {
            [self.bottomInfoView setHidden:YES];
            [self.dividerView setHidden:YES];
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
    return 169;// + 10;
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
            imExtra[@"realtor_position"] = @"neighborhood_expert_card";
            imExtra[@"from"] = @"app_neighborhood_aladdin";
//            imExtra[@"enter_from"] = self.traceParams[@"enter_from"];
            imExtra[kFHClueEndpoint] = @(FHClueEndPointTypeC);
            imExtra[kFHCluePage] = [NSString stringWithFormat:@"%ld",FHClueIMPageTypeCNeighborhoodAladdin];
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
        extraDict[@"realtor_position"] = @"neighborhood_expert_card";
        extraDict[@"realtor_logpb"] = contact.realtorLogpb;
//        extraDict[@"element_from"] = @"neighborhood_expert_card";
        extraDict[kFHClueEndpoint] = @(FHClueEndPointTypeC);
        extraDict[kFHCluePage] = @(FHClueCallPageTypeCNeighborhoodAladdin);
        
        FHHouseContactConfigModel *contactConfig = [[FHHouseContactConfigModel alloc] initWithDictionary:extraDict error:nil];
        contactConfig.houseType = FHHouseTypeNeighborhood;
        contactConfig.houseId = self.modelData.id;
        contactConfig.phone = contact.phone;
        contactConfig.realtorId = contact.realtorId;
        contactConfig.pageType = @"old_list";
        if (self.modelData.logPb) {
            contactConfig.searchId = self.modelData.logPb[@"search_id"];
            contactConfig.imprId = self.modelData.logPb[@"impr_id"];
        }
//        contactConfig.from = @"app_neighborhood_aladdin";
        [FHHousePhoneCallUtils callWithConfigModel:contactConfig completion:nil];
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
        extraDict[@"realtor_position"] = @"neighborhood_expert_card";
        extraDict[@"element_from"] = @"neighborhood_expert_card";
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
        tracerDict[@"element_from"] = @"neighborhood_expert_card";
        tracerDict[@"enter_from"] = self.traceParams[@"page_type"];
        tracerDict[@"page_type"] = nil;
        NSMutableDictionary *dict = @{@"house_type": @(FHHouseTypeNeighborhood), @"tracer": tracerDict}.mutableCopy;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

@end
