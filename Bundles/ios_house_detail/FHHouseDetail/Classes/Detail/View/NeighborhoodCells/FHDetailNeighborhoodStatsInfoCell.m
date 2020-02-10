//
//  FHDetailNeighborhoodStatsInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailNeighborhoodStatsInfoCell.h"
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

@interface FHDetailNeighborhoodStatsInfoCell ()

@property (nonatomic, strong)   NSMutableDictionary       *elementShowTraceDic;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *topLine;
@property (nonatomic, weak) UIView *bottomLine;

@end

@implementation FHDetailNeighborhoodStatsInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodStatsInfoModel class]]) {
        return;
    }
    self.currentData = data;
    //
    FHDetailNeighborhoodStatsInfoModel *model = (FHDetailNeighborhoodStatsInfoModel *)data;
    self.bottomLine.hidden = model.showBottomLine;
    self.shadowImage.image = model.shadowImage;
    if (model && model.statsInfo.count > 0) {
        //
        CGFloat space = (UIScreen.mainScreen.bounds.size.width -30- 40 - (70.0 * model.statsInfo.count)) / 2;
        __block CGFloat leftOffset = 20;
        CGFloat itemWidth = 70;
        [model.statsInfo enumerateObjectsUsingBlock:^(FHDetailNeighborhoodDataStatsInfoModel*  _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
            FHDetailNeighborhoodItemValueView *itemView = [[FHDetailNeighborhoodItemValueView alloc] init];
            itemView.keyLabel.text = info.value;
            itemView.valueDataLabel.valueLabel.text = info.attr;
            itemView.tag = idx;
            [itemView addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            if ([info.value isEqualToString:@"暂无"] || [info.value isEqualToString:@"0套"]) {
                itemView.keyLabel.text = @"暂无";
                itemView.valueDataLabel.isEnabled = NO;
                itemView.isDataEnabled = NO;
                itemView.enabled = NO;
            } else {
                itemView.valueDataLabel.isEnabled = YES;
                itemView.isDataEnabled = YES;
                itemView.enabled = YES;
                // element_show 埋点
                [self sendElementShowTrace:idx];
            }
            [self.containerView addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.containerView).offset(leftOffset);
                make.width.mas_equalTo(itemWidth);
                make.top.mas_equalTo(self.topLine.mas_bottom);
                make.bottom.mas_equalTo(self.bottomLine.mas_top);
            }];
            leftOffset += (itemWidth + space);
        }];
        
        // 添加中间 分割线
        for (int i = 1; i < model.statsInfo.count; i++) {
            UIView *v = [[UIView alloc] init];
            v.backgroundColor = [UIColor themeGray6];
            [self.containerView addSubview:v];
            CGFloat leftOffset = 20.0 + i * 70 + (i - 1 + 0.5) * space;
            [v mas_makeConstraints:^(MASConstraintMaker *maker) {
                maker.height.mas_equalTo(27);
                maker.width.mas_equalTo(0.5);
                maker.centerY.mas_equalTo(self.containerView);
                maker.left.mas_equalTo(self.containerView).offset(leftOffset);
            }];
        }
    }
    [self layoutIfNeeded];
}
// element_show 单独埋吧： '在售房源': 'house_onsale', '成交房源': 'house_deal',在租房源：'house_rent'
- (void)sendElementShowTrace:(NSInteger)index {
    NSString *element_type = @"be_null";
    switch (index) {
        case 0:
            element_type = @"house_onsale";
            break;
        case 1:
            element_type = @"house_deal";
            break;
        case 2:
            element_type = @"house_rent";
            break;
        default:
            break;
    }
    if (self.elementShowTraceDic[element_type]) {
        return;
    }
    self.elementShowTraceDic[element_type] = @(YES);
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    tracerDic[@"element_type"] = element_type;
    [tracerDic removeObjectForKey:@"element_from"];
    [FHUserTracker writeEvent:@"element_show" params:tracerDic];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
        _elementShowTraceDic = [NSMutableDictionary new];
    }
    return self;
}

- (void)createUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadowImage).offset(22);
        make.bottom.equalTo(self.shadowImage).offset(-22);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(0.3);
        make.left.equalTo(self.containerView).offset(16);
        make.right.equalTo(self.containerView).offset(-16);
        make.top.equalTo(self.containerView);
    }];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(0.3);
        make.left.equalTo(self.containerView).offset(16);
        make.right.equalTo(self.containerView).offset(-16);
        make.bottom.equalTo(self.containerView);
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

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc]init];
        [self.contentView addSubview: containerView];
        _containerView = containerView;
    }
    return _containerView;
}
- (UIView *)topLine {
    if (!_topLine) {
        UIView *topLine = [[UIView alloc]init];
        topLine.backgroundColor = [UIColor themeGray6];
        [self.containerView addSubview: topLine];
        _topLine = topLine;
    }
    return _topLine;
}
- (UIView *)bottomLine {
    if (!_bottomLine) {
        UIView *bottomLine = [[UIView alloc]init];
        bottomLine.backgroundColor = [UIColor themeGray6];
        [self.containerView addSubview: bottomLine];
        _bottomLine = bottomLine;
    }
    return _bottomLine;
}

