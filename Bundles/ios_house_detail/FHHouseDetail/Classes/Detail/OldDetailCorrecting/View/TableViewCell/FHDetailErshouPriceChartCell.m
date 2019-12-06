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
#import "FHDetailPriceToastView.h"
#import "UIView+House.h"
#import "FHDetailHeaderStarTitleView.h"
#import <FHHouseBase/FHUtils.h>

@interface FHDetailErshouPriceChartCell () <PNChartDelegate>

@property(nonatomic , weak) FHDetailHeaderStarTitleView *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;

//小区均价模块
@property(nonatomic , weak) UIView *priceView;
@property(nonatomic , weak) UIView *line;
@property(nonatomic , weak) UILabel *priceKeyLabel;
@property(nonatomic , weak) UILabel *priceValueLabel;
@property(nonatomic , weak) UILabel *monthUpKeyLabel;
@property(nonatomic , weak) UILabel *monthUpValueLabel;
@property(nonatomic , weak) UIImageView *monthUpTrend;


@property(nonatomic , weak) UIView *bottomBgView;
@property(nonatomic , weak) UIView *titleView;
@property(nonatomic , weak) UIView *chartBgView;
@property(nonatomic , weak) UILabel *priceLabel;
@property(nonatomic , weak) PNLineChart *chartView;
@property(nonatomic, strong) FHDetailPriceToastView *ToastView;

@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel *> *priceTrends;
@property(nonatomic, assign) double unitPerSquare;
@property(nonatomic, assign) double maxValue;
@property(nonatomic, assign) double minValue;
@property(nonatomic, strong)NSDateFormatter *monthFormatter;
@property(nonatomic, assign) NSInteger selectIndex;
@property(nonatomic, assign) BOOL hideToast;

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
    CGFloat trailing = [UIScreen mainScreen].bounds.size.width - 50 - 70;
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
            return [UIColor colorWithHexString:@"#ffc464"];
            break;
        case 2:
            return [UIColor colorWithHexString:@"#bebebe"];
            break;
        default:
            return [UIColor colorWithHexString:@"#bebebe"];
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
            return @"detail_circle_yellow";
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
         [self setupUI];
        self.unitPerSquare = 100 * 10000.0;
    }
    return self;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (FHDetailHeaderStarTitleView *)headerView {
    if (!_headerView) {
        FHDetailHeaderStarTitleView *headerView = [[FHDetailHeaderStarTitleView alloc] init];
        [self.contentView addSubview:headerView];
        _headerView = headerView;
    }
    return _headerView;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(12);
         make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
    }];
    
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(31);
        make.top.equalTo(self.headerView.mas_bottom).offset(15);
        make.right.equalTo(self.contentView).offset(-31);
        make.height.mas_equalTo(84);
    }];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.priceView);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(1);
    }];
    [self.priceKeyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priceView).offset(20);
        make.left.equalTo(self.priceView).offset(20);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.line.mas_left).mas_offset(-5);
    }];
    // value
    [self.priceValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceKeyLabel);
        make.top.mas_equalTo(self.priceKeyLabel.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.line.mas_left).mas_offset(-5);
    }];

    [self.monthUpKeyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.priceKeyLabel);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.line.mas_right).mas_offset(30);
    }];
    [self.monthUpValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.priceValueLabel);
        make.left.mas_equalTo(self.monthUpKeyLabel);
        make.height.mas_equalTo(20);
    }];
    [self.monthUpTrend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.priceView).mas_offset(-20);
        make.centerY.mas_equalTo(self.monthUpValueLabel);
        make.width.height.mas_equalTo(16);
    }];
    
    //底部曲线模块
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.top.mas_equalTo(self.priceView.mas_bottom).offset(20);
        make.bottom.mas_equalTo(self.shadowImage).offset(-12);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomBgView).offset(16);
        make.top.mas_equalTo(self.bottomBgView);
        make.height.mas_equalTo(20);
    }];
    [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bottomBgView).offset(-16);
        make.left.mas_equalTo(self.bottomBgView).mas_offset(70);
        make.centerY.mas_equalTo(self.priceLabel);
        make.height.mas_equalTo(20);
    }];
    [self.chartBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bottomBgView);
        make.top.equalTo(self.titleView.mas_bottom).mas_offset(10);
        make.bottom.equalTo(self.bottomBgView);
    }];
    [self.chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.chartBgView);
        make.height.mas_equalTo(207);
        make.bottom.mas_equalTo(self.chartBgView).offset(-20);
    }];

