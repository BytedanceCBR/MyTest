//
//  FHAreaItemSectionPlaceHolder.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "FHSectionCellPlaceHolder.h"
@class FHCityMarketDetailResponseDataHotListModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHAreaItemSectionPlaceHolder : NSObject<FHSectionCellPlaceHolder>
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataHotListModel*> *hotList;
@property (nonatomic, assign) NSUInteger sectionOffset;

@end

NS_ASSUME_NONNULL_END
