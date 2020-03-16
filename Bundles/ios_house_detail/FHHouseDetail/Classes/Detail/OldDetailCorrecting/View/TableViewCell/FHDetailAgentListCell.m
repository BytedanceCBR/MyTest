//
//  FHDetailAgentListCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailAgentListCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "FHDetailFoldViewButton.h"
#import "UILabel+House.h"
#import <FHHouseBase/FHHouseFollowUpHelper.h>
#import <FHHouseBase/FHHousePhoneCallUtils.h>
#import "BTDMacros.h"

@interface FHDetailAgentListCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   FHDetailFoldViewButton       *foldButton;
@property (nonatomic, strong)   NSMutableDictionary       *tracerDicCache;

@end

@implementation FHDetailAgentListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailAgentListModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)data;
    
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

    // 设置下发标题
    if(model.recommendedRealtorsTitle.length > 0) {
        self.headerView.label.text = model.recommendedRealtorsTitle;
    }else {
        self.headerView.label.text = (model.houseType == FHHouseTypeNewHouse) ? @"优选顾问" : @"推荐经纪人";
    }
    WeakSelf;
    if (model.recommendedRealtors.count > 0) {
        __block NSInteger itemsCount = 0;
        __block CGFloat vHeight = 76.0;
        __block CGFloat marginTop = 0;
        [model.recommendedRealtors enumerateObjectsUsingBlock:^(FHDetailContactModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            StrongSelf;
            if (obj.realtorScoreDescription.length >0&&obj.realtorScoreDisplay.length >0&&obj.realtorTags.count >0) {
                vHeight = 100;
            }else {
                vHeight = 76;
            }
            FHDetailAgentItemView *itemView = [[FHDetailAgentItemView alloc] initWithModel:obj];
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
            itemView.agency.text = obj.agencyName;
            if (obj.avatarUrl.length > 0) {
                [itemView.avator bd_setImageWithURL:[NSURL URLWithString:obj.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
            }
            FHDetailContactImageTagModel *tag = obj.imageTag;
            [self refreshIdentifyView:itemView.identifyView withUrl:tag.imageUrl];
            if (tag.imageUrl.length > 0) {
                [itemView.identifyView bd_setImageWithURL:[NSURL URLWithString:tag.imageUrl]];
                itemView.identifyView.hidden = NO;
            }else {
                itemView.identifyView.hidden = YES;
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
    // > 3 添加折叠展开
    if (model.recommendedRealtors.count > 3) {
        if (_foldButton) {
            [_foldButton removeFromSuperview];
            _foldButton = nil;
        }
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
            make.bottom.mas_equalTo(self.shadowImage).offset(-93);
        }];
        [self.foldButton addTarget:self action:@selector(foldButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.shadowImage).offset(-35);
        }];
    }
    [self updateItems:NO];
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
                    make.width.mas_equalTo(44);
                }];
            }
        }];
        identifyView.hidden = NO;
    }else {
        identifyView.hidden = YES;
    }
}

// cell点击
- (void)cellClick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    if (model.houseType == FHHouseTypeNewHouse) {
        return;
    }
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        model.phoneCallViewModel.belongsVC = model.belongsVC;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"element_from"] = [self elementTypeStringByHouseType:self.baseViewModel.houseType];
        dict[@"enter_from"] = [self.baseViewModel pageTypeString];
        [model.phoneCallViewModel jump2RealtorDetailWithPhone:contact isPreLoad:NO extra:dict];
    }
}

// 证书点击
- (void)licenseClick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        [model.phoneCallViewModel licenseActionWithPhone:contact];
    }
}

