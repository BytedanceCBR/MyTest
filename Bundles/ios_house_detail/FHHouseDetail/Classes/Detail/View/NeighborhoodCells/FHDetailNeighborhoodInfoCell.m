//
//  FHDetailNeighborhoodInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailNeighborhoodInfoCell.h"
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
#import "FHDetailSchoolInfoItemView.h"
#import "FHDetailHeaderViewNoMargin.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHHouseDetailContactViewModel.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHHouseContactDefines.h>

@interface FHDetailNeighborhoodConsultView : UIView

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIImageView *consultImgView;
@property (nonatomic, strong) UIButton *consultBtn;
@property (nonatomic, strong) UIButton *actionBtn;
@property (nonatomic, copy) void (^actionBlock)(void);

@end

@implementation FHDetailNeighborhoodConsultView

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
    self.backgroundColor = UIColor.whiteColor;
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.font = [UIFont themeFontRegular:15];
    _nameLabel.textColor = [UIColor themeGray3];
    [self addSubview:_nameLabel];
    
    _infoLabel = [[UILabel alloc]init];
    _infoLabel.font = [UIFont themeFontRegular:15];
    _infoLabel.textColor = [UIColor themeRed1];
    [self addSubview:_infoLabel];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    
    _consultBtn = [[UIButton alloc]init];
    [self addSubview:_consultBtn];

    _actionBtn = [[UIButton alloc]init];
    [self addSubview:_actionBtn];
    [_actionBtn addTarget:self action:@selector(consultBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];

    UIImage *img = ICON_FONT_IMG(15, @"\U0000e691", [UIColor themeRed1]);
    _consultImgView = [[UIImageView alloc] init];
    _consultImgView.image = img;
    _consultImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_consultImgView];

    // 布局
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20).priorityHigh();
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(12);
        make.right.mas_lessThanOrEqualTo(-30);
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.consultImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoLabel.mas_right).offset(6);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(20);
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

@interface FHDetailNeighborhoodInfoCell ()

@property (nonatomic, strong)   FHDetailHeaderViewNoMargin       *headerView;
@property (nonatomic, strong)   UIView       *topView;
@property (nonatomic, assign)   CGFloat       topHeight;
@property (nonatomic, strong)   FHDetailNeighborhoodConsultView       *consultView;
@property (nonatomic, strong)   UIView       *schoolView;
@property (nonatomic, strong)   NSMutableDictionary       *houseShowCache; // 埋点缓存

@end

@implementation FHDetailNeighborhoodInfoCell

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
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodInfoModel class]]) {
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
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)data;
    // 二手房
    if (model.neighborhoodInfo) {
        [self updateErshouCellData];
    }
    // 租房
    if (model.rent_neighborhoodInfo) {
        [self updateRentCellData];
    }
}

// 小区信息
- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"neighborhood_detail";
}

// 租房
- (void)updateRentCellData
{ 	
    CGFloat topHeight = 0;
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    if (model) {
        NSString *headerName = [NSString stringWithFormat:@"小区 %@",model.rent_neighborhoodInfo.name];
        self.headerView.label.text = headerName;
        NSString *districtName = model.rent_neighborhoodInfo.districtName;
        NSString *areaName = model.rent_neighborhoodInfo.areaName;
        UIView *lastView = nil;
        if (areaName.length > 0 && districtName.length > 0) {
            topHeight = [self showLabelWithKey:@"所属区域" value:[NSString stringWithFormat:@"%@-%@",districtName,areaName] parentView:self.topView bottomY:topHeight];
        } else if (districtName.length > 0) {
            topHeight = [self showLabelWithKey:@"所属区域" value:districtName parentView:self.topView bottomY:topHeight];
        }
        self.topHeight = topHeight;
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.topHeight);
        }];

        [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(26 + self.topHeight);
        }];
        [self updateSchoolView:model.rent_neighborhoodInfo.schoolDictList];
    }
}

