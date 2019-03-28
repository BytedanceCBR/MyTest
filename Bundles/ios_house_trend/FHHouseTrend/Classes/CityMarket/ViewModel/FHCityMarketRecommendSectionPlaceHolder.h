//
//  FHCityMarketRecommendSectionPlaceHolder.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "FHSectionCellPlaceHolder.h"
@class FHCityMarketDetailResponseDataSpecialOldHouseListModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHCityMarketRecommendSectionPlaceHolder : NSObject<FHSectionCellPlaceHolder>
@property (nonatomic, assign) NSUInteger sectionOffset;
@property (nonatomic, strong) NSArray<FHCityMarketDetailResponseDataSpecialOldHouseListModel*> *specialOldHouseList;
@end

NS_ASSUME_NONNULL_END
