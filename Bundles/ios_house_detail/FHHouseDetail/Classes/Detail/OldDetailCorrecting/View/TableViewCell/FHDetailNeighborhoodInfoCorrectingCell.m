//
//  FHDetailNeighborhoodInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailNeighborhoodInfoCorrectingCell.h"
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
#import "FHDetailBottomOpenAllView.h"
#import "FHDetailStarsCountView.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"
#import <FHCommonUI/UIView+House.h>
#import "FHCommonDefines.h"
#import <TTBaseLib/UIButton+TTAdditions.h>
#import "FHOldDetailSchoolInfoItemView.h"
#import "FHDetailNeighborhoodTitleView.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHHouseDetailContactViewModel.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHHouseContactDefines.h>
#import "FHUtils.h"
#import "FHUIAdaptation.h"
#import <ByteDanceKit/NSString+BTDAdditions.h>
#import <ByteDanceKit/UILabel+BTDAdditions.h>

@interface FHDetailNeighborhoodConsultCorrectingView : UIView
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIImageView *consultImgView;
@property (nonatomic, strong) UIButton *consultBtn;
@property (nonatomic, strong) UIButton *actionBtn;
@property (nonatomic, copy) void (^actionBlock)(void);

@end

@implementation FHDetailNeighborhoodConsultCorrectingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI
{
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.font = [UIFont themeFontRegular:AdaptFont(14)];
    _nameLabel.textColor = [UIColor themeGray3];
    [self addSubview:_nameLabel];
    
    _infoLabel = [[UILabel alloc]init];
    _infoLabel.font = [UIFont themeFontMedium:AdaptFont(14)];
    _infoLabel.textColor = [UIColor colorWithHexStr:@"#ff9629"];
    [self addSubview:_infoLabel];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    
    _consultBtn = [[UIButton alloc]init];
    [self addSubview:_consultBtn];

    _actionBtn = [[UIButton alloc]init];
    [self addSubview:_actionBtn];
    [_actionBtn addTarget:self action:@selector(consultBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];

    _consultImgView = [[UIImageView alloc] init];
    _consultImgView.image = [UIImage imageNamed:@"plot__message"];
    _consultImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_consultImgView];

    // 布局
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(42);
        make.right.mas_lessThanOrEqualTo(AdaptOffset(-30));
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.consultImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoLabel.mas_right).offset(AdaptOffset(3));
        make.centerY.mas_equalTo(self).offset(-1);
        make.height.mas_equalTo(AdaptOffset(15));
        make.width.mas_equalTo(AdaptOffset(16));
    }];
    [self.consultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.consultImgView);
    }];
    [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.infoLabel);
        make.right.mas_equalTo(self.consultImgView.mas_right);
    }];
}

- (void)consultBtnDidClick:(UIButton *)btn
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

@end

@interface FHDetailNeighborhoodInfoCorrectingCell ()
@property (nonatomic, weak) UIImageView *mainImage;
@property (nonatomic, weak) FHDetailNeighborhoodTitleView *headerView;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) FHDetailNeighborhoodConsultCorrectingView *consultView;
@property (nonatomic, weak) UIView *schoolView;
@property (nonatomic, strong)   NSMutableDictionary       *houseShowCache; // 埋点缓存
@property (nonatomic, weak) UILabel *schoolNameLabel;
@property (nonatomic, weak) UIButton *foldBtn;

@end

@implementation FHDetailNeighborhoodInfoCorrectingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodInfoCorrectingModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *subview in self.topView.subviews) {
        [subview removeFromSuperview];
    }
    for (UIView *subview in self.schoolView.subviews) {
        [subview removeFromSuperview];
    }
    self.consultView.hidden = YES;
    FHDetailNeighborhoodInfoCorrectingModel *model = (FHDetailNeighborhoodInfoCorrectingModel *)data;
    // 二手房
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
    if (model.neighborhoodInfo) {
        [self updateErshouCellData];
    }
//    // 租房
//    if (model.rent_neighborhoodInfo) {
//        [self updateRentCellData];
//    }
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

