//
//  FHDetailPropertyListCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailPropertyListCorrectingCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "UILabel+House.h"
#import "FHAgencyNameInfoView.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHHouseDetailContactViewModel.h"
#import <FHHouseBase/FHHouseContactDefines.h>
#import "FHPropertyListCorrectingRowView.h"

extern NSString *const DETAIL_SHOW_POP_LAYER_NOTIFICATION ;
@interface FHDetailPropertyListCorrectingCell()
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *itemArray;
@end
@implementation FHDetailPropertyListCorrectingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPropertyListCorrectingModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.itemArray   ) {
        [v removeFromSuperview];
    }

//    FHDetailPropertyListCorrectingModel *propertyModel = (FHDetailPropertyListCorrectingModel *)self.currentData;
    FHDetailPropertyListCorrectingModel *model = (FHDetailPropertyListCorrectingModel *)data;
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
    FHAgencyNameInfoView *infoView = nil;
    if (model.certificate && model.certificate.labels.count) {
        infoView = [[FHAgencyNameInfoView alloc] init];
        infoView.backgroundColor = [UIColor colorWithHexString:model.certificate.bgColor]?:[UIColor themeRed2];
        [infoView setAgencyNameInfo:model.certificate.labels];
        [self.containerView addSubview:infoView];
        [self.itemArray addObject:infoView];
    }
    __block UIView *lastView = nil; // 最后一个视图
    NSInteger count = model.baseInfo.count;
    __block CGFloat topOffset = model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll?18:0;// 高度
    if (count > 0) {
        NSMutableArray *singles = [NSMutableArray new];
        __block NSInteger doubleCount = 0;// 两列计数
        __block CGFloat listRowHeight = 28;// 30
        __block CGFloat lastViewLeftOffset = 20;
        __block CGFloat lastTopOffset = 20;
        CGFloat viewWidth = (UIScreen.mainScreen.bounds.size.width - 40) / 2;
        [model.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSingle) {
                [singles addObject:obj];
            } else {
                // 两列
                if (doubleCount % 2 == 0) {
                    // 第1列
                    FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                    v.valueLabel.font = [UIFont themeFontMedium:14];
                    v.valueLabel.textColor = [UIColor themeGray2];
                    [self.containerView addSubview:v];
                    [self.itemArray addObject:v];
                    v.frame = CGRectMake(31, topOffset,viewWidth, listRowHeight);
                    v.keyLabel.text = obj.attr;
                    v.valueLabel.text = obj.value;
                    lastView = v;
                    lastViewLeftOffset = 20;
                    lastTopOffset = topOffset;
                    topOffset += listRowHeight;
                } else {
                    // 第2列
                    topOffset -= listRowHeight;
                    FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                    v.valueLabel.font = [UIFont themeFontMedium:14];
                    v.valueLabel.textColor = [UIColor themeGray2];
                    [self.containerView addSubview:v];
                    [self.itemArray addObject:v];
                    v.frame = CGRectMake(31 + viewWidth, topOffset,viewWidth, listRowHeight);
                    v.keyLabel.text = obj.attr;
                    v.valueLabel.text = obj.value;
                    lastView = v;
                    lastViewLeftOffset = 20 + viewWidth;
                    lastTopOffset = topOffset;
                    topOffset += listRowHeight;
                }
                doubleCount += 1;
            }
        }];
        // 添加单列数据
        if (singles.count > 0) {
            // 重新计算topOffset
            [singles enumerateObjectsUsingBlock:^(FHHouseCoreInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                v.valueLabel.font = [UIFont themeFontMedium:14];
                v.valueLabel.textColor = [UIColor themeGray2];
                [self.containerView addSubview:v];
                [self.itemArray addObject:v];
                v.frame = CGRectMake(topOffset, 31, viewWidth*2, listRowHeight);
                v.keyLabel.text = obj.attr;
                v.valueLabel.text = obj.value;
                lastView = v;
                lastViewLeftOffset = 20;
                lastTopOffset = topOffset;
                topOffset += listRowHeight;
            }];
        }
    }
    topOffset += 2;
    //extra info
    if (model.extraInfo) {
        FHDetailExtarInfoCorrectingRowView *rowView = nil;
        if (model.extraInfo.neighborhoodInfo) {
            rowView = [[FHDetailExtarInfoCorrectingRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(jump2Page:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithNeighborhoodInfoData:model.extraInfo.neighborhoodInfo];
            [self.containerView addSubview:rowView];
            [self.itemArray addObject:rowView];
            rowView.frame = CGRectMake(31, topOffset, UIScreen.mainScreen.bounds.size.width - 62, 30);
            topOffset += 30;
            lastView = rowView;
        }
        if (model.extraInfo.budget) {
            rowView = [[FHDetailExtarInfoCorrectingRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(jump2Page:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithBudgetData:model.extraInfo.budget];
            [self.containerView addSubview:rowView];
            [self.itemArray addObject:rowView];
            rowView.frame = CGRectMake(31, topOffset, UIScreen.mainScreen.bounds.size.width - 62, 30);
            topOffset += 30;
            lastView = rowView;
        }
        if (model.extraInfo.floorInfo) {
            rowView = [[FHDetailExtarInfoCorrectingRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(jump2Page:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithFloorInfo:model.extraInfo.floorInfo];
            [self.containerView addSubview:rowView];
            [self.itemArray addObject:rowView];
            rowView.frame = CGRectMake(31, topOffset, UIScreen.mainScreen.bounds.size.width - 62, 30);
            topOffset += 30;
            lastView = rowView;
        }
        if (model.extraInfo.official) {
            rowView = [[FHDetailExtarInfoCorrectingRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(onRowViewAction:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithOfficalData:model.extraInfo.official];
            [self.containerView addSubview:rowView];
            [self.itemArray addObject:rowView];
            rowView.frame = CGRectMake(31, topOffset, UIScreen.mainScreen.bounds.size.width - 62, 30);
            topOffset += 30;
            lastView = rowView;
        }
        
        if (model.extraInfo.detective) {
            rowView = [[FHDetailExtarInfoCorrectingRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(onRowViewAction:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithDetectiveData:model.extraInfo.detective];
            [self.containerView addSubview:rowView];
            [self.itemArray addObject:rowView];
            rowView.frame = CGRectMake(31, topOffset, UIScreen.mainScreen.bounds.size.width - 62, 30);
            topOffset += 30;
            lastView = rowView;
        }
        if (model.extraInfo.houseCertificationInfo) {
            rowView = [[FHDetailExtarInfoCorrectingRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(jump2Page:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithHouseCertificationInfo:model.extraInfo.houseCertificationInfo];
            [self.containerView addSubview:rowView];
            [self.itemArray addObject:rowView];
            rowView.frame = CGRectMake(31, topOffset, UIScreen.mainScreen.bounds.size.width - 62, 30);
            topOffset += 30;
            lastView = rowView;
        }
    }
    
    if (model.rentExtraInfo.securityInformation) {
        FHDetailExtarInfoCorrectingRowView *rowView = [[FHDetailExtarInfoCorrectingRowView alloc] initWithFrame:CGRectZero ];
        [rowView addTarget:self action:@selector(onRowViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [rowView updateWithSecurityInfo:model.rentExtraInfo.securityInformation];
        [self.containerView addSubview:rowView];
        [self.itemArray addObject:rowView];
        rowView.frame = CGRectMake(31, topOffset, UIScreen.mainScreen.bounds.size.width - 62, 30);
        topOffset += 30;
        lastView = rowView;              
    }
    
    if (infoView) {
        infoView.frame = CGRectMake(31, topOffset, UIScreen.mainScreen.bounds.size.width - 62, 30);
    }
    
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(topOffset);
    }];
    
//    [self layoutIfNeeded];
}

- (NSArray *)elementTypeStringArray:(FHHouseType)houseType
{
    FHDetailPropertyListCorrectingModel *model = (FHDetailPropertyListCorrectingModel *)self.currentData;
    if (model.certificate && model.certificate.labels.count) {
        return @[@"agency_info"];
    }
    if (model.extraInfo) {
        
        NSMutableArray *types = [NSMutableArray new];
        if (model.extraInfo.official) {
            [types addObject:@"official_inspection"];
        }
//        if (model.extraInfo.detective) {
//            [types addObject:@"happiness_eye"];
//        }
        
        return types;
    }
    
    if (model.rentExtraInfo) {
        return @[@"transaction_remind"];
    }
    
    return @[];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _itemArray = [[NSMutableArray alloc]init];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-14);
        make.bottom.equalTo(self.contentView).offset(14);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(14);
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
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

-(void)onRowViewAction:(FHDetailExtarInfoCorrectingRowView *)view
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DETAIL_SHOW_POP_LAYER_NOTIFICATION object:nil userInfo:@{@"cell":self,@"model":view.data?:@""}];
}


- (void)jump2Page:(FHDetailExtarInfoCorrectingRowView *)view
{
    NSString *positionStr = @"be_null";
    if ([view.data isKindOfClass:[FHDetailDataBaseExtraNeighborhoodModel class]]) {
        // 二手房详情下发小区字段
        FHDetailDataBaseExtraNeighborhoodModel *neighborhoodModel = (FHDetailDataBaseExtraNeighborhoodModel *)view.data;
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        // tracerDic[@"card_type"] = @"no_pic";
        tracerDic[@"element_from"] = @"neighborhood_type";
        tracerDic[@"enter_from"] = @"old_detail";
        [tracerDic removeObjectForKey:@"rank"];
        [tracerDic removeObjectForKey:@"card_type"];
        if (!tracerDic) {
            tracerDic = @{};
        }
        NSDictionary *userInfoDict = @{@"tracer":tracerDic};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
        NSString *openUrl = neighborhoodModel.openUrl;
        if (openUrl.length > 0) {
            NSURL *url = [NSURL URLWithString:openUrl];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
        positionStr = @"neighborhood_type";
    } else if ([view.data isKindOfClass:[FHDetailDataBaseExtraBudgetModel class]]) {
        FHDetailDataBaseExtraBudgetModel *budgetModel = (FHDetailDataBaseExtraBudgetModel *)view.data;
        if ([budgetModel.openUrl containsString:@"open_single_chat"]) {
            [self imAction:budgetModel.openUrl isFloorAction:NO];
            positionStr = @"loan";
        }else {
            NSDictionary *userInfoDict = @{@"tracer":@{}};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
            NSString *openUrl = budgetModel.openUrl;
            if (openUrl.length > 0) {
                NSURL *url = [NSURL URLWithString:openUrl];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            }
            positionStr = @"debit_calculator";
        }
        
    }else if ([view.data isKindOfClass:[FHDetailDataBaseExtraHouseCertificationModel class]]) {
        FHDetailDataBaseExtraHouseCertificationModel *houseCertificationModel = (FHDetailDataBaseExtraHouseCertificationModel *)view.data;
            NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
               // tracerDic[@"card_type"] = @"no_pic";
            tracerDic[@"enter_from"] = @"old_detail";
            NSDictionary *userInfoDict = @{@"tracer":@{}};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
            NSString *openUrl = houseCertificationModel.openUrl;
            if (openUrl.length > 0) {
                NSURL *url = [NSURL URLWithString:openUrl];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            }
            positionStr = @"certification_type";
    }else if ([view.data isKindOfClass:[FHDetailDataBaseExtraFloorInfoModel class]]) {
        FHDetailDataBaseExtraFloorInfoModel *floorInfo = (FHDetailDataBaseExtraFloorInfoModel *)view.data;
        [self imAction:floorInfo.openUrl isFloorAction:YES];
        positionStr = @"floor_type";
    }
    if (self.baseViewModel) {
        [self.baseViewModel addClickOptionLog:positionStr];
    }
}

- (void)imAction:(NSString *)openUrl isFloorAction:(BOOL)isFloorAction
{
    if (openUrl.length < 1) {
        return;
    }
    FHDetailPropertyListCorrectingModel *propertyModel = (FHDetailPropertyListCorrectingModel *)self.currentData;
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"source_from"] = isFloorAction?@"floor_type":@"loan";
    imExtra[@"im_open_url"] = openUrl;
    imExtra[@"realtor_position"] = isFloorAction?@"floor_type":@"loan";
    if([self.baseViewModel.detailData isKindOfClass:FHDetailOldModel.class]) {
        FHDetailOldModel *detailOldModel = (FHDetailOldModel *)self.baseViewModel.detailData;
        
        if(isFloorAction) {
            if(detailOldModel.data.baseExtra.floorInfo.associateInfo) {
                imExtra[kFHAssociateInfo] = detailOldModel.data.baseExtra.floorInfo.associateInfo;
            }
        }
        else {
            if(detailOldModel.data.baseExtra.budget.associateInfo) {
                imExtra[kFHAssociateInfo] = detailOldModel.data.baseExtra.budget.associateInfo;
            }
        }
    }
    [propertyModel.contactViewModel onlineActionWithExtraDict:imExtra];
}

@end



@implementation FHDetailExtarInfoCorrectingRowView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
//#if DEBUG
//        _logoImageView.backgroundColor = [UIColor redColor];
//#endif
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    _nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _nameLabel.textColor = [UIColor themeGray3];
    [self addSubview:_nameLabel];
    _nameLabel.backgroundColor = [UIColor whiteColor];
    
    _infoLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _infoLabel.font = [UIFont themeFontMedium:14];
    _infoLabel.textColor = [UIColor themeGray2];
    [self addSubview:_infoLabel];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    
    UIImage *img = ICON_FONT_IMG(16, @"\U0000e670", [UIColor themeGray3]); //@"detail_entrance_arrow"

    _logoImageView = [[UIImageView alloc] init];
    _logoImageView.image = img;
    _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _indicatorLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _indicatorLabel.font = [UIFont themeFontMedium:14];
    _indicatorLabel.textColor = [UIColor colorWithHexStr:@"#ff9629"];
    
    _indicator = [[UIImageView alloc]initWithImage:img];
    _indicator.contentMode = UIViewContentModeCenter;
    
    [self addSubview:_logoImageView];
    [self addSubview:_indicatorLabel];
    [self addSubview:_indicator];
    
    // 布局
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0).priorityHigh();
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(10);
        make.top.bottom.mas_equalTo(self);
        make.right.mas_lessThanOrEqualTo(self.logoImageView.mas_left).offset(-10);
    }];
    
    [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.mas_equalTo(self);
    }];
    
    [self.indicatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-26);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-26);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(0);
    }];
}

-(void)updateWithOfficalData:(FHDetailDataBaseExtraOfficialModel *)officialModel
{
    self.data = officialModel;
    _nameLabel.text = officialModel.baseTitle;
    _infoLabel.text =  officialModel.agency.name;
    _logoImageView.image = nil;
    
    __weak typeof(self) wself = self;
    [_logoImageView bd_setImageWithURL:[NSURL URLWithString:officialModel.agencyLogoUrl] placeholder:nil options:BDImageRequestHighPriority completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        if (image && wself) {
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            if (width > 0 && height > 20) {
                width = 20*width/height;
                height = 20;
            }
            
            [wself.logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-26);
                make.size.mas_equalTo(CGSizeMake(width, height));
            }];
            
            [wself.infoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_lessThanOrEqualTo(wself.logoImageView.mas_left).offset(-10);
            }];
        }        
    }];
    
    self.indicatorLabel.hidden = YES;
        
}

