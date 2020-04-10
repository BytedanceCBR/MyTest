//
//  FHDetailPropertyListCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailPropertyListCell.h"
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

extern NSString *const DETAIL_SHOW_POP_LAYER_NOTIFICATION ;

@implementation FHDetailPropertyListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPropertyListModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }

    FHDetailPropertyListModel *propertyModel = (FHDetailPropertyListModel *)self.currentData;
    FHDetailPropertyListModel *model = (FHDetailPropertyListModel *)data;
    FHAgencyNameInfoView *infoView = nil;
    if (model.certificate && model.certificate.labels.count) {
        infoView = [[FHAgencyNameInfoView alloc] init];
        infoView.backgroundColor = [UIColor colorWithHexString:model.certificate.bgColor]?:[UIColor themeRed2];
        [infoView setAgencyNameInfo:model.certificate.labels];
        [self.contentView addSubview:infoView];
    }
    __block UIView *lastView = nil; // 最后一个视图
    NSInteger count = model.baseInfo.count;
    if (count > 0) {
        NSMutableArray *singles = [NSMutableArray new];
        __block NSInteger doubleCount = 0;// 两列计数
        __block CGFloat topOffset = 6;// 高度
        __block CGFloat listRowHeight = 29;// 30
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
                    FHPropertyListRowView *v = [[FHPropertyListRowView alloc] init];
                    [self.contentView addSubview:v];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(topOffset);
                        make.left.mas_equalTo(20);
                        make.width.mas_equalTo(viewWidth);
                        make.height.mas_equalTo(listRowHeight);
                    }];
                    v.keyLabel.text = obj.attr;
                    v.valueLabel.text = obj.value;
                    lastView = v;
                    lastViewLeftOffset = 20;
                    lastTopOffset = topOffset;
                } else {
                    // 第2列
                    FHPropertyListRowView *v = [[FHPropertyListRowView alloc] init];
                    [self.contentView addSubview:v];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(topOffset);
                        make.left.mas_equalTo(20 + viewWidth);
                        make.width.mas_equalTo(viewWidth);
                        make.height.mas_equalTo(listRowHeight);
                    }];
                    v.keyLabel.text = obj.attr;
                    v.valueLabel.text = obj.value;
                    lastView = v;
                    lastViewLeftOffset = 20 + viewWidth;
                    lastTopOffset = topOffset;
                    //
                    topOffset += listRowHeight;
                }
                doubleCount += 1;
            }
        }];
        // 添加单列数据
        if (singles.count > 0) {
            // 重新计算topOffset
            topOffset = 6 + (doubleCount / 2 + doubleCount % 2) * listRowHeight;
            [singles enumerateObjectsUsingBlock:^(FHHouseCoreInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHPropertyListRowView *v = [[FHPropertyListRowView alloc] init];
                [self.contentView addSubview:v];
                [v mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(topOffset);
                    make.left.mas_equalTo(20);
                    make.width.mas_equalTo(viewWidth * 2);
                    make.height.mas_equalTo(listRowHeight);
                }];
                v.keyLabel.text = obj.attr;
                v.valueLabel.text = obj.value;
                lastView = v;
                lastViewLeftOffset = 20;
                lastTopOffset = topOffset;
                
                topOffset += listRowHeight;
            }];
        }
