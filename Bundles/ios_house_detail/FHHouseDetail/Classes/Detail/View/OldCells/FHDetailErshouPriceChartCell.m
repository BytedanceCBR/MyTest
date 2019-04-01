//
//  FHDetailErshouPriceChartCell.m
//  Pods
//
//  Created by 张静 on 2019/2/18.
//

#import "FHDetailErshouPriceChartCell.h"
#import "FHDetailOldModel.h"
#import "TTDeviceHelper.h"
#import "FHDetailFoldViewButton.h"
#import <PNChart.h>
#import "FHDetailPriceMarkerView.h"
#import "UIView+House.h"

@interface FHDetailErshouPriceChartCell () <PNChartDelegate>

@property(nonatomic , strong) UIImageView *bgView;
@property(nonatomic , strong) UIView *line;
@property(nonatomic , strong) UILabel *priceUpValueLabel;
@property(nonatomic , strong) UIImageView *priceUpTrend;
@property(nonatomic , strong) UILabel *pricePerKeyLabel;
@property(nonatomic , strong) UILabel *priceKeyLabel;
@property(nonatomic , strong) UILabel *priceValueLabel;
@property(nonatomic , strong) UILabel *monthUpKeyLabel;
@property(nonatomic , strong) UILabel *monthUpValueLabel;
@property(nonatomic , strong) UIImageView *monthUpTrend;
@property(nonatomic , strong) UIView *priceView;
@property(nonatomic , strong) UIView *titleView;
@property(nonatomic , strong) UILabel *priceLabel;
@property(nonatomic , strong) UIView *chartBgView;
@property(nonatomic , strong) UIView *bottomBgView;
@property(nonatomic , strong) PNLineChart *chartView;
@property(nonatomic, strong) FHDetailPriceMarkerView *markerView;

@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel *> *priceTrends;
@property(nonatomic, assign) double unitPerSquare;
@property(nonatomic, assign) double maxValue;
@property(nonatomic, assign) double minValue;
@property(nonatomic, strong)NSDateFormatter *monthFormatter;
@property(nonatomic, assign) NSInteger selectIndex;
@property(nonatomic, assign) BOOL hideMarker;

@end

@implementation FHDetailErshouPriceChartCell

- (void)setUnitPerSquare:(double)unitPerSquare
{
    _unitPerSquare = unitPerSquare;
    if (unitPerSquare >= 100 * 10000) {
        self.priceLabel.text = @"万元/平";
        self.chartView.yLabelFormat = @"%.2f";
    }else {
        self.priceLabel.text = @"元/平";
        self.chartView.yLabelFormat = @"%1.f";
    }
}

