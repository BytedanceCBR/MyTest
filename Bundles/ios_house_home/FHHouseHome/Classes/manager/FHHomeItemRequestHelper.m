//
//  FHHomeItemRequestHelper.m
//  FHHouseHome
//
//  Created by bytedance on 2020/11/27.
//

#import "FHHomeItemRequestHelper.h"
#import "FHEnvContext.h"
#import "FHHomeRequestAPI.h"
#import "FHSearchChannelTypes.h"
#import "TTHttpTask.h"
#import "FHHouseType.h"
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>

typedef NS_ENUM(NSInteger, FHHomeItemPreloadState) {
    FHHomeItemPreloadStateNone,
    FHHomeItemPreloadStateFetching,
    FHHomeItemPreloadStateDone
};

@interface FHHomeItemRequestHelper()
@property (nonatomic, copy) NSString *originalCityId;
@property (nonatomic, assign) FHHomeItemPreloadState preloadState;
@property (nonatomic, strong) FHHomeHouseModel *model;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) TTHttpTask *requestTask;
@property (nonatomic, copy) FHHomeRecommendRequestCompletionBlock completionBlock;
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

- (void)initRequestRecommend:(NSDictionary *)contextParams completion:(FHHomeRecommendRequestCompletionBlock)completion {
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

- (void)requestRecommend:(NSDictionary *)contextParams completion:(FHHomeRecommendRequestCompletionBlock)completion {
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary addEntriesFromDictionary:[FHHomeItemRequestManager commonRequestParams:self.houseType]];
    if (contextParams) {
        [requestDictonary addEntriesFromDictionary:contextParams];
    }

    if (self.requestTask) {
        [self.requestTask cancel];
    }

    self.requestTask = [FHHomeRequestAPI requestRecommendForLoadMore:requestDictonary completion:completion];
}

- (void)handlePreloadResult:(FHHomeHouseModel *)model error:(NSError *)error {
    [FHHomeItemRequestHelper performAtMainThreadWithBlock:^{
        self.error = error;
        self.model = model;
        self.preloadState = FHHomeItemPreloadStateDone;
        if (self.completionBlock) {
            self.completionBlock(self.model, self.error);
        }
    }];
}

+ (void)performAtMainThreadWithBlock:(void (^)(void))block {
    if(block) {
        if([NSThread isMainThread]) {
            block();
        } else {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

@end


#import "TTSettingsManager+FHSettings.h"

@interface FHHomeItemRequestManager() {
    NSMutableDictionary *_itemHelperMap;
}
@property (nonatomic, assign) BOOL preloadDisabled;
@end

@implementation FHHomeItemRequestManager

+ (instancetype)sharedInstance {
    static FHHomeItemRequestManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FHHomeItemRequestManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemHelperMap = [NSMutableDictionary new];
        _preloadDisabled = [[TTSettingsManager fSettings] btd_boolValueForKey:@"f_disable_homepage_preload" default:NO];
    }
    return self;
}

- (FHHomeItemRequestHelper *)getItemRequestHelperWithHouseType:(NSInteger)houseType {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)houseType];
    FHHomeItemRequestHelper *helper = [_itemHelperMap objectForKey:key];
    if (!helper) {
        helper = [[FHHomeItemRequestHelper alloc] initWithHouseType:houseType];
        [_itemHelperMap setObject:helper forKey:key];
    }
    
    return helper;
}

+ (FHHomeItemRequestHelper *)getItemRequestHelperWithHouseType:(NSInteger)houseType {
    return [[FHHomeItemRequestManager sharedInstance] getItemRequestHelperWithHouseType:houseType];
}

+ (BOOL)preloadEnabled {
    return ![FHHomeItemRequestManager sharedInstance].preloadDisabled;
}

+ (void)preloadIfNeed {
    if (![self preloadEnabled]) return;
    NSInteger defaultHouseType = [self defaultHouseType];
    [[self getItemRequestHelperWithHouseType:defaultHouseType] preloadIfNeed];
}

+ (NSInteger)defaultHouseType {
    NSNumber *userSelectType = [[FHEnvContext sharedInstance].generalBizConfig getUserSelectTypeDiskCache];
    NSArray *houstTypeList = [[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList;
    if ([houstTypeList containsObject:userSelectType]) {
        return [userSelectType integerValue];
    }
    
    if ([houstTypeList count] > 0) {
        id typeValue = [houstTypeList objectAtIndex:0];
        if ([typeValue respondsToSelector:@selector(integerValue)]) {
            return [typeValue integerValue];
        }
    }
    
    return FHHouseTypeSecondHandHouse;
}

+ (NSDictionary *)commonRequestParams:(NSInteger)houseType {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params btd_setObject:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    [params btd_setObject:@(houseType) forKey:@"house_type"];
    [params btd_setObject:@(20) forKey:@"count"];
    switch (houseType) {
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

@end
