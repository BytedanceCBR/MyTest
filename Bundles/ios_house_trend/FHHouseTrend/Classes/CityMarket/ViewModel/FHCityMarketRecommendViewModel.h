//
//  FHCityMarketRecommendViewModel.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/28.
//

#import <Foundation/Foundation.h>
@class FHCityMarketDetailResponseDataSpecialOldHouseListModel;
@class FHSearchHouseDataModel;
NS_ASSUME_NONNULL_BEGIN
@protocol FHCityMarketRecommendViewModelDataChangedListener <NSObject>

-(void)onDataArrived;

@end

@interface FHCityMarketRecommendViewModel : NSObject
@property (nonatomic, strong) NSArray<FHCityMarketDetailResponseDataSpecialOldHouseListModel*> *specialOldHouseList;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* question;
@property (nonatomic, copy) NSString* answoer;
@property (nonatomic, copy) NSString* footerTitle;
@property (nonatomic, copy) NSString* openUrl;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, weak) id<FHCityMarketRecommendViewModelDataChangedListener> listener;
-(void)onCategoryChange:(NSInteger)categoryIndex;

-(NSUInteger)arrivedDataCount;
-(FHSearchHouseDataModel*)currentData;
-(NSString*)categoryNameOfindex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
