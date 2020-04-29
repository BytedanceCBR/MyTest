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
                           @"name": @"social_group_name",
                           @"url": @"announcement_url",
                           @"socialGroupId": @"social_group_id",
                           @"showStatus": @"show_status",
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
    @"cellCtrls": @"cell_ctrls",
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
    @"articleSchema": @"article_schema",
    @"videoId": @"video_id",
    @"videoDetailInfo": @"video_detail_info",
    @"playAuthToken": @"play_auth_token",
    @"groupFlags": @"group_flags",
    @"debugInfo": @"debug_info",
    @"banImmersive": @"ban_immersive",
    @"videoDuration": @"video_duration",
    @"videoProportionArticle": @"video_proportion_article",
    @"playBizToken": @"play_biz_token",
    @"danmakuCount": @"danmaku_count",
    @"isStick": @"is_stick",
    @"stickStyle": @"stick_style",
    @"originType": @"origin_type",
    @"subRawDatas": @"sub_raw_datas"
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
                           @"originCommonContent": @"origin_common_content",
                           @"recommendSocialGroupList": @"recommend_social_group_list",
                           @"articleSchema": @"article_schema",
                           @"hotTopicList": @"hot_topic_list",
                           
                           @"firstFrameImageList": @"first_frame_image_list",
                           @"detailSchema": @"detail_schema",
                           @"titleRichSpan": @"title_rich_span",
                           @"createTime": @"create_time",
                           @"videoContent": @"video_content",
                           @"isStick": @"is_stick",
                           @"stickStyle": @"stick_style",
                           @"contentDecoration": @"content_decoration",
                           @"originThread": @"origin_thread",
                           @"originUgcVideo": @"origin_ugc_video",
                           @"originType": @"origin_type",
                           @"voteInfo": @"vote_info",
                           @"logPb":@"log_pb",
                           @"commentCount":@"comment_count",
                           @"diggCount":@"digg_count",
                           @"readCount":@"read_count",
                           @"userDigg":@"is_digg",
                           @"distanceInfo":@"distance_info",
                           @"subCellType": @"sub_cell_type",
                           @"hotCellList": @"hot_cell_list",
                           @"cardFooter": @"card_footer",
                           @"cardHeader": @"card_header",
                           @"hotSocialList":@"hot_social_list",
                           @"articleTitle":@"article_title",
                           @"userName":@"user_name",
                            @"allSchema":@"all_schema",
                           @"upSpace":@"up_space",
                           @"downSpace":@"down_space",
                           @"hidelLine":@"hide_line"
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
                           @"imageList": @"image_list",
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

@implementation FHFeedContentRawDataOriginCommonContentModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"richTitle": @"rich_title",
                           @"businessPayload": @"business_payload",
                           @"titleRichSpan": @"title_rich_span",
                           @"hasVideo": @"has_video",
                           @"coverImage": @"cover_image",
                           @"groupIdStr": @"group_id_str",
                           @"groupId": @"group_id",
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

@implementation FHFeedContentRawDataCommentBaseActionModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"readCount": @"read_count",
                           @"userBury": @"user_bury",
                           @"buryCount": @"bury_count",
                           @"forwardCount": @"forward_count",
                           @"diggCount": @"digg_count",
                           @"playCount": @"play_count",
                           @"commentCount": @"comment_count",
                           @"userRepin": @"user_repin",
                           @"shareCount": @"share_count",
                           @"userDigg": @"user_digg",
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

@implementation FHFeedContentRawDataOriginCommonContentUserModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentRawDataCommentBaseUserInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"originUserId": @"origin_user_id",
                           @"mediaId": @"media_id",
                           @"banStatus": @"ban_status",
                           @"originProfileUrl": @"origin_profile_url",
                           @"userDecoration": @"user_decoration",
                           @"realName": @"real_name",
                           @"verifiedContent": @"verified_content",
                           @"avatarUrl": @"avatar_url",
                           @"userId": @"user_id",
                           @"liveInfoType": @"live_info_type",
                           @"userVerified": @"user_verified",
                           @"roomSchema": @"room_schema",
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

@implementation FHFeedContentRawDataOriginCommonContentUserInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"originUserId": @"origin_user_id",
                           @"mediaId": @"media_id",
                           @"banStatus": @"ban_status",
                           @"originProfileUrl": @"origin_profile_url",
                           @"userDecoration": @"user_decoration",
                           @"realName": @"real_name",
                           @"verifiedContent": @"verified_content",
                           @"avatarUrl": @"avatar_url",
                           @"userId": @"user_id",
                           @"liveInfoType": @"live_info_type",
                           @"userVerified": @"user_verified",
                           @"roomSchema": @"room_schema",
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

@implementation FHFeedContentRawDataCommentBaseUserBlockModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isBlocking": @"is_blocking",
                           @"isBlocked": @"is_blocked",
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

@implementation FHFeedContentRawDataCommentBaseUserModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentRawDataContentExtraModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"answerCount": @"answer_count",
                           @"articleSchema": @"article_schema",
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

@implementation FHFeedContentRawDataOperationModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"imageList": @"image_list",
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

@implementation FHFeedContentRawDataHotTopicListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"forumName": @"forum_name",
                           @"concernId": @"concern_id",
                           @"forumId": @"forum_id",
                           @"avatarUrl": @"avatar_url",
                           @"talkCountStr": @"talk_count_str",
                           @"talkCount": @"talk_count",
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

@implementation FHFeedContentRawDataVoteModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"needUserLogin": @"need_user_login",
                           @"rightName": @"right_name",
                           @"leftValue": @"left_value",
                           @"leftName": @"left_name",
                           @"voteId": @"vote_id",
                           @"rightValue": @"right_value",
                           @"personDesc": @"person_desc",
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

@implementation FHFeedContentRawDataVideoOriginCoverModel
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

@implementation FHFeedContentRawDataVideoPlayAddrModel
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

@implementation FHFeedContentRawDataVideoDownloadAddrModel
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

@implementation FHFeedContentRawDataVideoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"playAddr": @"play_addr",
                           @"videoId": @"video_id",
                           @"originCover": @"origin_cover",
                           @"downloadAddr": @"download_addr",
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

@implementation FHFeedContentVideoDetailInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"groupFlags": @"group_flags",
                           @"videoId": @"video_id",
                           @"videoType": @"video_type",
                           @"videoWatchingCount": @"video_watching_count",
                           @"videoPreloadingFlag": @"video_preloading_flag",
                           @"directPlay": @"direct_play",
                           @"detailVideoLargeImage": @"detail_video_large_image",
                           @"showPgcSubscribe": @"show_pgc_subscribe",
                           @"videoWatchCount": @"video_watch_count",
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

@implementation FHFeedContentRawDataOriginThreadModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"readCount": @"read_count",
    @"defaultTextLine": @"default_text_line",
    @"stickStyle": @"stick_style",
    @"createTime": @"create_time",
    @"shareUrl": @"share_url",
    @"videoGroup": @"video_group",
    @"detailCoverList": @"detail_cover_list",
    @"userVerified": @"user_verified",
    @"cellLayoutStyle": @"cell_layout_style",
    @"maxTextLine": @"max_text_line",
    @"businessPayload": @"business_payload",
    @"innerUiFlag": @"inner_ui_flag",
    @"contentRichSpan": @"content_rich_span",
    @"commentCount": @"comment_count",
    @"ugcU13CutImageList": @"ugc_u13_cut_image_list",
    @"threadIdStr": @"thread_id_str",
    @"diggIconKey": @"digg_icon_key",
    @"uiType": @"ui_type",
    @"followButtonStyle": @"follow_button_style",
    @"cellType": @"cell_type",
    @"verifiedContent": @"verified_content",
    @"isStick": @"is_stick",
    @"userDigg": @"user_digg",
    @"ugcCutImageList": @"ugc_cut_image_list",
    @"cellFlag": @"cell_flag",
    @"cellUiType": @"cell_ui_type",
    @"diggCount": @"digg_count",
    @"threadId": @"thread_id",
    @"thumbImageList": @"thumb_image_list",
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

@implementation FHFeedContentRawDataOriginUgcVideoRawDataUserModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"relationCount": @"relation_count",
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

@implementation FHFeedContentRawDataOriginUgcVideoRawDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"groupIdStr": @"group_id_str",
    @"textCommentCount": @"text_comment_count",
    @"detailSchema": @"detail_schema",
    @"titleRichSpan": @"title_rich_span",
    @"voiceCommentEnable": @"voice_comment_enable",
    @"voiceCommentCount": @"voice_comment_count",
    @"createTime": @"create_time",
    @"thumbImageList": @"thumb_image_list",
    @"largeImageList": @"large_image_list",
    @"groupSource": @"group_source",
    @"itemId": @"item_id",
    @"groupId": @"group_id",
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

@implementation FHFeedContentRawDataOriginUgcVideoRawDataUserRelationCountModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"followersCount": @"followers_count",
    @"followingsCount": @"followings_count",
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

@implementation FHFeedContentRawDataOriginUgcVideoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"cellType": @"cell_type",
    @"dataType": @"data_type",
    @"rawData": @"raw_data",
    @"showOrigin": @"show_origin",
    @"idStr": @"id_str",
    @"showTips": @"show_tips",
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

@implementation FHFeedContentRawDataOriginUgcVideoRawDataUserInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"userId": @"user_id",
    @"userDecoration": @"user_decoration",
    @"verifiedContent": @"verified_content",
    @"avatarUrl": @"avatar_url",
    @"userVerified": @"user_verified",
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

@implementation FHFeedContentRawDataHotCellListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"hotCellType": @"hot_cell_type",
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

@implementation FHFeedContentRawDataHotCellListTipsModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedContentCellCtrlsModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"cellFlag": @"cell_flag",
                           @"cellHeight": @"cell_height",
                           @"cellLayoutStyle": @"cell_layout_style",
                           @"needClientImprRecycle": @"need_client_impr_recycle",
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

@implementation FHFeedContentRawDataCardFooterModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"footerLayoutStyle": @"footer_layout_style",
    @"nightIcon": @"night_icon",
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

@implementation FHFeedContentRawDataCardHeaderModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"headerLayoutStyle": @"header_layout_style",
    @"publisherText": @"publisher_text",
    @"relatedForum": @"related_forum",
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

@implementation FHFeedContentRawDataCardHeaderRelatedForumModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"concernId": @"concern_id",
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

