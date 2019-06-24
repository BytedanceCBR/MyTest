//GENERATED CODE , DON'T EDIT
#import "FHFeedContentModel.h"
@implementation FHFeedContentCommunityModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentForwardInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"forwardCount": @"forward_count",
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

@implementation FHFeedContentShareInfoShareTypeModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentShareInfoWeixinCoverImageUrlListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentActionListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentUgcRecommendModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentMediaInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"isStarUser": @"is_star_user",
    @"userId": @"user_id",
    @"verifiedContent": @"verified_content",
    @"avatarUrl": @"avatar_url",
    @"recommendType": @"recommend_type",
    @"recommendReason": @"recommend_reason",
    @"mediaId": @"media_id",
    @"userVerified": @"user_verified",
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

@implementation FHFeedContentMiddleImageUrlListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentImageListUrlListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"logPb": @"log_pb",
    @"contentDecoration": @"content_decoration",
    @"mediaName": @"media_name",
    @"banComment": @"ban_comment",
    @"imageList": @"image_list",
    @"readCount": @"read_count",
    @"isSubject": @"is_subject",
    @"articleType": @"article_type",
    @"publishTime": @"publish_time",
    @"shareUrl": @"share_url",
    @"hasM3u8Video": @"has_m3u8_video",
    @"hasMp4Video": @"has_mp4_video",
    @"diggCount": @"digg_count",
    @"aggrType": @"aggr_type",
    @"cellLayoutStyle": @"cell_layout_style",
    @"articleSubType": @"article_sub_type",
    @"buryCount": @"bury_count",
    @"needClientImprRecycle": @"need_client_impr_recycle",
    @"ignoreWebTransform": @"ignore_web_transform",
    @"sourceIconStyle": @"source_icon_style",
    @"hasVideo": @"has_video",
    @"forwardInfo": @"forward_info",
    @"showPortraitArticle": @"show_portrait_article",
    @"userInfo": @"user_info",
    @"commentCount": @"comment_count",
    @"articleUrl": @"article_url",
    @"filterWords": @"filter_words",
    @"interactionData": @"interaction_data",
    @"allowDownload": @"allow_download",
    @"shareCount": @"share_count",
    @"showDislike": @"show_dislike",
    @"actionList": @"action_list",
    @"shareInfo": @"share_info",
    @"gallaryImageCount": @"gallary_image_count",
    @"cellType": @"cell_type",
    @"tagId": @"tag_id",
    @"actionExtra": @"action_extra",
    @"itemVersion": @"item_version",
    @"verifiedContent": @"verified_content",
    @"articleVersion": @"article_version",
    @"itemId": @"item_id",
    @"showPortrait": @"show_portrait",
    @"repinCount": @"repin_count",
    @"cellFlag": @"cell_flag",
    @"sourceOpenUrl": @"source_open_url",
    @"displayUrl": @"display_url",
    @"userVerified": @"user_verified",
    @"ugcRecommend": @"ugc_recommend",
    @"behotTime": @"behot_time",
    @"preloadWeb": @"preload_web",
    @"userRepin": @"user_repin",
    @"hasImage": @"has_image",
    @"videoStyle": @"video_style",
    @"mediaInfo": @"media_info",
    @"groupId": @"group_id",
    @"middleImage": @"middle_image",
    @"openUrl": @"open_url",
    @"sourceDesc": @"source_desc",
    
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

@implementation FHFeedContentShareInfoWeixinCoverImageModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"urlList": @"url_list",
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

@implementation FHFeedContentMiddleImageModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"urlList": @"url_list",
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

@implementation FHFeedContentImageListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"urlList": @"url_list",
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

@implementation FHFeedContentFilterWordsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"isSelected": @"is_selected",
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

@implementation FHFeedContentActionListExtraModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentShareInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"weixinCoverImage": @"weixin_cover_image",
    @"shareType": @"share_type",
    @"shareUrl": @"share_url",
    @"tokenType": @"token_type",
    @"coverImage": @"cover_image",
    @"onSuppress": @"on_suppress",
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

@implementation FHFeedContentUserInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"followerCount": @"follower_count",
    @"liveInfoType": @"live_info_type",
    @"avatarUrl": @"avatar_url",
    @"userId": @"user_id",
    @"userVerified": @"user_verified",
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

