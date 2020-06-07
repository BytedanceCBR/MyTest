//
//  FHHouseAgentCardCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/6/1.
//

#import "FHHouseAgentCardCell.h"
#import <Masonry/View+MASAdditions.h>
#import <FHCommonUI/UILabel+House.h>
#import "FHNeighbourhoodAgencyCardCell.h"
#import "FHSearchHouseModel.h"
#import "FHDetailBaseModel.h"
#import <BDWebImage/BDWebImage.h>
#import "FHDetailAgentListCell.h"
#import "FHExtendHotAreaButton.h"
#import "FHShadowView.h"
#import "FHHousePhoneCallUtils.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <TTThemed/SSViewBase.h>
#import <TTThemed/UIColor+TTThemeExtension.h>
#import "UIImage+FIconFont.h"
#import "YYLabel.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHLynxView.h"
#import "FHLynxRealtorBridge.h"

@interface FHHouseAgentCardCell ()


@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) FHShadowView *shadowView;

@property(nonatomic, strong) UIView *topInfoView;
@property(nonatomic, strong) UILabel *mainTitleLabel; //小区名称
@property(nonatomic, strong) UIView *bottomInfoView;
@property(nonatomic, strong) UIImageView *avator;
@property(nonatomic, strong) UIButton *callBtn;
@property(nonatomic, strong) UIButton *imBtn;
@property(nonatomic, strong) UILabel *name;
@property(nonatomic, strong) UILabel *agency;
@property (nonatomic, strong) UILabel     *score;
@property (nonatomic, strong) UILabel     *scoreDescription;
@property (nonatomic, strong) FHHomeHouseDataItemsModel *itemHomeModel;
@property(nonatomic, strong) FHDetailContactModel *modelData;
@property(nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property(nonatomic, strong) NSMutableDictionary *traceParams;
@property(nonatomic, strong) FHLynxView *lynxView;

@property(nonatomic, strong) YYLabel *tagLabel; // 标签 label

@end

@implementation FHHouseAgentCardCell

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
    [_shadowView setCornerRadius:10];
    [_shadowView setShadowColor:[UIColor colorWithRed:110.f/255.f green:110.f/255.f blue:110.f/255.f alpha:1]];
    [_shadowView setShadowOffset:CGSizeMake(0, 2)];
    _shadowView.hidden = YES;
    [self.contentView addSubview:_shadowView];

    _containerView = [[UIView alloc] init];
//    CALayer *layer = _containerView.layer;
//    layer.cornerRadius = 10;
//    layer.masksToBounds = YES;
//    layer.borderColor =  [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
//    layer.borderWidth = 0.5f;
    [self.contentView addSubview:_containerView];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(15);
        make.right.mas_equalTo(self).mas_offset(-15);
        make.top.mas_equalTo(self).offset(0);
        make.bottom.mas_equalTo(self).offset(0);
    }];
    
     [self.contentView setBackgroundColor:[UIColor themeHomeColor]];
     [_containerView setBackgroundColor:[UIColor whiteColor]];
    
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    
    if (NO) {
        [self setUpLynxView];
        return;
    }

    _topInfoView = [[UIView alloc] init];
    [self.containerView addSubview:_topInfoView];

    _mainTitleLabel = [[UILabel alloc] init];
    _mainTitleLabel.textAlignment = NSTextAlignmentLeft;
    _mainTitleLabel.textColor = [UIColor themeGray1];
    _mainTitleLabel.font = [UIFont themeFontSemibold:16];
    [self.topInfoView addSubview:_mainTitleLabel];

    _bottomInfoView = [[UIView alloc] init];
    [self.containerView addSubview:_bottomInfoView];
    

    _avator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_default_avatar"]];
    _avator.layer.cornerRadius = 23;
    _avator.contentMode = UIViewContentModeScaleAspectFill;
    _avator.clipsToBounds = YES;
    [self.bottomInfoView addSubview:_avator];


    _callBtn = [[FHExtendHotAreaButton alloc] init];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_normal_new"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press_new"] forState:UIControlStateSelected];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press_new"] forState:UIControlStateHighlighted];
    [self.bottomInfoView addSubview:_callBtn];

    _imBtn = [[FHExtendHotAreaButton alloc] init];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_normal_new"] forState:UIControlStateNormal];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press_new"] forState:UIControlStateSelected];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press_new"] forState:UIControlStateHighlighted];
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
     _score.font = [UIFont themeFontDINAlternateBold:14];
    _score.textAlignment = NSTextAlignmentLeft;
    [self.bottomInfoView addSubview:_score];
    
    _scoreDescription= [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _scoreDescription.textColor = [UIColor colorWithHexStr:@"6d7278"];
    _scoreDescription.textAlignment = NSTextAlignmentLeft;
    [self.bottomInfoView addSubview:_scoreDescription];

    [self.topInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(neighbourhoodInfoClick:)]];
    [self.bottomInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(realtorInfoClick)]];

    [self.callBtn addTarget:self action:@selector(phoneClick) forControlEvents:UIControlEventTouchUpInside];
    [self.imBtn addTarget:self action:@selector(imclick) forControlEvents:UIControlEventTouchUpInside];


    [self.topInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(22);
    }];

    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topInfoView).offset(16);
        make.left.mas_equalTo(self.topInfoView).offset(15);
        make.height.mas_equalTo(22);
        make.right.mas_lessThanOrEqualTo(self.topInfoView).offset(-10);
    }];

    [self.bottomInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topInfoView.mas_bottom).offset(16);
        make.left.mas_equalTo(self.containerView.mas_left);
        make.right.mas_equalTo(self.containerView.mas_right);
        make.height.mas_equalTo(76);
        make.left.right.mas_equalTo(self.containerView);
    }];


    [self.avator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(46);
        make.left.mas_equalTo(self.bottomInfoView).mas_offset(15);
        make.top.mas_equalTo(self.bottomInfoView).mas_offset(15);
    }];

    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avator.mas_right).offset(10);
        make.top.mas_equalTo(self.avator);
        make.height.mas_equalTo(22);
    }];
    
    [self.agency mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.name);
        make.height.mas_equalTo(17);
        make.left.mas_equalTo(self.name.mas_right).offset(4);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-4);
    }];
    
    [self.bottomInfoView addSubview:self.tagLabel];

    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).offset(8);
        make.left.equalTo(self.name);
    }];
