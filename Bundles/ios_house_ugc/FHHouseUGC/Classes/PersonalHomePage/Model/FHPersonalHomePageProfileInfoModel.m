//
//  FHPersonalHomePageProfileInfoModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageProfileInfoModel.h"

@implementation FHPersonalHomePageProfileInfoDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"userId": @"user_id",
    @"avatarUrl": @"avatar_url",
    @"desc": @"description",
    @"verifiedContent": @"verified_content",
    @"bigAvatarUrl": @"big_avatar_url",
    @"logPb": @"log_pb",
    @"FHomePageAuth" : @"f_homepage_auth"
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

@implementation FHPersonalHomePageProfileInfoModel

+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"errorCode": @"errno",
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