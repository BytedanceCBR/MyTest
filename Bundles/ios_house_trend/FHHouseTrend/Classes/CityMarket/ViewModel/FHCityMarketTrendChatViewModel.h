//
//  FHCityMarketTrendChatViewModel.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import <Foundation/Foundation.h>
#import "PNLineChart.h"
@class FHCityMarketDetailResponseDataMarketTrendListModel;
@class FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel;
NS_ASSUME_NONNULL_BEGIN
@interface FHCityMarketTrendChatViewModel : NSObject<PNChartDelegate>
@property (nonatomic, copy) NSString* currentSelected;
@property (nonatomic, strong) NSArray<NSString*>* categorys;
@property (nonatomic, strong) FHCityMarketDetailResponseDataMarketTrendListModel* model;
@property (nonatomic, strong) FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel* selectedInfoListModel;
@property (nonatomic, weak) UIView* chartView;
-(void)changeCategory:(NSString*)category;
@end

NS_ASSUME_NONNULL_END
