//
//  WDDetailNatantRewardViewModel.m
//  Article
//
//  Created by 张延晋 on 17/11/16.
//
//

#import "WDDetailNatantRewardViewModel.h"

@implementation WDDetailNatantRewardUser

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"avatar_url" : @"avatarURL",
                           @"user_id"    : @"userID",
                           @"user_auth_info": @"userAuthInfo",
                           @"user_decoration": @"userDecoration"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end

@implementation WDDetailNatantRewardViewModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"rewards_open_url" : @"rewardOpenURL",
                           @"rewards_list_url" : @"rewardListURL",
                           @"rewards_num"      : @"rewardNum",
                           @"rewards_list"     : @"rewardUserList"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end
