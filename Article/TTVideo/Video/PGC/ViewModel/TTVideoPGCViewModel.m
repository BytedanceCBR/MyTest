//
//  TTVideoPGCViewModel.m
//  Article
//
//  Created by 刘廷勇 on 15/11/5.
//
//

#import "TTVideoPGCViewModel.h"

@implementation TTVideoPGC

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"user_auth_info" : @"userAuthInfo",
                           @"avatar_url"    : @"avatarUrl",
                           @"media_id"      : @"mediaID",
                           @"description"   : @"desc",
                           @"open_url"      : @"openUrl"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end



@implementation TTVideoPGCViewModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"data.open_url"  : @"openUrl",
                           @"data.list"      : @"pgcList",
                           @"data.text"      : @"defaultDesc"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end
