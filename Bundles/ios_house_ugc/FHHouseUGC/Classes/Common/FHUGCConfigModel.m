//GENERATED CODE , DON'T EDIT
#import "FHUGCConfigModel.h"
@implementation FHUGCConfigModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCConfigDataPermissionModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCConfigDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"leadSuggest": @"lead_suggest",
    @"ugcDistrict": @"ugc_district",
    @"userAuth": @"user_auth",
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

@implementation FHUGCConfigDataLeadSuggestModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCConfigDataDistrictModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"districtId": @"district_id",
            @"districtName": @"district_name",
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


@implementation FHPostUGCSelectedGroupHistory
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
@implementation FHPostUGCSelectedGroupModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