//    [self updateChartConstraints:NO];
//    [FHUtils addShadowToView:self.priceView withOpacity:0.1 shadowColor:[UIColor blackColor] shadowOffset:CGSizeMake(0, 2) shadowRadius:6 andCornerRadius:4];
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPriceTrendCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailPriceTrendCellModel *cellModel = (FHDetailPriceTrendCellModel *)data;
    self.shadowImage.image = cellModel.shadowImage;
    if(cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    [self.headerView updateTitle:cellModel.priceAnalyze.title ? : @"价格指数"];
    [self.headerView updateStarsCount:cellModel.priceAnalyze.score.integerValue];
    
    NSArray *priceTrends = cellModel.priceTrends; 
    self.priceValueLabel.text = cellModel.neighborhoodInfo.pricingPerSqm;
    self.priceView.hidden = NO;
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
        [self.chartBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.bottomBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(50);
        }];
    }
//    else {
//        [self updateChartConstraints:NO];
//    }
}

//- (void)updateChartConstraints:(BOOL)animated
//{
//    FHDetailPriceTrendCellModel *model = (FHDetailPriceTrendCellModel *)self.currentData;
//    CGFloat bottomHeight = model.bottomHeight;
//    [self.bottomBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(207 + 120);
//    }];
//}

- (void)setupChartUI
{

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
    
    FHDetailPriceToastView *view = [self.chartView viewWithTag:200];
    if (pointIndex == self.selectIndex && self.hideToast) {
        [view removeFromSuperview];
        view = nil;
        self.hideToast = NO;
        return;
    }
    self.selectIndex = pointIndex;
    self.hideToast = YES;

    if (!view) {
        view = [[FHDetailPriceToastView alloc]init];
        view.tag = 200;
        [self.chartView addSubview:view];
    }
    if (![view isKindOfClass:[FHDetailPriceToastView class]]) {
        return;
    }
    FHDetailPriceToastData *markData = [[FHDetailPriceToastData alloc]init];
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
        FHDetailPriceToastItem *item = [[FHDetailPriceToastItem alloc] init];
        item.name = priceTrend.name;
        item.priceModel = priceValue;
        [trendItems addObject:item];
    }
    markData.trendItems = trendItems;
    [view refreshContent:markData];
    //calculate Toastview position
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

- (UIView *)line
{
    if (!_line) {
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor themeGray6];
        [self.priceView addSubview:line];
        _line = line;
    }
    return _line;
}

- (UILabel *)priceKeyLabel
{
    if (!_priceKeyLabel) {
        UILabel *priceKeyLabel = [[UILabel alloc]init];
        priceKeyLabel.font = [UIFont themeFontRegular:14];
        priceKeyLabel.textColor = [UIColor themeGray3];
        priceKeyLabel.text = @"小区均价";
        [self.priceView addSubview:priceKeyLabel] ;
        _priceKeyLabel = priceKeyLabel;
    }
    return _priceKeyLabel;
}

- (UILabel *)priceValueLabel
{
    if (!_priceValueLabel) {
         UILabel *priceValueLabel = [[UILabel alloc]init];
        priceValueLabel.font = [UIFont themeFontMedium:16];
        priceValueLabel.textColor = [UIColor themeGray1];
        [self.priceView addSubview:priceValueLabel];
        _priceValueLabel = priceValueLabel;
    }
    return _priceValueLabel;
}

- (UILabel *)monthUpKeyLabel
{
    if (!_monthUpKeyLabel) {
        UILabel *monthUpKeyLabel = [[UILabel alloc]init];
        monthUpKeyLabel.font = [UIFont themeFontRegular:14];
        monthUpKeyLabel.textColor = [UIColor themeGray3];
        monthUpKeyLabel.text = @"比上月";
        [self.priceView addSubview:monthUpKeyLabel];
        _monthUpKeyLabel = monthUpKeyLabel;
    }
    return _monthUpKeyLabel;
}

