//GENERATED CODE , DON'T EDIT
#import "FHHouseNewsSocialModel.h"

@implementation FHHouseNewsSocialAssociateActiveInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"associateContentTitle":@"associate_content_title",
    @"associateLinkTitle": @"associate_link_title",
    @"associateLinkShowType": @"associate_link_type",
    @"activeInfo": @"active_info",
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

@implementation FHHouseNewsSocialModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"socialActiveInfo": @"social_active_info",
    @"associateActiveInfo": @"associate_active_info",
    @"socialGroupInfo": @"social_group_info",
    @"groupChatLinkTitle": @"group_chat_link_title",
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
