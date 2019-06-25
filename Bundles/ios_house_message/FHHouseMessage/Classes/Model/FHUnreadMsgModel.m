//GENERATED CODE , DON'T EDIT
#import "FHUnreadMsgModel.h"
@implementation FHUnreadMsgDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUnreadMsgModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUnreadMsgDataUnreadModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"openUrl": @"open_url",
    @"dateStr": @"date_str",
    @"lastUserAvatar": @"last_user_avatar",
    @"hasHistoryMsg": @"has_history_msg",
    @"lastMsgId": @"last_msg_id",
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

