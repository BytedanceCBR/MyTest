//
//  CityMarketDetailAPI.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/26.
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>
@class FHCityMarketDetailResponseModel;
NS_ASSUME_NONNULL_BEGIN

@interface CityMarketDetailAPI : NSObject
+(TTHttpTask*)requestCityMarketWithCompletion:(void(^)(FHCityMarketDetailResponseModel * _Nullable model , NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
