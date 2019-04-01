//
//  FHCityMarketRecommendSectionPlaceHolder.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "FHSectionCellPlaceHolder.h"
#import "FHDetailTracerPlaceHolder.h"

@class FHCityMarketDetailResponseDataSpecialOldHouseListModel;
@class FHCityMarketRecommendViewModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHCityMarketRecommendSectionPlaceHolder : FHDetailTracerPlaceHolder<FHSectionCellPlaceHolder>
@property (nonatomic, strong) NSArray<FHCityMarketDetailResponseDataSpecialOldHouseListModel*> *specialOldHouseList;
-(instancetype)initWithViewModel:(FHCityMarketRecommendViewModel*)viewModel;
@end

NS_ASSUME_NONNULL_END
