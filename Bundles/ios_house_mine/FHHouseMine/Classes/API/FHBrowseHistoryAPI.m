//
//  FHBrowseHistoryAPI.m
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/7/13.
//

#import "FHBrowseHistoryAPI.h"
#import "WDDefines.h"

#define BROWSE_HISTORY_CHANNEL_ID   @"94349554992"

@implementation FHBrowseHistoryAPI

#pragma mark - Internal method

+ (TTHttpTask *)requestBrowseHistoryWithHouseType:(FHBrowseHistoryType)houseType count:(NSInteger)count offset:(NSInteger)offset class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/api/browse_history";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"channel_id"] = BROWSE_HISTORY_CHANNEL_ID;
    paramDic[@"house_type"] = @(houseType);
    paramDic[@"count"] = @(count);
    paramDic[@"offset"] = @(offset);
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

#pragma mark - Public API

+ (TTHttpTask *)requestBrowseHistoryWithCount:(NSInteger)count houseType:(FHHouseType)houseType offset:(NSInteger)offset class:(Class)cls completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
    return [self requestBrowseHistoryWithHouseType:houseType count:count offset:offset class:cls completion:completion];
}

@end