// 小区信息
- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"neighborhood_detail";
}

// 二手房
- (void)updateErshouCellData
{
    FHDetailNeighborhoodInfoCorrectingModel *model = (FHDetailNeighborhoodInfoCorrectingModel *)self.currentData;
    if (model) {
        NSString *headerName = [NSString stringWithFormat:@"%@",model.neighborhoodInfo.name];
        self.headerView.titleStr = headerName;
        NSString *areaName = model.neighborhoodInfo.areaName;
        NSString *districtName = model.neighborhoodInfo.districtName;
        if (areaName.length > 0 && districtName.length > 0) {
            [self showLabelWithKey:@"位置:" value:[NSString stringWithFormat:@"%@-%@",districtName,areaName] parentView:self.topView];

        } else if (districtName.length > 0) {
            [self showLabelWithKey:@"位置:" value:districtName parentView:self.topView];
        }
        if (model.neighborhoodInfo.neighborhoodImage.count >0) {
            FHImageModel *imageModel = model.neighborhoodInfo.neighborhoodImage[0];
            if (imageModel.url.length >0) {
                [self.mainImage bd_setImageWithURL:[NSURL URLWithString:imageModel.url]];
            }
        }
        CGFloat topMargin = 8 + 12;
        if (model.neighborhoodInfo.useSchoolIm) {
            self.schoolView.hidden = YES;
            self.consultView.hidden = NO;
            self.consultView.nameLabel.text = @"学校:";
            self.consultView.infoLabel.text = model.neighborhoodInfo.schoolConsult.text;
        } else {
            self.schoolView.hidden = NO;
            self.consultView.hidden = YES;
            if (model.neighborhoodInfo.schoolDictList.count < 1) {
                topMargin = 8 + 26;
            }
            [self updateSchoolView:model.neighborhoodInfo.schoolDictList];
        }
        [self.headerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topMargin);
        }];
    }
}

#pragma mark - FHDetailScrollViewDidScrollProtocol

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
    if (vcParentView) {
        CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
        if (UIScreen.mainScreen.bounds.size.height - point.y > 150) {
            [self addHouseShowLog];
        }
    }
}

// 添加house_show 埋点
- (void)addHouseShowLog
{
    FHDetailNeighborhoodInfoCorrectingModel *model = (FHDetailNeighborhoodInfoCorrectingModel *)self.currentData;
    NSString *tempKey = [NSString stringWithFormat:@"%@", model.neighborhoodInfo.id];
    if ([self.houseShowCache valueForKey:tempKey]) {
        return;
    }
    [self.houseShowCache setValue:@(YES) forKey:tempKey];
    // house_show
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    tracerDic[@"rank"] = @(0);
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"log_pb"] = model.neighborhoodInfo.logPb ? model.neighborhoodInfo.logPb : @"be_null";
    tracerDic[@"house_type"] = @"neighborhood";
    tracerDic[@"element_type"] = @"neighborhood_detail";
    tracerDic[@"search_id"] = model.neighborhoodInfo.searchId.length > 0 ? model.neighborhoodInfo.searchId : @"be_null";
    tracerDic[@"group_id"] = model.neighborhoodInfo.groupId.length > 0 ? model.neighborhoodInfo.groupId : (model.neighborhoodInfo.id ? model.neighborhoodInfo.id : @"be_null");
    tracerDic[@"impr_id"] = model.neighborhoodInfo.imprId.length > 0 ? model.neighborhoodInfo.imprId : @"be_null";
    [tracerDic removeObjectsForKeys:@[@"element_from"]];
    [FHUserTracker writeEvent:@"house_show" params:tracerDic];
}

