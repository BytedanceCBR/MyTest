//
//  FHHomeItemRequestManager.m
//  FHHouseHome
//
//  Created by bytedance on 2020/11/27.
//

#import "FHHomeItemRequestManager.h"
#import "FHEnvContext.h"
#import "FHHomeItemRequestHelper.h"
#import "FHHouseType.h"
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import "BDTrackerProtocol.h"
#import "SSCommonLogic.h"

@interface FHHomeItemRequestManager() {
    NSMutableDictionary *_itemHelperMap;
}
@property (nonatomic, assign) FHHomepagePreloadType preloadType;
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

+ (FHHomepagePreloadType)preloadType {
    static FHHomepagePreloadType preloadType = FHHomepagePreloadTypeNone;
    static dispatch_once_t preloadTypeOnceToken;
    dispatch_once(&preloadTypeOnceToken, ^{
        NSDictionary *settings = [SSCommonLogic fhSettings];
        if (settings && [settings isKindOfClass:[NSDictionary class]]) {
            NSInteger preloadCategory = [settings btd_integerValueForKey:@"f_homepage_preload_category" default:0];
            switch (preloadCategory) {
                case 1:
                    preloadType = FHHomepagePreloadTypeStartupTask;
                    break;
                case 2:
                    preloadType = FHHomepagePreloadTypeHomeMain;
                    break;
                case 3: {
                    NSInteger did = [[BDTrackerProtocol deviceID] integerValue];
                    if (did % 2 == 1) {
                        preloadType = FHHomepagePreloadTypeStartupTask;
                    } else {
                        preloadType = FHHomepagePreloadTypeHomeMain;
                    }
                    break;
                }
                default:
                    break;
            }
        }
    });
    return preloadType;
}

+ (void)initRequestRecommendWithHouseType:(NSInteger)houseType contextParams:(NSDictionary *)contextParams completion:(FHHomeRecommendRequestCompletionBlock)completion {
    FHHomeItemRequestHelper *helper = [[FHHomeItemRequestManager sharedInstance] getItemRequestHelperWithHouseType:houseType];
    [helper initRequestRecommend:contextParams completion:completion];
}

+ (void)requestRecommendWithHouseType:(NSInteger)houseType contextParams:(NSDictionary *)contextParams completion:(FHHomeRecommendRequestCompletionBlock)completion {
    FHHomeItemRequestHelper *helper = [[FHHomeItemRequestManager sharedInstance] getItemRequestHelperWithHouseType:houseType];
    [helper requestRecommend:contextParams completion:completion];
}

+ (void)preloadIfNeed {
    NSInteger defaultHouseType = [self defaultHouseType];
    FHHomeItemRequestHelper *helper = [[FHHomeItemRequestManager sharedInstance] getItemRequestHelperWithHouseType:defaultHouseType];
    [helper preloadIfNeed];
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

@end
