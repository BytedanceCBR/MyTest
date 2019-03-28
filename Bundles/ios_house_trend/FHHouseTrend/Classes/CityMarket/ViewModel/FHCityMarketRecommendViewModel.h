//
//  FHCityMarketRecommendViewModel.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/28.
//

#import <Foundation/Foundation.h>
@class FHCityMarketDetailResponseDataSpecialOldHouseListModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHCityMarketRecommendViewModel : NSObject
@property (nonatomic, strong) NSArray<FHCityMarketDetailResponseDataSpecialOldHouseListModel*> *specialOldHouseList;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* question;
@property (nonatomic, copy) NSString* answoer;
@property (nonatomic, assign) NSUInteger selectedIndex;
@end

NS_ASSUME_NONNULL_END
