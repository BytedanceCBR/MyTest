//
//  FHHouseContactBaseModel.m
//  FHHouseBase
//
//  Created by 张静 on 2019/4/25.
//

#import "FHHouseContactBaseModel.h"


@implementation  FHDetailResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailVirtualNumModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"realtorId": @"realtor_id",
                           @"virtualNumber": @"virtual_number",
                           @"isVirtual": @"is_virtual",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailVirtualNumResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


@implementation FHDetailUserFollowStatusModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"followStatus": @"follow_status",
                           @"socialGroupFollowStatus": @"social_group_follow_status",
                           @"socialGroupId": @"social_group_id",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailUserFollowResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHHouseContactBaseModel

@end
