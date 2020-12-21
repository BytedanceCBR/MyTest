//
//  FHHomeItemRequestManager.h
//  FHHouseHome
//
//  Created by bytedance on 2020/11/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FHHomepagePreloadType) {
    FHHomepagePreloadTypeNone,
    FHHomepagePreloadTypeStartupTask,
    FHHomepagePreloadTypeHomeMain
};

@class FHHomeHouseModel;
typedef void(^FHHomeRecommendRequestCompletionBlock)(FHHomeHouseModel *model, NSError *error);
@interface FHHomeItemRequestManager : NSObject

+ (void)initRequestRecommendWithHouseType:(NSInteger)houseType contextParams:(NSDictionary *)contextParams completion:(FHHomeRecommendRequestCompletionBlock)completion;

+ (void)requestRecommendWithHouseType:(NSInteger)houseType contextParams:(NSDictionary *)contextParams completion:(FHHomeRecommendRequestCompletionBlock)completion;

+ (FHHomepagePreloadType)preloadType;

+ (void)preloadIfNeed;

@end

NS_ASSUME_NONNULL_END
