//
//  FHChatSectionCellPlaceHolder.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHChatSectionCellPlaceHolder.h"
#import "FHCityMarketTrendChatCellTableViewCell.h"
#import "FHCityMarketDetailResponseModel.h"
#import "FHEnvContext.h"
#import "FHConfigModel.h"
#import "FHCityMarketTrendChatView.h"
#import "RXCollection.h"
#import "PNChart.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCityMarketTrendChatViewModel.h"
#import "ReactiveObjC.h"
@interface FHChatSectionCellPlaceHolder ()
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, FHCityMarketTrendChatViewModel*>* chartViewModels;
@end

@implementation FHChatSectionCellPlaceHolder

- (instancetype)init
{
    self = [super init];
    if (self) {
        FHConfigDataModel* model = [[FHEnvContext sharedInstance] getConfigFromCache];
        self.chartViewModels = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)isDisplayData {
    return [_marketTrendList count] > 0;
}

- (NSUInteger)numberOfSection {
    return 1;
}

- (NSUInteger)numberOfRowInSection:(NSUInteger)section {
    return [_marketTrendList count];
}

- (void)registerCellToTableView:(nonnull UITableView *)tableView {
    [tableView registerClass:[FHCityMarketTrendChatCellTableViewCell class] forCellReuseIdentifier:@"chart"];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FHCityMarketTrendChatCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"chart" forIndexPath:indexPath];
    FHCityMarketDetailResponseDataMarketTrendListModel* model = _marketTrendList[indexPath.row];
    cell.chatView.titleLable.text = model.title;
    cell.chatView.categorys = self.districtNameList;
    FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel* infoList = [model.districtMarketInfoList firstObject];
    NSArray<FHCityMarketTrendChatViewInfoItem*>* items = [infoList.trendLines rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel* each) {
        FHCityMarketTrendChatViewInfoItem* item = [[FHCityMarketTrendChatViewInfoItem alloc] init];
        item.name = each.desc;
        item.color = each.color;
        return item;
    }];
    FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel* trendLine = infoList.trendLines.firstObject;


    //计算是否应该增加万单位
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [infoList.trendLines enumerateObjectsUsingBlock:^(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [array addObjectsFromArray:obj.values];
    }];

    BOOL shouldUseTenThousandUnit = [self shouldUseTenThousandunit:array];
    if (shouldUseTenThousandUnit) {
        cell.chatView.banner.unitLabel.text = [NSString stringWithFormat:@"万%@", trendLine.valueUnit];
    } else {
        cell.chatView.banner.unitLabel.text = trendLine.valueUnit;
    }
    cell.chatView.sourceLabel.text = [NSString stringWithFormat:@"%@ 更新时间: %@", model.dataSource, model.updateTime];
    [cell.chatView.banner setItems:items];

    FHCityMarketTrendChatViewModel* viewModel = [self viewModelAtIndexPath:indexPath withModel:model withCell:cell];
//    [self setupChat:infoList ofChartView:cell.chatView.lineChart];
    return cell;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 382;  //366 + 16;
}

- (nonnull UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(FHCityMarketTrendChatViewModel*)viewModelAtIndexPath:(NSIndexPath*)indexPath
                                             withModel:(FHCityMarketDetailResponseDataMarketTrendListModel*)model
                                              withCell:(FHCityMarketTrendChatCellTableViewCell*) cell {
    FHCityMarketTrendChatViewModel* result = _chartViewModels[@(indexPath.row)];
    if (result == nil) {
        result = [[FHCityMarketTrendChatViewModel alloc] init];
        result.model = model;
        cell.chatView.lineChart.delegate = result;
        [self bindViewModel:result toCell:cell];
        FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel* info = model.districtMarketInfoList.firstObject;
        cell.chatView.selectCategory = info.locationName;
        result.chartView = cell.chatView.lineChart;
        _chartViewModels[@(indexPath.row)] = result;
    }
    return result;
}

-(void)bindViewModel:(FHCityMarketTrendChatViewModel*)model toCell:(FHCityMarketTrendChatCellTableViewCell*)cell {
    [[RACObserve(cell.chatView, selectCategory) filter:^BOOL(id  _Nullable value) {
        return value != nil;
    }] subscribeNext:^(id  _Nullable x) {
        [model changeCategory:x];
    }];
    @weakify(cell);
    @weakify(self);
    [RACObserve(model, selectedInfoListModel) subscribeNext:^(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel*  _Nullable x) {
        @strongify(cell);
        @strongify(self);
        [self setupChat:x ofChartView:cell.chatView];
        cell.chatView.lineChart.delegate = model;
        model.chartView = cell.chatView.lineChart;
        
        NSArray<FHCityMarketTrendChatViewInfoItem*>* items = [x.trendLines rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel* each) {
            FHCityMarketTrendChatViewInfoItem* item = [[FHCityMarketTrendChatViewInfoItem alloc] init];
            item.name = each.desc;
            item.color = each.color;
            return item;
        }];
        [cell.chatView.banner setItems:items];
    }];
}