-(void)updateWithDetectiveData:(FHDetailDataBaseExtraDetectiveModel *)detectiveModel
{
    self.data = detectiveModel;
    _nameLabel.text = detectiveModel.baseTitle;
    
    NSMutableAttributedString *minfoAttrStr = [[NSMutableAttributedString alloc] init];
    if (!IS_EMPTY_STRING(detectiveModel.content)) {
        NSAttributedString *infoStr = [[NSAttributedString alloc] initWithString:detectiveModel.content attributes:@{NSForegroundColorAttributeName:[UIColor themeGray2],NSFontAttributeName:[UIFont themeFontMedium:14]}];
        [minfoAttrStr appendAttributedString:infoStr];
    }

    if (!IS_EMPTY_STRING(detectiveModel.warnContent)) {
        NSAttributedString *warnStr = [[NSAttributedString alloc] initWithString:detectiveModel.warnContent attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexStr:@"#ff9629"],NSFontAttributeName:[UIFont themeFontMedium:14]}];
        [minfoAttrStr appendAttributedString:warnStr];
    }
    
    _infoLabel.attributedText = minfoAttrStr;
    
    _logoImageView.image = nil;
    [_logoImageView bd_setImageWithURL:[NSURL URLWithString:detectiveModel.icon]];
    
    _indicatorLabel.text = detectiveModel.tips;
    
    [_indicatorLabel sizeToFit];
    
    CGSize size = _indicatorLabel.bounds.size;
    _indicatorLabel.hidden = NO;
    
    [_indicatorLabel  mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
    
    [_logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-(31+size.width));
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
}

