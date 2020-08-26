//
//  FHDetailSurveyAgentListCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/08/26.
//

#import "FHDetailSurveyAgentListCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHDetailNewModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHDetailFoldViewButton.h"
#import "UILabel+House.h"
#import <FHHouseBase/FHHouseFollowUpHelper.h>
#import <FHHouseBase/FHHousePhoneCallUtils.h>
#import "BTDMacros.h"
#import "FHDetailAgentItemView.h"

@interface FHDetailSurveyAgentListCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   FHDetailFoldViewButton       *foldButton;
@property (nonatomic, strong)   NSMutableDictionary       *tracerDicCache;

@end

@implementation FHDetailSurveyAgentListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailSurveyAgentListModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *)data;
    
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeDefault){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(-14);
            make.bottom.equalTo(self.contentView).offset(14);
        }];
    }

    // 设置下发标题
    if(model.recommendedRealtorsTitle.length > 0) {
        self.headerView.label.text = model.recommendedRealtorsTitle;
    }else {
        self.headerView.label.text = (model.houseType == FHHouseTypeNewHouse) ? @"优选顾问" : @"推荐经纪人";
    }
    if ((model.houseType == FHHouseTypeNewHouse)) {
        [self.headerView setSubTitleWithTitle:model.recommendedRealtorsSubTitle];
    }else{
        [self.headerView removeSubTitleWithTitle];
    }
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"element_type"] = [self elementTypeStringByHouseType:model.houseType];
    self.headerView.tracerDict = dict;
    self.headerView.showTipButton.hidden = NO;
    self.headerView.detailVC = (FHHouseDetailViewController *)model.belongsVC;
    
    WeakSelf;
    if (model.recommendedRealtors.count > 0) {
        __block NSInteger itemsCount = 0;
        __block CGFloat vHeight = 65;
        __block CGFloat marginTop = 0;
        [model.recommendedRealtors enumerateObjectsUsingBlock:^(FHDetailContactModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            StrongSelf;
            if (obj.realtorScoreDescription.length > 0 && obj.realtorScoreDisplay.length > 0 && obj.realtorTags.count > 0) {
                vHeight = 90;
            }else {
                vHeight = 65;
            }
            FHDetailAgentItemView *itemView = [[FHDetailAgentItemView alloc] initWithModel:obj topMargin:15];
            // 添加事件
            itemView.tag = idx;
            itemView.licenceIcon.tag = idx;
            itemView.callBtn.tag = idx;
            itemView.imBtn.tag = idx;
            [itemView addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
            [itemView.licenceIcon addTarget:self action:@selector(licenseClick:) forControlEvents:UIControlEventTouchUpInside];
            [itemView.callBtn addTarget:self action:@selector(phoneClick:) forControlEvents:UIControlEventTouchUpInside];
            [itemView.imBtn addTarget:self action:@selector(imclick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.containerView addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(marginTop);
                make.left.right.mas_equalTo(self.containerView);
                make.height.mas_equalTo(vHeight);
            }];
            marginTop = marginTop +vHeight;

            itemView.name.text = obj.realtorName;
            if (obj.realtorName.length >5 && obj.realtorCellShow == FHRealtorCellShowStyle3) {
                itemView.name.text = [NSString stringWithFormat:@"%@...",[obj.realtorName substringToIndex:5]];
            }
            itemView.agency.text = obj.agencyName;
            [itemView.avatorView updateAvatarWithModel:obj];
            if (obj.realtorCellShow == FHRealtorCellShowStyle0) {
                itemView.agency.font = [UIFont themeFontRegular:14];
            }
            BOOL isLicenceIconHidden = ![self shouldShowContact:obj];
            [itemView configForLicenceIconWithHidden:isLicenceIconHidden];
            if(obj.realtorEvaluate.length > 0) {
                itemView.realtorEvaluate.text = obj.realtorEvaluate;
            }
            if(obj.realtorScoreDisplay.length > 0) {
                  itemView.score.text = obj.realtorScoreDisplay;
              }
            if(obj.realtorScoreDescription.length > 0) {
                  itemView.scoreDescription.text = obj.realtorScoreDescription;
              }
            itemsCount += 1;
        }];
    }
    if (_foldButton) {
        [_foldButton removeFromSuperview];
        _foldButton = nil;
    }
    // > 3 添加折叠展开
    if (model.recommendedRealtors.count > 3) {
        _foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部" upText:@"收起" isFold:YES];
        _foldButton.openImage = [UIImage imageNamed:@"message_more_arrow"];
        _foldButton.foldImage = [UIImage imageNamed:@"message_flod_arrow"];
        _foldButton.keyLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
         _foldButton.keyLabel.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:_foldButton];
        [_foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView.mas_bottom);
            make.height.mas_equalTo(58);
            make.left.right.mas_equalTo(self.contentView);
        }];
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.shadowImage).offset(-78);
        }];
        [self.foldButton addTarget:self action:@selector(foldButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self updateItems:NO];
}