- (void)setPriceTrends:(NSArray<FHDetailPriceTrendModel *> *)priceTrends
{
    _priceTrends = priceTrends;
    if (priceTrends.count < 1) {
        return;
    }
    CGFloat trailing = [UIScreen mainScreen].bounds.size.width - 20 - 70;
    CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 14 : 12;
    for (UIView *subview in self.titleView.subviews) {
        [subview removeFromSuperview];
    }
    FHDetailPriceTrendModel *maxPriceTrend = priceTrends.firstObject;
    FHDetailPriceTrendValuesModel *value = maxPriceTrend.values.firstObject;
    double maxValue = value.price.length > 0 ? value.price.doubleValue : 0;
    double minValue = maxValue;

    for (NSInteger index = priceTrends.count - 1; index >= 0; index--) {
        FHDetailPriceTrendModel *priceTrend = priceTrends[index];
        if (priceTrend.values.count > maxPriceTrend.values.count) {
            maxPriceTrend = priceTrend;
        }
        NSString *trendName = priceTrend.name;
        if (trendName.length > 7) {
            trendName = [NSString stringWithFormat:@"%@...",[trendName substringToIndex:7]];
        }
        UIView *icon = [[UIView alloc]init];
        icon.width = 8;
        icon.height = 8;
        icon.layer.cornerRadius = 4;
        icon.layer.masksToBounds = YES;
        icon.backgroundColor = [self lineColorByIndex:index];
        [self.titleView addSubview:icon];

        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont themeFontRegular:fontSize];
        label.textColor = [UIColor themeGray1];
        label.text = trendName;
        [self.titleView addSubview:label];

        [label sizeToFit];
        label.left = trailing - label.width;
        label.height = 20;
        label.top = 0;
        trailing = label.left - 10;
        
        icon.left = trailing - icon.width;
        icon.centerY = label.centerY;
        trailing = icon.left - 20;
        
        for (FHDetailPriceTrendValuesModel *value in priceTrend.values) {
            if (value.price.doubleValue > maxValue) {
                maxValue = value.price.doubleValue;
            }
            if (value.price.doubleValue < minValue) {
                minValue = value.price.doubleValue;
            }
        }
        
    }
    // 处理最大最小值
    self.maxValue = maxValue;
    self.minValue = minValue;
    if (self.maxValue >= 100 * 10000.0) {
        self.unitPerSquare = 100.0 * 10000.0;
    }else {
        self.unitPerSquare = 100.0;
        
    }
    NSMutableArray *mutable = @[].mutableCopy;

    for (NSInteger index = priceTrends.count - 1; index >= 0; index--) {

        FHDetailPriceTrendModel *priceTrend = priceTrends[index];
        NSArray *data01Array = priceTrend.values;
        PNLineChartData *data01 = [PNLineChartData new];
        data01.color = [self lineColorByIndex:index];
        data01.highlightedImg = [self highlightImgNameByIndex:index];
        data01.alpha = 1;
        data01.showPointLabel = NO; // 是否显示坐标点的值
        data01.itemCount = data01Array.count;
        data01.inflexionPointColor = [self lineColorByIndex:index];
        data01.inflexionPointStyle = PNLineChartPointStyleCircle;
        data01.lineWidth = 1;
        data01.inflexionPointWidth = 4; // inflexionPoint 圆圈圈
        data01.pointLabelFormat = @"%.2f";
        __weak typeof(self)wself = self;
        data01.getData = ^(NSUInteger index) {

            if (index < data01Array.count) {

                FHDetailPriceTrendValuesModel *trendValue = data01Array[index];
                CGFloat yValue = trendValue.price.floatValue / wself.unitPerSquare;
                return [PNLineChartDataItem dataItemWithY:yValue andRawY:yValue];
            }
            return [PNLineChartDataItem dataItemWithY:0];
        };
        [mutable addObject:data01];
    }

    CGFloat padding = (self.maxValue - self.minValue) / self.unitPerSquare / 16;
    self.chartView.yFixedValueMax = self.maxValue / self.unitPerSquare - padding;
    self.chartView.yFixedValueMin = self.minValue / self.unitPerSquare - padding;
    self.chartView.chartData = mutable;
    [self.chartView strokeChart];

    NSMutableArray *Xlabels = @[].mutableCopy;
    for (FHDetailPriceTrendValuesModel *trendValue in maxPriceTrend.values) {
        NSString *monthStr = [self.monthFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:trendValue.timestamp.doubleValue]];
        [Xlabels addObject:monthStr];
    }
    [self.chartView setXLabels:Xlabels];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"price_trend";
}

- (UIColor *)lineColorByIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return [UIColor themeRed1];
            break;
        case 1:
            return [UIColor colorWithHexString:@"#bebebe"];
            break;
        case 2:
            return [UIColor themeGray5];
            break;
        default:
            return [UIColor themeGray5];
            break;
    }
}