-(void)updateWithSecurityInfo:(FHRentDetailDataBaseExtraSecurityInformationModel *)securityInfo
{
    self.data = securityInfo;
    _nameLabel.text = securityInfo.baseTitle;
    _infoLabel.text = securityInfo.baseContent;
    
    _indicatorLabel.text = securityInfo.tipsContent;
    [_indicatorLabel sizeToFit];
    
    _logoImageView.image = nil;
    [_logoImageView bd_setImageWithURL:[NSURL URLWithString:securityInfo.tipsIcon]];
    
    
    CGSize size = _indicatorLabel.bounds.size;
    _indicatorLabel.hidden = NO;
    
    [_indicatorLabel  mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
    
    [_logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-(31+size.width));
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
}

-(void)updateWithNeighborhoodInfoData:(FHDetailDataBaseExtraNeighborhoodModel *)neighborModel
{
    self.data = neighborModel;
    _nameLabel.text = neighborModel.baseTitle;
    
    NSMutableAttributedString *minfoAttrStr = [[NSMutableAttributedString alloc] init];
    if (!IS_EMPTY_STRING(neighborModel.subName)) {
        NSAttributedString *infoStr = [[NSAttributedString alloc] initWithString:neighborModel.subName attributes:@{NSForegroundColorAttributeName:[UIColor themeGray2],NSFontAttributeName:[UIFont themeFontMedium:14]}];
        [minfoAttrStr appendAttributedString:infoStr];
    }
    _infoLabel.attributedText = minfoAttrStr;
    
    _logoImageView.hidden = YES;
    _indicatorLabel.hidden = YES;
}

-(void)updateWithBudgetData:(FHDetailDataBaseExtraBudgetModel *)budgetmodel
{
    self.data = budgetmodel;
    _nameLabel.text = budgetmodel.baseTitle;
    
    NSMutableAttributedString *minfoAttrStr = [[NSMutableAttributedString alloc] init];
    UIColor *infoColor = [UIColor colorWithHexStr:@"#ff9629"];
    if (!IS_EMPTY_STRING(budgetmodel.baseContent)) {
        // 支持贷款及展示
        if (!budgetmodel.canLoan) {
            infoColor = [UIColor themeGray2];
        }
        NSAttributedString *infoStr = [[NSAttributedString alloc] initWithString:budgetmodel.baseContent attributes:@{NSForegroundColorAttributeName:infoColor,NSFontAttributeName:[UIFont themeFontMedium:14]}];
        [minfoAttrStr appendAttributedString:infoStr];
    }
    _infoLabel.attributedText = minfoAttrStr;
    
    _logoImageView.hidden = YES;
    
    _indicatorLabel.text = budgetmodel.extraContent;
    
    [_indicatorLabel sizeToFit];
    
    CGSize size = _indicatorLabel.bounds.size;
    _indicatorLabel.hidden = NO;
    
    [_indicatorLabel  mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
    
    [_logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-(26+size.width));
        make.size.mas_equalTo(CGSizeZero);
    }];
}

