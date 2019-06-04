//
//  FHHouseUGCAPI.m
//

#import "FHHouseUGCAPI.h"

@implementation FHHouseUGCAPI

+ (TTHttpTask *)requestTopicList:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/api/community/topics";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"community_id"] = communityId ?: @"";
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

@end