// 二手房
- (void)updateErshouCellData
{
    CGFloat topHeight = 0;
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    if (model) {
        NSString *headerName = [NSString stringWithFormat:@"小区 %@",model.neighborhoodInfo.name];
        self.headerView.label.text = headerName;
        NSString *areaName = model.neighborhoodInfo.areaName;
        NSString *districtName = model.neighborhoodInfo.districtName;
        UIView *lastView = nil;
        if (areaName.length > 0 && districtName.length > 0) {
            topHeight = [self showLabelWithKey:@"所属区域" value:[NSString stringWithFormat:@"%@-%@",districtName,areaName] parentView:self.topView bottomY:topHeight];

        } else if (districtName.length > 0) {
            topHeight = [self showLabelWithKey:@"所属区域" value:districtName parentView:self.topView bottomY:topHeight];
        }else {
            topHeight = 0;
        }
        self.topHeight = topHeight;
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.topHeight);
        }];
        
        if (model.neighborhoodInfo.useSchoolIm) {
            self.schoolView.hidden = YES;
            self.consultView.hidden = NO;
            self.consultView.nameLabel.text = @"学校资源:";
            self.consultView.infoLabel.text = model.neighborhoodInfo.schoolConsult.text;
            [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(26 + self.topHeight);
                make.height.mas_equalTo(24);
            }];
            [self.consultView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(26 + self.topHeight);
                make.height.mas_equalTo(30);
            }];
        }else {
            self.schoolView.hidden = NO;
            self.consultView.hidden = YES;
            [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(26 + self.topHeight);
            }];
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
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    NSDictionary *logPb = nil;
    NSString *searchId = nil;
    NSString *groupId = nil;
    NSString *imprId = nil;

    if (model.neighborhoodInfo) {
        FHDetailOldDataNeighborhoodInfoModel *neighborhoodInfo = model.neighborhoodInfo;
        logPb = neighborhoodInfo.logPb;
        searchId = neighborhoodInfo.searchId;
        groupId = neighborhoodInfo.groupId.length > 0 ? neighborhoodInfo.groupId : ( neighborhoodInfo.id ? neighborhoodInfo.id : @"be_null");
        imprId = neighborhoodInfo.imprId.length > 0 ? neighborhoodInfo.imprId : @"be_null";
    }else if (model.rent_neighborhoodInfo) {
        FHRentDetailResponseDataNeighborhoodInfoModel *neighborhoodInfo = model.rent_neighborhoodInfo;
        logPb = neighborhoodInfo.logPb;
        searchId = neighborhoodInfo.searchId;
        groupId = neighborhoodInfo.id ? neighborhoodInfo.id : @"be_null";
        imprId = neighborhoodInfo.imprId.length > 0 ? neighborhoodInfo.imprId : @"be_null";
    }
    NSString *tempKey = [NSString stringWithFormat:@"%ld", groupId];
    if ([self.houseShowCache valueForKey:tempKey]) {
        return;
    }
    [self.houseShowCache setValue:@(YES) forKey:tempKey];
    // house_show
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    tracerDic[@"rank"] = @(0);
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"log_pb"] = logPb ? logPb : @"be_null";
    tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
    tracerDic[@"element_type"] = @"neighborhood_detail";
    tracerDic[@"search_id"] = searchId;
    tracerDic[@"group_id"] = groupId;
    tracerDic[@"impr_id"] = imprId;
    [tracerDic removeObjectsForKeys:@[@"element_from"]];
    [FHUserTracker writeEvent:@"house_show" params:tracerDic];
}


