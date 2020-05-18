//GENERATED CODE , DON'T EDIT
#import "FHUGCCategoryModel.h"
@implementation FHUGCCategoryDataDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"iconUrl": @"icon_url",
    @"concernId": @"concern_id",
    @"defaultAdd": @"default_add",
    @"recommendScore": @"recommend_score",
    @"channelId": @"channel_id",
    @"webUrl": @"web_url",
    @"imageUrl": @"image_url",
    @"feedListStyle": @"feed_list_style",
    @"tipNew": @"tip_new",
    @"iconUrl2": @"icon_url2",
    @"backgroundColor": @"background_color",
    @"placeholdColor": @"placehold_color",
    @"parentChannelId": @"parent_channel_id",
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

@implementation FHUGCCategoryModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCCategoryDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

