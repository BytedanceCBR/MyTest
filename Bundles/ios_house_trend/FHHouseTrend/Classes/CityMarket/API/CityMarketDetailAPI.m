//
//  CityMarketDetailAPI.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/26.
//

#import "CityMarketDetailAPI.h"
#import "FHMainApi.h"
#import "FHCityMarketDetailResponseModel.h"
@implementation CityMarketDetailAPI

+(TTHttpTask*)requestCityMarketWithCompletion:(void(^)(FHCityMarketDetailResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString *queryPath = @"/f100/api/city_market_info";
    return [FHMainApi
            queryData:queryPath
            params:nil
            class:[FHCityMarketDetailResponseModel class]
            completion:completion];
}


@end
