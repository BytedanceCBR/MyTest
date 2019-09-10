//GENERATED CODE , DON'T EDIT
#import "FHTopicHeaderModel.h"
@implementation FHTopicHeaderPublisherControlPublisherTypesModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHTopicHeaderShareInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"shareDesc": @"share_desc",
    @"shareType": @"share_type",
    @"shareUrl": @"share_url",
    @"tokenType": @"token_type",
    @"shareTitle": @"share_title",
    @"shareCover": @"share_cover",
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

@implementation FHTopicHeaderForumExtraModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"themeId": @"theme_id",
    @"musicId": @"music_id",
    @"effectId": @"effect_id",
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

@implementation FHTopicHeaderForumModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"rankInfo": @"rank_info",
    @"bannerUrl": @"banner_url",
    @"hostInfo": @"host_info",
    @"forumName": @"forum_name",
    @"concernId": @"concern_id",
    @"forumLogoUrl": @"forum_logo_url",
    @"forumSpot": @"forum_spot",
    @"forumId": @"forum_id",
    @"showFollowButton": @"show_follow_button",
    @"headerStyle": @"header_style",
    @"richContent": @"rich_content",
    @"categoryType": @"category_type",
    @"avatarUrl": @"avatar_url",
    @"isFollowing": @"is_following",
    @"subDesc": @"sub_desc",
    @"productType": @"product_type",
    @"titleUrl": @"title_url",
    @"descRichSpan": @"desc_rich_span",
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

@implementation FHTopicHeaderShareInfoShareTypeModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHTopicHeaderModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"errNo": @"err_no",
    @"shareInfo": @"share_info",
    @"publisherControl": @"publisher_control",
    @"repostParams": @"repost_params",
    @"errTips": @"err_tips",
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

@implementation FHTopicHeaderTabsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"tabEtStatus": @"tab_et_status",
    @"needCommonParams": @"need_common_params",
    @"soleName": @"sole_name",
    @"tabType": @"tab_type",
    @"banRefresh": @"ban_refresh",
    @"tabId": @"tab_id",
    @"categoryName": @"category_name",
    @"refreshInterval": @"refresh_interval",
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

@implementation FHTopicHeaderPublisherControlModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"postContentHint": @"post_content_hint",
    @"showEtStatus": @"show_et_status",
    @"publisherTypes": @"publisher_types",
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

