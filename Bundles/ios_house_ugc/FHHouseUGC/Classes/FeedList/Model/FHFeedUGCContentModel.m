//GENERATED CODE , DON'T EDIT
#import "FHFeedUGCContentModel.h"
@implementation FHFeedUGCContentCommunityModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"socialGroupId": @"social_group_id",
                           @"name": @"social_group_name",
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

@implementation FHFeedUGCContentRepostParamsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"optId": @"opt_id",
    @"fwIdType": @"fw_id_type",
    @"fwId": @"fw_id",
    @"fwNativeSchema": @"fw_native_schema",
    @"coverUrl": @"cover_url",
    @"hasVideo": @"has_video",
    @"optIdType": @"opt_id_type",
    @"repostType": @"repost_type",
    @"fwUserId": @"fw_user_id",
    @"fwShareUrl": @"fw_share_url",
    @"titleRichSpan": @"title_rich_span",
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

@implementation FHFeedUGCContentLargeImageListModel
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

@implementation FHFeedUGCContentShareModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"shareWeiboDesc": @"share_weibo_desc",
    @"shareTitle": @"share_title",
    @"shareDesc": @"share_desc",
    @"shareUrl": @"share_url",
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

@implementation FHFeedUGCContentDetailCoverListModel
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

@implementation FHFeedUGCContentUgcU13CutImageListModel
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

@implementation FHFeedUGCContentLargeImageListUrlListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentUgcU13CutImageListUrlListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentShareShareCoverModel
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

@implementation FHFeedUGCContentUserModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"isFollowed": @"is_followed",
    @"isBlocking": @"is_blocking",
    @"userId": @"user_id",
    @"screenName": @"screen_name",
    @"isFriend": @"is_friend",
    @"userDecoration": @"user_decoration",
    @"remarkName": @"remark_name",
    @"verifiedContent": @"verified_content",
    @"avatarUrl": @"avatar_url",
    @"isFollowing": @"is_following",
    @"liveInfoType": @"live_info_type",
    @"isBlocked": @"is_blocked",
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

@implementation FHFeedUGCContentRawDataModel
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
                           @"contentRichSpan": @"content_rich_span",
                           @"ugcU13CutImageList":@"ugc_u13_cut_image_list",
                           @"thumbImageList":@"thumb_image_list",
                           @"largeImageList":@"large_image_list",
                           @"threadId":@"thread_id",
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

@implementation FHFeedUGCContentActionListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentThumbImageListModel
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

@implementation FHFeedUGCContentModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"logPb": @"log_pb",
    @"contentDecoration": @"content_decoration",
    @"hasM3u8Video": @"has_m3u8_video",
    @"banComment": @"ban_comment",
    @"contentRichSpan": @"content_rich_span",
    @"readCount": @"read_count",
    @"isSubject": @"is_subject",
    @"threadId": @"thread_id",
    @"createTime": @"create_time",
    @"forwardInfo": @"forward_info",
    @"videoGroup": @"video_group",
    @"detailCoverList": @"detail_cover_list",
    @"hasMp4Video": @"has_mp4_video",
    @"cellLayoutStyle": @"cell_layout_style",
    @"articleSubType": @"article_sub_type",
    @"businessPayload": @"business_payload",
    @"buryCount": @"bury_count",
    @"innerUiFlag": @"inner_ui_flag",
    @"ignoreWebTransform": @"ignore_web_transform",
    @"hasVideo": @"has_video",
    @"shareUrl": @"share_url",
    @"showPortraitArticle": @"show_portrait_article",
    @"tinyToutiaoUrl": @"tiny_toutiao_url",
    @"commentCount": @"comment_count",
    @"hasEdit": @"has_edit",
    @"filterWords": @"filter_words",
    @"ugcU13CutImageList": @"ugc_u13_cut_image_list",
    @"groupSource": @"group_source",
    @"allowDownload": @"allow_download",
    @"shareCount": @"share_count",
    @"threadIdStr": @"thread_id_str",
    @"uiType": @"ui_type",
    @"showDislike": @"show_dislike",
    @"actionList": @"action_list",
    @"followButtonStyle": @"follow_button_style",
    @"richContent": @"rich_content",
    @"shareInfo": @"share_info",
    @"interactionData": @"interaction_data",
    @"cellType": @"cell_type",
    @"brandInfo": @"brand_info",
    @"defaultTextLine": @"default_text_line",
    @"itemVersion": @"item_version",
    @"verifiedContent": @"verified_content",
    @"thumbImageList": @"thumb_image_list",
    @"largeImageList": @"large_image_list",
    @"maxTextLine": @"max_text_line",
    @"userDigg": @"user_digg",
    @"ugcCutImageList": @"ugc_cut_image_list",
    @"showPortrait": @"show_portrait",
    @"commentSchema": @"comment_schema",
    @"articleType": @"article_type",
    @"cellFlag": @"cell_flag",
    @"cellUiType": @"cell_ui_type",
    @"needClientImprRecycle": @"need_client_impr_recycle",
    @"userVerified": @"user_verified",
    @"diggCount": @"digg_count",
    @"behotTime": @"behot_time",
    @"repostParams": @"repost_params",
    @"communityInfo": @"community_info",
    @"userRepin": @"user_repin",
    @"videoStyle": @"video_style",
    @"diggIconKey": @"digg_icon_key",
    @"ugcRecommend": @"ugc_recommend",
    @"distanceInfo": @"distance_info",
    @"ugcStatus": @"status",
    @"isStick": @"is_stick",
    @"stickStyle": @"stick_style",
    @"rawData": @"raw_data",
    @"threadId": @"thread_id_str",
    @"attachCardInfo": @"attach_card_info",
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

@implementation FHFeedUGCContentForwardInfoModel
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

@implementation FHFeedUGCContentShareInfoShareTypeModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentFilterWordsModel
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

@implementation FHFeedUGCContentActionListExtraModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentShareInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"tokenType": @"token_type",
    @"coverImage": @"cover_image",
    @"weixinCoverImage": @"weixin_cover_image",
    @"shareUrl": @"share_url",
    @"shareType": @"share_type",
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

@implementation FHFeedUGCContentForumModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"onlookersCount": @"onlookers_count",
    @"bannerUrl": @"banner_url",
    @"forumName": @"forum_name",
    @"forumId": @"forum_id",
    @"shareUrl": @"share_url",
    @"avatarUrl": @"avatar_url",
    @"showEtStatus": @"show_et_status",
    @"followerCount": @"follower_count",
    @"talkCount": @"talk_count",
    @"participantCount": @"participant_count",
    @"introdutionUrl": @"introdution_url",
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

@implementation FHFeedUGCContentThumbImageListUrlListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentUgcCutImageListModel
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

@implementation FHFeedUGCContentPositionModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentDetailCoverListUrlListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentUgcCutImageListUrlListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentUgcRecommendModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentAttachCardInfoButtonModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFeedUGCContentAttachCardInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"cardType": @"card_type",
    @"coverImage": @"cover_image",
    @"cardStyle": @"card_style",
    @"desc": @"description",
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

@implementation FHFeedUGCContentAttachCardInfoCoverImageModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"imageStyle": @"image_style",
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

@implementation FHFeedUGCContentAttachCardInfoExtraModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"houseType": @"house_type",
    @"fromGid": @"from_gid",
    @"imprId": @"impr_id",
    @"groupId": @"group_id",
    @"groupSource": @"group_source",
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

