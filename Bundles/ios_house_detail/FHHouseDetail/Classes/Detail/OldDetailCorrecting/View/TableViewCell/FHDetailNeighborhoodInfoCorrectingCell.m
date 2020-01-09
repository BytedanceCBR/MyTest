//
//  FHDetailNeighborhoodInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailNeighborhoodInfoCorrectingCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
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
#import <FHCommonDefines.h>
#import <TTBaseLib/UIButton+TTAdditions.h>
#import "FHOldDetailSchoolInfoItemView.h"
#import "FHDetailNeighborhoodTitleView.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHHouseDetailContactViewModel.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHHouseContactDefines.h>
#import "FHUtils.h"
#import "FHUIAdaptation.h"

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
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(AdaptOffset(5));
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

- (UIImageView *)mainImage {
    if (!_mainImage) {
        UIImageView *mainImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"plot_image"]];
        [self.containerView addSubview:mainImage];
        _mainImage = mainImage;
    }
    return  _mainImage;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc]init];
        containerView.clipsToBounds = YES;
        containerView.layer.cornerRadius = 10;
        [self.contentView addSubview:containerView];
        _containerView = containerView;
    }
    return _containerView;
}

- (FHDetailNeighborhoodTitleView *)headerView {
    if (!_headerView) {
        FHDetailNeighborhoodTitleView *headerView = [[FHDetailNeighborhoodTitleView alloc]init];
        headerView.titleStr= @"小区";
        headerView.isShowLoadMore = YES; // 点击可以跳转小区详情
        [self.contentView addSubview:headerView];
        [headerView addTarget:self action:@selector(gotoNeighborhood) forControlEvents:UIControlEventTouchUpInside];
        _headerView = headerView;
    }
    return _headerView;
}

- (UIView *)topView {
    if (!_topView) {
        UIView *topView = [[UIView alloc]init];
        topView = [[UIView alloc] init];
        [self.containerView addSubview:topView];
        _topView = topView;
    }
    return _topView;
}

- (FHDetailNeighborhoodConsultCorrectingView *)consultView {
    if (!_consultView) {
        FHDetailNeighborhoodConsultCorrectingView *consultView = [[FHDetailNeighborhoodConsultCorrectingView alloc]init];
        __weak typeof(self)wself = self;
        consultView.backgroundColor = [UIColor clearColor];
        consultView.actionBlock = ^{
            [wself imAction];
        };
        [self.containerView addSubview:consultView];
        _consultView = consultView;
    }
    return _consultView;
}

- (UIView *)schoolView {
    if (!_schoolView) {
        UIView *schoolView = [[UIView alloc]init];
        schoolView.backgroundColor = [UIColor clearColor];
        [self.containerView addSubview:schoolView];
        _schoolView = schoolView;
    }
    return _schoolView;
}
// 小区信息
- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"neighborhood_detail";
}

