//GENERATED CODE , DON'T EDIT
#import "FHFeedListModel.h"
@implementation FHFeedListDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedListModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"loginStatus": @"login_status",
    @"totalNumber": @"total_number",
    @"hasMore": @"has_more",
    @"postContentHint": @"post_content_hint",
    @"showEtStatus": @"show_et_status",
    @"isUseBytedanceStream": @"is_use_bytedance_stream",
    @"feedFlag": @"feed_flag",
    @"actionToLastStick": @"action_to_last_stick",
    @"hasMoreToRefresh": @"has_more_to_refresh",
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

@implementation FHFeedListTipsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"openUrl": @"open_url",
    @"appName": @"app_name",
    @"packageName": @"package_name",
    @"displayTemplate": @"display_template",
    @"displayDuration": @"display_duration",
    @"downloadUrl": @"download_url",
    @"displayInfo": @"display_info",
    @"webUrl": @"web_url",
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