-(void)setupChat:(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel*)values
      ofChartView:(FHCityMarketTrendChatView*) chartView {
    [chartView resetChatView];
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [values.trendLines enumerateObjectsUsingBlock:^(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [array addObjectsFromArray:obj.values];
    }];
    __block NSUInteger lineIndex = 0;
    BOOL shouldUseTenThousandUnit = [self shouldUseTenThousandunit:array];

    __block CGFloat maxValue = CGFLOAT_MIN;
    __block CGFloat minValue = CGFLOAT_MAX;
    [array enumerateObjectsUsingBlock:^(NSNumber*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        maxValue = MAX(maxValue, [obj floatValue]);
        minValue = MIN(minValue, [obj floatValue]);
    }];
    FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel* trendLine = values.trendLines.firstObject;
    if (shouldUseTenThousandUnit) {
        chartView.banner.unitLabel.text = [NSString stringWithFormat:@"万%@", trendLine.valueUnit];
    } else {
        chartView.banner.unitLabel.text = trendLine.valueUnit;
    }
    NSArray* lineDatas = [values.trendLines rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel* each) {
        PNLineChartData *data01 = [PNLineChartData new];
        UIColor* color = [UIColor colorWithHexString:each.color];
        data01.color = color;
        data01.alpha = 1;
//        data01.highlightedImage = [[self class] dotImageByColor:color];
        data01.highlightedImg = [self highlightImgNameByIndex:lineIndex];
        data01.showPointLabel = NO; // 是否显示坐标点的值
        data01.itemCount = [each.values count];
        data01.inflexionPointColor = color;
        data01.inflexionPointStyle = PNLineChartPointStyleCircle;
        data01.lineWidth = 1;
        data01.inflexionPointWidth = 4; // inflexionPoint 圆圈圈
        data01.pointLabelFormat = @"%.2f";
        data01.getData = ^PNLineChartDataItem *(NSUInteger index) {
            id theNumber = each.values[index];
            if ([theNumber isKindOfClass:[NSNull class]]) {
                return [PNLineChartDataItem empty];
            } else if ([theNumber isKindOfClass:[NSNumber class]]) {
                CGFloat theValue = [theNumber floatValue];
                if (shouldUseTenThousandUnit) {
                    theValue /= 10000.0;
                }
                return [PNLineChartDataItem dataItemWithY:theValue];
            }
        };
        lineIndex += 1;
        return data01;
    }];
    if (shouldUseTenThousandUnit) {
//        CGFloat padding = (maxValue - minValue) / 10000 / 16;
        chartView.lineChart.yFixedValueMax = maxValue / 10000;
        chartView.lineChart.yFixedValueMin = minValue / 10000;
    } else {
//        CGFloat padding = (maxValue - minValue) / 16;
        chartView.lineChart.yFixedValueMax = maxValue;
        chartView.lineChart.yFixedValueMin = minValue;
    }
//    chartView.lineChart.yFixedValueMin = 0;
    chartView.lineChart.chartData = lineDatas;
    [chartView.lineChart strokeChart];

    NSArray* xLabels = [values.timeLine rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTimeLineModel* each) {
        return each.month;
    }];
    [chartView.lineChart setXLabels:xLabels];
}

-(BOOL)shouldUseTenThousandunit:(NSArray<NSNumber*>*)values {
    return [values rx_detectWithBlock:^BOOL(NSNumber* each) {
        return [each doubleValue] > 10000;
    }];
}

- (NSString *)highlightImgNameByIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return @"detail_circle_dark";
            break;
        case 1:
            return @"detail_circle_red";
            break;
        case 2:
            return @"detail_circle_gray";
            break;
        default:
            return @"detail_circle_gray";
            break;
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)traceCellDisplayAtIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath* offset = [self indexPathWithOffset:indexPath];
    FHCityMarketDetailResponseDataMarketTrendListModel* model = _marketTrendList[offset.row];

    if (![self.traceCache containsObject:offset]) {
        FHCityMarketTrendChatViewModel* result = _chartViewModels[@(indexPath.row)];
        if (result != nil) {
            [self traceElementShow:@{@"element_type": model.type ? : @"be_null"}];
            [[self traceCache] addObject:offset];
        }
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

+(UIImage*)dotImageByColor:(UIColor*)color {
    CGFloat whiteRadius = 4;
    CGFloat colorRadius = 2;
    CGPoint centerPoint = CGPointMake(9, 9);
    UIImage* result = nil;
    UIGraphicsBeginImageContext(CGSizeMake(18, 18));
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetShadow(context, CGSizeMake(0.0, 0.1), 0.1);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(centerPoint.x - whiteRadius, centerPoint.y - whiteRadius, whiteRadius * 2, whiteRadius * 2));

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(centerPoint.x - colorRadius, centerPoint.y - colorRadius, colorRadius * 2, colorRadius * 2));


    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
