//GENERATED CODE , DON'T EDIT
#import "FHDetailReplyCommentModel.h"
@implementation FHDetailReplyCommentModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"banFace": @"ban_face",
    @"errNo": @"err_no",
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

@implementation FHDetailReplyCommentDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"hasMore": @"has_more",
    @"totalCount": @"total_count",
    @"stickTotalNumber": @"stick_total_number",
    @"groupId": @"group_id",
    @"stickHasMore": @"stick_has_more",
    @"allCommentModels": @"data",
    @"stickCommentModels": @"stick_comments",
    @"hotCommentModels": @"hot_comments",
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

