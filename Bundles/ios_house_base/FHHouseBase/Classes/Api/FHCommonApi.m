//
//  FHCommonApi.m
//  FHHouseBase
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHCommonApi.h"

@implementation FHCommonApi

+ (TTHttpTask *)requestCommonDigg:(NSString *)group_id groupType:(FHDetailDiggType)group_type action:(NSInteger)action completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion {
    return [self requestCommonDigg:group_id groupType:group_type action:action tracerParam:nil completion:completion];
}

// 点赞通用接口
+ (TTHttpTask *)requestCommonDigg:(NSString *)group_id groupType:(FHDetailDiggType)group_type action:(NSInteger)action tracerParam:(NSDictionary *)params completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/digg";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (group_id.length > 0 ) {
        paramDic[@"group_id"] = group_id;
    }
    paramDic[@"group_type"] = @(group_type);
    paramDic[@"action"] = @(action);
    NSString *query = [NSString stringWithFormat:@"group_id=%@&group_type=%ld&action=%ld",group_id,group_type,action];
    // 埋点上报
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        NSString *element_from = params[@"element_from"] ?: @"be_null";
        NSString *enter_from = params[@"enter_from"] ?: @"be_null";
        NSString *page_type = params[@"page_type"] ?: @"be_null";
        paramDic[@"element_from"] = element_from;
        paramDic[@"enter_from"] = enter_from;
        paramDic[@"page_type"] = page_type;
        query = [NSString stringWithFormat:@"%@&element_from=%@&enter_from=%@&page_type=%@",query,element_from,enter_from,page_type];
    }
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

@implementation FHCommonModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
