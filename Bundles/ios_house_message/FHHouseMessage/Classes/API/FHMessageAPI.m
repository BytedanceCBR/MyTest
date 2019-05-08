//
//  FHMessageAPI.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import "FHMessageAPI.h"

@implementation FHMessageAPI

+ (TTHttpTask *)requestMessageListWithCompletion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/msg/unread";
    
    Class cls = NSClassFromString(@"FHUnreadMsgModel");
    
    return [FHMainApi queryData:queryPath params:nil class:cls completion:completion];
}

+ (TTHttpTask *)requestSysMessageWithListId:(NSInteger)listId maxCoursor:(NSString *)maxCoursor completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/v2/msg/system_list";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"list_id"] = @(listId);
    paramDic[@"max_cursor"] = maxCoursor;
    
    Class cls = NSClassFromString(@"FHSystemMsgModel");
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestHouseMessageWithListId:(NSInteger)listId maxCoursor:(NSString *)maxCoursor searchId:(nullable NSString *)searchId completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/msg/list";

    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"list_id"] = @(listId);
    paramDic[@"max_cursor"] = maxCoursor;
    paramDic[@"limit"] = @(10);
    if(searchId){
        paramDic[@"search_id"] = searchId;
    }
    
    Class cls = NSClassFromString(@"FHHouseMsgModel");
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

@end
