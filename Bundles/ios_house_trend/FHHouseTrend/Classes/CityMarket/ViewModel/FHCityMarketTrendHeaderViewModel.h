//
//  FHCityMarketTrendHeaderViewModel.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "FHCityMarketDetailResponseModel.h"
@class FHCityMarketDetailResponseModel;
NS_ASSUME_NONNULL_BEGIN

@protocol FHCityMarketTrendHeaderViewModelDelegate <NSObject>

-(void)onNetworkError;
-(void)onNoNetwork;

@end

@interface FHCityMarketTrendHeaderViewModel : NSObject
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* price;
@property (nonatomic, copy) NSString* unit;
@property (nonatomic, copy) NSString* source;
@property (nonatomic, weak) id<FHCityMarketTrendHeaderViewModelDelegate> delegate;
@property (nonatomic, strong) NSArray<FHCityMarketDetailResponseDataSummaryItemListModel*>* properties;
@property (nonatomic, strong) FHCityMarketDetailResponseModel* model;
-(void)requestData;

@end

NS_ASSUME_NONNULL_END