//        // 父视图布局
//        if (lastView) {
//            CGFloat vWidTemp = viewWidth;
//            if (lastViewLeftOffset < 30) {
//                // 单行
//                vWidTemp = viewWidth * 2;
//            }
//            [lastView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(lastTopOffset);
//                make.left.mas_equalTo(lastViewLeftOffset);
//                make.width.mas_equalTo(vWidTemp);
//                make.height.mas_equalTo(listRowHeight);
//                if (!infoView && !model.extraInfo) {
//                    make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
//                }
//            }];
//        }
    }
    
    //extra info
    if (model.extraInfo) {
        
        FHDetailExtarInfoRowView *rowView = nil;
        if (model.extraInfo.neighborhoodInfo) {
            rowView = [[FHDetailExtarInfoRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(jump2Page:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithNeighborhoodInfoData:model.extraInfo.neighborhoodInfo];
            [self.contentView addSubview:rowView];
            [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.top.mas_equalTo(lastView.mas_bottom).offset(10);
                }else{
                    make.top.mas_equalTo(10);
                }
                make.left.mas_equalTo(20);
                make.right.mas_equalTo(-20);
                make.height.mas_equalTo(20);
            }];
            lastView = rowView;
        }
        if (model.extraInfo.budget) {
            rowView = [[FHDetailExtarInfoRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(jump2Page:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithBudgetData:model.extraInfo.budget];
            [self.contentView addSubview:rowView];
            [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.top.mas_equalTo(lastView.mas_bottom).offset(10);
                }else{
                    make.top.mas_equalTo(10);
                }
                make.left.mas_equalTo(20);
                make.right.mas_equalTo(-20);
                make.height.mas_equalTo(20);
            }];
            lastView = rowView;
        }
        if (model.extraInfo.floorInfo) {
            rowView = [[FHDetailExtarInfoRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(jump2Page:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithFloorInfo:model.extraInfo.floorInfo];
            [self.contentView addSubview:rowView];
            [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.top.mas_equalTo(lastView.mas_bottom).offset(10);
                }else{
                    make.top.mas_equalTo(10);
                }
                make.left.mas_equalTo(20);
                make.right.mas_equalTo(-20);
                make.height.mas_equalTo(20);
            }];
            lastView = rowView;
        }
        if (model.extraInfo.official) {
            rowView = [[FHDetailExtarInfoRowView alloc] initWithFrame:CGRectZero ];
            [rowView addTarget:self action:@selector(onRowViewAction:) forControlEvents:UIControlEventTouchUpInside];
            [rowView updateWithOfficalData:model.extraInfo.official];
            [self.contentView addSubview:rowView];
            [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.top.mas_equalTo(lastView.mas_bottom).offset(10);
                }else{
                    make.top.mas_equalTo(10);
                }
                make.left.mas_equalTo(20);
                make.right.mas_equalTo(-20);
                make.height.mas_equalTo(20);
            }];
            lastView = rowView;
        }
        
//        if (model.extraInfo.detective) {
//            rowView = [[FHDetailExtarInfoRowView alloc] initWithFrame:CGRectZero ];
//            [rowView addTarget:self action:@selector(onRowViewAction:) forControlEvents:UIControlEventTouchUpInside];
//            [self.contentView addSubview:rowView];
//            [rowView updateWithDetectiveData:model.extraInfo.detective];
//            [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
//                if (lastView) {
//                    make.top.mas_equalTo(lastView.mas_bottom).offset(10);
//                }else{
//                    make.top.mas_equalTo(10);
//                }
//                make.left.mas_equalTo(20);
//                make.right.mas_equalTo(-20);
//                make.height.mas_equalTo(20);
//            }];
//            lastView = rowView;
//        }
    }
    
    if (model.rentExtraInfo.securityInformation) {
        
        FHDetailExtarInfoRowView *rowView = [[FHDetailExtarInfoRowView alloc] initWithFrame:CGRectZero ];
        [rowView addTarget:self action:@selector(onRowViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:rowView];
        [rowView updateWithSecurityInfo:model.rentExtraInfo.securityInformation];
        [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.mas_equalTo(lastView.mas_bottom).offset(10);
            }else{
                make.top.mas_equalTo(10);
            }
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(20);
        }];
        lastView = rowView;                
    }
    
    if (infoView) {
        [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.mas_equalTo(lastView.mas_bottom).offset(10);
            }else{
                make.top.mas_equalTo(10);
            }
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(self.contentView).offset(-20);
            make.height.mas_equalTo(26);
//            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
        }];
        lastView = infoView;
    }
    
    [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
    }];
    
    [self layoutIfNeeded];
}

- (NSArray *)elementTypeStringArray:(FHHouseType)houseType
{
    FHDetailPropertyListModel *model = (FHDetailPropertyListModel *)self.currentData;
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
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
}

-(void)onRowViewAction:(FHDetailExtarInfoRowView *)view
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DETAIL_SHOW_POP_LAYER_NOTIFICATION object:nil userInfo:@{@"cell":self,@"model":view.data?:@""}];
}


- (void)jump2Page:(FHDetailExtarInfoRowView *)view
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
        NSDictionary *userInfoDict = @{@"tracer":@{}};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
        NSString *openUrl = budgetModel.openUrl;
        if (openUrl.length > 0) {
            NSURL *url = [NSURL URLWithString:openUrl];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
        positionStr = @"debit_calculator";
    }else if ([view.data isKindOfClass:[FHDetailDataBaseExtraFloorInfoModel class]]) {
        FHDetailDataBaseExtraFloorInfoModel *floorInfo = (FHDetailDataBaseExtraFloorInfoModel *)view.data;
        [self imAction:floorInfo.openUrl];
        positionStr = @"floor_type";
    }
    if (self.baseViewModel) {
        [self.baseViewModel addClickOptionLog:positionStr];
    }
}

