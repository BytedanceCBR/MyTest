//
//  FHHomeRequestAPI.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import "FHHomeRequestAPI.h"
#import "FHMainApi.h"
#import "FHHomeHouseModel.h"

@implementation FHHomeRequestAPI

+ (void)requestRecommendFirstTime:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion
{
    [FHMainApi requestHomeRecommend:param completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        if (!completion) {
            return ;
        }
        completion(model,error);
    }];
}

+ (void)requestRecommendForLoadMore:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion
{
    [FHMainApi requestHomeRecommend:param completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        if (!completion) {
            return ;
        }
        completion(model,error);
    }];
}

@end