//    [self.scoreDescription mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.score.mas_right).offset(3);
//        make.centerY.mas_equalTo(self.score);
//        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-4);
//    }];
//    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.name.mas_right).offset(5);
//        make.width.height.mas_equalTo(20);
//        make.centerY.mas_equalTo(self.name);
//        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-15);
//    }];
    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.right.mas_equalTo(self.bottomInfoView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.avator);
    }];
    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-30);
        make.centerY.mas_equalTo(self.avator);
    }];
 

}

- (void)setUpLynxView{
    _lynxView = [[FHLynxView alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 116)];
    [self.containerView addSubview:_lynxView];
    FHLynxViewBaseParams *baesparmas = [[FHLynxViewBaseParams alloc] init];
    baesparmas.channel = @"lynx_realtor_card";
    baesparmas.bridgePrivate = self;
    baesparmas.clsPrivate = [FHLynxRealtorBridge class];
    [_lynxView loadLynxWithParams:baesparmas];
}

- (void)bindData:(FHHouseNeighborAgencyModel *)model traceParams:(NSMutableDictionary *)params {
 
}


- (void)bindAgentData:(FHHomeHouseDataItemsModel *)itemModel traceParams:(NSMutableDictionary *)params {
    if (itemModel) {
        [self updateUIFromData:itemModel];
    }
}

-(YYLabel *)tagLabel
{
    if (!_tagLabel) {
        _tagLabel = [[YYLabel alloc]init];
        _tagLabel.numberOfLines = 0;
        _tagLabel.font = [UIFont themeFontRegular:12];
        _tagLabel.textColor = [UIColor themeGray3];
        _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _tagLabel;
}

- (void)updateUIFromData:(id)data{
     FHHomeHouseDataItemsModel *itemModel =  (FHHomeHouseDataItemsModel *)data;
     
        if (itemModel) {
            FHDetailContactModel *contactModel =  itemModel.contactModel;
            self.modelData = contactModel;
            self.itemHomeModel = itemModel;
            
   
            if (contactModel) {
                
                NSMutableDictionary *tracerDict = @{}.mutableCopy;
                if (self.traceParams) {
                      [tracerDict addEntriesFromDictionary:self.traceParams];
                }
                
                if (!self.phoneCallViewModel) {
                    self.phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeSecondHandHouse houseId:nil];
                }
                self.phoneCallViewModel.tracerDict = tracerDict;
                self.phoneCallViewModel.belongsVC = self.currentWeakVC;

                if (itemModel.contactModel && _lynxView) {
                  [_lynxView updateData:itemModel.contactModel.toDictionary];
                  return;
                }
                
                self.mainTitleLabel.text = contactModel.realtorDescription;
                self.name.text = contactModel.realtorName;
                self.agency.text = contactModel.agencyName;
                self.score.text = contactModel.realtorScoreDisplay;
                NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringWithTagList:itemModel.tags];
                self.tagLabel.attributedText =  attributeString;
                self.scoreDescription.text = contactModel.realtorScoreDescription;
                if (IS_EMPTY_STRING(self.scoreDescription.text) || IS_EMPTY_STRING(self.score.text)) {
                    [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.mas_equalTo(self.avator);
                        make.left.mas_equalTo(self.avator.mas_right).offset(10);
                        make.height.mas_equalTo(22);
                    }];
                    self.score.hidden = YES;
                    self.scoreDescription.hidden = YES;
                }
                if (contactModel.avatarUrl.length > 0) {
                    [self.avator bd_setImageWithURL:[NSURL URLWithString:contactModel.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
                }
    //            BOOL isLicenceIconHidden = ![self shouldShowContact:model.contactModel];

            } else {
                [self.bottomInfoView setHidden:YES];
            }
        }
}