- (void)imAction
{
    FHDetailNeighborhoodInfoCorrectingModel *model = (FHDetailNeighborhoodInfoCorrectingModel *)self.currentData;
    if (model.neighborhoodInfo.useSchoolIm && model.neighborhoodInfo.schoolConsult.openUrl.length > 0) {
        
        NSMutableDictionary *imExtra = @{}.mutableCopy;
        imExtra[@"source_from"] = @"education_type";
        imExtra[@"im_open_url"] = model.neighborhoodInfo.schoolConsult.openUrl;
        if([self.baseViewModel.detailData isKindOfClass:FHDetailOldModel.class]) {
            FHDetailOldModel *detailOldModel = (FHDetailOldModel *)self.baseViewModel.detailData;
            if(detailOldModel.data.neighborhoodInfo.schoolConsult.associateInfo) {
                imExtra[kFHAssociateInfo] = detailOldModel.data.neighborhoodInfo.schoolConsult.associateInfo;
            }
        }
        [model.contactViewModel onlineActionWithExtraDict:imExtra];
        if (self.baseViewModel) {
            [self.baseViewModel addClickOptionLog:@"education_type"];
        }
    }
}

- (void)updateSchoolView:(NSArray<FHDetailDataNeighborhoodInfoSchoolItemModel>*)schoolDictList
{
    if (schoolDictList.count < 1) {
        return;
    }
//    FHDetailNeighborhoodInfoCorrectingModel *model = (FHDetailNeighborhoodInfoCorrectingModel *)self.currentData;
//    __block UIView *lastItemView = nil;
//    CGFloat sumHeight = 0;
    NSMutableString *schoolNameComponents = [NSMutableString string];
    for (NSInteger index = 0; index < schoolDictList.count; index++) {
        FHDetailDataNeighborhoodInfoSchoolItemModel *item = schoolDictList[index];
        if (item.schoolList.count < 1) {
            continue;
        }
        FHDetailDataNeighborhoodInfoSchoolInfoModel *school = item.schoolList[0];
        if (!school.schoolName.length) {
            continue;
        }
        if (schoolNameComponents.length) {
            [schoolNameComponents appendFormat:@"、%@",school.schoolName];
        } else {
            [schoolNameComponents appendString:school.schoolName];
        }
        
//        FHOldDetailSchoolInfoItemModel *schoolInfoModel = [[FHOldDetailSchoolInfoItemModel alloc]init];
//        schoolInfoModel.schoolItem = item;
//        schoolInfoModel.tableView = model.tableView;
//        FHOldDetailSchoolInfoItemView *itemView = [[FHOldDetailSchoolInfoItemView alloc]initWithSchoolInfoModel:schoolInfoModel];
//        sumHeight += itemView.bottomY;
//        __weak typeof(self)wself = self;
//        itemView.foldBlock = ^(FHOldDetailSchoolInfoItemView *theItemView, CGFloat height) {
//
//            [model.tableView beginUpdates];
//             [wself refreshSchoolViewFrame];
//            [UIView animateWithDuration:0.3 animations:^{
//                [wself refreshItemsView];
//            } completion:^(BOOL finished) {
//            }];
//            [model.tableView endUpdates];
//
//        };
//        [self.schoolView addSubview:itemView];
//        itemView.frame = CGRectMake(0, lastItemView.bottom, SCREEN_WIDTH-30-97, itemView.bottomY);
//        lastItemView = itemView;
    }
//    [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(sumHeight);
//    }];
    if (schoolNameComponents.length) {
        CGFloat width = CGRectGetWidth(self.containerView.bounds) - 16 - 72 - 52 - 37;
        UILabel *nameKey = [UILabel createLabel:@"学校:" textColor:@"" fontSize:14];
        nameKey.textColor = [UIColor themeGray3];
        UILabel *nameValue = [UILabel createLabel:schoolNameComponents.copy textColor:@"" fontSize:14];
        nameValue.lineBreakMode = NSLineBreakByTruncatingTail;
        nameValue.numberOfLines = 1;
        nameValue.textColor = [UIColor themeGray1];
        [self.schoolView addSubview:nameKey];
        [self.schoolView addSubview:nameValue];
        self.schoolNameLabel = nameValue;
        [nameKey mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.schoolView);
            make.top.bottom.equalTo(self.schoolView);
        }];
        [nameValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.schoolView).mas_offset(42);
            make.centerY.equalTo(nameKey);
        }];
        
        if ([schoolNameComponents btd_widthWithFont:[UIFont themeFontRegular:14] height:16] > width) {
            UIButton *foldBtn = [[UIButton alloc] init];
            UIImage *img = ICON_FONT_IMG(16, @"\U0000e672", nil);
            [foldBtn setImage:img forState:UIControlStateNormal];
            [foldBtn setImage:img forState:UIControlStateHighlighted];
            [foldBtn setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -20, -20, -10)];
            [foldBtn addTarget:self action:@selector(foldBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:foldBtn];
            self.foldBtn = foldBtn;
            [self.foldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(nameKey.mas_centerY);
                make.right.mas_equalTo(-12);
                make.size.mas_equalTo(CGSizeMake(16, 16));
            }];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(foldBtnDidClick)];
            nameValue.userInteractionEnabled = YES;
            [nameValue addGestureRecognizer:tap];
        }
    }
}