//// 租房
//- (void)updateRentCellData {
//    CGFloat topHeight = 0;
//    FHDetailNeighborhoodInfoCorrectingModel *model = (FHDetailNeighborhoodInfoCorrectingModel *)self.currentData;
//    if (model) {
//        NSString *headerName = [NSString stringWithFormat:@"小区 %@",model.rent_neighborhoodInfo.name];
//        self.headerView.label.text = headerName;
//        NSString *districtName = model.rent_neighborhoodInfo.districtName;
//        NSString *areaName = model.rent_neighborhoodInfo.areaName;
//        if (areaName.length > 0 && districtName.length > 0) {
//            topHeight = [self showLabelWithKey:@"所属区域" value:[NSString stringWithFormat:@"%@-%@",districtName,areaName] parentView:self.topView bottomY:topHeight];
//        } else if (districtName.length > 0) {
//            topHeight = [self showLabelWithKey:@"所属区域" value:districtName parentView:self.topView bottomY:topHeight];
//        }
//        self.topHeight = topHeight;
//        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(self.topHeight);
//        }];
//
//        [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(26 + self.topHeight);
//        }];
//        [self updateSchoolView:model.rent_neighborhoodInfo.schoolDictList];
//    }
//}

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
        if (model.neighborhoodInfo.useSchoolIm) {
            self.schoolView.hidden = YES;
            self.consultView.hidden = NO;
            self.consultView.nameLabel.text = @"学校资源:";
            self.consultView.infoLabel.text = model.neighborhoodInfo.schoolConsult.text;
        }else {
            self.schoolView.hidden = NO;
            self.consultView.hidden = YES;
            [self updateSchoolView:model.neighborhoodInfo.schoolDictList];
        }
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
    NSString *tempKey = [NSString stringWithFormat:@"%ld", model.neighborhoodInfo.id];
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
        imExtra[@"from"] = @"app_oldhouse_school";
        imExtra[@"source_from"] = @"education_type";
        imExtra[@"im_open_url"] = model.neighborhoodInfo.schoolConsult.openUrl;
        imExtra[kFHClueEndpoint] = [NSString stringWithFormat:@"%ld",FHClueEndPointTypeC];
        imExtra[kFHCluePage] = [NSString stringWithFormat:@"%ld",FHClueIMPageTypeCOldSchool];
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
    FHDetailNeighborhoodInfoCorrectingModel *model = (FHDetailNeighborhoodInfoCorrectingModel *)self.currentData;
    __block UIView *lastItemView = nil;
    CGFloat sumHeight = 0;
    for (NSInteger index = 0; index < schoolDictList.count; index++) {
        FHDetailDataNeighborhoodInfoSchoolItemModel *item = schoolDictList[index];
        if (item.schoolList.count < 1) {
            continue;
        }
        FHOldDetailSchoolInfoItemModel *schoolInfoModel = [[FHOldDetailSchoolInfoItemModel alloc]init];
        schoolInfoModel.schoolItem = item;
        schoolInfoModel.tableView = model.tableView;
        FHOldDetailSchoolInfoItemView *itemView = [[FHOldDetailSchoolInfoItemView alloc]initWithSchoolInfoModel:schoolInfoModel];
        sumHeight += itemView.bottomY;
        __weak typeof(self)wself = self;
        itemView.foldBlock = ^(FHOldDetailSchoolInfoItemView *theItemView, CGFloat height) {
            
            [model.tableView beginUpdates];
             [wself refreshSchoolViewFrame];
            [UIView animateWithDuration:0.3 animations:^{
                [wself refreshItemsView];
            } completion:^(BOOL finished) {
            }];
            [model.tableView endUpdates];
  
        };
        [self.schoolView addSubview:itemView];
        itemView.frame = CGRectMake(0, lastItemView.bottom, SCREEN_WIDTH-30-97, itemView.bottomY);
        lastItemView = itemView;
    }
    [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(sumHeight);
    }];
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
    UILabel *nameKey = [UILabel createLabel:key textColor:@"" fontSize:AdaptFont(14)];
    nameKey.textColor = [UIColor themeGray3];
    UILabel *nameValue = [UILabel createLabel:value textColor:@"" fontSize:AdaptFont(14)];
    nameValue.numberOfLines = 0;
    nameValue.textColor = [UIColor themeGray3];
    [parentView addSubview:nameKey];
    [parentView addSubview:nameValue];
    [nameKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(parentView);
        make.top.bottom.equalTo(parentView);
    }];
    [nameValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nameKey.mas_right).mas_offset(AdaptOffset(5));
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
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(AdaptOffset(15));
        make.right.mas_equalTo(self.contentView).mas_offset(AdaptOffset(-15));
        make.top.equalTo(self.shadowImage).offset(12);
        make.bottom.equalTo(self.shadowImage).offset(-12);
    }];
    [self.mainImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView);
        make.top.equalTo(self.containerView).offset(8);
        make.width.mas_equalTo(AdaptOffset(81));
        make.height.mas_equalTo(AdaptOffset(96));
    }];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainImage.mas_right).offset(AdaptOffset(16));
        make.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.containerView).offset(AdaptOffset(25));
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.headerView);
        make.top.mas_equalTo(self.headerView.mas_bottom);
    }];
    [self.schoolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.headerView);
        make.top.equalTo(self.topView.mas_bottom);
        make.bottom.mas_equalTo(self.containerView).mas_offset(-10);
    }];
    [self.consultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.headerView);
        make.top.equalTo(self.topView.mas_bottom);
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
