//
//  FHCityMarketTrendHeaderViewModel.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHCityMarketTrendHeaderViewModel.h"
#import "FHCityMarketDetailResponseModel.h"
#import "CityMarketDetailAPI.h"
#import <TTNetworkManager.h>
#import "ReactiveObjC.h"
#import "extobjc.h"
#import "TTReachability.h"

@interface FHCityMarketTrendHeaderViewModel ()
@property (nonatomic, weak) TTHttpTask* marketDetailRequest;
@end

@implementation FHCityMarketTrendHeaderViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        @weakify(self);
        [RACObserve(self, model) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self onModelChanged:x];
        }];
    }
    return self;
}

-(void)onModelChanged:(FHCityMarketDetailResponseModel*)model {
    self.title = model.data.title;
    self.price = model.data.pricePerSqm;
    self.unit = model.data.pricePerSqmUnit;
    self.source = model.data.dataSource;
    self.properties = model.data.summaryItemList;
}

- (void)requestData {
    if([TTReachability isNetworkConnected]) {
        [_marketDetailRequest cancel];
        _marketDetailRequest = [CityMarketDetailAPI
                                requestCityMarketWithCompletion:^(FHCityMarketDetailResponseModel * _Nullable model, NSError * _Nullable error) {
                                    if (error != nil) {
                                        self.model = model;
                                    } else {
                                        [_delegate onNetworkError];
                                    }
                                }];
    } else {
        [_delegate onNoNetwork];
    }
}
@end
