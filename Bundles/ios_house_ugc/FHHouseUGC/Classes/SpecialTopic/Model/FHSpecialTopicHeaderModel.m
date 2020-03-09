//GENERATED CODE , DON'T EDIT
#import "FHSpecialTopicHeaderModel.h"
@implementation FHSpecialTopicHeaderRepostParamsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"optIdType": @"opt_id_type",
    @"fwIdType": @"fw_id_type",
    @"fwId": @"fw_id",
    @"coverUrl": @"cover_url",
    @"optId": @"opt_id",
    @"repostType": @"repost_type",
    @"fwUserId": @"fw_user_id",
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

@implementation FHSpecialTopicHeaderPublisherControlPublisherTypesModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHSpecialTopicHeaderShareInfoShareTypeModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHSpecialTopicHeaderPublisherControlModel
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

@implementation FHSpecialTopicHeaderTabsModel
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

@implementation FHSpecialTopicHeaderForumModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"productType": @"product_type",
    @"bannerUrl": @"banner_url",
    @"richContent": @"rich_content",
    @"forumName": @"forum_name",
    @"concernId": @"concern_id",
    @"forumId": @"forum_id",
    @"showFollowButton": @"show_follow_button",
    @"categoryType": @"category_type",
    @"avatarUrl": @"avatar_url",
    @"isFollowing": @"is_following",
    @"modifyTime": @"modify_time",
    @"subDesc": @"sub_desc",
    @"headerStyle": @"header_style",
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

@implementation FHSpecialTopicHeaderInsertControlModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"categoryName": @"category_name",
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

@implementation FHSpecialTopicHeaderModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"errTips": @"err_tips",
    @"shareInfo": @"share_info",
    @"publisherControl": @"publisher_control",
    @"insertControl": @"insert_control",
    @"errNo": @"err_no",
    @"repostParams": @"repost_params",
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

@implementation FHSpecialTopicHeaderShareInfoModel
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

@implementation FHSpecialTopicHeaderForumExtraModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"curCityCode": @"cur_city_code",
    @"musicId": @"music_id",
    @"ncovStringList": @"ncov_string_list",
    @"ncovImageUrl": @"ncov_image_url",
    @"themeId": @"theme_id",
    @"effectId": @"effect_id",
    @"gpsCityCode": @"gps_city_code",
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