- (NSString *)highlightImgNameByIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return @"detail_circle_red";
            break;
        case 1:
            return @"detail_circle_dark";
            break;
        case 2:
            return @"detail_circle_gray";
            break;
        default:
            return @"detail_circle_gray";
            break;
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.unitPerSquare = 100 * 10000.0;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    [self.contentView addSubview:self.priceView];
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.contentView);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(138);
    }];
    [self.priceView addSubview:self.bgView];

    // 小区均价
    [self.priceView addSubview:self.priceKeyLabel];
    [self.priceKeyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    // 均价值
    [self.priceView addSubview:self.priceValueLabel];
    [self.priceValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceKeyLabel);
        make.top.mas_equalTo(self.priceKeyLabel.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(30);
    }];
    // "本房源单价比小区均价"
    [self.priceView addSubview:self.pricePerKeyLabel];
    [self.pricePerKeyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceValueLabel.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.priceValueLabel);
    }];
    // value
    [self.priceView addSubview:self.priceUpValueLabel];
    [self.priceUpValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pricePerKeyLabel);
        make.top.mas_equalTo(self.pricePerKeyLabel.mas_bottom).mas_offset(11);
        make.height.mas_equalTo(20);
    }];
    [self.priceView addSubview:self.priceUpTrend];
    [self.priceUpTrend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.pricePerKeyLabel);
        make.centerY.mas_equalTo(self.priceUpValueLabel);
        make.width.height.mas_equalTo(16);
    }];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.priceView);
        make.bottom.mas_equalTo(self.priceUpValueLabel).mas_offset(18);
        make.bottom.mas_equalTo(self.priceView);
    }];
    [self.priceView addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.priceView);
        make.top.mas_equalTo(self.pricePerKeyLabel).mas_offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(1);
    }];
    [self.priceView addSubview:self.monthUpKeyLabel];
    [self.monthUpKeyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.pricePerKeyLabel);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.line.mas_right).mas_offset(30);
    }];
    [self.priceView addSubview:self.monthUpValueLabel];
    [self.monthUpValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.priceUpValueLabel);
        make.left.mas_equalTo(self.monthUpKeyLabel);
        make.height.mas_equalTo(20);
    }];
    [self.priceView addSubview:self.monthUpTrend];
    [self.monthUpTrend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.priceView).mas_offset(-20);
        make.centerY.mas_equalTo(self.monthUpValueLabel);
        make.width.height.mas_equalTo(16);
    }];
    [self.contentView addSubview:self.bottomBgView];
    self.bottomBgView.clipsToBounds = YES;
    [self.bottomBgView addSubview:self.chartBgView];
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(138);
        make.height.mas_equalTo(58);
        make.bottom.mas_equalTo(0);
    }];
    [self.chartBgView addSubview:self.titleView];
    [self.chartBgView addSubview:self.priceLabel];
    [self.chartBgView addSubview:self.chartView];
    [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(70);
        make.centerY.mas_equalTo(self.priceLabel);
        make.height.mas_equalTo(20);
    }];
    [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(20);
    }];
    [self.chartView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.priceLabel.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(207);
        make.bottom.mas_equalTo(0);
    }];

    [self setupChartUI];
    [self updateChartConstraints:NO];
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPriceTrendCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailPriceTrendCellModel *cellModel = (FHDetailPriceTrendCellModel *)data;
    NSArray *priceTrends = cellModel.priceTrends; 
    self.priceValueLabel.text = cellModel.neighborhoodInfo.pricingPerSqm;
    self.priceView.hidden = NO;
    
    float pricingPerSqm = cellModel.neighborhoodInfo.pricingPerSqmV.floatValue;
    if (pricingPerSqm > 0) {
        
        float pricingPerSqmValue = cellModel.pricingPerSqmV.floatValue;
        float priceUp = (pricingPerSqmValue - pricingPerSqm) / pricingPerSqm * 100;
        if (priceUp == 0) {
            self.priceUpValueLabel.text = @"持平";
            self.monthUpTrend.hidden = YES;
        } else {
            self.priceUpValueLabel.text = [NSString stringWithFormat:@"%.2f%%",fabs(priceUp)];
            self.monthUpTrend.hidden = NO;
            if (priceUp > 0) {
                self.priceUpTrend.image = [UIImage imageNamed:@"detail_trend_red"];
            } else {
                self.priceUpTrend.image = [UIImage imageNamed:@"detail_trend_green"];
            }
        }
    }else {
        
        self.priceUpValueLabel.text = @"持平";
        self.monthUpTrend.hidden = YES;
    }
    if (cellModel.neighborhoodInfo.monthUp.length > 0) {
        float monthUp = cellModel.neighborhoodInfo.monthUp.floatValue;
        float absValue = fabs(monthUp) * 100;
        if (absValue == 0) {
            self.monthUpValueLabel.text = @"持平";
            self.monthUpTrend.hidden = YES;
        } else {
            self.monthUpValueLabel.text = [NSString stringWithFormat:@"%.2f%%",fabs(absValue)];
            self.monthUpTrend.hidden = NO;
            if (monthUp > 0) {
                self.monthUpTrend.image = [UIImage imageNamed:@"detail_trend_red"];
            } else {
                self.monthUpTrend.image = [UIImage imageNamed:@"detail_trend_green"];
            }
        }
    }
    self.priceTrends = priceTrends;
    if (priceTrends.count < 1) {
        [self.chartBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        [self.bottomBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }else {
        [self updateChartConstraints:NO];
    }
}

- (void)updateChartConstraints:(BOOL)animated
{
    FHDetailPriceTrendCellModel *model = (FHDetailPriceTrendCellModel *)self.currentData;
    CGFloat bottomHeight = 58;
    if (!model.hasSuggestion) {
        bottomHeight = 58 - 20;
    }
    [self.chartBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(207 + 50);
    }];
    [self.bottomBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(315 - bottomHeight);
    }];
}

