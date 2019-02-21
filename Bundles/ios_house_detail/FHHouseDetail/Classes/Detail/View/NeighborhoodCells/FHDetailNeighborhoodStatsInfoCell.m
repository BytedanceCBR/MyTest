//
//  FHDetailNeighborhoodStatsInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailNeighborhoodStatsInfoCell.h"
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

@interface FHDetailNeighborhoodStatsInfoCell ()

@property (nonatomic, strong)   NSMutableDictionary       *elementShowTraceDic;

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
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailNeighborhoodStatsInfoModel *model = (FHDetailNeighborhoodStatsInfoModel *)data;
    if (model && model.statsInfo.count > 0) {
        UIView *topLine = [[UIView alloc] init];
        topLine.backgroundColor = [UIColor colorWithHexString:@"#e8eaeb"];
        [self.contentView addSubview:topLine];
        [topLine mas_makeConstraints:^(MASConstraintMaker *maker) {
            maker.height.mas_equalTo(0.5);
            maker.left.mas_equalTo(20);
            maker.right.mas_equalTo(-20);
            maker.top.mas_equalTo(self.contentView);
        }];
        //
        CGFloat space = (UIScreen.mainScreen.bounds.size.width - 40 - (70.0 * model.statsInfo.count)) / 2;
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
            [self.contentView addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.contentView).offset(leftOffset);
                make.width.mas_equalTo(itemWidth);
                make.top.mas_equalTo(topLine.mas_bottom);
                make.bottom.mas_equalTo(self.contentView);
            }];
            leftOffset += (itemWidth + space);
        }];
        
        // 添加中间 分割线
        for (int i = 1; i < model.statsInfo.count; i++) {
            UIView *v = [[UIView alloc] init];
            v.backgroundColor = [UIColor colorWithHexString:@"#e8eaeb"];
            [self.contentView addSubview:v];
            CGFloat leftOffset = 20.0 + i * 70 + (i - 1 + 0.5) * space;
            [v mas_makeConstraints:^(MASConstraintMaker *maker) {
                maker.height.mas_equalTo(27);
                maker.width.mas_equalTo(0.5);
                maker.centerY.mas_equalTo(self.contentView);
                maker.left.mas_equalTo(self.contentView).offset(leftOffset);
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
    [FHUserTracker writeEvent:@"element_show" params:tracerDic];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _elementShowTraceDic = [NSMutableDictionary new];
    }
    return self;
}

- (void)clickButton:(UIControl *)control {
    FHDetailNeighborhoodStatsInfoModel *model = (FHDetailNeighborhoodStatsInfoModel *)self.currentData;
    NSInteger index = control.tag;
    if (model && model.statsInfo.count > 0 && index >= 0 && index < model.statsInfo.count) {
        FHDetailNeighborhoodDataStatsInfoModel *info = model.statsInfo[index];
        NSLog(@"click：%ld",index);
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
    _valueLabel = [UILabel createLabel:@"" textColor:@"#8a9299" fontSize:12];
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
    self.backgroundColor = [UIColor whiteColor];
    _keyLabel = [UILabel createLabel:@"" textColor:@"#517b9f" fontSize:14];
    [self addSubview:_keyLabel];
    
    _valueDataLabel = [[FHDetailNeighborhoodItemButtonControl alloc] init];
    _valueDataLabel.userInteractionEnabled = NO;
    [self addSubview:_valueDataLabel];
    
    [self.valueDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(14.5);
        make.right.mas_equalTo(self);
    }];
    
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.valueDataLabel.mas_left);
        make.top.mas_equalTo(self.valueDataLabel.mas_bottom).offset(2);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self).offset(-14);
        
    }];
    self.isDataEnabled = YES;
}

- (void)setIsDataEnabled:(BOOL)isDataEnabled {
    _isDataEnabled = isDataEnabled;
    if (isDataEnabled) {
        self.keyLabel.textColor = [UIColor colorWithHexString:@"#517b9f"];
    } else {
        self.keyLabel.textColor = [UIColor colorWithHexString:@"#a1aab3"];
    }
}

@end
