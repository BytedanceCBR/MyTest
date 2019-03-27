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
@implementation FHChatSectionCellPlaceHolder

- (instancetype)init
{
    self = [super init];
    if (self) {
        FHConfigDataModel* model = [[FHEnvContext sharedInstance] getConfigFromCache];
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
    [cell.chatView.banner setItems:items];
    [self setupChat:infoList ofChartView:cell.chatView.lineChart];
    return cell;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 382;  //366 + 16;
}

- (nonnull UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}


-(void)setupChat:(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel*)values
      ofChartView:(PNLineChart*) chartView {
    NSArray* lineDatas = [values.trendLines rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel* each) {
        PNLineChartData *data01 = [PNLineChartData new];
        UIColor* color = [UIColor colorWithHexString:each.color];
        data01.color = color;
        data01.alpha = 1;
        data01.showPointLabel = NO; // 是否显示坐标点的值
        data01.itemCount = [each.values count];
        data01.inflexionPointColor = color;
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

    chartView.chartData = lineDatas;
    [chartView strokeChart];

    NSArray* xLabels = [values.timeLine rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTimeLineModel* each) {
        return each.month;
    }];
    [chartView setXLabels:xLabels];

//    for (NSInteger index = priceTrends.count - 1; index >= 0; index--) {
//
//        FHDetailPriceTrendModel *priceTrend = priceTrends[index];
//        NSArray *data01Array = priceTrend.values;
//        PNLineChartData *data01 = [PNLineChartData new];
//        data01.color = [self lineColorByIndex:index];
//        data01.highlightedImg = [self highlightImgNameByIndex:index];
//        data01.alpha = 1;
//        data01.showPointLabel = NO; // 是否显示坐标点的值
//        data01.itemCount = data01Array.count;
//        data01.inflexionPointColor = [self lineColorByIndex:index];
//        data01.inflexionPointStyle = PNLineChartPointStyleCircle;
//        data01.lineWidth = 1;
//        data01.inflexionPointWidth = 4; // inflexionPoint 圆圈圈
//        data01.pointLabelFormat = @"%.2f";
//        __weak typeof(self)wself = self;
//        data01.getData = ^(NSUInteger index) {
//
//            FHDetailPriceTrendValuesModel *trendValue = data01Array[index];
//            CGFloat yValue = trendValue.price.floatValue / wself.unitPerSquare;
//            return [PNLineChartDataItem dataItemWithY:yValue andRawY:yValue];
//
//            return [PNLineChartDataItem dataItemWithY:yValue];
//        };
//        [mutable addObject:data01];
//    }

}



@end