// 电话点击
- (void)phoneClick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        extraDict[@"realtor_id"] = contact.realtorId;
        extraDict[@"realtor_rank"] = @(index);
        extraDict[@"realtor_position"] = @"detail_related";
        extraDict[@"realtor_logpb"] = contact.realtorLogpb;
        if (self.baseViewModel.detailTracerDic) {
            [extraDict addEntriesFromDictionary:self.baseViewModel.detailTracerDic];
        }

        FHHouseContactConfigModel *contactConfig = [[FHHouseContactConfigModel alloc]initWithDictionary:extraDict error:nil];
        contactConfig.houseType = self.baseViewModel.houseType;
        contactConfig.houseId = self.baseViewModel.houseId;
        contactConfig.phone = contact.phone;
        contactConfig.realtorId = contact.realtorId;
        contactConfig.searchId = model.searchId;
        contactConfig.imprId = model.imprId;
        contactConfig.realtorType = contact.realtorType;
        if (self.baseViewModel.houseType == FHHouseTypeNeighborhood) {
            contactConfig.cluePage = @(FHClueCallPageTypeCNeighborhoodMulrealtor);
        }else if (self.baseViewModel.houseType == FHHouseTypeNewHouse) {
            contactConfig.cluePage = @(FHClueCallPageTypeCNewHouseMulrealtor);
        }else {
            contactConfig.from = contact.realtorType == FHRealtorTypeNormal ? @"app_oldhouse_mulrealtor" : @"app_oldhouse_expert_mid";
        }
        [FHHousePhoneCallUtils callWithConfigModel:contactConfig completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
            if(success && [model.belongsVC isKindOfClass:[FHHouseDetailViewController class]]){
                FHHouseDetailViewController *vc = (FHHouseDetailViewController *)model.belongsVC;
                vc.isPhoneCallShow = YES;
                vc.phoneCallRealtorId = contactConfig.realtorId;
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
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        NSMutableDictionary *imExtra = @{}.mutableCopy;
        imExtra[@"realtor_position"] = @"detail_related";
        if (self.baseViewModel.houseType == FHHouseTypeNeighborhood) {
            imExtra[kFHClueEndpoint] = @(FHClueEndPointTypeC);
            imExtra[kFHCluePage] = [NSString stringWithFormat:@"%ld",FHClueIMPageTypeCNeighborhoodMulrealtor];
        }else if (self.baseViewModel.houseType == FHHouseTypeNewHouse) {
            imExtra[kFHClueEndpoint] = @(FHClueEndPointTypeC);
            imExtra[kFHCluePage] = [NSString stringWithFormat:@"%ld",FHClueIMPageTypeCNewHouseMulrealtor];
        }else {
            imExtra[@"from"] = contact.realtorType == FHRealtorTypeNormal ? @"app_oldhouse_mulrealtor" : @"app_oldhouse_expert_mid";
        }
        [model.phoneCallViewModel imchatActionWithPhone:contact realtorRank:[NSString stringWithFormat:@"%d", index] extraDic:imExtra];
    }
}