- (UILabel *)monthUpValueLabel
{
    if (!_monthUpValueLabel) {
        UILabel *monthUpValueLabel = [[UILabel alloc]init];
        monthUpValueLabel.font = [UIFont themeFontMedium:16];
        monthUpValueLabel.textColor = [UIColor themeGray1];
        [self.priceView addSubview:monthUpValueLabel];
        _monthUpValueLabel = monthUpValueLabel;
    }
    return _monthUpValueLabel;
}

-(UIImageView *)monthUpTrend
{
    if (!_monthUpTrend) {
       UIImageView *monthUpTrend = [[UIImageView alloc]init];
        [self.priceView addSubview:monthUpTrend];
        _monthUpTrend = monthUpTrend;
    }
    return _monthUpTrend;
}

- (UIView *)priceView
{
    if (!_priceView) {
         UIView *priceView = [[UIView alloc]init];
        priceView.backgroundColor = [UIColor colorWithHexStr:@"#fafafa"];
        priceView.layer.cornerRadius = 10;
        [self.contentView addSubview:priceView];
        _priceView = priceView;
    }
    return _priceView;
}

- (UIView *)bottomBgView
{
    if (!_bottomBgView) {
        UIView *bottomBgView = [[UIView alloc]init];
        bottomBgView.clipsToBounds = YES;
        [self.contentView addSubview:bottomBgView];
        _bottomBgView = bottomBgView;
    }
    return _bottomBgView;
}

- (UIView *)titleView
{
    if (!_titleView) {
        UIView *titleView = [[UIView alloc]init];
        [self.bottomBgView addSubview:titleView];
        _titleView = titleView;
    }
    return _titleView;
}

- (UILabel *)priceLabel
{
    if (!_priceLabel) {
         UILabel *priceLabel = [[UILabel alloc]init];
        priceLabel.font = [UIFont themeFontRegular:14];
        priceLabel.textColor = [UIColor themeGray3];
        [self.bottomBgView addSubview:priceLabel];
        _priceLabel = priceLabel;
    }
    return _priceLabel;
}

- (UIView *)chartBgView
{
    if (!_chartBgView) {
        UIView *chartBgView = [[UIView alloc]init];
        [self.bottomBgView addSubview:chartBgView];
        _chartBgView= chartBgView;
    }
    return _chartBgView;
}



- (PNLineChart *)chartView
{
    if (!_chartView) {
        PNLineChart *chartView = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-30, 207.0)];
        chartView.yLabelNum = 4; // 4 lines
        chartView.chartMarginLeft = 17;
        chartView.chartMarginRight = 17;
        chartView.backgroundColor = [UIColor clearColor];
        chartView.yGridLinesColor = [UIColor themeGray6];
        chartView.showYGridLines = YES; // 横着的虚线
        [chartView.chartData enumerateObjectsUsingBlock:^(PNLineChartData *obj, NSUInteger idx, BOOL *stop) {
            obj.pointLabelColor = [UIColor blackColor];
        }];
        chartView.showCoordinateAxis = YES;// 坐标轴的线
        chartView.yLabelColor = [UIColor themeGray3];
        chartView.yLabelFormat = @"%.2f";
        chartView.yLabelFont = [UIFont themeFontRegular:12];
        chartView.yLabelHeight = 17;
        chartView.showGenYLabels = YES; // 竖轴的label值
        chartView.xLabelColor = [UIColor themeGray3];
        chartView.xLabelFont = [UIFont themeFontRegular:12];
        chartView.yHighlightedColor = [UIColor themeRed1];
        chartView.axisColor = [UIColor themeGray6]; // x轴和y轴
        [chartView setXLabels:@[@"", @"", @"", @"", @"", @""]];
        chartView.delegate = self;
        [self.chartBgView addSubview:chartView];
        _chartView = chartView;
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
