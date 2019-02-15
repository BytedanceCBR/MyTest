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

/*
 let url = "\(EnvContext.networkConfig.host)/f100/api/clear_history?"
 
 return TTNetworkManager.shareInstance().rx
 .requestForBinary(
 url: url,
 params: ["house_type":houseType],
 method: "GET",
 needCommonParams: true)
 .map({ (data) -> NSString? in
 NSString(data: data, encoding: String.Encoding.utf8.rawValue)
 })
 */

@end
