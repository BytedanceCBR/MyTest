//
//  FHHomeRequestAPI.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import <Foundation/Foundation.h>
#import "FHHomeRollModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeRequestAPI : NSObject

+ (void)requestRecommendFirstTime:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeRollModel *model, NSError *error))completion;

+ (void)requestRecommendForLoadMore:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeRollModel *model, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