// cell点击
- (void)cellClick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *)self.currentData;
    if (model.houseType == FHHouseTypeNewHouse) {
        return;
    }
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        model.phoneCallViewModel.belongsVC = model.belongsVC;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"element_from"] = @"actually_survey";
        dict[@"enter_from"] = [self.baseViewModel pageTypeString];
        [model.phoneCallViewModel jump2RealtorDetailWithPhone:contact isPreLoad:NO extra:dict];
    }
}

// 证书点击
- (void)licenseClick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        [model.phoneCallViewModel licenseActionWithPhone:contact];
    }
}

// 电话点击
- (void)phoneClick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        extraDict[@"realtor_id"] = contact.realtorId;
        extraDict[@"realtor_rank"] = @(index);
        extraDict[@"realtor_position"] = @"actually_survey";
        extraDict[@"realtor_logpb"] = contact.realtorLogpb;
        if (self.baseViewModel.detailTracerDic) {
            [extraDict addEntriesFromDictionary:self.baseViewModel.detailTracerDic];
        }
        NSDictionary *associateInfoDict = model.associateInfo.phoneInfo;
        extraDict[kFHAssociateInfo] = associateInfoDict;
        FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
        associatePhone.reportParams = extraDict;
        associatePhone.associateInfo = associateInfoDict;
        associatePhone.realtorId = contact.realtorId;
        associatePhone.searchId = model.searchId;
        associatePhone.imprId = model.imprId;

        associatePhone.houseType = self.baseViewModel.houseType;
        associatePhone.houseId = self.baseViewModel.houseId;
        associatePhone.showLoading = NO;
        
        if (contact.bizTrace) {
            associatePhone.extraDict = @{@"biz_trace":contact.bizTrace};
        }
        
        //        FHHouseContactConfigModel *contactConfig = [[FHHouseContactConfigModel alloc]initWithDictionary:extraDict error:nil];
//        contactConfig.houseType = self.baseViewModel.houseType;
//        contactConfig.houseId = self.baseViewModel.houseId;
//        contactConfig.phone = contact.phone;
//        contactConfig.realtorId = contact.realtorId;
//        contactConfig.searchId = model.searchId;
//        contactConfig.imprId = model.imprId;
//        contactConfig.realtorType = contact.realtorType;
//        if (self.baseViewModel.houseType == FHHouseTypeNeighborhood) {
//            contactConfig.cluePage = @(FHClueCallPageTypeCNeighborhoodMulrealtor);
//        }else if (self.baseViewModel.houseType == FHHouseTypeNewHouse) {
//            contactConfig.cluePage = @(FHClueCallPageTypeCNewHouseMulrealtor);
//        }else {
//            contactConfig.from = contact.realtorType == FHRealtorTypeNormal ? @"app_oldhouse_mulrealtor" : @"app_oldhouse_expert_mid";
//        }
        
        [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhone completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {

            if(success && [model.belongsVC isKindOfClass:[FHHouseDetailViewController class]]){
                FHHouseDetailViewController *vc = (FHHouseDetailViewController *)model.belongsVC;
                vc.isPhoneCallShow = YES;
                vc.phoneCallRealtorId = contact.realtorId;
                vc.phoneCallRequestId = virtualPhoneNumberModel.requestId;
            }
        }];

        FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:extraDict error:nil];
        configModel.houseType = self.baseViewModel.houseType;
        configModel.followId = self.baseViewModel.houseId;
        configModel.actionType = self.baseViewModel.houseType;
        
        // 静默关注功能
        [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];
    }
}

