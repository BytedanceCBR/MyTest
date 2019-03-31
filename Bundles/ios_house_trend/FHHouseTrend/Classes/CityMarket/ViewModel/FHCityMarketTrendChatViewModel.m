//
//  FHCityMarketTrendChatViewModel.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import "FHCityMarketTrendChatViewModel.h"
#import "FHCityMarketDetailResponseModel.h"
#import "RXCollection.h"
#import "FHDetailPriceMarkerView.h"
#import "UIView+House.h"

@interface FHCityMarketTrendChatViewModel ()
@property (nonatomic, assign) NSUInteger selectIndex;
@property (nonatomic, assign) BOOL hideMarker;
@end

@implementation FHCityMarketTrendChatViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setModel:(FHCityMarketDetailResponseDataMarketTrendListModel *)model {
    [self willChangeValueForKey:@"model"];
    _model = model;
    [self onDataChange];
    [self didChangeValueForKey:@"model"];
}

-(void)onDataChange {
    FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel* info = _model.districtMarketInfoList.firstObject;
    self.currentSelected = info.locationName;
    self.categorys = [_model.districtMarketInfoList rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel* each) {
        return each.locationName;
    }];
    self.selectedInfoListModel = info;
}

-(void)changeCategory:(NSString*)category {
    NSParameterAssert(category);
    self.currentSelected = category;
    [self dismissInfoView];
    [_model.districtMarketInfoList enumerateObjectsUsingBlock:^(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([category isEqualToString:obj.locationName]) {
            self.selectedInfoListModel = obj;
        }
    }];
}


- (void)userClickedOnKeyPoint:(CGPoint)point
                    lineIndex:(NSInteger)lineIndex
                   pointIndex:(NSInteger)pointIndex
                  selectPoint:(CGPoint)selectPoint
{

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
        view = [[FHDetailPriceMarkerView alloc] init];
        view.tag = 200;
        [self.chartView addSubview:view];
    }
    if (![view isKindOfClass:[FHDetailPriceMarkerView class]]) {
        return;
    }
    FHDetailPriceMarkerData *markData = [[FHDetailPriceMarkerData alloc] init];
    NSArray *priceTrends = self.selectedInfoListModel.trendLines;
    if (priceTrends.count < 1) {
        return;
    }
    FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel* infoList = priceTrends.firstObject;
    markData.trendItems = [priceTrends rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTrendLinesModel* each) {
        FHDetailPriceMarkerItem* item = [[FHDetailPriceMarkerItem alloc] init];
        item.name = each.shortDesc;
        FHDetailPriceTrendValuesModel* m = [[FHDetailPriceTrendValuesModel alloc] init];
        m.price = [@([each.values[pointIndex] floatValue] * 1000000.00f) stringValue];
        FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListTimeLineModel* time = self.selectedInfoListModel.timeLine[pointIndex];
        m.timeStr = [NSString stringWithFormat:@"%@%@", time.year, time.month];
        item.priceModel = m;
        return item;
    }];

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
    view.centerY = (self.chartView.height - 40) / 2;
}

-(void)dismissInfoView {
    FHDetailPriceMarkerView *view = [self.chartView viewWithTag:200];
    view.hidden = YES;
}

@end