-(void)updateWithFloorInfo:(FHDetailDataBaseExtraFloorInfoModel *)floorInfo
{
    self.data = floorInfo;
     _nameLabel.text = floorInfo.baseTitle;
    NSMutableAttributedString *minfoAttrStr = [[NSMutableAttributedString alloc] init];
    if (!IS_EMPTY_STRING(floorInfo.baseContent)) {
        NSAttributedString *infoStr = [[NSAttributedString alloc] initWithString:floorInfo.baseContent attributes:@{NSForegroundColorAttributeName:[UIColor themeGray2],NSFontAttributeName:[UIFont themeFontMedium:14]}];
        [minfoAttrStr appendAttributedString:infoStr];
    }
    _infoLabel.attributedText = minfoAttrStr;
    
    _logoImageView.hidden = YES;

    _indicatorLabel.text = floorInfo.extraContent;
    
    [_indicatorLabel sizeToFit];
    
    CGSize size = _indicatorLabel.bounds.size;
    _indicatorLabel.hidden = NO;
    
    [_indicatorLabel  mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
    
    [_logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-(26+size.width));
        make.size.mas_equalTo(CGSizeZero);
    }];
    
}

- (void)updateWithHouseCertificationInfo:(FHDetailDataBaseExtraHouseCertificationModel *)houseCertificationInfo {
    self.data = houseCertificationInfo;
      _nameLabel.text = houseCertificationInfo.baseTitle;
     NSMutableAttributedString *minfoAttrStr = [[NSMutableAttributedString alloc] init];
     if (!IS_EMPTY_STRING(houseCertificationInfo.subName)) {
         NSAttributedString *infoStr = [[NSAttributedString alloc] initWithString:houseCertificationInfo.subName attributes:@{NSForegroundColorAttributeName:[UIColor themeGray2],NSFontAttributeName:[UIFont themeFontMedium:14]}];
         [minfoAttrStr appendAttributedString:infoStr];
     }
     _infoLabel.attributedText = minfoAttrStr;
     
     _logoImageView.hidden = YES;

//     _indicatorLabel.text = floorInfo.extraContent;
     
     [_indicatorLabel sizeToFit];
     
     CGSize size = _indicatorLabel.bounds.size;
     _indicatorLabel.hidden = NO;
     
     [_indicatorLabel  mas_updateConstraints:^(MASConstraintMaker *make) {
         make.width.mas_equalTo(size.width);
     }];
     
     [_logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
         make.right.mas_equalTo(-(26+size.width));
         make.size.mas_equalTo(CGSizeZero);
     }];
    
}
@end

@implementation FHDetailPropertyListCorrectingModel


@end