- (void)clickButton:(UIControl *)control {
    FHDetailNeighborhoodStatsInfoModel *model = (FHDetailNeighborhoodStatsInfoModel *)self.currentData;
    NSInteger index = control.tag;
    if (model && model.statsInfo.count > 0 && index >= 0 && index < model.statsInfo.count) {
        FHDetailNeighborhoodDataStatsInfoModel *info = model.statsInfo[index];
        NSString *openUrl = [info.openUrl stringByRemovingPercentEncoding];
        if (openUrl.length > 0) {
            openUrl = [openUrl stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
            NSURL *theUrl = [NSURL URLWithString:openUrl];
            if (theUrl) {
                FHDetailNeighborhoodModel *detailModel = self.baseViewModel.detailData;
                NSString *neighborhood_id = @"";
                if (detailModel && detailModel.data.id.length > 0) {
                    neighborhood_id = detailModel.data.id;
                }
                NSString *house_id = @"";
                if (self.baseViewModel.houseId.length > 0) {
                    house_id = self.baseViewModel.houseId;
                }
                NSMutableDictionary *userInfo = [NSMutableDictionary new];
                if (neighborhood_id.length > 0) {
                    userInfo[@"neighborhood_id"] = neighborhood_id;
                }
                NSString *element_from = @"be_null";
                NSString *category_name = @"be_null";
                NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
                tracerDic[@"enter_type"] = @"click";
                tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
                switch (index) {
                    case 0:
                        // 在售房源
                        element_from = @"house_onsale";
                        category_name = @"same_neighborhood_list";
                        userInfo[@"house_type"] = @(FHHouseTypeSecondHandHouse);
                        userInfo[@"list_vc_type"] = @(3);
                        if (detailModel.data.name.length > 0) {
                            NSString *name = @"0套";
                            if (info.value.length > 0) {
                                name  = info.value;
                            }
                            userInfo[@"title"] = [NSString stringWithFormat:@"%@(%@)",detailModel.data.name,name];
                        }
                        break;
                    case 1:
                        // 成交历史
                        element_from = @"house_deal";
                        category_name = @"neighborhood_trade_list";
                        break;
                    case 2:
                        // 在租房源
                        element_from = @"house_renting";
                        category_name = @"same_neighborhood_list";
                        userInfo[@"house_type"] = @(FHHouseTypeRentHouse);
                        userInfo[@"list_vc_type"] = @(4);
                        if (detailModel.data.name.length > 0) {
                            NSString *name = @"0套";
                            if (info.value.length > 0) {
                                name  = info.value;
                            }
                            userInfo[@"title"] = [NSString stringWithFormat:@"%@(%@)",detailModel.data.name,name];
                        }
                        break;
                    default:
                        break;
                }
                tracerDic[@"category_name"] = category_name;
                tracerDic[@"element_from"] = element_from;
                tracerDic[@"enter_from"] = @"neighborhood_detail";
                userInfo[@"tracer"] = tracerDic;
                TTRouteUserInfo *userInf = [[TTRouteUserInfo alloc] initWithInfo:userInfo];
                [[TTRoute sharedRoute] openURLByPushViewController:theUrl userInfo:userInf];
            }
        }
    }
}

@end


// FHDetailNeighborhoodStatsInfoModel
@implementation FHDetailNeighborhoodStatsInfoModel

@end


// FHDetailNeighborhoodItemButtonControl
@interface FHDetailNeighborhoodItemButtonControl ()

@end

@implementation FHDetailNeighborhoodItemButtonControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _valueLabel.textColor = [UIColor themeGray3];
    [self addSubview:_valueLabel];
    
    _rightArrowImageView = [[UIImageView alloc] init];
    _rightArrowImageView.image = [UIImage imageNamed:@"setting-arrow-4"];
    [self addSubview:_rightArrowImageView];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self);
        make.height.mas_equalTo(17);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.valueLabel.mas_right).offset(10);
        make.width.height.mas_equalTo(12);
        make.centerY.mas_equalTo(self.valueLabel);
    }];
}

- (void)setIsEnabled:(BOOL)isEnabled {
    _isEnabled = isEnabled;
    self.rightArrowImageView.hidden = !isEnabled;
}

@end

// FHDetailNeighborhoodItemValueView
@interface FHDetailNeighborhoodItemValueView ()

@end

@implementation FHDetailNeighborhoodItemValueView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _keyLabel.font = [UIFont themeFontSemibold:18];
    _keyLabel.textColor = [UIColor themeGray1];
    [self addSubview:_keyLabel];
    
    _valueDataLabel = [[FHDetailNeighborhoodItemButtonControl alloc] init];
    _valueDataLabel.userInteractionEnabled = NO;
    [self addSubview:_valueDataLabel];
    
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(17);
        make.right.mas_equalTo(self);
    }];
    
    [self.valueDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.keyLabel.mas_left);
        make.top.mas_equalTo(self.keyLabel.mas_bottom).offset(2);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self).offset(-17);
        
    }];
    self.isDataEnabled = YES;
}

- (void)setIsDataEnabled:(BOOL)isDataEnabled {
    _isDataEnabled = isDataEnabled;
}

@end