- (void)foldButtonClick:(UIButton *)button {
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
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
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"推荐经纪人";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(30);
        make.right.mas_equalTo(self.shadowImage).offset(-15);
        make.left.mas_equalTo(self.shadowImage).offset(15);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(15);
        make.left.mas_equalTo(self.shadowImage).mas_offset(15);
        make.right.mas_equalTo(self.shadowImage).mas_offset(-15);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.shadowImage).offset(-35);
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
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
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
                    showHeight = showHeight +100;
                }else {
                    showHeight = showHeight + 76;
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
                     showHeight = showHeight +100;
                 }else {
                     showHeight = showHeight + 76;
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
         if (showModel.realtorScoreDisplay.length>0 && showModel.realtorScoreDescription.length>0&&showModel.realtorTags.count >0) {
                  showHeight = showHeight +100;
              }else {
                  showHeight = showHeight + 76;
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
    FHDetailAgentListModel *model = (FHDetailAgentListModel *) self.currentData;
    __block CGFloat showHeight = 0;
    for (int m = 0; m <model.recommendedRealtors.count; m++) {
        FHDetailContactModel *showModel = model.recommendedRealtors[m];
        if (showModel.realtorScoreDisplay.length>0 && showModel.realtorScoreDescription.length>0&&showModel.realtorTags.count >0) {
            showHeight = showHeight +100;
        }else {
            showHeight = showHeight + 76;
        };
        if (UIScreen.mainScreen.bounds.size.height - point.y>showHeight) {
            NSInteger showCount = model.isFold ? MIN(m, 3):MIN(model.recommendedRealtors.count, m);
            [self tracerRealtorShowToIndex:showCount];
        };
    }
}

-(void)addRealtorShowLog{
    FHDetailAgentListModel *model = (FHDetailAgentListModel *) self.currentData;
    NSInteger showCount = model.isFold ? MIN(model.recommendedRealtors.count, 3): model.recommendedRealtors.count;
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
    for (int i = 0; i< index; i++) {
        NSString *cahceKey = [NSString stringWithFormat:@"%d",i];
        if (self.tracerDicCache[cahceKey]) {
            continue;
        }
        self.tracerDicCache[cahceKey] = @(YES);
        FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
        if (i < model.recommendedRealtors.count) {
            FHDetailContactModel *contact = model.recommendedRealtors[i];
            NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
            tracerDic[@"element_type"] = [self elementTypeStringByHouseType:self.baseViewModel.houseType];
            tracerDic[@"realtor_id"] = contact.realtorId ?: @"be_null";
            tracerDic[@"realtor_rank"] = @(i);
            tracerDic[@"realtor_position"] = @"detail_related";
            tracerDic[@"realtor_logpb"] = contact.realtorLogpb;
            if (contact.phone.length < 1) {
                [tracerDic setValue:@"0" forKey:@"phone_show"];
            } else {
                [tracerDic setValue:@"1" forKey:@"phone_show"];
            }
            if (![@"" isEqualToString:contact.imOpenUrl] && contact.imOpenUrl != nil) {
                [tracerDic setValue:@"1" forKey:@"im_show"];
            } else {
                [tracerDic setValue:@"0" forKey:@"im_show"];
            }
            // 移除字段
            [tracerDic removeObjectsForKeys:@[@"card_type",@"element_from",@"search_id"]];
            [FHUserTracker  writeEvent:@"realtor_show" params:tracerDic];
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


// FHDetailAgentItemView
@interface FHDetailAgentItemTagsViewCell: UICollectionViewCell

@property (nonatomic, strong) UILabel *tagLabel;

+ (NSString *)reuseIdentifier;
@end

@implementation FHDetailAgentItemTagsViewCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

-(UILabel *)tagLabel {
    if(!_tagLabel) {
        _tagLabel = [[UILabel alloc]init];
        _tagLabel.font = [UIFont themeFontMedium:10];
        _tagLabel.numberOfLines = 1;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.tagLabel];
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
            
        }];

        self.contentView.layer.cornerRadius = 2;
//        self.contentView.layer.masksToBounds = YES;
    }
    return self;
}
@end

@interface FHDetailAgentItemTagsFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat maximumInteritemSpacing;

@end

@implementation FHDetailAgentItemTagsFlowLayout
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //使用系统帮我们计算好的结果。
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    //第0个cell没有上一个cell，所以从1开始
    for(int i = 1; i < [attributes count]; ++i) {
        //这里 UICollectionViewLayoutAttributes 的排列总是按照 indexPath的顺序来的。
        UICollectionViewLayoutAttributes *curAttr = attributes[i];
        UICollectionViewLayoutAttributes *preAttr = attributes[i-1];
        
        NSInteger origin = CGRectGetMaxX(preAttr.frame);
        //根据  maximumInteritemSpacing 计算出的新的 x 位置
        CGFloat targetX = origin + self.maximumInteritemSpacing;
        // 只有系统计算的间距大于  maximumInteritemSpacing 时才进行调整
        if (CGRectGetMinX(curAttr.frame) > targetX) {
            // 换行时不用调整
            if (targetX + CGRectGetWidth(curAttr.frame) <= self.collectionViewContentSize.width) {
                CGRect frame = curAttr.frame;
                frame.origin.x = targetX;
                curAttr.frame = frame;
            } else {
                CGRect frame = curAttr.frame;
                frame.size.width = 0;
                curAttr.frame = frame;
            }
        }
    }
    return attributes;
}
-(instancetype)init {
    if(self = [super init]) {
        self.maximumInteritemSpacing = 6.0f;
        self.minimumInteritemSpacing = 6.0f;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}
@end

@interface FHDetailAgentItemView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) FHDetailContactModel *model;
@property (nonatomic, strong) UICollectionView *tagsView;
@property (nonatomic, strong) UIView *vSepLine;
@end

@implementation FHDetailAgentItemView

-(UILabel *)realtorEvaluate {
    if(!_realtorEvaluate) {
        _realtorEvaluate = [UILabel new];
        _realtorEvaluate.textColor = [UIColor themeGray3];
        _realtorEvaluate.font = [UIFont themeFontRegular:12];
    }
    return _realtorEvaluate;
}

- (UICollectionView *)tagsView {
    if(!_tagsView) {
        _tagsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[FHDetailAgentItemTagsFlowLayout alloc] init]];
        _tagsView.scrollEnabled = NO;
        _tagsView.backgroundColor = [UIColor whiteColor];
        _tagsView.delegate = self;
        _tagsView.dataSource = self;

        [_tagsView registerClass:[FHDetailAgentItemTagsViewCell class] forCellWithReuseIdentifier:[FHDetailAgentItemTagsViewCell reuseIdentifier]];
    }
    return _tagsView;
}

- (UIView *)vSepLine {
    if(!_vSepLine) {
        _vSepLine = [UIView new];
        _vSepLine.backgroundColor = [UIColor themeGray6];
    }
    return _vSepLine;
}