- (void)refreshWithData:(id)data
{
    FHHomeHouseDataItemsModel *itemModel =  (FHHomeHouseDataItemsModel *)data;
    if (itemModel) {
        FHDetailContactModel *contactModel =  itemModel.contactModel;
        self.modelData = contactModel;
        self.itemHomeModel = itemModel;
        
        CALayer *layer = _containerView.layer;
        layer.cornerRadius = 10;
        layer.masksToBounds = YES;
        layer.borderColor =  [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        layer.borderWidth = 0.5f;
        _shadowView.hidden = NO;
        
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).mas_offset(15);
            make.right.mas_equalTo(self).mas_offset(-15);
            make.top.mas_equalTo(self).offset(10);
            make.bottom.mas_equalTo(self).offset(-10);
        }];


        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        
       [self updateUIFromData:itemModel];
    }
    
}

- (void)setCurrentWeakVC:(UIViewController *)currentWeakVC{
    _currentWeakVC = currentWeakVC;
    self.phoneCallViewModel.belongsVC = currentWeakVC;
}

+ (CGFloat)heightForData:(id)data
{
    return 136;// + 10;
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

- (void)imclick{
    if (self.modelData) {
        FHDetailContactModel *contact = self.modelData;
        if (self.phoneCallViewModel) {
            NSMutableDictionary *imExtra = @{}.mutableCopy;
            imExtra[@"realtor_position"] = @"neighborhood_expert_card";

            if(self.itemHomeModel.associateInfo) {
                imExtra[kFHAssociateInfo] = self.itemHomeModel.associateInfo;
            }
            imExtra[@"im_open_url"] = contact.imOpenUrl;
            [self.phoneCallViewModel imchatActionWithPhone:contact realtorRank:@"0" extraDic:imExtra];
        }
    }

}

- (void)phoneClick {
    if (self.modelData) {
        FHDetailContactModel *contact = self.itemHomeModel.contactModel;

        NSMutableDictionary *extraDict = @{}.mutableCopy;
        if (self.traceParams) {
            [extraDict addEntriesFromDictionary:self.traceParams];
        }
        extraDict[@"realtor_id"] = contact.realtorId;
        extraDict[@"realtor_rank"] = @"be_null";
        extraDict[@"realtor_position"] = @"neighborhood_expert_card";
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

        NSDictionary *associateInfoDict = self.itemHomeModel.associateInfo.phoneInfo;
        extraDict[kFHAssociateInfo] = associateInfoDict;
        FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
        associatePhone.reportParams = extraDict;
        associatePhone.associateInfo = associateInfoDict;
        associatePhone.realtorId = contact.realtorId;
        if ([self.itemHomeModel.logPb isKindOfClass:[NSDictionary class]]) {
            associatePhone.searchId = self.itemHomeModel.logPb[@"search_id"];
            associatePhone.imprId = self.itemHomeModel.logPb[@"impr_id"];
        }
        associatePhone.houseType = FHHouseTypeNeighborhood;
        associatePhone.showLoading = NO;
        [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhone completion:nil];
    }

}

- (void)licenseClick:(id)licenseClick {
    if (self.modelData) {
        if (self.phoneCallViewModel) {
//            [self.phoneCallViewModel licenseActionWithPhone:self.modelData.contactModel];
        }
    }
}

- (void)realtorInfoClick {
    if (self.modelData) {
        FHDetailContactModel *contact = self.modelData;
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
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@", self.modelData.id]];
//
//        NSMutableDictionary *tracerDict = @{}.mutableCopy;
//        if (self.traceParams) {
//            [tracerDict addEntriesFromDictionary:self.traceParams];
//        }
//        tracerDict[@"element_from"] = @"neighborhood_expert_card";
//        tracerDict[@"enter_from"] = self.traceParams[@"page_type"];
//        tracerDict[@"page_type"] = nil;
//        NSMutableDictionary *dict = @{@"house_type": @(FHHouseTypeNeighborhood), @"tracer": tracerDict}.mutableCopy;
//        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

@end
