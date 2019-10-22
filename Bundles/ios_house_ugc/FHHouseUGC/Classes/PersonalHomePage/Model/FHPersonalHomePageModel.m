//GENERATED CODE , DON'T EDIT
#import "FHPersonalHomePageModel.h"
@implementation FHPersonalHomePageDataTopTabModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"isDefault": @"is_default",
    @"showName": @"show_name",
    @"disableCommonParams": @"disable_common_params",
    @"isNative": @"is_native",
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

@implementation FHPersonalHomePageDataFollowersDetailModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"fansCount": @"fans_count",
    @"openUrl": @"open_url",
    @"appName": @"app_name",
    @"packageName": @"package_name",
    @"downloadUrl": @"download_url",
    @"appleId": @"apple_id",
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

@implementation FHPersonalHomePageModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"dErrno": @"errno",
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

@implementation FHPersonalHomePageDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"isFollowed": @"is_followed",
    @"currentUserId": @"current_user_id",
    @"followersDetail": @"followers_detail",
    @"fCommentCount": @"f_comment_count",
    @"articleLimitEnable": @"article_limit_enable",
    @"verifiedAgency": @"verified_agency",
    @"privateLetterPermission": @"private_letter_permission",
    @"followingsCount": @"followings_count",
    @"pgcLikeCount": @"pgc_like_count",
    @"publishCount": @"publish_count",
    @"topTab": @"top_tab",
    @"isBlocking": @"is_blocking",
    @"userId": @"user_id",
    @"hasSponsor": @"has_sponsor",
    @"userDecoration": @"user_decoration",
    @"noDisplayPgcIcon": @"no_display_pgc_icon",
    @"applyAuthEntryTitle": @"apply_auth_entry_title",
    @"shareUrl": @"share_url",
    @"ugcPublishMediaId": @"ugc_publish_media_id",
    @"showPrivateLetter": @"show_private_letter",
    @"followersCount": @"followers_count",
    @"applyAuthUrl": @"apply_auth_url",
    @"mediaType": @"media_type",
    @"hideFollowCount": @"hide_follow_count",
    @"mediaId": @"media_id",
    @"forumFollowingCount": @"forum_following_count",
    @"fFollowSgCount": @"f_follow_sg_count",
    @"mplatformFollowersCount": @"mplatform_followers_count",
    @"verifiedContent": @"verified_content",
    @"followRecommendBarHeight": @"follow_recommend_bar_height",
    @"isBlocked": @"is_blocked",
    @"userAuthInfo": @"user_auth_info",
    @"screenName": @"screen_name",
    @"bigAvatarUrl": @"big_avatar_url",
    @"logId": @"log_id",
    @"flipchatInvite": @"flipchat_invite",
    @"diggCount": @"digg_count",
    @"sponsorUrl": @"sponsor_url",
    @"fDiggCount": @"f_digg_count",
    @"avatarUrl": @"avatar_url",
    @"isFollowing": @"is_following",
    @"fHomepageAuth": @"f_homepage_auth",
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

