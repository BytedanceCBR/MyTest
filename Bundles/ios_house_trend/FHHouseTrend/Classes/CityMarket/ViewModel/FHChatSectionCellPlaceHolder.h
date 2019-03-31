//
//  FHChatSectionCellPlaceHolder.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "FHSectionCellPlaceHolder.h"
NS_ASSUME_NONNULL_BEGIN
@class FHCityMarketDetailResponseDataMarketTrendListModel;
@interface FHChatSectionCellPlaceHolder : NSObject<FHSectionCellPlaceHolder>
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataMarketTrendListModel*> *marketTrendList;
@property (nonatomic, strong) NSArray<NSString*>* districtNameList;
@property (nonatomic, assign) NSUInteger sectionOffset;

@end

NS_ASSUME_NONNULL_END
