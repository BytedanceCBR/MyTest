//GENERATED CODE , DON'T EDIT
#import "FHFeedContentModel.h"

@implementation FHFeedContentRecommendSocialGroupListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"contentCount": @"content_count",
                           @"countText": @"count_text",
                           @"socialGroupName": @"social_group_name",
                           @"suggestReason": @"suggest_reason",
                           @"socialGroupId": @"social_group_id",
                           @"hasFollow": @"has_follow",
                           @"followerCount": @"follower_count",
                           @"logPb": @"log_pb",
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

@implementation FHFeedContentCommunityModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"socialGroupId": @"social_group_id",
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
    @"largeImageList": @"large_image_list",
    @"readCount": @"read_count",
    @"isSubject": @"is_subject",
    @"articleType": @"article_type",
    @"publishTime": @"publish_time",
    @"shareUrl": @"share_url",
    @"hasM3u8Video": @"has_m3u8_video",
    @"hasMp4Video": @"has_mp4_video",
    @"diggCount": @"digg_count",
    @"userDigg": @"user_digg",
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
    @"recommendSocialGroupList": @"recommend_social_group_list",
    @"rawData": @"raw_data",
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

@implementation FHFeedContentRawDataContentModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"defaultLines": @"default_lines",
                           @"imageType": @"image_type",
                           @"commentSchema": @"comment_schema",
                           @"maxLines": @"max_lines",
                           @"filterWords": @"filter_words",
                           @"recommendReason": @"recommend_reason",
                           @"layoutType": @"layout_type",
                           @"repostParams": @"repost_params",
                           @"jumpType": @"jump_type",
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

@implementation FHFeedContentRawDataContentQuestionAnswerUserListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"userId": @"user_id",
                           @"isVerify": @"is_verify",
                           @"userSchema": @"user_schema",
                           @"avatarUrl": @"avatar_url",
                           @"isFollowing": @"is_following",
                           @"vIcon": @"v_icon",
                           @"userAuthInfo": @"user_auth_info",
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

@implementation FHFeedContentRawDataContentAnswerModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"answerType": @"answer_type",
                           @"answerDetailSchema": @"answer_detail_schema",
                           @"abstractText": @"abstract_text",
                           @"forwardCount": @"forward_count",
                           @"diggCount": @"digg_count",
                           @"videoType": @"video_type",
                           @"commentCount": @"comment_count",
                           @"createTime": @"create_time",
                           @"thumbImageList": @"thumb_image_list",
                           @"largeImageList": @"large_image_list",
                           @"browCount": @"brow_count",
                           @"isDigg": @"is_digg",
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

@implementation FHFeedContentRawDataContentRepostParamsModel
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

@implementation FHFeedContentRawDataContentQuestionModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"answerUserList": @"answer_user_list",
                           @"isAnonymous": @"is_anonymous",
                           @"followCount": @"follow_count",
                           @"niceAnsCount": @"nice_ans_count",
                           @"answerCountDescription": @"answer_count_description",
                           @"isQuestionDelete": @"is_question_delete",
                           @"writeAnswerSchema": @"write_answer_schema",
                           @"createTime": @"create_time",
                           @"questionListSchema": @"question_list_schema",
                           @"normalAnsCount": @"normal_ans_count",
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

@implementation FHFeedContentRawDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"itemId": @"item_id",
                           @"groupId": @"group_id",
                           @"commentBase": @"comment_base",
                           @"originGroup": @"origin_group",
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

@implementation FHFeedContentRawDataContentFilterWordsModel
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

@implementation FHFeedContentRawDataContentQuestionContentModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"thumbImageList": @"thumb_image_list",
                           @"largeImageList": @"large_image_list",
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

@implementation FHFeedContentRawDataContentUserModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"userId": @"user_id",
                           @"isVerify": @"is_verify",
                           @"userSchema": @"user_schema",
                           @"avatarUrl": @"avatar_url",
                           @"isFollowing": @"is_following",
                           @"vIcon": @"v_icon",
                           @"userAuthInfo": @"user_auth_info",
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

@implementation FHFeedContentRawDataOriginGroupModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"groupIdStr": @"group_id_str",
                           @"hasVideo": @"has_video",
                           @"titleRichSpan": @"title_rich_span",
                           @"itemId": @"item_id",
                           @"articleUrl": @"article_url",
                           @"itemIdStr": @"item_id_str",
                           @"groupId": @"group_id",
                           @"middleImage": @"middle_image",
                           @"aggrType": @"aggr_type",
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

@implementation FHFeedContentRawDataCommentBaseModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"contentDecoration": @"content_decoration",
                           @"richContent": @"rich_content",
                           @"detailSchema": @"detail_schema",
                           @"commentSchema": @"comment_schema",
                           @"contentRichSpan": @"content_rich_span",
                           @"createTime": @"create_time",
                           @"groupSource": @"group_source",
                           @"itemId": @"item_id",
                           @"groupId": @"group_id",
                           @"repostStatus": @"repost_status",
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