- (void)imAction
{
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
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
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    __block UIView *lastItemView = nil;
    CGFloat sumHeight = 0;
    for (NSInteger index = 0; index < schoolDictList.count; index++) {
        FHDetailDataNeighborhoodInfoSchoolItemModel *item = schoolDictList[index];
        if (item.schoolList.count < 1) {
            continue;
        }
        FHDetailSchoolInfoItemModel *schoolInfoModel = [[FHDetailSchoolInfoItemModel alloc]init];
        schoolInfoModel.schoolItem = item;
        schoolInfoModel.tableView = model.tableView;
        FHDetailSchoolInfoItemView *itemView = [[FHDetailSchoolInfoItemView alloc]initWithSchoolInfoModel:schoolInfoModel];
        sumHeight += itemView.bottomY;
        __weak typeof(self)wself = self;
        itemView.foldBlock = ^(FHDetailSchoolInfoItemView *theItemView, CGFloat height) {
            
            [model.tableView beginUpdates];
            [UIView animateWithDuration:0.3 animations:^{
                [wself refreshItemsView];
            } completion:^(BOOL finished) {
            }];
            
            [wself refreshSchoolViewFrame];
            [wself setNeedsUpdateConstraints];
            [model.tableView endUpdates];
  
        };
        
        [self.schoolView addSubview:itemView];
        itemView.frame = CGRectMake(0, lastItemView.bottom, SCREEN_WIDTH, itemView.bottomY);
        lastItemView = itemView;
    }
    [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(26 + self.topHeight);
        make.height.mas_equalTo(sumHeight);
    }];
}
- (void)refreshItemsView
{
    CGFloat viewHeight = 0;
    __block UIView *lastView = nil;
    for (FHDetailSchoolInfoItemView *itemView in self.schoolView.subviews) {
        if (![itemView isKindOfClass:[FHDetailSchoolInfoItemView class]]) {
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
    __block UIView *lastView = nil;
    for (FHDetailSchoolInfoItemView *itemView in self.schoolView.subviews) {
        if (![itemView isKindOfClass:[FHDetailSchoolInfoItemView class]]) {
            continue;
        }
        viewHeight += itemView.viewHeight;
    }
    [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(viewHeight);
    }];
}

- (CGFloat)showLabelWithKey:(NSString *)key value:(NSString *)value parentView:(UIView *)parentView bottomY:(CGFloat)bottomY
{
    UILabel *nameKey = [UILabel createLabel:key textColor:@"" fontSize:15];
    nameKey.textColor = [UIColor themeGray3];
    UILabel *nameValue = [UILabel createLabel:value textColor:@"" fontSize:14];
    nameValue.numberOfLines = 0;
    nameValue.textColor = [UIColor themeGray1];
    [parentView addSubview:nameKey];
    [parentView addSubview:nameValue];
    [nameKey sizeToFit];
    nameKey.left = 20;
    nameKey.top = bottomY + 10;
    nameKey.height = 20;
    
    nameValue.width = SCREEN_WIDTH - 20 - nameKey.right - 12;
    [nameValue sizeToFit];
    nameValue.left = nameKey.right + 12;
    nameValue.top = nameKey.top;
    
    bottomY = nameValue.bottom;
    return bottomY;
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
    _headerView = [[FHDetailHeaderViewNoMargin alloc] init];
    _headerView.label.text = @"小区 ";
    _headerView.isShowLoadMore = YES; // 点击可以跳转小区详情
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(26);
    }];
    [self.headerView addTarget:self action:@selector(gotoNeighborhood) forControlEvents:UIControlEventTouchUpInside];
    
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor whiteColor];
    _schoolView = [[UIView alloc] init];
    _schoolView.backgroundColor = [UIColor whiteColor];

    __weak typeof(self)wself = self;
    _consultView = [[FHDetailNeighborhoodConsultView alloc] init];
    _consultView.backgroundColor = [UIColor whiteColor];
    _consultView.actionBlock = ^{
        [wself imAction];
    };

    [self.contentView addSubview:_schoolView];
    [self.contentView addSubview:_topView];
    [self.contentView addSubview:_consultView];

    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(26);
        make.height.mas_equalTo(0);
    }];
    [_schoolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(-20);
    }];
    [_consultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
}

// 跳转小区
- (void)gotoNeighborhood {
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
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
@implementation FHDetailNeighborhoodInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end
