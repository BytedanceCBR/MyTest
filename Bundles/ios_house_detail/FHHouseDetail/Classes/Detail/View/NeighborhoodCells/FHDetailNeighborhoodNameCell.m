//
//  FHDetailNeighborhoodNameCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailNeighborhoodNameCell.h"
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

@interface FHDetailNeighborhoodNameCell ()

@property (nonatomic, strong)   UILabel       *nameLabel;
@property (nonatomic, strong)   UILabel       *subNameLabel;
@property (nonatomic, strong)   UILabel       *priceLabel;
@property (nonatomic, strong)   UILabel       *monthUp;
@property (nonatomic, strong)   UILabel       *monthUpLabel;
@property (nonatomic, strong)   UIImageView       *monthUpTrend;
@property (nonatomic, strong)   UIButton       *subNameLabelButton;

@end

@implementation FHDetailNeighborhoodNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodNameModel class]]) {
        return;
    }
    self.currentData = data;
    //
    FHDetailNeighborhoodNameModel *model = (FHDetailNeighborhoodNameModel *)data;
    if (model) {
        self.nameLabel.text  = model.name;
        self.subNameLabel.text = model.neighborhoodInfo.address;
        self.priceLabel.text = model.neighborhoodInfo.pricingPerSqm;
        if (model.neighborhoodInfo.monthUp.length > 0) {
            CGFloat value = [model.neighborhoodInfo.monthUp floatValue] * 100;
            if (fabsf(value) < 0.0001) {
                // 持平
                self.monthUpLabel.text = @"持平";
                self.monthUpTrend.hidden = YES;
            } else {
                self.monthUpLabel.text = [NSString stringWithFormat:@"%.2f%%",fabsf(value)];
                self.monthUpTrend.hidden = NO;
                if (value > 0) {
                    self.monthUpTrend.image = [UIImage imageNamed:@"detail_trend_red"];
                } else {
                    self.monthUpTrend.image = [UIImage imageNamed:@"detail_trend_green"];
                }
            }
        }
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
    _nameLabel = [UILabel createLabel:@"" textColor:@"#081f33" fontSize:24];
    _nameLabel.font = [UIFont themeFontMedium:24];
    _nameLabel.numberOfLines = 2;
    [self.contentView addSubview:_nameLabel];
    
    _subNameLabel = [UILabel createLabel:@"" textColor:@"#8a9299" fontSize:12];
    [self.contentView addSubview:_subNameLabel];
    
    _priceLabel = [UILabel createLabel:@"" textColor:@"#ff5b4c" fontSize:18];
    _priceLabel.font = [UIFont themeFontMedium:18];
    _priceLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_priceLabel];
    
    _monthUp = [UILabel createLabel:@"环比上月" textColor:@"#a1aab3" fontSize:12];
    _monthUp.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_monthUp];
    
    _monthUpLabel = [UILabel createLabel:@"" textColor:@"#a1aab3" fontSize:12];
    _monthUpLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_monthUpLabel];
    
    _monthUpTrend = [[UIImageView alloc] init];
    [self.contentView addSubview:_monthUpTrend];
    
    _subNameLabelButton = [[UIButton alloc] init];
    [self.contentView addSubview:_subNameLabelButton];
    
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(21);
        make.width.mas_greaterThanOrEqualTo(95).priorityHigh();
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(self.priceLabel.mas_left).offset(-5);
        make.height.mas_equalTo(34);
    }];
    
    [_subNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(6);
        make.height.mas_equalTo(17);
        make.bottom.mas_equalTo(-14);
        make.right.mas_equalTo(self.monthUp.mas_left).offset(-10);
    }];
    
    [_subNameLabelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.subNameLabel);
    }];
    
    [_monthUpTrend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.subNameLabel);
        make.right.mas_equalTo(-20);
        make.width.height.mas_equalTo(12);
    }];
    
    [self.monthUpLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.monthUpLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_monthUpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.monthUpTrend);
        make.right.mas_equalTo(self.monthUpTrend.mas_left);
    }];
    
    [_monthUp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.monthUpTrend.mas_centerY);
        make.right.mas_equalTo(self.monthUpLabel.mas_left).offset(-3);
    }];
    
    [_subNameLabelButton addTarget:self action:@selector(openMapButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

// 打开地图
- (void)openMapButtonClick:(UIButton *)button {
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:@"银行" forKey:@"category"];
    FHDetailNeighborhoodNameModel *model = (FHDetailNeighborhoodNameModel *)self.currentData;
    if (model) {
        double lng = [model.neighborhoodInfo.gaodeLng doubleValue];
        double lat = [model.neighborhoodInfo.gaodeLat doubleValue];
        [infoDict setValue:@(lat) forKey:@"latitude"];
        [infoDict setValue:@(lng) forKey:@"longitude"];
    }
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}

@end

// FHDetailNeighborhoodNameModel
@implementation FHDetailNeighborhoodNameModel

@end