-(instancetype)initWithModel:(FHDetailContactModel *)model {
    
    if(self = [super init]){
        self.model = model;
        switch (self.model.realtorCellShow) {
            case FHRealtorCellShowStyle1: // 经纪人名字和公司名字左右排列的样式: 标签
                [self layoutForStyle1];
                break;
            case FHRealtorCellShowStyle2: // 经纪人名字和公司名字左右排列的样式: 话术
                [self layoutForStyle2];
                break;
            case FHRealtorCellShowStyle0: // 经纪人名字和公司名字上下排列的样式
            default:
                [self layoutForStyle0];
                break;
        }
    }
    return self;
}

- (void)layoutForStyle0 {
    [self setupUI];
    if (self.model.realtorScoreDisplay.length <= 0 || self.model.realtorScoreDescription.length <=0) {
           self.score.hidden = YES;
           self.scoreDescription.hidden = YES;
       }
}

- (void)layoutForStyle1 {
    [self setupUI];
    [self modifiedLayoutNameNeedShowCenter:self.model.realtorTags.count >0||(self.model.realtorScoreDisplay.length>0&&self.model.realtorScoreDescription.length>0)];
    [self addSubview:self.tagsView];
    if (self.model.realtorScoreDisplay.length>0 && self.model.realtorScoreDescription.length>0) {
         [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.height.mas_equalTo(15);
               make.left.equalTo(self.name);
               make.right.equalTo(self.imBtn.mas_left).offset(-10);
             make.top.equalTo(self.score.mas_bottom).offset(self.model.realtorTags.count>0?6:8);
           }];
    }else {
        self.score.hidden = YES;
        self.scoreDescription.hidden = YES;
        [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
              make.height.mas_equalTo(15);
              make.left.equalTo(self.name);
              make.right.equalTo(self.imBtn.mas_left).offset(-10);
              make.top.equalTo(self.name.mas_bottom).offset(8);
          }];
    }
}

- (void)layoutForStyle2 {
    [self setupUI];
    [self modifiedLayoutNameNeedShowCenter:self.model.realtorEvaluate.length>0||(self.model.realtorScoreDisplay.length>0&&self.model.realtorScoreDescription.length>0)];
    [self addSubview:self.realtorEvaluate];
    if (self.model.realtorScoreDisplay.length>0 && self.model.realtorScoreDescription.length>0) {
         [self.realtorEvaluate mas_makeConstraints:^(MASConstraintMaker *make) {
             make.height.mas_equalTo(17);
             make.left.equalTo(self.name);
             make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
             make.top.equalTo(self.score.mas_bottom).offset(self.model.realtorTags.count>0?6:8);
         }];
    }else {
        self.score.hidden = YES;
        self.scoreDescription.hidden = YES;
        [self.realtorEvaluate mas_makeConstraints:^(MASConstraintMaker *make) {
              make.height.mas_equalTo(17);
              make.left.equalTo(self.name);
              make.right.equalTo(self.imBtn.mas_left).offset(-10);
              make.top.equalTo(self.name.mas_bottom).offset(8);
          }];
    }

}

-(void)modifiedLayoutNameNeedShowCenter:(BOOL )showCenter{
    
    [self addSubview: self.vSepLine];
    
    [self.vSepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(14);
        make.centerY.equalTo(self.name);
        make.left.equalTo(self.name.mas_right).offset(6);
    }];
    [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avator.mas_right).offset(14);
            if(!showCenter){
                make.centerY.equalTo(self.avator);
            }else {
                make.top.mas_equalTo(self.avator).offset(4);
            }
            make.height.mas_equalTo(20);
        }];
    [self.name setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    [self.agency mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.name);
        make.height.mas_equalTo(20);
        make.left.equalTo(self.vSepLine.mas_right).offset(6);
        make.right.equalTo(self.licenceIcon.mas_left).offset(-5);
    }];
    
    [self.agency setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.licenceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.agency.mas_right).offset(5);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
    }];
}

-(void)configForLicenceIconWithHidden:(BOOL)isHidden {
    
    self.licenceIcon.hidden = isHidden;
    
    switch (self.model.realtorCellShow) {
        case FHRealtorCellShowStyle1:
        case FHRealtorCellShowStyle2:
        {
            [self.agency mas_updateConstraints:^(MASConstraintMaker *make) {
                if(self.licenceIcon.hidden){
                    make.right.equalTo(self.imBtn.mas_left).offset(-10);
                } else {
                    make.right.equalTo(self.licenceIcon.mas_left).offset(-5);
                }
            }];
        }
            break;
        case FHRealtorCellShowStyle0:
        default:
            NSLog(@"Do nothing!");
            break;
    }
}

