//GENERATED CODE , DON'T EDIT
#import "FHUGCVoteInfoModel.h"

@implementation FHUGCVoteInfoVoteInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"richContent": @"rich_content",
    @"voteType": @"vote_type",
    @"voteId": @"vote_id",
    @"userCount": @"user_count",
    @"displayCount": @"option_limit",
    @"desc": @"subject_content",
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

@implementation FHUGCVoteInfoVoteInfoItemsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"voteCount": @"vote_count",
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

