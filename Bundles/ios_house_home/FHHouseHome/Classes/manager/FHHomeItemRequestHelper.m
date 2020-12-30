//
//  FHHomeItemRequestHelper.m
//  FHHouseHome
//
//  Created by bytedance on 2020/12/21.
//

#import "FHHomeItemRequestHelper.h"
#import "FHEnvContext.h"
#import "FHHomeRequestAPI.h"
#import "FHSearchChannelTypes.h"
#import "TTHttpTask.h"
#import "FHHouseType.h"
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>

@interface FHHomeItemRequestHelper()
@property (nonatomic, copy) NSString *originalCityId;
@property (nonatomic, assign) FHHomeItemPreloadState preloadState;
@property (nonatomic, strong) FHHomeHouseModel *model;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) TTHttpTask *requestTask;
@property (nonatomic, copy) FHHomeItemRequestCompletionBlock completionBlock;
@end

@implementation FHHomeItemRequestHelper

- (instancetype)init {
    return [self initWithHouseType:0];
}

- (instancetype)initWithHouseType:(NSInteger)houseType {
    NSAssert(houseType > 0, @"FHHomeItemRequestHelper初始化异常, house_type必须大于0");
    self = [super init];
    if (self) {
        _houseType = houseType;
        _originalCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
        _preloadState = FHHomeItemPreloadStateNone;
    }
    return self;
}

- (BOOL)canPreload {
    return (self.originalCityId && self.originalCityId.length > 0 && self.preloadState == FHHomeItemPreloadStateNone);
}

- (void)preloadIfNeed {
    if (![self canPreload]) return;
    self.preloadState = FHHomeItemPreloadStateFetching;
    WeakSelf;
    [self requestRecommend:@{@"offset": @(0)} completion:^(FHHomeHouseModel *model, NSError *error) {
        StrongSelf;
        [self handlePreloadResult:model error:error];
    }];
}

- (BOOL)canUsePreloadData {
    if (!self.originalCityId || !self.originalCityId.length) return NO;
    NSString *cityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    return (cityId && [cityId isEqualToString:self.originalCityId]);
}

- (NSDictionary *)commonRequestParams {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params btd_setObject:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    [params btd_setObject:@(self.houseType) forKey:@"house_type"];
    [params btd_setObject:@(20) forKey:@"count"];
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            [params btd_setObject:CHANNEL_ID_RECOMMEND_COURT forKey:CHANNEL_ID];
            break;
        case FHHouseTypeSecondHandHouse:
            [params btd_setObject:CHANNEL_ID_RECOMMEND forKey:CHANNEL_ID];
            break;
        case FHHouseTypeRentHouse:
            [params btd_setObject:CHANNEL_ID_RECOMMEND_RENT forKey:CHANNEL_ID];
            break;
        default:
            break;
    }
    return params;
}

- (void)initRequestRecommend:(NSDictionary *)contextParams completion:(FHHomeItemRequestCompletionBlock)completion {
    if ([self canUsePreloadData]) {
        switch (self.preloadState) {
            case FHHomeItemPreloadStateFetching:
                self.completionBlock = completion;
                return;
                break;
            case FHHomeItemPreloadStateDone: {
                if (self.model && self.error == nil) {
                    if (completion) {
                        completion(self.model, self.error);
                    }
                    return;
                }
                break;
            }
            default:
                break;
        }
    }
        
    [self requestRecommend:contextParams completion:completion];
}

- (void)requestRecommend:(NSDictionary *)contextParams completion:(FHHomeItemRequestCompletionBlock)completion {
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary addEntriesFromDictionary:[self commonRequestParams]];
    if (contextParams) {
        [requestDictonary addEntriesFromDictionary:contextParams];
    }

    if (self.requestTask) {
        [self.requestTask cancel];
    }

    self.requestTask = [FHHomeRequestAPI requestRecommendForLoadMore:requestDictonary completion:completion];
}

- (void)handlePreloadResult:(FHHomeHouseModel *)model error:(NSError *)error {
    [self performAtMainThreadWithBlock:^{
        self.error = error;
        self.model = model;
        self.preloadState = FHHomeItemPreloadStateDone;
        if (self.completionBlock) {
            self.completionBlock(self.model, self.error);
        }
    }];
}

- (void)performAtMainThreadWithBlock:(void (^)(void))block {
    if(block) {
        if([NSThread isMainThread]) {
            block();
        } else {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

@end