// 点击会话
- (void)imclick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        NSMutableDictionary *imExtra = @{}.mutableCopy;
        imExtra[@"realtor_position"] = @"actually_survey";
        
        switch (self.baseViewModel.houseType) {
            case FHHouseTypeNewHouse:
            {
                if([self.baseViewModel.detailData isKindOfClass:FHDetailNewModel.class]) {
                    FHDetailNewModel *detailNewModel = (FHDetailNewModel *)self.baseViewModel.detailData;
                    if(detailNewModel.data.recommendRealtorsAssociateInfo) {
                        imExtra[kFHAssociateInfo] =  detailNewModel.data.recommendRealtorsAssociateInfo;
                    }
                }
            }
                break;
            case FHHouseTypeSecondHandHouse:
            {
                imExtra[kFHAssociateInfo] =  model.associateInfo;
            }
                break;
            case FHHouseTypeNeighborhood:
            {
                if([self.baseViewModel.detailData isKindOfClass:FHDetailNeighborhoodModel.class]) {
                    FHDetailNeighborhoodModel *detailNeighborhoodModel = (FHDetailNeighborhoodModel *)self.baseViewModel.detailData;
                    if(detailNeighborhoodModel.data.recommendRealtorsAssociateInfo) {
                        imExtra[kFHAssociateInfo] =  detailNeighborhoodModel.data.recommendRealtorsAssociateInfo;
                    }
                }
            }
                break;
            default:
                break;
        }
        [model.phoneCallViewModel imchatActionWithPhone:contact realtorRank:[NSString stringWithFormat:@"%ld", (long)index] extraDic:imExtra];
    }
}

- (void)foldButtonClick:(UIButton *)button {
    FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *)self.currentData;
    model.isFold = !model.isFold;
    self.foldButton.isFold = model.isFold;
    [self updateItems:YES];
    [self addRealtorShowLog];
}

- (BOOL)shouldShowContact:(FHDetailContactModel* )contact {
    BOOL result  = NO;
    if (contact.businessLicense.length > 0) {
        result = YES;
    }
    if (contact.certificate.length > 0) {
        result = YES;
    }
    return result;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _tracerDicCache = [NSMutableDictionary new];
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-14);
        make.bottom.equalTo(self.contentView).offset(14);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"推荐经纪人";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(20);
        make.right.mas_equalTo(self.shadowImage).offset(-15);
        make.left.mas_equalTo(self.shadowImage).offset(15);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.mas_equalTo(self.shadowImage).mas_offset(15);
        make.right.mas_equalTo(self.shadowImage).mas_offset(-15);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.shadowImage).offset(-30);
    }];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)updateItems:(BOOL)animated {
    FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *)self.currentData;
    NSInteger realtorShowCount = 0;
    if (model.recommendedRealtors.count > 3) {
        if (animated) {
            [model.tableView beginUpdates];
        }
        if (model.isFold) {
            CGFloat showHeight = 0;
            for (int i = 0; i<3; i++) {
                FHDetailContactModel *showModel = (FHDetailContactModel*) model.recommendedRealtors[i];
                if (showModel.realtorScoreDisplay.length>0 && showModel.realtorScoreDescription.length>0&&showModel.realtorTags.count >0) {
                    showHeight = showHeight + 90;
                }else {
                    showHeight = showHeight + 65;
                };
            }
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(showHeight);
            }];
            realtorShowCount = 3;
        } else {
           __block CGFloat showHeight = 0;
            [model.recommendedRealtors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHDetailContactModel *showModel = obj;
            if (showModel.realtorScoreDisplay.length>0 && showModel.realtorScoreDescription.length>0&&showModel.realtorTags.count >0) {
                     showHeight = showHeight + 90;
                 }else {
                     showHeight = showHeight + 65;
                 };
            }];
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(showHeight);
            }];
            realtorShowCount = model.recommendedRealtors.count;
            [self addRealtorClickMore];
        }
        [self setNeedsUpdateConstraints];
        if (animated) {
            [model.tableView endUpdates];
        }
    } else if (model.recommendedRealtors.count > 0) {
        __block CGFloat showHeight = 0;
         [model.recommendedRealtors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             FHDetailContactModel *showModel = obj;
         if (showModel.realtorScoreDisplay.length > 0 && showModel.realtorScoreDescription.length > 0 && showModel.realtorTags.count > 0) {
             //二手房的经纪人一般会展示tag，新房顾问没有
                  showHeight = showHeight + 90;
              }else {
                  showHeight = showHeight + 65;
              };
         }];
         [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.height.mas_equalTo(showHeight);
         }];
         realtorShowCount = model.recommendedRealtors.count;
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        realtorShowCount = 0;
    }
