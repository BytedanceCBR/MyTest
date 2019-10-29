//
// Created by fengbo on 2019-10-28.
//

#import <FHCommonUI/UIFont+House.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UILabel+House.h>
#import <Masonry/View+MASAdditions.h>
#import "FHNeighbourhoodAgencyCardCell.h"
#import "FHSearchHouseModel.h"
#import "UIColor+Theme.h"
#import "FHShadowView.h"
#import "FHHouseNeighborModel.h"
#import "FHExtendHotAreaButton.h"
#import "MASConstraintMaker.h"
#import "FHHouseNeighborModel.h"
#import "FHDetailBaseModel.h"
#import "BDWebImage.h"
#import "FHCommonDefines.h"


@interface FHNeighbourhoodAgencyCardCell ()


@property(nonatomic , strong) UIView *containerView;
@property(nonatomic , strong) UIView *shadowView;


@property(nonatomic, strong) UIView *topInfoView;
@property(nonatomic, strong) UILabel *mainTitleLabel; //小区名称
@property(nonatomic, strong) UILabel *pricePerSqmLabel; //房源价格
@property(nonatomic, strong) UILabel *countOnSale; //在售套数
@property(nonatomic, strong) UIImageView *rightArrow;

@property(nonatomic, strong) UIView *dividerView;

//TODO copy from somewhere
@property(nonatomic, strong) UIView *bottomInfoView;
@property (nonatomic, strong)   UIImageView *avator;
@property(nonatomic , strong)   UIImageView *identifyView;
@property (nonatomic, strong)   UIButton    *licenceIcon;
@property (nonatomic, strong)   UIButton    *callBtn;
@property (nonatomic, strong)   UIButton    *imBtn;
@property (nonatomic, strong)   UILabel     *name;
@property (nonatomic, strong)   UILabel     *agency;


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


- (void) initUI {

    _shadowView = [[FHShadowView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_shadowView];

    _containerView = [[UIView alloc] init];
    CALayer * layer = _containerView.layer;
    layer.cornerRadius = 4;
    layer.masksToBounds = YES;
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
    [self.bottomInfoView addSubview: _licenceIcon];

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

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(20);
        make.right.mas_equalTo(self).mas_offset(-20);
        make.top.mas_equalTo(self).offset(10);
        make.bottom.mas_equalTo(self);
    }];

    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];

    [self.topInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView);
        make.width.mas_equalTo(self.containerView);
        make.height.mas_equalTo(79);
    }];

    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topInfoView).offset(20);
        make.left.mas_equalTo(self.topInfoView).offset(20);
    }];


    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(self.topInfoView).offset(20);
    }];

    [self.countOnSale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(self.pricePerSqmLabel.mas_right).offset(9);
    }];

    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topInfoView).offset(-20);
        make.centerY.mas_equalTo(self.topInfoView);
    }];

    [self.dividerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.mas_equalTo(self.containerView).offset(20);
        make.right.mas_equalTo(self.containerView).offset(-20);
        make.top.mas_equalTo(self.topInfoView.mas_bottom);
    }];

    [self.bottomInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dividerView.mas_bottom);
        make.height.mas_equalTo(69);
        make.width.mas_equalTo(self.containerView);
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
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left);
    }];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.name.mas_right).offset(5);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
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


- (void)bindData:(FHHouseNeighborAgencyModel *)model {

    if (model) {
        [self.mainTitleLabel setText:model.neighborhoodName];
        [self.pricePerSqmLabel setText:model.neighborhoodPrice];
        [self.countOnSale setText:model.displayStatusInfo];

//        [itemView addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
//        [itemView.licenceIcon addTarget:self action:@selector(licenseClick:) forControlEvents:UIControlEventTouchUpInside];
//        [itemView.callBtn addTarget:self action:@selector(phoneClick:) forControlEvents:UIControlEventTouchUpInside];
//        [itemView.imBtn addTarget:self action:@selector(imclick:) forControlEvents:UIControlEventTouchUpInside];


        self.name.text = model.contactModel.realtorName;
        self.agency.text = model.contactModel.agencyName;
        if (model.contactModel.avatarUrl.length > 0) {
            [self.avator bd_setImageWithURL:[NSURL URLWithString:model.contactModel.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
        }

        //TODO fengbo
//        FHDetailContactImageTagModel *tag = obj.imageTag;
//        [self refreshIdentifyView:itemView.identifyView withUrl:tag.imageUrl];
//        if (tag.imageUrl.length > 0) {
//            [itemView.identifyView bd_setImageWithURL:[NSURL URLWithString:tag.imageUrl]];
//            itemView.identifyView.hidden = NO;
//        }else {
//            itemView.identifyView.hidden = YES;
//        }

//        BOOL isLicenceIconHidden = ![self shouldShowContact:obj];
//        [itemView configForLicenceIconWithHidden:isLicenceIconHidden];
//        if(obj.realtorEvaluate.length > 0) {
//            itemView.realtorEvaluate.text = obj.realtorEvaluate;
//        }
    }



}
@end