- (void)imAction:(NSString *)openUrl
{
    if (openUrl.length < 1) {
        return;
    }
    FHDetailPropertyListModel *propertyModel = (FHDetailPropertyListModel *)self.currentData;
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"from"] = @"app_oldhouse_floor";
    imExtra[@"source"] = @"app_oldhouse_floor";
    imExtra[@"source_from"] = @"floor_type";
    imExtra[@"im_open_url"] = openUrl;
    imExtra[kFHClueEndpoint] = [NSString stringWithFormat:@"%ld",FHClueEndPointTypeC];
    imExtra[kFHCluePage] = [NSString stringWithFormat:@"%ld",FHClueIMPageTypeCOldFloor];
    [propertyModel.contactViewModel onlineActionWithExtraDict:imExtra];
}

@end


@implementation FHPropertyListRowView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = UIColor.whiteColor;
    _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _keyLabel.textColor = [UIColor themeGray3];
    [self addSubview:_keyLabel];
    [_keyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_keyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _valueLabel.textColor = [UIColor themeGray1];
    [self addSubview:_valueLabel];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    
    // 布局
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.keyLabel.mas_right).offset(10);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.keyLabel);
    }];
}


@end

@implementation FHDetailExtarInfoRowView

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
    self.backgroundColor = UIColor.whiteColor;
    _nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _nameLabel.textColor = [UIColor themeGray3];
    [self addSubview:_nameLabel];

    
    _infoLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _infoLabel.textColor = [UIColor themeGray1];
    [self addSubview:_infoLabel];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    
    UIImage *img = ICON_FONT_IMG(14, @"\U0000e670", [UIColor themeGray3]); //@"detail_entrance_arrow"

    _logoImageView = [[UIImageView alloc] init];
    _logoImageView.image = img;
    _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _indicatorLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _indicatorLabel.font = [UIFont themeFontRegular:14];
    _indicatorLabel.textColor = [UIColor themeOrange4];
    
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
        make.right.mas_equalTo(-30);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
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
                make.right.mas_equalTo(-30);
                make.size.mas_equalTo(CGSizeMake(width, height));
            }];
            
            [wself.infoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_lessThanOrEqualTo(self.logoImageView.mas_left).offset(-10);
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
        NSAttributedString *infoStr = [[NSAttributedString alloc] initWithString:detectiveModel.content attributes:@{NSForegroundColorAttributeName:[UIColor themeGray1],NSFontAttributeName:[UIFont themeFontRegular:14]}];
        [minfoAttrStr appendAttributedString:infoStr];
    }

    if (!IS_EMPTY_STRING(detectiveModel.warnContent)) {
        NSAttributedString *warnStr = [[NSAttributedString alloc] initWithString:detectiveModel.warnContent attributes:@{NSForegroundColorAttributeName:[UIColor themeOrange1],NSFontAttributeName:[UIFont themeFontRegular:14]}];
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
        NSAttributedString *infoStr = [[NSAttributedString alloc] initWithString:neighborModel.subName attributes:@{NSForegroundColorAttributeName:[UIColor themeGray1],NSFontAttributeName:[UIFont themeFontRegular:14]}];
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
    if (!IS_EMPTY_STRING(budgetmodel.baseContent)) {
        NSAttributedString *infoStr = [[NSAttributedString alloc] initWithString:budgetmodel.baseContent attributes:@{NSForegroundColorAttributeName:[UIColor themeOrange1],NSFontAttributeName:[UIFont themeFontRegular:14]}];
        [minfoAttrStr appendAttributedString:infoStr];
    }
    _infoLabel.attributedText = minfoAttrStr;
    
    _logoImageView.hidden = YES;
    _indicatorLabel.hidden = YES;
}

-(void)updateWithFloorInfo:(FHDetailDataBaseExtraFloorInfoModel *)floorInfo
{
    self.data = floorInfo;
    _nameLabel.text = floorInfo.baseTitle;
    
    NSMutableAttributedString *minfoAttrStr = [[NSMutableAttributedString alloc] init];
    if (!IS_EMPTY_STRING(floorInfo.baseContent)) {
        NSAttributedString *infoStr = [[NSAttributedString alloc] initWithString:floorInfo.baseContent attributes:@{NSForegroundColorAttributeName:[UIColor themeGray1],NSFontAttributeName:[UIFont themeFontRegular:14]}];
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
        make.right.mas_equalTo(-(31+size.width));
        make.size.mas_equalTo(CGSizeZero);
    }];
    
}

@end

@implementation FHDetailPropertyListModel


@end
