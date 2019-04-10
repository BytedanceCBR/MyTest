//
//  FHChatSectionCellPlaceHolder.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "FHSectionCellPlaceHolder.h"
#import "FHDetailTracerPlaceHolder.h"

NS_ASSUME_NONNULL_BEGIN
@class FHCityMarketDetailResponseDataMarketTrendListModel;
@interface FHChatSectionCellPlaceHolder : FHDetailTracerPlaceHolder<FHSectionCellPlaceHolder>
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataMarketTrendListModel*> *marketTrendList;
@property (nonatomic, strong) NSArray<NSString*>* districtNameList;

@end

NS_ASSUME_NONNULL_END
