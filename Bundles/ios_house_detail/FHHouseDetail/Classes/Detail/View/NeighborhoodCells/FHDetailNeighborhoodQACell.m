//
//  FHDetailNeighborhoodQACell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/2/7.
//

#import "FHDetailNeighborhoodQACell.h"
#import "FHDetailNeighborhoodModel.h"
#import "TTDeviceHelper.h"
#import "FHDetailFoldViewButton.h"
#import "PNChart.h"
#import "FHDetailPriceMarkerView.h"
#import "UIView+House.h"
#import <FHHouseBase/FHUserTracker.h>

@interface FHDetailNeighborhoodQACell () <PNChartDelegate>

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIView *titleView;

@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIButton *questionBtn;
//@property(nonatomic , strong) UIView *chartBgView;
//@property(nonatomic , strong) UIView *bottomBgView;
//@property(nonatomic , strong) PNLineChart *chartView;
//@property(nonatomic, strong) FHDetailPriceMarkerView *markerView;
//
//@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel *> *priceTrends;
//@property(nonatomic, assign) double unitPerSquare;
//@property(nonatomic, assign) double maxValue;
//@property(nonatomic, assign) double minValue;
//@property(nonatomic, strong)NSDateFormatter *monthFormatter;
//@property(nonatomic, assign) NSInteger selectIndex;
//@property(nonatomic, assign) BOOL hideMarker;

@end

@implementation FHDetailNeighborhoodQACell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self initConstaints];
    }
    return self;
}

- (void)setupUI {
    self.contentView.backgroundColor = [UIColor themeGray7];
    self.bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.masksToBounds = YES;
    _bgView.layer.cornerRadius = 10;
    [self.contentView addSubview:_bgView];
    
    self.titleView = [[UIView alloc] init];
    [self.bgView addSubview:_titleView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:18] textColor:[UIColor themeGray1]];
    [self.titleView addSubview:_titleLabel];
    
    self.questionBtn = [[UIButton alloc] init];
    [_questionBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _questionBtn.imageView.contentMode = UIViewContentModeCenter;
    [_questionBtn setImage:[UIImage imageNamed:@"detail_questiom_ask"] forState:UIControlStateNormal];
    [_questionBtn setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    _questionBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_questionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_questionBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    [self addSubview:_questionBtn];
    
//    [self.contentView addSubview:self.chartBgView];
//    [self.chartBgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.mas_equalTo(0);
//        make.bottom.mas_equalTo(-20);
//    }];
//    [self.chartBgView addSubview:self.titleView];
//    [self.chartBgView addSubview:self.priceLabel];
//    [self.chartBgView addSubview:self.chartView];
//    [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(0);
//        make.left.mas_equalTo(70);
//        make.centerY.mas_equalTo(self.priceLabel);
//        make.height.mas_equalTo(20);
//    }];
//    [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(20);
//        make.top.mas_equalTo(0);
//    }];
//    [self.chartView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.top.mas_equalTo(self.priceLabel.mas_bottom).mas_offset(10);
//        if ([TTDeviceHelper isScreenWidthLarge320]) {
//            make.height.mas_equalTo(207);
//        }else {
//
//            make.height.mas_equalTo(207);
//        }
//        make.bottom.mas_equalTo(0);
//    }];
//
//    [self setupChartUI];
}

- (void)initConstaints {
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(500);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(30);
        make.left.mas_equalTo(self.bgView).offset(16);
        make.right.mas_equalTo(self.bgView).offset(-16);
        make.height.mas_equalTo(25);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.mas_equalTo(self.titleView);
        make.right.mas_equalTo(self.questionBtn.mas_left).offset(-10);
    }];
    
    [_questionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(self.titleView);
        make.width.mas_lessThanOrEqualTo(100);
    }];
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailQACellModel class]]) {
        return;
    }
//    self.currentData = data;
//    FHDetailPriceTrendCellModel *cellModel = (FHDetailPriceTrendCellModel *)data;
//    NSArray *priceTrends = cellModel.priceTrends;
//    self.priceTrends = priceTrends;
    _titleLabel.text = @"小区问答（20）";
    [_questionBtn setTitle:@"我要提问" forState:UIControlStateNormal];
}

#pragma mark delegate
//- (void)addClickPriceTrendLog
//{
//    NSMutableDictionary *params = @{}.mutableCopy;
//    NSDictionary *traceDict = [self.baseViewModel detailTracerDic];
//
//    //    1. event_type：house_app2c_v2
//    //    2. page_type：页面类型,{'新房详情页': 'new_detail', '二手房详情页': 'old_detail', '小区详情页': 'neighborhood_detail'}
//    //    3. rank
//    //    4. origin_from
//    //    5. origin_search_id
//    //    6.log_pb
//
//    params[@"page_type"] = traceDict[@"page_type"] ? : @"be_null";
//    params[@"rank"] = traceDict[@"rank"] ? : @"be_null";
//    params[@"origin_from"] = traceDict[@"origin_from"] ? : @"be_null";
//    params[@"origin_search_id"] = traceDict[@"origin_search_id"] ? : @"be_null";
//    params[@"log_pb"] = traceDict[@"log_pb"] ? : @"be_null";
//    [FHUserTracker writeEvent:@"click_price_trend" params:params];
//}
//

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
