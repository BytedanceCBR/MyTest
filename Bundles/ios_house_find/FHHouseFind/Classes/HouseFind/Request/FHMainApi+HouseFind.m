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

@end
