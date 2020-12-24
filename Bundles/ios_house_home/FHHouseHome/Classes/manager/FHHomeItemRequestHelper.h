//
//  FHHomeItemRequestHelper.h
//  FHHouseHome
//
//  Created by bytedance on 2020/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FHHomeItemPreloadState) {
    FHHomeItemPreloadStateNone,
    FHHomeItemPreloadStateFetching,
    FHHomeItemPreloadStateDone
};

@class FHHomeHouseModel;
typedef void(^FHHomeItemRequestCompletionBlock)(FHHomeHouseModel *model, NSError *error);
@interface FHHomeItemRequestHelper : NSObject
@property (nonatomic, assign, readonly) NSInteger houseType;

- (instancetype)initWithHouseType:(NSInteger)houseType;

- (void)preloadIfNeed;

- (void)initRequestRecommend:(NSDictionary *)contextParams completion:(FHHomeItemRequestCompletionBlock)completion;

- (void)requestRecommend:(NSDictionary *)contextParams completion:(FHHomeItemRequestCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
