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
    cell.chatView.banner.unitLabel.text = trendLine.valueUnit;
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
    [RACObserve(model, selectedInfoListModel) subscribeNext:^(id  _Nullable x) {
        @strongify(cell);
        @strongify(self);
        [self setupChat:x ofChartView:cell.chatView];
        cell.chatView.lineChart.delegate = model;
        model.chartView = cell.chatView.lineChart;
    }];
}

-(void)setupChat:(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel*)values
      ofChartView:(FHCityMarketTrendChatView*) chartView {
    [chartView resetChatView];
    NSArray* lineDatas = [values.trendLines rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel* each) {
        PNLineChartData *data01 = [PNLineChartData new];
        UIColor* color = [UIColor colorWithHexString:each.color];
        data01.color = color;
        data01.alpha = 1;
        data01.highlightedImg = [self highlightImgNameByIndex:index];
        data01.showPointLabel = NO; // 是否显示坐标点的值
        data01.itemCount = [each.values count];
        data01.inflexionPointColor = color;
        data01.inflexionPointColor = [self lineColorByIndex:index];
        data01.inflexionPointStyle = PNLineChartPointStyleCircle;
        data01.lineWidth = 1;
        data01.inflexionPointWidth = 4; // inflexionPoint 圆圈圈
        data01.pointLabelFormat = @"%.2f";
        data01.getData = ^PNLineChartDataItem *(NSUInteger index) {
            NSNumber* value = each.values[index];
            return [PNLineChartDataItem dataItemWithY:[value doubleValue]];
        };
        return data01;
    }];

    chartView.lineChart.chartData = lineDatas;
    [chartView.lineChart strokeChart];

    NSArray* xLabels = [values.timeLine rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTimeLineModel* each) {
        return each.month;
    }];
    [chartView.lineChart setXLabels:xLabels];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)traceCellDisplayAtIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath* offset = [self indexPathWithOffset:indexPath];
    FHCityMarketDetailResponseDataMarketTrendListModel* model = _marketTrendList[offset.row];

    if ([self.traceCache containsObject:indexPath]) {
        FHCityMarketTrendChatViewModel* result = _chartViewModels[@(indexPath.row)];
        if (result == nil) {
            [self traceElementShow:@{@"element_type": model.type}];
            [[self traceCache] addObject:indexPath];
        }
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

@end
