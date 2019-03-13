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
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHDetailBottomOpenAllView.h"
#import "FHDetailStarsCountView.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"

@interface FHDetailNeighborhoodInfoCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;

@property (nonatomic, strong)   UILabel       *nameKey;
@property (nonatomic, strong)   UILabel       *nameValue;
@property (nonatomic, strong)   UILabel       *schoolKey;
@property (nonatomic, strong)   UILabel       *schoolLabel;

@end

@implementation FHDetailNeighborhoodInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodInfoModel class]]) {
        return;
    }
    self.currentData = data;
    //
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)data;
    // 二手房
    if (model.neighborhoodInfo) {
        [self updateErshouCellData];
    }
    // 租房
    if (model.rent_neighborhoodInfo) {
        [self updateRentCellData];
    }
    [self layoutIfNeeded];
}

// 小区信息
- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_detail";
}

// 租房
- (void)updateRentCellData {
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    if (model) {
        NSString *headerName = [NSString stringWithFormat:@"小区 %@",model.rent_neighborhoodInfo.name];
        self.headerView.label.text = headerName;
        NSString *districtName = model.rent_neighborhoodInfo.districtName;
        self.nameValue.text = districtName;
        NSString *schoolName = model.rent_neighborhoodInfo.schoolInfo.schoolName;
        [self updateSchoolName:schoolName];
    }
}

// 二手房
- (void)updateErshouCellData {
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    if (model) {
        NSString *headerName = [NSString stringWithFormat:@"小区 %@",model.neighborhoodInfo.name];
        self.headerView.label.text = headerName;
        NSString *areaName = model.neighborhoodInfo.areaName;
        NSString *districtName = model.neighborhoodInfo.districtName;
        if (areaName.length > 0 && districtName.length > 0) {
            self.nameValue.text = [NSString stringWithFormat:@"%@-%@",districtName,areaName];
        } else {
            self.nameValue.text = districtName;
        }
        NSString *schoolName = @"";
        if (model.neighborhoodInfo.schoolInfo.count > 0) {
            FHDetailOldDataNeighborhoodInfoSchoolInfoModel *schoolInfo = model.neighborhoodInfo.schoolInfo[0];
            schoolName = schoolInfo.schoolName;
        }
        [self updateSchoolName:schoolName];
    }
}

- (void)updateSchoolName:(NSString *)schoolName {
    self.schoolLabel.text = schoolName;
    if (schoolName.length > 0) {
        [self.nameKey mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-51);
        }];
        self.schoolKey.hidden = NO;
        self.schoolLabel.hidden = NO;
    } else {
        [self.nameKey mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-20);
        }];
        self.schoolKey.hidden = YES;
        self.schoolLabel.hidden = YES;
    }
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
    
    _nameKey = [UILabel createLabel:@"所属区域" textColor:@"" fontSize:15];
    _nameKey.textColor = [UIColor themeGray3];
    
    _nameValue = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _nameValue.textColor = [UIColor themeGray1];
    
    _schoolKey = [UILabel createLabel:@"教育资源" textColor:@"" fontSize:15];
    _schoolKey.textColor = [UIColor themeGray3];
    
    _schoolLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _schoolLabel.textColor = [UIColor themeGray1];
    
    [self.contentView addSubview:_nameKey];
    [self.nameKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-51);// 一定有区域名称
    }];
    [self.contentView addSubview:self.nameValue];
    [self.nameValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameKey.mas_right).offset(12);
        make.top.mas_equalTo(self.nameKey);
        make.height.mas_equalTo(20);
    }];
    [self.contentView addSubview:_schoolKey];
    [self.schoolKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameKey);
        make.top.mas_equalTo(self.nameKey.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    [self.contentView addSubview:self.schoolLabel];
    [self.schoolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.schoolKey.mas_right).offset(12);
        make.top.mas_equalTo(self.schoolKey);
        make.height.mas_equalTo(20);
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


@end