- (void)setupChartUI
{
    self.chartView.yLabelNum = 4; // 4 lines
    self.chartView.chartMarginLeft = 20;
    self.chartView.chartMarginRight = 20;
    self.chartView.backgroundColor = [UIColor whiteColor];
    self.chartView.yGridLinesColor = [UIColor themeGray6];
    self.chartView.showYGridLines = YES; // 横着的虚线
    [self.chartView.chartData enumerateObjectsUsingBlock:^(PNLineChartData *obj, NSUInteger idx, BOOL *stop) {
        obj.pointLabelColor = [UIColor blackColor];
    }];
    self.chartView.showCoordinateAxis = YES;// 坐标轴的线
    self.chartView.yLabelColor = [UIColor themeGray3];
    self.chartView.yLabelFormat = @"%.2f";
    self.chartView.yLabelFont = [UIFont themeFontRegular:12];
    self.chartView.yLabelHeight = 17;
    self.chartView.showGenYLabels = YES; // 竖轴的label值
    self.chartView.xLabelColor = [UIColor themeGray3];
    self.chartView.xLabelFont = [UIFont themeFontRegular:12];
    self.chartView.yHighlightedColor = [UIColor themeRed1];
    self.chartView.axisColor = [UIColor themeGray6]; // x轴和y轴
    [self.chartView setXLabels:@[@"", @"", @"", @"", @"", @""]];

    self.chartView.delegate = self;
}

#pragma mark delegate
- (void)addClickPriceTrendLog
{
    NSMutableDictionary *params = @{}.mutableCopy;
    NSDictionary *traceDict = [self.baseViewModel detailTracerDic];
    
    //    1. event_type：house_app2c_v2
    //    2. page_type：页面类型,{'新房详情页': 'new_detail', '二手房详情页': 'old_detail', '小区详情页': 'neighborhood_detail'}
    //    3. rank
    //    4. origin_from
    //    5. origin_search_id
    //    6.log_pb
    
    params[@"page_type"] = traceDict[@"page_type"] ? : @"be_null";
    params[@"rank"] = traceDict[@"rank"] ? : @"be_null";
    params[@"origin_from"] = traceDict[@"origin_from"] ? : @"be_null";
    params[@"origin_search_id"] = traceDict[@"origin_search_id"] ? : @"be_null";
    params[@"log_pb"] = traceDict[@"log_pb"] ? : @"be_null";
    [FHUserTracker writeEvent:@"click_price_trend" params:params];
}

- (void)addClickPriceRankLog
{
    NSMutableDictionary *params = @{}.mutableCopy;
    NSDictionary *traceDict = [self.baseViewModel detailTracerDic];
    params[@"page_type"] = traceDict[@"page_type"] ? : @"be_null";
    params[@"rank"] = traceDict[@"rank"] ? : @"be_null";
    params[@"origin_from"] = traceDict[@"origin_from"] ? : @"be_null";
    params[@"origin_search_id"] = traceDict[@"origin_search_id"] ? : @"be_null";
    params[@"log_pb"] = traceDict[@"log_pb"] ? : @"be_null";
    [FHUserTracker writeEvent:@"click_price_rank" params:params];
}

- (void)userClickedOnKeyPoint:(CGPoint)point
                    lineIndex:(NSInteger)lineIndex
                   pointIndex:(NSInteger)pointIndex
                  selectPoint:(CGPoint)selectPoint
{
    [self addClickPriceTrendLog];
    
    FHDetailPriceMarkerView *view = [self.chartView viewWithTag:200];
    if (pointIndex == self.selectIndex && self.hideMarker) {
        [view removeFromSuperview];
        view = nil;
        self.hideMarker = NO;
        return;
    }
    self.selectIndex = pointIndex;
    self.hideMarker = YES;

    if (!view) {
        view = [[FHDetailPriceMarkerView alloc]init];
        view.tag = 200;
        [self.chartView addSubview:view];
    }
    if (![view isKindOfClass:[FHDetailPriceMarkerView class]]) {
        return;
    }
    FHDetailPriceMarkerData *markData = [[FHDetailPriceMarkerData alloc]init];
    NSArray *priceTrends = self.priceTrends;
    if (priceTrends.count < 1) {
        return;
    }
    NSMutableArray *trendItems = @[].mutableCopy;
    for (FHDetailPriceTrendModel *priceTrend in priceTrends) {
        if (priceTrend.values.count < 1 || pointIndex >= priceTrend.values.count) {
            continue;
        }
        FHDetailPriceTrendValuesModel *priceValue = priceTrend.values[pointIndex];
        FHDetailPriceMarkerItem *item = [[FHDetailPriceMarkerItem alloc] init];
        item.name = priceTrend.name;
        item.priceModel = priceValue;
        [trendItems addObject:item];
    }
    markData.trendItems = trendItems;
    [view refreshContent:markData];
    //calculate markerview position
    CGFloat padding = 10;
    if (selectPoint.x + view.width + padding > self.chartView.width) {
        view.right = selectPoint.x - padding;
    }else{
        view.left = selectPoint.x + padding;
    }
    if (view.left < 0) {
        view.left = 0;
    }
    view.centerY = (self.chartView.height - 40) /2;
}


