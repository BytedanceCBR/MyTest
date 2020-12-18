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

@implementation FHFormAssociateInfoControlInfoDialogModel

+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"cancelBtnText": @"cancel_btn_text",
    @"confirmBtnText": @"confirm_btn_text",
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

@implementation FHFormAssociateInfoControlInfoModel

+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"verifyType": @"verify_type",
    @"associateTypes": @"associate_types",
    @"submitType": @"submit_type",
    @"showType": @"show_type",
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

@implementation FHFormAssociateInfoControlModel

+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"controlInfo": @"control_info",
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

@implementation FHFormAssociateInfoModel

+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"associateInfo": @"associate_info",
    @"associateId": @"associate_id"
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

@implementation FHDetailFillFormResponseModel

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
                           @"requestId": @"request_id",
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
