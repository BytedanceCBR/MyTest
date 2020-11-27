//
//  FHHomeItemRequestHelper.h
//  FHHouseHome
//
//  Created by bytedance on 2020/11/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHHomeHouseModel;
typedef void(^FHHomeRecommendRequestCompletionBlock)(FHHomeHouseModel *model, NSError *error);

@interface FHHomeItemRequestHelper : NSObject
@property (nonatomic, assign, readonly) NSInteger houseType;

- (void)initRequestRecommend:(NSDictionary *)contextParams completion:(FHHomeRecommendRequestCompletionBlock)completion;

- (void)requestRecommend:(NSDictionary *)contextParams completion:(FHHomeRecommendRequestCompletionBlock)completion;

@end


@interface FHHomeItemRequestManager : NSObject

+ (FHHomeItemRequestHelper *)getItemRequestHelperWithHouseType:(NSInteger)houseType;

+ (BOOL)preloadEnabled;

+ (void)preloadIfNeed;

+ (NSDictionary *)commonRequestParams:(NSInteger)houseType;

@end

NS_ASSUME_NONNULL_END
