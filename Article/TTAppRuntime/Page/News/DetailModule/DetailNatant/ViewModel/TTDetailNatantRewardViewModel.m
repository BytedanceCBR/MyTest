//
//  TTDetailNatantRewardViewModel.m
//  Article
//
//  Created by 刘廷勇 on 16/4/29.
//
//

#import "TTDetailNatantRewardViewModel.h"

@implementation TTDetailNatantRewardUser

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"avatar_url" : @"avatarURL",
                           @"user_id"    : @"userID",
                           @"user_auth_info": @"userAuthInfo"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end

@implementation TTDetailNatantRewardViewModel

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
