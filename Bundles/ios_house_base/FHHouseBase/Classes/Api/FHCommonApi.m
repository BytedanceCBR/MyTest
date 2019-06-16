//
//  FHCommonApi.m
//  FHHouseBase
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHCommonApi.h"

@implementation FHCommonApi

// 点赞通用接口
+ (TTHttpTask *)requestCommonDigg:(NSString *)group_id groupType:(FHDetailDiggType)group_type action:(NSInteger)action completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/digg";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (group_id.length > 0 ) {
        paramDic[@"group_id"] = group_id;
    }
    paramDic[@"group_type"] = @(group_type);
    paramDic[@"action"] = @(action);
    NSString *query = [NSString stringWithFormat:@"group_id=%@&group_type=%ld&action=%ld",group_id,group_type,action];
    return [FHMainApi postRequest:queryPath query:query params:paramDic jsonClass:[FHDetailDiggModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion(model,error);
        }
    }];
}

@end

@implementation FHDetailDiggModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
