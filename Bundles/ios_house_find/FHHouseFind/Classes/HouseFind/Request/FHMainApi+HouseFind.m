//
//  FHMainApi+HouseFind.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/13.
//

#import "FHMainApi+HouseFind.h"

@implementation FHMainApi (HouseFind)

+ (TTHttpTask *)requestHFHistoryByHouseType:(NSString *)houseType completion:(void(^_Nullable)(FHHFHistoryModel * model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/v2/get_history?";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_type"] = houseType;
    
    return [FHMainApi queryData:queryPath params:paramDic class:[FHHFHistoryModel class] completion:completion];
}

+ (TTHttpTask *)clearHFHistoryByHouseType:(NSString *)houseType completion:(void(^_Nullable)(FHFHClearHistoryModel * model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/clear_history?";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_type"] = houseType;
    
    return [FHMainApi queryData:queryPath params:paramDic class:[FHFHClearHistoryModel class] completion:completion];
}

+ (TTHttpTask *)requestHFHelpUsedByHouseType:(NSString *)houseType completion:(void(^_Nullable)(FHHouseFindRecommendModel * model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/help_find_is_used?";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_type"] = houseType;
    
    return [FHMainApi queryData:queryPath params:paramDic class:[FHHouseFindRecommendModel class] completion:completion];
}

+ (TTHttpTask *)saveHFHelpFindByHouseType:(NSString *)houseType query:(NSString *)query phoneNum:(NSString *)phoneNum completion:(void(^_Nullable)(FHHouseFindRecommendModel * model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/save_help_find";
    
    NSMutableDictionary *qparam = [NSMutableDictionary new];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_type"] = houseType;
    if (phoneNum.length > 0) {
        paramDic[@"tel_num"] = phoneNum;
    }
    return [FHMainApi queryData:queryPath params:paramDic class:[FHHouseFindRecommendModel class] completion:completion];
}

@end
