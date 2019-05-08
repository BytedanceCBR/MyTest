//
//  HTSVideoPlayUserInfoManager.m
//  LiveStreaming
//
//  Created by Quan Quan on 16/2/28.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "AWEVideoUserInfoManager.h"
#import "AWEVideoPlayNetworkManager.h"
#import "AWEUserModel.h"
#import "TSVMonitorManager.h"

extern NSString * const TTFollowSuccessForPushGuideNotification;

static NSString * const TT_DOMAIN = @"https://is.haoduofangs.com";

@implementation AWEVideoUserInfoManager

+ (void)followUser:(NSString *)userId completion:(void(^)(AWEUserModel *user, NSError *error))block
{
    if (!userId) {
        return;
    }

    NSString *url = [NSString stringWithFormat:@"%@/2/relation/follow/v2/", TT_DOMAIN];
    //https://docs.google.com/a/bytedance.com/spreadsheets/d/1v7vKLnFrO62E1sPbnp1szczfsnpIl3bxg97LaAKmvxc/edit?usp=sharing
    NSDictionary *params = @{
                            @"user_id" : userId,
                            @"new_reason" : @61,
                            @"new_source" : @61
                            };
    
    NSString *monitorIdentifier = [[TSVMonitorManager sharedManager] startMonitorNetworkService:TSVMonitorNetworkServiceFollow key:userId];
    
    [self sendRequest:params withUrl:url completion:^(AWEUserModel *user, NSError *error) {
        [[TSVMonitorManager sharedManager] endMonitorNetworkService:TSVMonitorNetworkServiceFollow identifier:monitorIdentifier error:error];
        
        if (block) {
            block(user, error);
        }
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTFollowSuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(30)}];
        }
    }];
}

+ (void)unfollowUser:(NSString *)userId completion:(void(^)(AWEUserModel *user, NSError *error))block
{
    if (!userId) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/2/relation/unfollow/", TT_DOMAIN];
    NSDictionary *params = @{
                                    @"user_id" : userId
                                 };
    
    NSString *monitorIdentifier = [[TSVMonitorManager sharedManager] startMonitorNetworkService:TSVMonitorNetworkServiceUnfollow key:userId];
    
    [self sendRequest:params withUrl:url completion:^(AWEUserModel *user, NSError *error) {
        [[TSVMonitorManager sharedManager] endMonitorNetworkService:TSVMonitorNetworkServiceUnfollow identifier:monitorIdentifier error:error];
        
        if (block) {
            block(user, error);
        }
    }];
}

+ (void)sendRequest:(NSDictionary *)params withUrl:(NSString *)url completion:(void(^)(AWEUserModel *user, NSError *error))block
{
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:url params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error || [jsonObj[@"message"] isEqualToString:@"error"] || !jsonObj[@"data"]) {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            errorInfo[@"prompts"] = jsonObj[@"data"][@"description"];
            NSInteger errCode = 0;
            if ([jsonObj[@"errno"] isKindOfClass:[NSNumber class]]) {
                errCode = [((NSNumber *)jsonObj[@"errno"]) integerValue];
            }
            block(nil, [NSError errorWithDomain:@"com.bytedance.douyin" code:errCode userInfo:errorInfo]);
            return;
        }
        
        NSError *mappingError = nil;
        NSDictionary *dataDic = jsonObj[@"data"][@"user"];
        AWEUserModel *model = [MTLJSONAdapter modelOfClass:[AWEUserModel class]
                                        fromJSONDictionary:dataDic
                                                     error:&mappingError];
        if (mappingError) {
            if (block) {
                block(nil, mappingError);
            }
            return;
        }
        !block?:block(model,nil);
    }];
}

@end