- (void)foldBtnDidClick {
    FHDetailNeighborhoodInfoCorrectingModel *model = (FHDetailNeighborhoodInfoCorrectingModel *)self.currentData;
    [model.tableView beginUpdates];
    
    CGFloat width = CGRectGetWidth(self.containerView.bounds) - 16 - 72 - 52 - 37;
    self.foldBtn.selected = !self.foldBtn.selected;
    UIImage *img = nil;
    if (self.foldBtn.selected) {
        img = ICON_FONT_IMG(16, @"\U0000e672", nil);
        self.schoolNameLabel.numberOfLines = 0;
        [self.schoolNameLabel btd_SetText:self.schoolNameLabel.text lineHeight:10];
        [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([self.schoolNameLabel btd_heightWithWidth:width]);
        }];
    }else {
        img = ICON_FONT_IMG(16, @"\U0000e65f", nil);
        self.schoolNameLabel.numberOfLines = 1;
        [self.schoolNameLabel btd_SetText:self.schoolNameLabel.text lineHeight:0];
        [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(16);
        }];
    }
    [self.foldBtn setImage:img forState:UIControlStateNormal];
    [self.foldBtn setImage:img forState:UIControlStateHighlighted];

    [model.tableView endUpdates];
}

- (void)refreshItemsView
{
    CGFloat viewHeight = 0;
    __block UIView *lastView = nil;
    for (FHOldDetailSchoolInfoItemView *itemView in self.schoolView.subviews) {
        if (![itemView isKindOfClass:[FHOldDetailSchoolInfoItemView class]]) {
            continue;
        }
        itemView.height = [itemView viewHeight];
        itemView.top = viewHeight;
        viewHeight += itemView.viewHeight;
        lastView = itemView;
    }
}

- (void)refreshSchoolViewFrame
{
    CGFloat viewHeight = 0;
    for (FHOldDetailSchoolInfoItemView *itemView in self.schoolView.subviews) {
        if (![itemView isKindOfClass:[FHOldDetailSchoolInfoItemView class]]) {
            continue;
        }
        viewHeight += itemView.viewHeight;
    }
    [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(viewHeight);
    }];
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        }];
}

