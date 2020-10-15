//
//  FHNeighborhoodDetailPriceTrendCollectionCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/15.
//

#import "FHNeighborhoodDetailPriceTrendCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "PNChart.h"
#import "FHDetailPriceToastView.h"
#import "UIView+House.h"
#import <FHHouseBase/FHUtils.h>

@interface FHNeighborhoodDetailPriceTrendCollectionCell ()<PNChartDelegate>

@property (nonatomic, strong) FHDetailSectionTitleCollectionView *headerTitleView;

@property(nonatomic , weak) UIView *titleView;
@property(nonatomic , weak) UIView *bottomBgView;
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

@implementation FHNeighborhoodDetailPriceTrendCollectionCell

+ (CGSize )cellSizeWithData:(id)data width:(CGFloat )width {
    
    return CGSizeMake(width, 61 + 257);
}

- (NSDateFormatter *)monthFormatter
{
    if (!_monthFormatter) {
        _monthFormatter = [[NSDateFormatter alloc]init];
        _monthFormatter.dateFormat = @"M月";
    }
    return _monthFormatter;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.unitPerSquare = 100 * 10000.0;
        
        self.headerTitleView = [[FHDetailSectionTitleCollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 61)];
        self.headerTitleView.titleLabel.text = @"均价走势";
        self.headerTitleView.titleLabel.font = [UIFont themeFontMedium:20];
        self.headerTitleView.titleLabel.textColor = [UIColor themeGray1];
        [self.contentView addSubview:self.headerTitleView];
        [self.headerTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(52);
        }];
       
        //底部曲线模块
        UIView *bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerTitleView.frame), CGRectGetWidth(self.contentView.frame), 257)];
        bottomBgView.clipsToBounds = YES;
        [self.contentView addSubview:bottomBgView];
        self.bottomBgView = bottomBgView;
        [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(self.headerTitleView.mas_bottom).mas_offset(0);
            make.height.mas_equalTo(257);
        }];
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.font = [UIFont themeFontRegular:14];
        priceLabel.textColor = [UIColor themeGray3];
        [self.bottomBgView addSubview:priceLabel];
        self.priceLabel = priceLabel;
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(20);
        }];
        
        UIView *titleView = [[UIView alloc]init];
        [self.bottomBgView addSubview:titleView];
        self.titleView = titleView;
        [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-16);
            make.left.mas_equalTo(70);
            make.centerY.mas_equalTo(self.priceLabel);
            make.height.mas_equalTo(20);
        }];

        UIView *chartBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.contentView.frame), 227)];
        [self.bottomBgView addSubview:chartBgView];
        self.chartBgView = chartBgView;
        [self.chartBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.bottomBgView);
            make.top.mas_equalTo(30);
            make.bottom.mas_equalTo(self.bottomBgView);
        }];
        
        PNLineChart *chartView = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.chartBgView.frame), 207)];
        chartView.yLabelNum = 4; // 4 lines
        chartView.chartMarginLeft = 17;
        chartView.chartMarginRight = 17;
        chartView.backgroundColor = [UIColor clearColor];
        chartView.yGridLinesColor = [[UIColor themeGray6] colorWithAlphaComponent:0.57];;
        chartView.showYGridLines = YES; // 横着的虚线
        [chartView.chartData enumerateObjectsUsingBlock:^(PNLineChartData *obj, NSUInteger idx, BOOL *stop) {
            obj.pointLabelColor = [UIColor blackColor];
        }];
        chartView.showCoordinateAxis = YES;// 坐标轴的线
        chartView.yLabelColor = [UIColor themeGray2];
        chartView.yLabelFormat = @"%.2f";
        chartView.yLabelFont = [UIFont themeFontRegular:12];
        chartView.yLabelHeight = 17;
        chartView.showGenYLabels = YES; // 竖轴的label值
        chartView.xLabelColor = [UIColor themeGray2];
        chartView.xLabelFont = [UIFont themeFontRegular:12];
        chartView.yHighlightedColor = [UIColor themeRed1];
        chartView.axisColor = [UIColor themeGray6]; // x轴和y轴
        [chartView setXLabels:@[@"", @"", @"", @"", @"", @""]];
        chartView.delegate = self;
        [self.chartBgView addSubview:chartView];
        self.chartView = chartView;
        [self.chartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.chartBgView);
            make.height.mas_equalTo(207);
            make.bottom.mas_equalTo(self.chartBgView).offset(-20);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailPriceTrendCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailPriceTrendCellModel *cellModel = (FHNeighborhoodDetailPriceTrendCellModel *)data;

    self.priceTrends = cellModel.priceTrends;
//    if (priceTrends.count < 1) {
//        [self.chartBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(0);
//        }];
//        [self.bottomBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(50);
//        }];
//    }
}

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
        trailing = label.left - 5;
        
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

#pragma mark - PNChartDelegate
//- (void)addClickPriceRankLog
//{
//    NSMutableDictionary *params = @{}.mutableCopy;
//    NSDictionary *traceDict = [self.baseViewModel detailTracerDic];
//    params[@"page_type"] = traceDict[@"page_type"] ? : @"be_null";
//    params[@"rank"] = traceDict[@"rank"] ? : @"be_null";
//    params[@"origin_from"] = traceDict[@"origin_from"] ? : @"be_null";
//    params[@"origin_search_id"] = traceDict[@"origin_search_id"] ? : @"be_null";
//    params[@"log_pb"] = traceDict[@"log_pb"] ? : @"be_null";
//    [FHUserTracker writeEvent:@"click_price_rank" params:params];
//}

- (void)userClickedOnKeyPoint:(CGPoint)point
                    lineIndex:(NSInteger)lineIndex
                   pointIndex:(NSInteger)pointIndex
                  selectPoint:(CGPoint)selectPoint
{
    if (self.addClickPriceTrendLogBlock) {
        self.addClickPriceTrendLogBlock();
    }
    
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
@end

@implementation FHNeighborhoodDetailPriceTrendCellModel

@end