//    [self tracerRealtorShowToIndex:realtorShowCount];
}

//- (void)fh_willDisplayCell;{
//    [self addRealtorShowLog];
//}

#pragma mark - FHDetailScrollViewDidScrollProtocol

// 滑动house_show埋点
- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
    CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
    FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *) self.currentData;
    CGFloat showHeight = 0;
    for (int m = 0; m <model.recommendedRealtors.count; m++) {
        FHDetailContactModel *showModel = model.recommendedRealtors[m];
        if (showModel.realtorScoreDisplay.length>0 && showModel.realtorScoreDescription.length>0&&showModel.realtorTags.count >0) {
            showHeight = showHeight + 90;
        }else {
            showHeight = showHeight + 70;
        };
        if (UIScreen.mainScreen.bounds.size.height - point.y > showHeight) {
            NSInteger showCount = model.isFold ? MIN(m, 2):MIN(model.recommendedRealtors.count, m);
            [self tracerRealtorShowToIndex:showCount];
        };
    }
}

-(void)addRealtorShowLog{
    FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *) self.currentData;
    NSInteger showCount = model.isFold ? MIN(model.recommendedRealtors.count, 2): model.recommendedRealtors.count;
    [self tracerRealtorShowToIndex:showCount];
}

- (NSString *)elementTypeStringByHouseType:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNeighborhood:
            return @"neighborhood_detail_related";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_detail_related";
            break;
        case FHHouseTypeNewHouse:
            return @"new_detail_related";
            break;
        default:
            break;
    }
    return @"be_null";
}

- (void)tracerRealtorShowToIndex:(NSInteger)index {
    for (int i = 0; i <= index; i++) {
        NSString *cahceKey = [NSString stringWithFormat:@"%d",i];
        if (self.tracerDicCache[cahceKey]) {
            continue;
        }
        self.tracerDicCache[cahceKey] = @(YES);
        FHDetailSurveyAgentListModel *model = (FHDetailSurveyAgentListModel *)self.currentData;
        if (i < model.recommendedRealtors.count) {
            FHDetailContactModel *contact = model.recommendedRealtors[i];
            NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
            tracerDic[@"element_type"] = [self elementTypeStringByHouseType:self.baseViewModel.houseType];
            tracerDic[@"realtor_id"] = contact.realtorId ?: @"be_null";
            tracerDic[@"realtor_rank"] = @(i);
            tracerDic[@"realtor_position"] = @"actually_survey";
            tracerDic[@"realtor_logpb"] = contact.realtorLogpb;
            tracerDic[@"biz_trace"] = contact.bizTrace;
            [tracerDic setValue:contact.enablePhone ? @"1" : @"0" forKey:@"phone_show"];
            if (![@"" isEqualToString:contact.imOpenUrl] && contact.imOpenUrl != nil) {
                [tracerDic setValue:@"1" forKey:@"im_show"];
            } else {
                [tracerDic setValue:@"0" forKey:@"im_show"];
            }
            // 移除字段
            [tracerDic removeObjectsForKeys:@[@"card_type",@"element_from",@"search_id"]];
            [FHUserTracker writeEvent:@"realtor_show" params:tracerDic];
        }
    }
}

- (void)addRealtorClickMore {
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    // 移除字段
    [tracerDic removeObjectsForKeys:@[@"card_type",@"element_from",@"search_id",@"enter_from"]];
    [FHUserTracker writeEvent:@"realtor_click_more" params:tracerDic];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    switch (houseType) {
        case FHHouseTypeSecondHandHouse:
            return @"old_detail_related";
            break;
        case FHHouseTypeNeighborhood:
            return @"neighborhood_detail_related";
        case FHHouseTypeNewHouse:
               return @"new_detail_related";
        default:
            break;
    }
    return @"be_null";
}

@end

// FHDetailSurveyAgentListModel
@implementation FHDetailSurveyAgentListModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFold = YES;
    }
    return self;
}

@end