- (void)showLabelWithKey:(NSString *)key value:(NSString *)value parentView:(UIView *)parentView
{
    UILabel *nameKey = [UILabel createLabel:key textColor:@"" fontSize:14];
    nameKey.textColor = [UIColor themeGray3];
    UILabel *nameValue = [UILabel createLabel:value textColor:@"" fontSize:14];
    nameValue.numberOfLines = 0;
    nameValue.textColor = [UIColor themeGray3];
    [parentView addSubview:nameKey];
    [parentView addSubview:nameValue];
    [nameKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(parentView);
        make.top.bottom.equalTo(parentView);
    }];
    [nameValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(parentView).mas_offset(42);
        make.centerY.equalTo(nameKey);
    }];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _houseShowCache = [NSMutableDictionary new];
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
    
    UIView *containerView = [[UIView alloc]init];
    containerView.clipsToBounds = YES;
    containerView.layer.cornerRadius = 10;
    [self.contentView addSubview:containerView];
    self.containerView = containerView;
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.top.equalTo(self.shadowImage).offset(12);
        make.bottom.equalTo(self.shadowImage).offset(-12);
    }];
    
    UIImageView *mainImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plot_image"]];
    mainImage.contentMode = UIViewContentModeScaleAspectFill;
    mainImage.layer.masksToBounds = YES;
    mainImage.layer.cornerRadius = 10.0;
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:mainImage.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10,10)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = CGRectMake(0, 0, ceil(AdaptOffset(81)), ceil(AdaptOffset(96)));
//    maskLayer.path = maskPath.CGPath;
//    mainImage.layer.mask = maskLayer;
    [self.containerView addSubview:mainImage];
    self.mainImage = mainImage;
    [self.mainImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).mas_offset(16);
        make.top.equalTo(self.containerView).mas_offset(8 + 12);
        make.width.mas_equalTo(72);
        make.height.mas_equalTo(72);
    }];
    
    FHDetailNeighborhoodTitleView *headerView = [[FHDetailNeighborhoodTitleView alloc] init];
    headerView.titleStr = @"小区";
    headerView.isShowLoadMore = YES; // 点击可以跳转小区详情
    [headerView addTarget:self action:@selector(gotoNeighborhood) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:headerView];
    self.headerView = headerView;
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainImage.mas_right).mas_offset(10);
        make.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(19);
        make.top.mas_equalTo(8 + 12);
    }];
    
    UIView *topView = [[UIView alloc]init];
    topView = [[UIView alloc] init];
    [self.containerView addSubview:topView];
    self.topView = topView;
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.headerView);
        make.height.mas_equalTo(16);
        make.top.mas_equalTo(self.headerView.mas_bottom).mas_offset(10);
    }];
    
    UIView *schoolView = [[UIView alloc]init];
    schoolView.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:schoolView];
    self.schoolView = schoolView;
    [self.schoolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.headerView);
        make.top.equalTo(self.topView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(16);
        make.bottom.mas_equalTo(self.containerView).mas_offset(-10);
    }];
    
    FHDetailNeighborhoodConsultCorrectingView *consultView = [[FHDetailNeighborhoodConsultCorrectingView alloc] init];
    __weak typeof(self)wself = self;
    consultView.backgroundColor = [UIColor clearColor];
    consultView.actionBlock = ^{
        [wself imAction];
    };
    [self.containerView addSubview:consultView];
    self.consultView = consultView;
    [self.consultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.headerView);
        make.top.equalTo(self.topView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(16);
        make.bottom.mas_equalTo(self.containerView).mas_offset(-10);
    }];
}

// 跳转小区
- (void)gotoNeighborhood {
    FHDetailNeighborhoodInfoCorrectingModel *model = (FHDetailNeighborhoodInfoCorrectingModel *)self.currentData;
    if (model) {
        NSString *enter_from = @"be_null";
        NSString *neighborhood_id = @"0";
        NSString *source = @"";
        NSDictionary *log_pb = nil;
        if (model.neighborhoodInfo) {
            // 二手房
            enter_from = @"old_detail";
            neighborhood_id = model.neighborhoodInfo.id;
            source = @"";
            log_pb = model.neighborhoodInfo.logPb;
        }
        if (model.rent_neighborhoodInfo) {
            // 租房
            enter_from = @"rent_detail";
            neighborhood_id = model.rent_neighborhoodInfo.id;
            source = @"rent_detail";
            log_pb = model.rent_neighborhoodInfo.logPb;
        }
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"card_type"] = @"no_pic";
        tracerDic[@"log_pb"] = log_pb ? log_pb : @"be_null";// 特殊，传入当前小区的logpb
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
        tracerDic[@"element_from"] = @"neighborhood_detail";
        tracerDic[@"enter_from"] = enter_from;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeNeighborhood),@"source":source}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",neighborhood_id];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

@end

// FHDetailNeighborhoodInfoModel
@implementation FHDetailNeighborhoodInfoCorrectingModel

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end