-(UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"detail_chart_bg"]];
        _bgView.contentMode = UIViewContentModeScaleToFill;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor themeGray6];
    }
    return _line;
}

- (UILabel *)priceUpValueLabel
{
    if (!_priceUpValueLabel) {
        _priceUpValueLabel = [[UILabel alloc]init];
        _priceUpValueLabel.font = [UIFont themeFontSemibold:18];
        _priceUpValueLabel.textColor = [UIColor themeGray1];
    }
    return _priceUpValueLabel;
}

-(UIImageView *)priceUpTrend
{
    if (!_priceUpTrend) {
        _priceUpTrend = [[UIImageView alloc]init];
    }
    return _priceUpTrend;
}

- (UILabel *)pricePerKeyLabel
{
    if (!_pricePerKeyLabel) {
        _pricePerKeyLabel = [[UILabel alloc]init];
        _pricePerKeyLabel.font = [TTDeviceHelper isScreenWidthLarge320] ? [UIFont themeFontRegular:14] : [UIFont themeFontRegular:12];
        _pricePerKeyLabel.textColor = [UIColor themeGray3];
        _pricePerKeyLabel.text = @"本房源单价比小区均价";
    }
    return _pricePerKeyLabel;
}

- (UILabel *)priceKeyLabel
{
    if (!_priceKeyLabel) {
        _priceKeyLabel = [[UILabel alloc]init];
        _priceKeyLabel.font = [UIFont themeFontRegular:14];
        _priceKeyLabel.textColor = [UIColor themeGray3];
        _priceKeyLabel.text = @"小区均价";
    }
    return _priceKeyLabel;
}

- (UILabel *)priceValueLabel
{
    if (!_priceValueLabel) {
        _priceValueLabel = [[UILabel alloc]init];
        _priceValueLabel.font = [UIFont themeFontMedium:24];
        _priceValueLabel.textColor = [UIColor themeGray1];
    }
    return _priceValueLabel;
}

- (UILabel *)monthUpKeyLabel
{
    if (!_monthUpKeyLabel) {
        _monthUpKeyLabel = [[UILabel alloc]init];
        _monthUpKeyLabel.font = [UIFont themeFontRegular:14];
        _monthUpKeyLabel.textColor = [UIColor themeGray3];
        _monthUpKeyLabel.text = @"环比上月";
    }
    return _monthUpKeyLabel;
}

- (UILabel *)monthUpValueLabel
{
    if (!_monthUpValueLabel) {
        _monthUpValueLabel = [[UILabel alloc]init];
        _monthUpValueLabel.font = [UIFont themeFontMedium:18];
        _monthUpValueLabel.textColor = [UIColor themeGray1];
    }
    return _monthUpValueLabel;
}

-(UIImageView *)monthUpTrend
{
    if (!_monthUpTrend) {
        _monthUpTrend = [[UIImageView alloc]init];
    }
    return _monthUpTrend;
}

- (UIView *)priceView
{
    if (!_priceView) {
        _priceView = [[UIView alloc]init];
    }
    return _priceView;
}

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc]init];
    }
    return _titleView;
}

- (UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.font = [UIFont themeFontRegular:14];
        _priceLabel.textColor = [UIColor themeGray3];
    }
    return _priceLabel;
}

- (UIView *)chartBgView
{
    if (!_chartBgView) {
        _chartBgView = [[UIView alloc]init];
    }
    return _chartBgView;
}

- (UIView *)bottomBgView
{
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]init];
    }
    return _bottomBgView;
}

- (PNLineChart *)chartView
{
    if (!_chartView) {
        _chartView = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 207.0)];
    }
    return _chartView;
}

- (NSDateFormatter *)monthFormatter
{
    if (!_monthFormatter) {
        _monthFormatter = [[NSDateFormatter alloc]init];
        _monthFormatter.dateFormat = @"M月";
    }
    return _monthFormatter;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