- (void)setupUI {
    _avator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_default_avatar"]];
    _avator.layer.cornerRadius = 23;
    _avator.contentMode = UIViewContentModeScaleAspectFill;
    _avator.clipsToBounds = YES;
    [self addSubview:_avator];
    
    [self addSubview:self.identifyView];

    _licenceIcon = [[FHExtendHotAreaButton alloc] init];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateNormal];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateSelected];
    [_licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateHighlighted];
    [self addSubview:_licenceIcon];
    
    _callBtn = [[FHExtendHotAreaButton alloc] init];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_normal_new"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press_new"] forState:UIControlStateSelected];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press_new"] forState:UIControlStateHighlighted];
    [self addSubview:_callBtn];
    
    _imBtn = [[FHExtendHotAreaButton alloc] init];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_normal_new"] forState:UIControlStateNormal];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press_new"] forState:UIControlStateSelected];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press_new"] forState:UIControlStateHighlighted];
    [self addSubview:_imBtn];
    
    self.name = [UILabel createLabel:@"" textColor:@"" fontSize:18];
    _name.textColor = [UIColor themeGray1];
    _name.font = [UIFont themeFontMedium:18];
    _name.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_name];
    
    self.agency = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _agency.textColor = [UIColor themeGray3];
    _agency.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_agency];
    
    self.score = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _score.textColor = [UIColor themeGray1];
    _score.font = [UIFont themeFontMedium:14];
    _score.textAlignment = NSTextAlignmentLeft;
    [_score setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_score setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:_score];
    
    self.scoreDescription = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _scoreDescription.textColor = [UIColor themeGray2];
    _scoreDescription.textAlignment = NSTextAlignmentLeft;

    [self addSubview:_scoreDescription];
    
    [self.avator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(46);
        make.left.mas_equalTo(16);
        make.centerY.mas_equalTo(self);
    }];
    CGFloat ratio = 0;
    [self.identifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avator).mas_offset(27);
        make.centerX.mas_equalTo(self.avator);
        make.height.mas_equalTo(19);
        make.width.mas_equalTo(44);
    }];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avator.mas_right).offset(14);
        make.top.mas_equalTo(self.avator).offset(4);
        make.height.mas_equalTo(22);
    }];
    [self.agency mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.name.mas_bottom);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.avator.mas_right).offset(14);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left);
    }];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.name.mas_right).offset(4);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
    }];
    
    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.name).offset(-5);
    }];
    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-20);
        make.top.mas_equalTo(self.name).offset(-5);
    }];
    
    [self.score mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name);
        make.top.equalTo(self.name.mas_bottom).offset(6);
    }];
    [self.scoreDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.score.mas_right).offset(2);
        make.right.mas_lessThanOrEqualTo(self).offset(-20);
        make.centerY.equalTo(self.score);
    }];
}


- (UIImageView *)identifyView
{
    if (!_identifyView) {
        _identifyView = [[UIImageView alloc]init];
    }
    return _identifyView;
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FHRealtorTag *tagInfo = [self.model.realtorTags objectAtIndex:indexPath.row];
    UIColor *fontColor = [UIColor colorWithHexStr:tagInfo.fontColor];
    UIColor *backgroundColor = [UIColor colorWithHexStr:tagInfo.backgroundColor];
    if(fontColor && backgroundColor) {
        CGSize itemSize = [tagInfo.text sizeWithAttributes:@{
                                                  NSForegroundColorAttributeName: fontColor,
                                                  NSBackgroundColorAttributeName: backgroundColor,
                                                  NSFontAttributeName: [UIFont themeFontRegular:10]
                                                  }];
        
        itemSize.width += 8;
        return itemSize;
    }
    return CGSizeZero;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.realtorTags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHDetailAgentItemTagsViewCell *tagCell = [collectionView dequeueReusableCellWithReuseIdentifier:[FHDetailAgentItemTagsViewCell reuseIdentifier] forIndexPath:indexPath];
    
    FHRealtorTag *tagInfo = [self.model.realtorTags objectAtIndex:indexPath.row];
    
    tagCell.tagLabel.text = tagInfo.text;
    tagCell.contentView.backgroundColor = [UIColor colorWithHexStr:tagInfo.backgroundColor];
    tagCell.contentView.layer.borderColor = [UIColor colorWithHexStr:tagInfo.borderColor].CGColor;
    tagCell.contentView.layer.borderWidth = .3;
    tagCell.tagLabel.textColor = [UIColor colorWithHexStr:tagInfo.fontColor];
    return tagCell;
}

@end

// FHDetailAgentListModel

@implementation FHDetailAgentListModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFold = YES;
    }
    return self;
}

@end
