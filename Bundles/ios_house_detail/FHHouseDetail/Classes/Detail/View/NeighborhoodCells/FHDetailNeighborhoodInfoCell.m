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

@interface FHDetailNeighborhoodInfoCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *topView;
@property (nonatomic, assign)   CGFloat       topHeight;
@property (nonatomic, strong)   UIView       *bottomView;
@property (nonatomic, strong)   UIView       *schoolView;

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
        self.topHeight = topHeight > 0 ? 30 : 0;
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.topHeight);
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
        self.topHeight = topHeight > 0 ? 30 : 0;
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.topHeight);
        }];
        [self updateSchoolView:model.neighborhoodInfo.schoolDictList];
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
            [theItemView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            [wself refreshSchoolViewFrame];
//            [theItemView setNeedsUpdateConstraints];
            [wself setNeedsUpdateConstraints];
            [model.tableView endUpdates];
        };
        
        [self.schoolView addSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.schoolView);
            if (lastItemView) {
                make.top.mas_equalTo(lastItemView.mas_bottom);
            }else {
                make.top.mas_equalTo(0);
            }
            make.height.mas_equalTo(itemView.bottomY);
        }];
        lastItemView = itemView;
    }
    [self.schoolView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(sumHeight);
    }];
}

- (void)refreshSchoolViewFrame
{
    CGFloat viewHeight = 0;
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
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"小区 ";
    _headerView.isShowLoadMore = YES; // 点击可以跳转小区详情
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
    [self.headerView addTarget:self  action:@selector(gotoNeighborhood) forControlEvents:UIControlEventTouchUpInside];
    
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor whiteColor];
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor whiteColor];
    _schoolView = [[UIView alloc] init];
    _schoolView.backgroundColor = [UIColor whiteColor];
    _schoolView.clipsToBounds = YES;

    [self.contentView addSubview:_schoolView];
    [self.contentView addSubview:_topView];
    [self.contentView addSubview:_bottomView];
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.schoolView.mas_bottom);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(0);
    }];
    [_schoolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
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
