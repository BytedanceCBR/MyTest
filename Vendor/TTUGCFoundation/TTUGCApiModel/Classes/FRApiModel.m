#import "FRApiModel.h"
@implementation FRApiRequestModel
- (instancetype) init {
    self = [super init];
    if (self) {
        self._uri = @"";
        self._response = @"";
        self._isGet = NO;
    }

    return self;
}
@end

@implementation FRApiResponseModel
- (instancetype) init {
    self = [super init];
    if (self) {
        self.error = 0;
    }

    return self;
}
@end

@implementation FRGroupStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.group_id = nil;
    self.title = nil;
    self.thumb_url = nil;
    self.media_type = 0;
    self.open_url = nil;
}
@end

@implementation FRUserRoleStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.role_display_type = 0;
    self.role_name = nil;
}
@end

@implementation FRUserApplyRoleInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.owner_forum_length = nil;
    self.apply_owner_forum_length = nil;
    self.vice_owner_forum_length = nil;
    self.apply_vice_owner_forum_length = nil;
    self.user_to_forum_owner = nil;
    self.user_to_forum_vice_owner = nil;
}
@end

@implementation FRForumRoleInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.moderator_users_length = nil;
    self.vice_moderator_users_length = nil;
}
@end

@implementation FRUserStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.is_friend = nil;
    self.is_blocked = nil;
    self.is_blocking = nil;
    self.avatar_url = nil;
    self.desc = nil;
    self.user_verified = nil;
    self.screen_name = nil;
    self.user_id = nil;
    self.is_following = nil;
    self.user_role = nil;
    self.verified_content = nil;
    self.user_roles = nil;
    self.user_role_icons = nil;
    self.user_auth_info = nil;
    self.schema = nil;
    self.followers_count = nil;
    self.followings_count = nil;
    self.user_decoration = nil;
}
@end

@implementation FRSimpleUserStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_id = nil;
    self.name = nil;
    self.verified_content = nil;
    self.avatar_url = nil;
    self.follow = nil;
    self.user_verified = nil;
    self.user_auth_info = nil;
}
@end

@implementation FRViceOwnerInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_info = nil;
    self.commit_count = nil;
    self.reply_count = nil;
    self.reason = nil;
    self.apply_time = nil;
}
@end

@implementation FRCommentStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.comment_id = nil;
    self.content = nil;
    self.create_time = nil;
    self.digg_count = nil;
    self.user_digg = 0;
    self.user = nil;
    self.reply_comment = nil;
}
@end

@implementation FRMoMoAdStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.avatar = nil;
    self.url = nil;
    self.ad_id = nil;
    self.name = nil;
    self.sname = nil;
    self.distance = nil;
    self.sign = nil;
    self.gid = nil;
    self.show_ad_tag = nil;
}
@end

@implementation FRInterestItemStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.name = nil;
    self.avatar_url = nil;
    self.open_url = nil;
}
@end

@implementation FRInterestForumStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.reason = nil;
    self.interest_forum_list = nil;
}
@end

@implementation FROpenForumStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum_item = nil;
    self.open_url = nil;
}
@end

@implementation FRRelatedForumStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.reason = nil;
    self.related_forum_list = nil;
}
@end

@implementation FRForumItemStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum_name = nil;
    self.forum_id = nil;
    self.onlookers_count = nil;
    self.avatar_url = nil;
    self.banner_url = nil;
    self.talk_count = nil;
    self.like_time = nil;
    self.forum_hot_header = nil;
    self.schema = nil;
}
@end

@implementation FRForumClassStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.class_name = nil;
    self.forum_list = nil;
}
@end

@implementation FRImageUrlStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.height = nil;
    self.width = nil;
    self.uri = nil;
    self.url = nil;
    self.url_list = nil;
    self.type = nil;
    self.open_url = nil;
}
@end

@implementation FRMagicUrlStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.url = nil;
}
@end

@implementation FRTipsStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.display_info = nil;
    self.display_duration = nil;
    self.click_url = nil;
}
@end

@implementation FRTabStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.table_type = 0;
    self.name = nil;
    self.url = nil;
    self.need_common_params = 0;
    self.refresh_interval = nil;
    self.extra = nil;
}
@end

@implementation FRTabExtraStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.umeng_name = nil;
    self.query_dict = nil;
    self.rn_info = nil;
}
@end

@implementation FRTabRNInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.module_name = nil;
    self.bundle_url = nil;
    self.version = nil;
    self.props = nil;
    self.md5 = nil;
    self.rn_min_version = nil;
}
@end

@implementation FRCommentBrowStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.thread_id = nil;
    self.has_more = 0;
    self.offset = nil;
    self.total_count = nil;
    self.data = nil;
}
@end

@implementation FRUserInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.is_following = 0;
    self.followings_count = nil;
    self.mobile_hash = nil;
    self.avatar_url = nil;
    self.verified_agency = nil;
    self.is_blocking = 0;
    self.user_verified = 0;
    self.reason_type = 0;
    self.is_blocked = 0;
    self.desc = nil;
    self.name = nil;
    self.gender = 0;
    self.screen_name = nil;
    self.user_id = nil;
    self.is_followed = 0;
    self.followers_count = nil;
    self.verified_content = nil;
    self.recommend_reason = nil;
    self.mobile = nil;
    self.user_auth_info = nil;
}
@end

@implementation FRThreadDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.thread_id = nil;
    self.cursor = nil;
    self.reason = nil;
    self.modify_time = nil;
    self.item_type = 0;
    self.comment_count = nil;
    self.talk_type = nil;
    self.digg_count = nil;
    self.digg_limit = nil;
    self.digg_list = nil;
    self.friend_digg_list = nil;
    self.content = nil;
    self.create_time = nil;
    self.share_url = nil;
    self.talk_item = nil;
    self.large_image_list = nil;
    self.thumb_image_list = nil;
    self.group = nil;
    self.origin_item = nil;
    self.user = nil;
    self.comments = nil;
    self.user_digg = 0;
    self.show_comments_num = nil;
    self.user_comment = nil;
    self.position = nil;
    self.rate = nil;
    self.status = nil;
    self.omitted_content = nil;
    self.time_desc = nil;
    self.title = nil;
    self.phone = nil;
    self.score = nil;
    self.user_repin = nil;
    self.forward_info = nil;
    self.repost_params = nil;
    self.brand_info = nil;
    self.forum_id = nil;
    self.content_rich_span = nil;
    self.flags = nil;
    self.read_count = nil;
    self.show_origin = nil;
    self.show_tips = nil;
    self.forward_num = nil;
}
@end

@implementation FRGeneralThreadStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.thread = nil;
    self.momo_ad = nil;
    self.interest_forum = nil;
    self.related_forum = nil;
}
@end

@implementation FRForumBannerStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum_info = nil;
    self.banner_imglist = nil;
    self.banner_header_name = nil;
    self.jump_url = nil;
}
@end

@implementation FRMessageListStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.has_more = 0;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.data = nil;
}
@end

@implementation FRMessageListUserInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_verified = 0;
    self.user_id = nil;
    self.avatar_url = nil;
    self.screen_name = nil;
    self.user_auth_info = nil;
    self.schema = nil;
    self.verified_content = nil;
}
@end

@implementation FRMessageListDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.group = nil;
    self.cursor = nil;
    self.create_time = nil;
    self.user = nil;
    self.dongtai_id = nil;
    self.type = nil;
    self.msg_id = nil;
    self.content = nil;
}
@end

@implementation FRMessageListDataGroupStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.title = nil;
    self.thumb_url = nil;
}
@end

@implementation FRForumStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum_id = nil;
    self.forum_name = nil;
    self.desc = nil;
    self.status = nil;
    self.banner_url = nil;
    self.avatar_url = nil;
    self.follower_count = nil;
    self.participant_count = nil;
    self.talk_count = nil;
    self.onlookers_count = nil;
    self.like_time = nil;
    self.share_url = nil;
    self.introdution_url = nil;
    self.show_et_status = nil;
    self.article_count = nil;
    self.forum_type_flags = nil;
    self.schema = nil;
    self.sub_title = nil;
    self.label_style = nil;
    self.icon_style = nil;
    self.concern_id = nil;
}
@end

@implementation FRTagStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.tag_id = nil;
    self.tag_name = nil;
}
@end

@implementation FRForumTagStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.tag_id = nil;
    self.tag_name = nil;
    self.forum_info = nil;
}
@end

@implementation FRButtonListItemStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.appleid = nil;
    self.text = nil;
    self.action_url = nil;
}
@end

@implementation FRDataListItemStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.button_list = nil;
    self.force_update = nil;
    self.content = nil;
    self.latency_seconds = nil;
    self.rule_id = nil;
    self.title = nil;
}
@end

@implementation FRUserCommentSpecialStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.show_content = nil;
    self.comment_id = nil;
}
@end

@implementation FRLoginUserInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_id = nil;
    self.user_perm = nil;
}
@end

@implementation FRGeographyStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.longitude = nil;
    self.latitude = nil;
    self.position = nil;
}
@end

@implementation FRRoleMemberStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_role = nil;
    self.users = nil;
}
@end

@implementation FROwnerApplyHistoryItemStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum = nil;
    self.apply_status = nil;
}
@end

@implementation FROwnerApplyHistorysStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.cursor = nil;
    self.has_more = 0;
    self.history_list = nil;
}
@end

@implementation FROwnerAuditingInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum = nil;
    self.apply_count = nil;
}
@end

@implementation FROwnerHotForumStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum = nil;
    self.is_follow = nil;
}
@end

@implementation FRUserIconStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.icon_url = nil;
    self.action_url = nil;
}
@end

@implementation FROwnerActionStatDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_id = nil;
    self.user_name = nil;
    self.publish_count = nil;
    self.comment_count = nil;
    self.star_count = nil;
    self.delete_count = nil;
}
@end

@implementation FRForumStatDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.data_time = nil;
    self.publish_count = nil;
    self.comment_count = nil;
    self.new_follow_count = 0;
    self.owner_action_stat_data_list = nil;
}
@end

@implementation FRMovieReviewBasicInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.rate = nil;
    self.participant_count = nil;
    self.douban_rate = nil;
    self.imdb_rate = nil;
}
@end

@implementation FRGroupLikeStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.group_id = nil;
    self.schema = nil;
    self.user = nil;
    self.digg_count = nil;
    self.comment_count = nil;
    self.content = nil;
    self.create_time = nil;
    self.title = nil;
    self.action_list = nil;
}
@end

@implementation FRUgcDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.thread_id = nil;
    self.schema = nil;
    self.content = nil;
    self.digg_count = nil;
    self.comment_count = nil;
    self.max_text_line = nil;
    self.ui_type = nil;
    self.share_url = nil;
    self.inner_ui_flag = nil;
    self.large_image_list = nil;
    self.thumb_image_list = nil;
    self.user = nil;
    self.friend_digg_list = nil;
    self.comments = nil;
    self.action_list = nil;
    self.user_digg = nil;
    self.title = nil;
    self.forum = nil;
    self.group = nil;
    self.position = nil;
    self.score = nil;
    self.behot_time = nil;
    self.cursor = nil;
    self.cell_type = nil;
    self.title_tags = nil;
    self.content_tags = nil;
    self.cell_flag = nil;
    self.cell_layout_style = nil;
    self.is_stick = nil;
    self.stick_style = nil;
    self.stick_label = nil;
    self.label = nil;
    self.reason = nil;
    self.content_rich_span = nil;
    self.origin_thread = nil;
    self.origin_group = nil;
    self.origin_ugc_video = nil;
    self.repost_type = nil;
    self.status = nil;
    self.create_time = nil;
    self.forward_info = nil;
    self.default_text_line = nil;
    self.ugc_cut_image_list = nil;
    self.read_count = nil;
    self.brand_info = nil;
    self.content_decoration = nil;
}
@end

@implementation FRActionStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.action = nil;
    self.desc = nil;
}
@end

@implementation FRGroupInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.source = nil;
    self.title = nil;
    self.open_url = nil;
    self.behot_time = nil;
    self.tip = nil;
    self.image_list = nil;
    self.city = nil;
    self.large_image_list = nil;
    self.middle_image = nil;
    self.detail_video_large_image = nil;
    self.comment = nil;
    self.ban_comment = nil;
    self.article_type = nil;
    self.article_sub_type = nil;
    self.preload_web = nil;
    self.display_url = nil;
    self.display_title = nil;
    self.item_version = nil;
    self.label = nil;
    self.subject_group_id = nil;
    self.natant_level = nil;
    self.group_flags = nil;
    self.tc_head_text = nil;
    self.label_style = nil;
    self.info_desc = nil;
    self.reback_flag = nil;
    self.video_style = nil;
    self.video_id = nil;
    self.reason = nil;
    self.video_duration = nil;
    self.stick_label = nil;
    self.stick_style = nil;
    self.source_avatar = nil;
    self.source_open_url = nil;
    self.source_desc = nil;
    self.source_desc_open_url = nil;
    self.source_icon_style = nil;
    self.is_subscribe = nil;
    self.action_list = nil;
    self.cell_flag = nil;
    self.like_count = nil;
    self.comment_count = nil;
    self.abstract = nil;
    self.group_id = nil;
    self.item_id = nil;
    self.aggr_type = nil;
    self.cell_type = nil;
    self.media_info = nil;
    self.user_like = nil;
    self.share_url = nil;
    self.bury_count = nil;
    self.ignore_web_transform = nil;
    self.user_info = nil;
    self.digg_count = nil;
    self.read_count = nil;
    self.has_video = nil;
    self.keywords = nil;
    self.article_url = nil;
    self.has_m3u8_video = nil;
    self.has_mp4_video = nil;
    self.schema = nil;
    self.article_deleted = nil;
    self.show_origin = nil;
    self.show_tips = nil;
}
+ (JSONKeyMapper *)keyMapper {
    JSONKeyMapper * keyMapper = [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqualToString:@"delete"]) {
            return @"article_deleted";
        }else {
            return keyName;
        }
    } modelToJSONBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqualToString:@"article_deleted"]) {
            return @"delete";
        }else {
            return keyName;
        }
    }];
    return keyMapper;
}
@end

@implementation FRMediaInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.avatar_url = nil;
    self.media_id = nil;
    self.name = nil;
    self.user_verified = nil;
    self.user_auth_info = nil;
}
@end

@implementation FRNormalThreadStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.has_more = 0;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.finfo_list = nil;
    self.table = nil;
    self.login_user_info = nil;
    self.top_thread = nil;
    self.tips = nil;
}
@end

@implementation FRMovieStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.name = nil;
    self.english_name = nil;
    self.type = nil;
    self.area_info = nil;
    self.actors = nil;
    self.rate = nil;
    self.days = nil;
    self.image_url = nil;
    self.movie_id = nil;
    self.concern_id = nil;
    self.channel_id = nil;
    self.actor_url = nil;
    self.info_url = nil;
    self.uniqueID = nil;
    self.group_flags = nil;
    self.purchase_url = nil;
    self.rate_user_count = nil;
}
@end

@implementation FRUserPositionStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.start = nil;
    self.end = nil;
    self.schema = nil;
}
@end

@implementation FRDiscussCommentStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.comment_id = nil;
    self.content = nil;
    self.create_time = nil;
    self.digg_count = nil;
    self.user_digg = 0;
    self.user = nil;
    self.user_position = nil;
}
@end

@implementation FRDiscussCommentBrowStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.thread_id = nil;
    self.has_more = 0;
    self.offset = nil;
    self.total_count = nil;
    self.data = nil;
}
@end

@implementation FRRelatedNewStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.aggr_type = nil;
    self.article_sub_type = nil;
    self.article_type = nil;
    self.article_url = nil;
    self.ban_comment = nil;
    self.behot_time = nil;
    self.bury_count = nil;
    self.comment_count = nil;
    self.digg_count = nil;
    self.display_title = nil;
    self.display_url = nil;
    self.group_id = nil;
    self.has_image = nil;
    self.has_m3u8_video = nil;
    self.has_mp4_video = nil;
    self.has_video = nil;
    self.hot = nil;
    self.image_list = nil;
    self.item_id = nil;
    self.keywords = nil;
    self.level = nil;
    self.media_name = nil;
    self.middle_image = nil;
    self.preload_web = nil;
    self.repin_count = nil;
    self.share_url = nil;
    self.source = nil;
    self.tag = nil;
    self.tag_id = nil;
    self.tip = nil;
    self.url = nil;
    self.is_article = nil;
    self.tags = nil;
}
@end

@implementation FRConcernWordsStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.schema = nil;
    self.word = nil;
}
@end

@implementation FRHashTagPositionStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.start = nil;
    self.end = nil;
    self.schema = nil;
}
@end

@implementation FRConcernForumStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum_id = nil;
    self.forum_name = nil;
    self.show_et_status = nil;
}
@end

@implementation FRConcernTabStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.table_type = 0;
    self.name = nil;
    self.url = nil;
    self.need_common_params = 0;
    self.refresh_interval = nil;
    self.extra = nil;
    self.sole_name = nil;
    self.tab_et_status = nil;
}
@end

@implementation FRConcernItemStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.concern_id = nil;
    self.name = nil;
    self.new_thread_count = 0;
    self.avatar_url = nil;
    self.concern_count = nil;
    self.discuss_count = nil;
    self.newly = nil;
    self.open_url = nil;
    self.concern_time = nil;
    self.managing = nil;
    self.sub_title = nil;
}
@end

@implementation FRConcernStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.name = nil;
    self.avatar_url = nil;
    self.concern_id = nil;
    self.concern_count = nil;
    self.discuss_count = nil;
    self.concern_time = nil;
    self.share_url = nil;
    self.introdution_url = nil;
    self.desc = nil;
    self.type = 0;
    self.extra = nil;
    self.share_data = nil;
    self.read_count = nil;
    self.desc_rich_span = nil;
}
@end

@implementation FRShareStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.title = nil;
    self.content = nil;
    self.image_url = nil;
    self.share_url = nil;
}
@end

@implementation FRConcernForTagStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.concern_id = nil;
    self.name = nil;
    self.avatar_url = nil;
    self.concern_count = nil;
    self.discuss_count = nil;
    self.concern_time = nil;
    self.desc = nil;
    self.status = nil;
}
@end

@implementation FRConcernTagStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.tag_id = nil;
    self.tag_name = nil;
    self.concern_info = nil;
}
@end

@implementation FRRecommendTagStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.tag_name = nil;
    self.count = nil;
    self.has_more = nil;
    self.concern_info = nil;
}
@end

@implementation FRThreadListStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.tips = nil;
    self.has_more = 0;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.threads = nil;
}
@end

@implementation FRPublisherPermissionIntroStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.normal_intro = nil;
    self.video_intro_tips = nil;
    self.video_intro_tips_text = nil;
    self.redpack = nil;
}
@end

@implementation FRPublisherPermissionStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.post_ugc_status = nil;
    self.ban_status = nil;
    self.ban_tips = nil;
    self.post_message_content_hint = nil;
    self.show_et_status = nil;
    self.first_tips = nil;
    self.publish_entrance_style = nil;
    self.disable_entrance = nil;
    self.show_wenda = nil;
    self.show_author_delete_entrance = nil;
    self.main_publisher_type = nil;
    self.video_intro = nil;
}
@end

@implementation FRUgcVideoDetailInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.group_flags = nil;
    self.video_id = nil;
    self.video_preloading_flag = nil;
    self.direct_play = nil;
    self.detail_video_large_image = nil;
    self.show_pgc_subscribe = nil;
}
@end

@implementation FRUgcVideoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.video_detail_info = nil;
    self.article_type = nil;
    self.publish_time = nil;
    self.video_duration = nil;
    self.video_proportion = nil;
    self.cell_type = nil;
    self.title = nil;
    self.has_video = nil;
    self.show_portrait_article = nil;
    self.user_info = nil;
    self.source_open_url = nil;
    self.group_flags = nil;
    self.video_source = nil;
    self.video_proportion_article = nil;
    self.cell_layout_style = nil;
    self.large_image_list = nil;
    self.item_id = nil;
    self.show_portrait = nil;
    self.display_url = nil;
    self.cell_flag = nil;
    self.video_id = nil;
    self.is_subscribe = nil;
    self.source = nil;
    self.video_style = nil;
    self.media_info = nil;
    self.group_id = nil;
}
@end

@implementation FRCommentTabInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.tabs = @[];
    self.current_tab_index = nil;
}
@end

@implementation FRNewCommentReplyStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.id = nil;
    self.user_id = nil;
    self.user_name = nil;
    self.text = nil;
    self.user_verified = nil;
    self.is_pgc_author = nil;
    self.author_badge = nil;
    self.user_auth_info = nil;
    self.content_rich_span = nil;
}
@end

@implementation FRNewCommentQutoedStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.id = nil;
    self.user_id = nil;
    self.user_name = nil;
    self.text = nil;
    self.content_rich_span = nil;
}
@end

@implementation FRNewCommentStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.is_followed = nil;
    self.text = nil;
    self.reply_count = nil;
    self.is_following = nil;
    self.reply_list = nil;
    self.user_verified = nil;
    self.is_blocking = nil;
    self.user_id = nil;
    self.bury_count = nil;
    self.author_badge = @[];
    self.id = nil;
    self.verified_reason = nil;
    self.platform = nil;
    self.score = nil;
    self.user_name = nil;
    self.user_profile_image_url = nil;
    self.user_bury = nil;
    self.user_digg = nil;
    self.is_blocked = nil;
    self.user_relation = nil;
    self.is_pgc_author = nil;
    self.digg_count = nil;
    self.create_time = nil;
    self.user_auth_info = nil;
    self.reply_to_comment = nil;
    self.bind_mobile = nil;
    self.content_rich_span = nil;
    self.user_decoration = nil;
}
@end

@implementation FRNewCommentDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.comment = nil;
    self.cell_type = nil;
}
@end

@implementation FRDeleteCommentDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.reply_dongtai_id = nil;
    self.dongtai_comment_id = nil;
    self.dongtai_id = nil;
}
@end

@implementation FRRichTextLinkStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.start = nil;
    self.length = nil;
    self.link = nil;
}
@end

@implementation FRRichTextAttributesStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.links = nil;
}
@end

@implementation FRRichTextStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.text = nil;
    self.attributes = nil;
}
@end

@implementation FRColdStartRecommendUserStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_id = nil;
    self.screen_name = nil;
    self.avatar_url = nil;
    self.gender = nil;
    self.desc = nil;
    self.selected = nil;
    self.dongtai_content = nil;
    self.user_type = nil;
    self.name = nil;
    self.create_time = nil;
    self.media_id = nil;
    self.user_verified = nil;
    self.user_auth_info = nil;
}
@end

@implementation FRFollowInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forward_count = nil;
}
@end

@implementation FRPublishConfigStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.type = nil;
    self.name = nil;
    self.schema = nil;
    self.icon = nil;
    self.top_icon = nil;
}
@end

@implementation FRCommonUserStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.info = nil;
    self.relation = nil;
    self.relation_count = nil;
    self.block = nil;
}
@end

@implementation FRCommonUserInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_id = nil;
    self.name = nil;
    self.desc = nil;
    self.schema = nil;
    self.avatar_url = nil;
    self.user_auth_info = nil;
    self.user_verified = nil;
    self.verified_content = nil;
    self.medals = @[];
    self.media_id = nil;
    self.remark_name = nil;
    self.user_decoration = nil;
}
@end

@implementation FRCommonUserRelationStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.is_friend = nil;
    self.is_following = nil;
    self.is_followed = nil;
}
@end

@implementation FRUserRelationCountStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.followings_count = nil;
    self.followers_count = nil;
}
@end

@implementation FRRecommendCardStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user = nil;
    self.recommend_reason = nil;
    self.recommend_type = nil;
    self.activity = nil;
    self.stats_place_holder = nil;
    self.card_type = nil;
    self.profile_user_id = nil;
}
@end

@implementation FRRecommendUserLargeCardStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user = nil;
    self.recommend_reason = nil;
    self.recommend_type = nil;
    self.selected = nil;
    self.stats_place_holder = nil;
}
@end

@implementation FRFollowChannelColdBootUserContainerStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user = nil;
    self.recommend_reason = nil;
    self.selected = nil;
}
@end

@implementation FRFollowChannelColdBootRecommendUserCardStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.type = nil;
    self.user_cards = nil;
    self.selected = nil;
}
@end

@implementation FRUserRelationContactFriendsUserStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_id = nil;
    self.screen_name = nil;
    self.mobile_name = nil;
    self.avatar_url = nil;
    self.user_verified = 0;
    self.user_auth_info = nil;
    self.is_friend = nil;
    self.is_following = nil;
    self.is_followed = nil;
    self.recommend_reason = nil;
}
@end

@implementation FRUserRelationContactFriendsDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.users = nil;
    self.title = nil;
}
@end

@implementation FRUGCVideoUserInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_id = nil;
    self.name = nil;
    self.verified_content = nil;
    self.user_verified = nil;
    self.desc = nil;
    self.schema = nil;
    self.avatar_url = nil;
    self.user_auth_info = nil;
}
@end

@implementation FRUGCVideoUserRelationStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.is_friend = nil;
    self.is_following = nil;
    self.is_followed = nil;
}
@end

@implementation FRUGCVideoUserRelationCountStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.following_count = nil;
    self.follower_count = nil;
}
@end

@implementation FRUGCVideoUserStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.info = nil;
    self.relation = nil;
    self.relation_count = nil;
}
@end

@implementation FRUGCVideoActionStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forward_count = nil;
    self.comment_count = nil;
    self.read_count = nil;
    self.digg_count = nil;
    self.bury_count = nil;
    self.user_digg = nil;
    self.user_repin = nil;
    self.user_bury = nil;
    self.play_count = nil;
}
@end

@implementation FRUGCVideoPublishReasonStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.verb = nil;
    self.noun = nil;
}
@end

@implementation FRUGCVideoRawDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.item_id = nil;
    self.title = nil;
    self.create_time = nil;
    self.app_schema = nil;
    self.detail_schema = nil;
    self.user = nil;
    self.action = nil;
    self.publish_reason = nil;
    self.thumb_image_list = nil;
    self.large_image_list = nil;
}
@end

@implementation FRUGCVideoDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.group_id = nil;
    self.show_tips = nil;
    self.show_origin = nil;
    self.raw_data = nil;
}+(JSONKeyMapper*)keyMapper
{
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id":@"group_id",
                                                       }];
}
@end

@implementation FRRecommendSponsorStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.icon_url = nil;
    self.target_url = nil;
    self.label = nil;
}
@end

@implementation FRRedpackStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.redpack_id = nil;
    self.button_style = nil;
    self.user_info = nil;
    self.subtitle = nil;
    self.content = nil;
    self.token = nil;
}
@end

@implementation FRActivityStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.redpack = nil;
}
@end

@implementation FRUserExpressionConfigStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.default_seq = @[];
}
@end

@implementation FRTextUrlStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.text = nil;
    self.url = nil;
}
@end

@implementation FRBonusStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.bonus_id = nil;
    self.amount = nil;
    self.show_tips = nil;
}
@end

@implementation FRRedpacketOpenResultStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.status_code = nil;
    self.bonus = nil;
    self.reason = nil;
    self.footer = nil;
}
@end

@implementation FRAddFriendsUserWrapperStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user = nil;
    self.show_name = nil;
    self.real_name = nil;
    self.intro = nil;
}
@end

@implementation FRInviteFriendsUserWrapperStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user = nil;
    self.contact_name = nil;
    self.show_name = nil;
    self.is_toutiao_user = nil;
    self.intro = nil;
}
@end

@implementation FRAddFriendsDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.tabs = @[];
    self.source = @[];
    self.server_source = @[];
    self.recommend_users = nil;
    self.has_more = nil;
    self.server_follow = nil;
}
@end

@implementation FRInviteFriendsDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.server_source = @[];
    self.contact_users = nil;
    self.has_more = nil;
}
@end

@implementation FRContactsRedpacketCheckResultStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.status = nil;
    self.redpack_id = nil;
    self.token = nil;
}
@end

@implementation FRContactsRedpacketOpenResultStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.redpack_id = nil;
    self.redpack_amount = nil;
    self.my_redpacks_url = nil;
}
@end

@implementation FRMomentsRecommendUserStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user = nil;
    self.real_name = nil;
    self.fans = nil;
    self.intro = nil;
    self.stats_place_holder = nil;
    self.recommend_type = nil;
    self.selected = nil;
}
@end

@implementation FRActionDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forward_count = nil;
    self.comment_count = nil;
    self.read_count = nil;
    self.digg_count = nil;
    self.bury_count = nil;
    self.user_digg = nil;
    self.user_repin = nil;
    self.user_bury = nil;
    self.play_count = nil;
}
@end

@implementation FRShareInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.share_url = nil;
    self.share_title = nil;
    self.share_desc = nil;
    self.share_weibo_desc = nil;
    self.share_cover = nil;
}
@end

@implementation FRUserBlockedAndBlockingStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.is_blocking = nil;
    self.is_blocked = nil;
}
@end

@implementation FRPublishPostUserInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_id = nil;
    self.name = nil;
    self.desc = nil;
    self.schema = nil;
    self.avatar_url = nil;
    self.user_auth_info = nil;
    self.user_verified = nil;
    self.verified_content = nil;
    self.media_id = nil;
    self.user_decoration = nil;
}
@end

@implementation FRPublishPostUserRelationCountStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.followings_count = nil;
    self.followers_count = nil;
}
@end

@implementation FRPublishPostUserRelationStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.remark_name = nil;
}
@end

@implementation FRPublishPostUserStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.info = nil;
    self.relation = nil;
    self.relation_count = nil;
}
@end

@implementation FRPublishPostUserHighlightStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.name = @[];
    self.remark_name = @[];
}
@end

@implementation FRPublishPostSearchUserStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user = nil;
    self.highlight = nil;
}
@end

@implementation FRPublishPostSearchUserContactStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.offset = nil;
    self.has_more = 0;
    self.recently = nil;
    self.following = nil;
}
@end

@implementation FRPublishPostSearchUserSuggestStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.offset = nil;
    self.has_more = 0;
    self.following = nil;
    self.suggest = nil;
}
@end

@implementation FRRecommendRedpacketDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.id = nil;
    self.amount = nil;
    self.sub_title = nil;
    self.schema = nil;
}
@end

@implementation FRRecommendRedpacketResultStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.redpack = nil;
    self.title = nil;
    self.users = nil;
    self.show_label = nil;
    self.button_text = nil;
    self.button_schema = nil;
}
@end

@implementation FRShareImageUrlStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.uri = nil;
    self.url_list = @[];
}
@end

@implementation FRPublishPostSearchHashtagItemStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum_name = nil;
    self.forum_id = nil;
    self.avatar_url = nil;
    self.desc = nil;
    self.schema = nil;
    self.concern_id = nil;
}
@end

@implementation FRPublishPostHashtagHighlightStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum_name = @[];
}
@end

@implementation FRPublishPostSearchHashtagStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.forum = nil;
    self.highlight = nil;
}
@end

@implementation FRPublishPostSearchHashtagHotStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.offset = nil;
    self.has_more = 0;
    self.recently = nil;
    self.hot = nil;
}
@end

@implementation FRPublishPostSearchHashtagSuggestStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.offset = nil;
    self.has_more = 0;
    self.suggest = nil;
}
@end

@implementation FRRepostCommonContentStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.schema = nil;
    self.title = nil;
    self.cover_image = nil;
    self.has_video = nil;
}
@end

@implementation FRRepostParamStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.repost_type = nil;
    self.fw_id = nil;
    self.fw_id_type = 0;
    self.fw_user_id = nil;
    self.opt_id = nil;
    self.opt_id_type = 0;
    self.schema = nil;
    self.title = nil;
    self.cover_url = nil;
}
@end

@implementation FRUserRelationContactCheckDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.should_popup = nil;
    self.has_collected = nil;
    self.popup_type = nil;
    self.next_time = nil;
    self.redpack = nil;
}
@end

@implementation FRFooterRepostStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.id = nil;
    self.repost_id_type = 0;
    self.content = nil;
    self.content_rich_span = nil;
    self.user = nil;
    self.is_author = nil;
    self.detail_schema = nil;
    self.action = nil;
    self.create_time = nil;
    self.author_badge = nil;
}
@end

@implementation FRRecommendUserStoryCardStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user = nil;
    self.open_url = nil;
    self.has_new = nil;
    self.stats_place_holder = nil;
    self.story_label = nil;
}
@end

@implementation FRRecommendUserStoryVerifyInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.title = nil;
    self.reason = nil;
}
@end

@implementation FRUGCThreadStoryDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.has_more = nil;
    self.stories = @[];
    self.user = nil;
    self.err_tips = nil;
    self.tail = nil;
}
@end

@implementation FRUGCStoryCoverDataStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user = nil;
    self.content_id = nil;
    self.cover_image = nil;
    self.update_time = nil;
    self.content = nil;
    self.content_rich_span = nil;
    self.origin_content = nil;
    self.origin_content_rich_span = nil;
    self.detail_schema = nil;
    self.has_video = nil;
    self.image_num = nil;
    self.video_duration = nil;
    self.display_type = 0;
    self.story_label = nil;
    self.display_sub_type = nil;
}
@end

@implementation FRUserDecorationStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.user_id = nil;
    self.user_decoration = nil;
}
@end

@implementation FRRecommendUserStoryHasMoreStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.title = nil;
    self.icon = nil;
    self.schema = nil;
    self.function_name = nil;
    self.night_icon = nil;
}
@end

@implementation FRQRCodeLinkInfoStructModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.url = nil;
}
@end

@implementation FRUgcUserDecorationV1RequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/user/decoration/v1";
        self._response = @"FRUgcUserDecorationV1ResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_user_ids forKey:@"user_ids"];

    return params;
}

@end


@implementation FRUgcUserDecorationV1ResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.user_decoration_list = nil;
}
@end

@implementation FRTtdiscussV1ShareRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/share";
        self._response = @"FRTtdiscussV1ShareResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forward_to forKey:@"forward_to"];
    [params setValue:_forward_type forKey:@"forward_type"];
    [params setValue:_forward_id forKey:@"forward_id"];
    [params setValue:_forward_content forKey:@"forward_content"];

    return params;
}

@end


@implementation FRTtdiscussV1ShareResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.expired_platform = nil;
}
@end

@implementation FRTtdiscussV1ForumSearchRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/forum/search";
        self._response = @"FRTtdiscussV1ForumSearchResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_keyword forKey:@"keyword"];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_count forKey:@"count"];

    return params;
}

@end


@implementation FRTtdiscussV1ForumSearchResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.forum_list = nil;
    self.has_more = 0;
    self.err_tips = nil;
}
@end

@implementation FRUgcPublishVideoV3CommitRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/video/v3/commit";
        self._response = @"FRUgcPublishVideoV3CommitResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_title forKey:@"title"];
    [params setValue:_video_id forKey:@"video_id"];
    [params setValue:_video_name forKey:@"video_name"];
    [params setValue:_thumb_uri forKey:@"thumb_uri"];
    [params setValue:_video_type forKey:@"video_type"];
    [params setValue:_video_duration forKey:@"video_duration"];
    [params setValue:_width forKey:@"width"];
    [params setValue:_height forKey:@"height"];
    [params setValue:_thumb_source forKey:@"thumb_source"];
    [params setValue:_enter_from forKey:@"enter_from"];
    [params setValue:_title_rich_span forKey:@"title_rich_span"];
    [params setValue:_mention_user forKey:@"mention_user"];
    [params setValue:_mention_concern forKey:@"mention_concern"];
    [params setValue:_category forKey:@"category"];
    [params setValue:_music_id forKey:@"music_id"];
    [params setValue:_challenge_group_id forKey:@"challenge_group_id"];

    return params;
}

@end


@implementation FRUgcPublishVideoV3CommitResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.data = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1CommitCommentdeleteRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/commentdelete";
        self._response = @"FRTtdiscussV1CommitCommentdeleteResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_comment_id forKey:@"comment_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitCommentdeleteResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1MovieListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/movie/list";
        self._response = @"FRTtdiscussV1MovieListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_movie_id forKey:@"movie_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_movie_cursor forKey:@"movie_cursor"];
    [params setValue:_ugc_cursor forKey:@"ugc_cursor"];
    [params setValue:_sort_type forKey:@"sort_type"];

    return params;
}

@end


@implementation FRTtdiscussV1MovieListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.ugc_min_cursor = nil;
    self.ugc_max_cursor = nil;
    self.movie_min_cursor = nil;
    self.movie_max_cursor = nil;
    self.ugc_has_more = nil;
    self.movie_has_more = nil;
    self.group_list = nil;
    self.thread_list = nil;
    self.review_info = nil;
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV2UgcVideoCheckTitleRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v2/ugc_video/check_title";
        self._response = @"FRTtdiscussV2UgcVideoCheckTitleResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_title forKey:@"title"];
    [params setValue:_content_rich_span forKey:@"content_rich_span"];
    [params setValue:_mention_user forKey:@"mention_user"];
    [params setValue:_mention_concern forKey:@"mention_concern"];

    return params;
}

@end


@implementation FRTtdiscussV2UgcVideoCheckTitleResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.status = 0;
    self.status_tips = nil;
}
@end

@implementation FRConcernV1HomeHeadRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/concern/v1/home/head";
        self._response = @"FRConcernV1HomeHeadResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_city forKey:@"city"];
    [params setValue:_longitude forKey:@"longitude"];
    [params setValue:_latitude forKey:@"latitude"];

    return params;
}

@end


@implementation FRConcernV1HomeHeadResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.concern_obj = nil;
    self.show_et_status = nil;
    self.post_content_hint = nil;
    self.tabs = nil;
    self.thread_list = nil;
    self.forum = nil;
    self.show_describe = nil;
    self.describe_max_line_number = nil;
    self.concern_and_discuss_describe = nil;
    self.hash_tag_type = nil;
    self.publisher_controll = nil;
}
@end

@implementation FRTtdiscussV2CommitPublishRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v2/commit/publish";
        self._response = @"FRTtdiscussV2CommitPublishResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_content forKey:@"content"];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_image_uris forKey:@"image_uris"];
    [params setValue:_longitude forKey:@"longitude"];
    [params setValue:_latitude forKey:@"latitude"];
    [params setValue:_city forKey:@"city"];
    [params setValue:_detail_pos forKey:@"detail_pos"];
    [params setValue:_is_forward forKey:@"is_forward"];
    [params setValue:_phone forKey:@"phone"];
    [params setValue:_title forKey:@"title"];
    [params setValue:@(_from_where) forKey:@"from_where"];
    [params setValue:_rate forKey:@"rate"];

    return params;
}

@end


@implementation FRTtdiscussV2CommitPublishResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.thread = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcPublishPostV4CommitRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/post/v4/commit";
        self._response = @"FRUgcPublishPostV4CommitResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_content forKey:@"content"];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_image_uris forKey:@"image_uris"];
    [params setValue:_longitude forKey:@"longitude"];
    [params setValue:_latitude forKey:@"latitude"];
    [params setValue:_city forKey:@"city"];
    [params setValue:_detail_pos forKey:@"detail_pos"];
    [params setValue:_is_forward forKey:@"is_forward"];
    [params setValue:_phone forKey:@"phone"];
    [params setValue:_title forKey:@"title"];
    [params setValue:@(_from_where) forKey:@"from_where"];
    [params setValue:_score forKey:@"score"];
    [params setValue:_category_id forKey:@"category_id"];
    [params setValue:_enter_from forKey:@"enter_from"];
    [params setValue:_content_rich_span forKey:@"content_rich_span"];
    [params setValue:_mention_user forKey:@"mention_user"];
    [params setValue:_mention_concern forKey:@"mention_concern"];

    return params;
}

@end


@implementation FRUgcPublishPostV4CommitResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.thread = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV2LongReviewListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v2/long/review/list";
        self._response = @"FRTtdiscussV2LongReviewListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_movie_id forKey:@"movie_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_cursor forKey:@"cursor"];
    [params setValue:_sort_type forKey:@"sort_type"];

    return params;
}

@end


@implementation FRTtdiscussV2LongReviewListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.group_list = nil;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.has_more = nil;
}
@end

@implementation FRTtdiscussV1CommitThreadforwardRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/threadforward";
        self._response = @"FRTtdiscussV1CommitThreadforwardResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forward_talk forKey:@"forward_talk"];
    [params setValue:_thread_id forKey:@"thread_id"];
    [params setValue:_content forKey:@"content"];
    [params setValue:_forward_weibo forKey:@"forward_weibo"];
    [params setValue:_forum_id forKey:@"forum_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitThreadforwardResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.thread = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcActivityVideoIntroRedpackV1OpenRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/activity/video_intro_redpack/v1/open";
        self._response = @"FRUgcActivityVideoIntroRedpackV1OpenResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_redpack_id forKey:@"redpack_id"];
    [params setValue:_is_login_open forKey:@"is_login_open"];
    [params setValue:_token forKey:@"token"];

    return params;
}

@end


@implementation FRUgcActivityVideoIntroRedpackV1OpenResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.data = nil;
}
@end

@implementation FRUgcPublishPostV1ContactRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/post/v1/contact";
        self._response = @"FRUgcPublishPostV1ContactResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_offset forKey:@"offset"];

    return params;
}

@end


@implementation FRUgcPublishPostV1ContactResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.data = nil;
}
@end

@implementation FRConcernV1CommitDiscareRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/concern/v1/commit/discare";
        self._response = @"FRConcernV1CommitDiscareResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];

    return params;
}

@end


@implementation FRConcernV1CommitDiscareResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserProfileEvaluationRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/profile/evaluation";
        self._response = @"FRUserProfileEvaluationResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_log_action forKey:@"log_action"];
    [params setValue:_disable forKey:@"disable"];

    return params;
}

@end


@implementation FRUserProfileEvaluationResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.score = nil;
    self.beat_pct = nil;
    self.show = nil;
    self.name = nil;
    self.avatar_url = nil;
    self.is_name_valid = nil;
    self.is_avatar_valid = nil;
    self.apply_auth_url = nil;
}
@end

@implementation FRTtdiscussV1CommitPublishRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/publish";
        self._response = @"FRTtdiscussV1CommitPublishResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_content forKey:@"content"];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_image_uris forKey:@"image_uris"];
    [params setValue:_longitude forKey:@"longitude"];
    [params setValue:_latitude forKey:@"latitude"];
    [params setValue:_city forKey:@"city"];
    [params setValue:_detail_pos forKey:@"detail_pos"];
    [params setValue:_is_forward forKey:@"is_forward"];
    [params setValue:_phone forKey:@"phone"];
    [params setValue:_title forKey:@"title"];
    [params setValue:@(_from_where) forKey:@"from_where"];
    [params setValue:_rate forKey:@"rate"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitPublishResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.thread = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1CommitOpthreadRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/opthread";
        self._response = @"FRTtdiscussV1CommitOpthreadResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_user_id forKey:@"user_id"];
    [params setValue:_thread_id forKey:@"thread_id"];
    [params setValue:_action_type forKey:@"action_type"];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_op_reason_no forKey:@"op_reason_no"];
    [params setValue:_op_extra_reason forKey:@"op_extra_reason"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitOpthreadResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRArticleV2TabCommentsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/article/v2/tab_comments";
        self._response = @"FRArticleV2TabCommentsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_group_id forKey:@"group_id"];
    [params setValue:_item_id forKey:@"item_id"];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:@(_group_type) forKey:@"group_type"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_fold forKey:@"fold"];
    [params setValue:_msg_id forKey:@"msg_id"];

    return params;
}

@end


@implementation FRArticleV2TabCommentsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.total_number = nil;
    self.ban_comment = nil;
    self.has_more = nil;
    self.detail_no_comment = nil;
    self.go_topic_detail = nil;
    self.show_add_forum = nil;
    self.tab_info = nil;
    self.message = nil;
    self.data = nil;
    self.fold_comment_count = nil;
    self.stick_has_more = nil;
    self.stick_total_number = nil;
    self.stick_comments = nil;
    self.ban_face = nil;
}
@end

@implementation FRUgcPublishPostV1CheckRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/post/v1/check";
        self._response = @"FRUgcPublishPostV1CheckResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];

    return params;
}

@end


@implementation FRUgcPublishPostV1CheckResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.bind_mobile = 0;
}
@end

@implementation FRUserRelationFriendsV1RequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/friends/v1";
        self._response = @"FRUserRelationFriendsV1ResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_tab forKey:@"tab"];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_from_page forKey:@"from_page"];
    [params setValue:_profile_user_id forKey:@"profile_user_id"];

    return params;
}

@end


@implementation FRUserRelationFriendsV1ResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.message = nil;
    self.data = nil;
    self.error_tips = nil;
}
@end

@implementation FRConcernV1CommitCareRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/concern/v1/commit/care";
        self._response = @"FRConcernV1CommitCareResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];

    return params;
}

@end


@implementation FRConcernV1CommitCareResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserRelationUserRecommendV1FollowChannelRecommendsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/user_recommend/v1/follow_channel_recommends";
        self._response = @"FRUserRelationUserRecommendV1FollowChannelRecommendsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];

    return params;
}

@end


@implementation FRUserRelationUserRecommendV1FollowChannelRecommendsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.auto_skip = nil;
    self.unselected_tips = nil;
    self.selected_tips = nil;
    self.err_tips = nil;
    self.recommends = nil;
}
@end

@implementation FRUgcPublishRepostV6CommitRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/repost/v6/commit";
        self._response = @"FRUgcPublishRepostV6CommitResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_content forKey:@"content"];
    [params setValue:_repost_type forKey:@"repost_type"];
    [params setValue:_cover_url forKey:@"cover_url"];
    [params setValue:_content_rich_span forKey:@"content_rich_span"];
    [params setValue:_fw_user_id forKey:@"fw_user_id"];
    [params setValue:_fw_id forKey:@"fw_id"];
    [params setValue:@(_fw_id_type) forKey:@"fw_id_type"];
    [params setValue:_opt_id forKey:@"opt_id"];
    [params setValue:@(_opt_id_type) forKey:@"opt_id_type"];
    [params setValue:_mention_user forKey:@"mention_user"];
    [params setValue:_mention_concern forKey:@"mention_concern"];
    [params setValue:_schema forKey:@"schema"];
    [params setValue:_title forKey:@"title"];
    [params setValue:_repost_to_comment forKey:@"repost_to_comment"];

    return params;
}

@end


@implementation FRUgcPublishRepostV6CommitResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_tips = nil;
    self.err_no = nil;
    self.thread = nil;
}
@end

@implementation FRDongtaiGroupCommentDeleteRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/dongtai/group_comment/delete";
        self._response = @"FRDongtaiGroupCommentDeleteResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_id forKey:@"id"];
    [params setValue:_is_answer forKey:@"is_answer"];

    return params;
}

@end


@implementation FRDongtaiGroupCommentDeleteResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.message = nil;
    self.data = nil;
}
@end

@implementation FRTtdiscussV1CommitOwnerapplyRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/ownerapply";
        self._response = @"FRTtdiscussV1CommitOwnerapplyResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_user_id forKey:@"user_id"];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_reason forKey:@"reason"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitOwnerapplyResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FR2DataV4PostMessageRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/2/data/v4/post_message";
        self._response = @"FR2DataV4PostMessageResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_group_id forKey:@"group_id"];
    [params setValue:_item_id forKey:@"item_id"];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_is_comment forKey:@"is_comment"];
    [params setValue:_text forKey:@"text"];
    [params setValue:_comment_duration forKey:@"comment_duration"];
    [params setValue:_read_pct forKey:@"read_pct"];
    [params setValue:_staytime_ms forKey:@"staytime_ms"];
    [params setValue:_reply_to_comment_id forKey:@"reply_to_comment_id"];
    [params setValue:_dongtai_comment_id forKey:@"dongtai_comment_id"];
    [params setValue:@(_group_type) forKey:@"group_type"];

    return params;
}

@end


@implementation FR2DataV4PostMessageResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.message = nil;
    self.group_id = nil;
    self.tag_id = nil;
    self.tag = nil;
    self.data = nil;
}
@end

@implementation FRTtdiscussV1ForumFollowRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/forum/follow";
        self._response = @"FRTtdiscussV1ForumFollowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_user_id forKey:@"user_id"];

    return params;
}

@end


@implementation FRTtdiscussV1ForumFollowResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.has_more = 0;
    self.forum_list = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV2MovieListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v2/movie/list";
        self._response = @"FRTtdiscussV2MovieListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_movie_id forKey:@"movie_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_movie_cursor forKey:@"movie_cursor"];
    [params setValue:_ugc_cursor forKey:@"ugc_cursor"];
    [params setValue:_sort_type forKey:@"sort_type"];

    return params;
}

@end


@implementation FRTtdiscussV2MovieListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.ugc_min_cursor = nil;
    self.ugc_max_cursor = nil;
    self.movie_min_cursor = nil;
    self.movie_max_cursor = nil;
    self.ugc_has_more = nil;
    self.movie_has_more = nil;
    self.group_list = nil;
    self.thread_list = nil;
    self.review_info = nil;
}
@end

@implementation FRUserRelationFriendsInviteRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/friends/invite";
        self._response = @"FRUserRelationFriendsInviteResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_count forKey:@"count"];

    return params;
}

@end


@implementation FRUserRelationFriendsInviteResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.message = nil;
    self.data = nil;
    self.error_tips = nil;
}
@end

@implementation FRUserRelationSetCanBeFoundByPhoneRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/set_can_be_found_by_phone";
        self._response = @"FRUserRelationSetCanBeFoundByPhoneResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_can_be_found_by_phone forKey:@"can_be_found_by_phone"];

    return params;
}

@end


@implementation FRUserRelationSetCanBeFoundByPhoneResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcPublishVideoV3CheckAuthRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/video/v3/check_auth";
        self._response = @"FRUgcPublishVideoV3CheckAuthResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];

    return params;
}

@end


@implementation FRUgcPublishVideoV3CheckAuthResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.publisher_permission_control = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1ThreadListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/thread/list";
        self._response = @"FRTtdiscussV1ThreadListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_count forKey:@"count"];
    [params setValue:_min_cursor forKey:@"min_cursor"];
    [params setValue:_max_cursor forKey:@"max_cursor"];
    [params setValue:_forum_id forKey:@"forum_id"];

    return params;
}

@end


@implementation FRTtdiscussV1ThreadListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.has_more = 0;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.finfo_list = nil;
    self.login_user_info = nil;
    self.err_tips = nil;
    self.tips = nil;
}
@end

@implementation FRUgcActivityUploadContactRedpackV1OpenRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/activity/upload_contact_redpack/v1/open";
        self._response = @"FRUgcActivityUploadContactRedpackV1OpenResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_redpack_id forKey:@"redpack_id"];
    [params setValue:_token forKey:@"token"];

    return params;
}

@end


@implementation FRUgcActivityUploadContactRedpackV1OpenResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.data = nil;
}
@end

@implementation FRTtdiscussV2CommitCommentRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v2/commit/comment";
        self._response = @"FRTtdiscussV2CommitCommentResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forward_talk forKey:@"forward_talk"];
    [params setValue:_thread_id forKey:@"thread_id"];
    [params setValue:_content forKey:@"content"];
    [params setValue:_forward_weibo forKey:@"forward_weibo"];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_reply_comment_id forKey:@"reply_comment_id"];
    [params setValue:_reply_user_id forKey:@"reply_user_id"];

    return params;
}

@end


@implementation FRTtdiscussV2CommitCommentResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.thread_id = nil;
    self.comment_id = nil;
    self.comment = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1CommitCommentdiggRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/commentdigg";
        self._response = @"FRTtdiscussV1CommitCommentdiggResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_comment_id forKey:@"comment_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitCommentdiggResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcThreadDetailV2InfoRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/thread/detail/v2/info";
        self._response = @"FRUgcThreadDetailV2InfoResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_thread_id forKey:@"thread_id"];

    return params;
}

@end


@implementation FRUgcThreadDetailV2InfoResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.ad = nil;
    self.h5_extra = nil;
    self.like_desc = nil;
    self.content_rich_span = nil;
    self.repost_type = nil;
    self.forum_info = nil;
    self.thread = nil;
    self.origin_thread = nil;
    self.origin_group = nil;
    self.origin_ugc_video = nil;
    self.recommend_sponsor = nil;
    self.origin_common_content = nil;
}
@end

@implementation FRTtdiscussV1CommitCommentRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/comment";
        self._response = @"FRTtdiscussV1CommitCommentResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forward_talk forKey:@"forward_talk"];
    [params setValue:_thread_id forKey:@"thread_id"];
    [params setValue:_content forKey:@"content"];
    [params setValue:_forward_weibo forKey:@"forward_weibo"];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_reply_comment_id forKey:@"reply_comment_id"];
    [params setValue:_reply_user_id forKey:@"reply_user_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitCommentResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.thread_id = nil;
    self.comment_id = nil;
    self.comment = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1DiggUserRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/digg/user";
        self._response = @"FRTtdiscussV1DiggUserResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_count forKey:@"count"];
    [params setValue:_thread_id forKey:@"thread_id"];
    [params setValue:_offset forKey:@"offset"];

    return params;
}

@end


@implementation FRTtdiscussV1DiggUserResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.thread_id = nil;
    self.anonymous_count = nil;
    self.has_more = 0;
    self.total_count = nil;
    self.user_lists = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserRelationUserRecommendV1DislikeUserRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/user_recommend/v1/dislike_user";
        self._response = @"FRUserRelationUserRecommendV1DislikeUserResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_dislike_user_id forKey:@"dislike_user_id"];

    return params;
}

@end


@implementation FRUserRelationUserRecommendV1DislikeUserResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1CommitCancelthreaddiggRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/cancelthreaddigg";
        self._response = @"FRTtdiscussV1CommitCancelthreaddiggResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_thread_id forKey:@"thread_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitCancelthreaddiggResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1CommitFollowforumRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/followforum";
        self._response = @"FRTtdiscussV1CommitFollowforumResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id forKey:@"forum_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitFollowforumResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserExpressionConfigRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/expression/config";
        self._response = @"FRUserExpressionConfigResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];

    return params;
}

@end


@implementation FRUserExpressionConfigResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.data = nil;
}
@end

@implementation FRUgcPublishPostV1SuggestRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/post/v1/suggest";
        self._response = @"FRUgcPublishPostV1SuggestResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_words forKey:@"words"];

    return params;
}

@end


@implementation FRUgcPublishPostV1SuggestResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.data = nil;
}
@end

@implementation FRTtdiscussV1ForumIntroductionRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/forum/introduction";
        self._response = @"FRTtdiscussV1ForumIntroductionResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id forKey:@"forum_id"];

    return params;
}

@end


@implementation FRTtdiscussV1ForumIntroductionResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.role_members = nil;
    self.qr_code_uri = nil;
    self.forum = nil;
    self.notice_list = @[];
    self.err_tips = nil;
    self.user_id = nil;
    self.req_params = nil;
    self.user_apply_info = nil;
    self.forum_role_info = nil;
    self.forum_stat_data_list = nil;
}
@end

@implementation FRUserRelationContactinfoRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/contactinfo";
        self._response = @"FRUserRelationContactinfoResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];

    return params;
}

@end


@implementation FRUserRelationContactinfoResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.message = nil;
    self.is_collected = nil;
}
@end

@implementation FRTtdiscussV1MomentListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/moment/list";
        self._response = @"FRTtdiscussV1MomentListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_count forKey:@"count"];
    [params setValue:_min_cursor forKey:@"min_cursor"];
    [params setValue:_max_cursor forKey:@"max_cursor"];

    return params;
}

@end


@implementation FRTtdiscussV1MomentListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.login_status = 0;
    self.has_more = 0;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.data_list = nil;
    self.tips = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcPublishShareV1SetConfigRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/share/v1/set_config";
        self._response = @"FRUgcPublishShareV1SetConfigResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_share_repost forKey:@"share_repost"];

    return params;
}

@end


@implementation FRUgcPublishShareV1SetConfigResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRVerticalMovie1ReviewsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/vertical/movie/1/reviews";
        self._response = @"FRVerticalMovie1ReviewsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_review_cursor forKey:@"review_cursor"];
    [params setValue:_post_cursor forKey:@"post_cursor"];
    [params setValue:_sort_type forKey:@"sort_type"];

    return params;
}

@end


@implementation FRVerticalMovie1ReviewsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.post_min_cursor = nil;
    self.post_max_cursor = nil;
    self.review_min_cursor = nil;
    self.review_max_cursor = nil;
    self.post_has_more = nil;
    self.review_has_more = nil;
    self.reviews = nil;
    self.posts = nil;
    self.review_info = nil;
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1CommentRecommendforumRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/comment/recommendforum";
        self._response = @"FRTtdiscussV1CommentRecommendforumResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_user_id forKey:@"user_id"];
    [params setValue:_group_id forKey:@"group_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommentRecommendforumResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.forum_info = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcPublishPostV1HashtagRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/post/v1/hashtag";
        self._response = @"FRUgcPublishPostV1HashtagResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_words forKey:@"words"];
    [params setValue:_forum_flag forKey:@"forum_flag"];

    return params;
}

@end


@implementation FRUgcPublishPostV1HashtagResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.data = nil;
}
@end

@implementation FRTtdiscussV1CommitOpcommentRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/opcomment";
        self._response = @"FRTtdiscussV1CommitOpcommentResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_user_id forKey:@"user_id"];
    [params setValue:_comment_id forKey:@"comment_id"];
    [params setValue:_action_type forKey:@"action_type"];
    [params setValue:_forum_id forKey:@"forum_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitOpcommentResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1ThreadDetailRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/thread/detail";
        self._response = @"FRTtdiscussV1ThreadDetailResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_count forKey:@"count"];
    [params setValue:_thread_id forKey:@"thread_id"];
    [params setValue:_forum_id forKey:@"forum_id"];

    return params;
}

@end


@implementation FRTtdiscussV1ThreadDetailResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.thread = nil;
    self.comments = nil;
    self.hot_comments = nil;
    self.login_user_info = nil;
    self.forum_info = nil;
    self.err_tips = nil;
    self.openurl = nil;
}
@end

@implementation FRUgcThreadStoryVRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/thread/story/v";
        self._response = @"FRUgcThreadStoryVResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_user_id forKey:@"user_id"];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_is_preload forKey:@"is_preload"];

    return params;
}

@end


@implementation FRUgcThreadStoryVResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.message = nil;
    self.data = nil;
}
@end

@implementation FRTtdiscussV2ForumListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v2/forum/list";
        self._response = @"FRTtdiscussV2ForumListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_city forKey:@"city"];
    [params setValue:_remote_ip forKey:@"remote_ip"];

    return params;
}

@end


@implementation FRTtdiscussV2ForumListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.type = 0;
    self.forum_info = nil;
    self.normal_thread_info = nil;
    self.movie_info = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserRelationContactfriendsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/contactfriends";
        self._response = @"FRUserRelationContactfriendsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_auto_follow forKey:@"auto_follow"];

    return params;
}

@end


@implementation FRUserRelationContactfriendsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.message = nil;
    self.data = nil;
}
@end

@implementation FRUgcThreadDetailV2ContentRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/thread/detail/v2/content";
        self._response = @"FRUgcThreadDetailV2ContentResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_thread_id forKey:@"thread_id"];

    return params;
}

@end


@implementation FRUgcThreadDetailV2ContentResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.content = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcPublishPostV1HotForumRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/post/v1/hot_forum";
        self._response = @"FRUgcPublishPostV1HotForumResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_forum_flag forKey:@"forum_flag"];

    return params;
}

@end


@implementation FRUgcPublishPostV1HotForumResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.data = nil;
}
@end

@implementation FRTtdiscussV1ThreadDetailCommentRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/thread/detail/comment";
        self._response = @"FRTtdiscussV1ThreadDetailCommentResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_count forKey:@"count"];
    [params setValue:_thread_id forKey:@"thread_id"];
    [params setValue:_offset forKey:@"offset"];

    return params;
}

@end


@implementation FRTtdiscussV1ThreadDetailCommentResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.comment_number = nil;
    self.comments = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcThreadLinkV1ConvertRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/thread/link/v1/convert";
        self._response = @"FRUgcThreadLinkV1ConvertResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_url forKey:@"url"];

    return params;
}

@end


@implementation FRUgcThreadLinkV1ConvertResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.url_info = nil;
}
@end

@implementation FRUgcPublishShareV3NotifyRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/publish/share/v3/notify";
        self._response = @"FRUgcPublishShareV3NotifyResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_share_id forKey:@"share_id"];
    [params setValue:_share_channel forKey:@"share_channel"];
    [params setValue:_item_type forKey:@"item_type"];
    [params setValue:_content forKey:@"content"];
    [params setValue:_repost_type forKey:@"repost_type"];
    [params setValue:_cover_url forKey:@"cover_url"];
    [params setValue:_content_rich_span forKey:@"content_rich_span"];
    [params setValue:_fw_user_id forKey:@"fw_user_id"];
    [params setValue:_fw_id forKey:@"fw_id"];
    [params setValue:@(_fw_id_type) forKey:@"fw_id_type"];
    [params setValue:_opt_id forKey:@"opt_id"];
    [params setValue:@(_opt_id_type) forKey:@"opt_id_type"];
    [params setValue:_schema forKey:@"schema"];
    [params setValue:_title forKey:@"title"];

    return params;
}

@end


@implementation FRUgcPublishShareV3NotifyResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcCommentAuthorActionV2DeleteRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/comment/author_action/v2/delete";
        self._response = @"FRUgcCommentAuthorActionV2DeleteResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_comment_id forKey:@"comment_id"];
    [params setValue:_thread_id forKey:@"thread_id"];
    [params setValue:_reply_id forKey:@"reply_id"];
    [params setValue:_action_type forKey:@"action_type"];
    [params setValue:_group_id forKey:@"group_id"];

    return params;
}

@end


@implementation FRUgcCommentAuthorActionV2DeleteResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRVerticalMovie1ShortReviewsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/vertical/movie/1/short/reviews";
        self._response = @"FRVerticalMovie1ShortReviewsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_cursor forKey:@"cursor"];
    [params setValue:_sort_type forKey:@"sort_type"];

    return params;
}

@end


@implementation FRVerticalMovie1ShortReviewsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.posts = nil;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.has_more = nil;
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcRepostV1ListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/repost/v1/list";
        self._response = @"FRUgcRepostV1ListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_id forKey:@"id"];
    [params setValue:@(_type) forKey:@"type"];
    [params setValue:_msg_id forKey:@"msg_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_offset forKey:@"offset"];

    return params;
}

@end


@implementation FRUgcRepostV1ListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.has_more = nil;
    self.offset = nil;
    self.total_number = nil;
    self.reposts = nil;
    self.stick_reposts = nil;
}
@end

@implementation FRUserRelationUserRecommendV1SupplementCardRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/user_recommend/v1/supplement_card";
        self._response = @"FRUserRelationUserRecommendV1SupplementCardResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_source forKey:@"source"];
    [params setValue:_follow_user_id forKey:@"follow_user_id"];

    return params;
}

@end


@implementation FRUserRelationUserRecommendV1SupplementCardResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.message = nil;
    self.data = nil;
}
@end

@implementation FRUgcDiggV1ListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/digg/v1/list";
        self._response = @"FRUgcDiggV1ListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_id forKey:@"id"];
    [params setValue:@(_type) forKey:@"type"];
    [params setValue:_msg_id forKey:@"msg_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_offset forKey:@"offset"];

    return params;
}

@end


@implementation FRUgcDiggV1ListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.has_more = nil;
    self.offset = nil;
    self.total_number = nil;
    self.anoy_number = nil;
    self.digg_users = nil;
    self.stick_users = nil;
}
@end

@implementation FRConcernV2CommitPublishRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/concern/v2/commit/publish";
        self._response = @"FRConcernV2CommitPublishResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_content forKey:@"content"];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_image_uris forKey:@"image_uris"];
    [params setValue:_longitude forKey:@"longitude"];
    [params setValue:_latitude forKey:@"latitude"];
    [params setValue:_city forKey:@"city"];
    [params setValue:_detail_pos forKey:@"detail_pos"];
    [params setValue:_is_forward forKey:@"is_forward"];
    [params setValue:_phone forKey:@"phone"];
    [params setValue:_title forKey:@"title"];
    [params setValue:@(_from_where) forKey:@"from_where"];
    [params setValue:_score forKey:@"score"];
    [params setValue:_category_id forKey:@"category_id"];
    [params setValue:_enter_from forKey:@"enter_from"];

    return params;
}

@end


@implementation FRConcernV2CommitPublishResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.thread = nil;
    self.err_tips = nil;
}
@end

@implementation FRConcernV1ThreadListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/concern/v1/thread/list";
        self._response = @"FRConcernV1ThreadListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_min_cursor forKey:@"min_cursor"];
    [params setValue:_max_cursor forKey:@"max_cursor"];

    return params;
}

@end


@implementation FRConcernV1ThreadListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.tips = nil;
    self.has_more = 0;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.threads = nil;
}
@end

@implementation FRTtdiscussV1ThreadCommentsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/thread/comments";
        self._response = @"FRTtdiscussV1ThreadCommentsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_count forKey:@"count"];
    [params setValue:_thread_id forKey:@"thread_id"];
    [params setValue:_offset forKey:@"offset"];

    return params;
}

@end


@implementation FRTtdiscussV1ThreadCommentsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.comments = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserRelationCredibleFriendsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/credible_friends";
        self._response = @"FRUserRelationCredibleFriendsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_user_ids forKey:@"user_ids"];
    [params setValue:_redpack_id forKey:@"redpack_id"];
    [params setValue:_token forKey:@"token"];
    [params setValue:_rel_type forKey:@"rel_type"];

    return params;
}

@end


@implementation FRUserRelationCredibleFriendsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.message = nil;
    self.data = nil;
    self.error_tips = nil;
}
@end

@implementation FRArticleV1TabCommentsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/article/v1/tab_comments";
        self._response = @"FRArticleV1TabCommentsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_group_id forKey:@"group_id"];
    [params setValue:_item_id forKey:@"item_id"];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:@(_group_type) forKey:@"group_type"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_fold forKey:@"fold"];

    return params;
}

@end


@implementation FRArticleV1TabCommentsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.total_number = nil;
    self.ban_comment = nil;
    self.has_more = nil;
    self.detail_no_comment = nil;
    self.go_topic_detail = nil;
    self.show_add_forum = nil;
    self.tab_info = nil;
    self.message = nil;
    self.data = nil;
    self.fold_comment_count = nil;
    self.ban_face = nil;
}
@end

@implementation FRTtdiscussV1SmartReviewListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/smart/review/list";
        self._response = @"FRTtdiscussV1SmartReviewListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id forKey:@"forum_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_cursor forKey:@"cursor"];
    [params setValue:_sort_type forKey:@"sort_type"];

    return params;
}

@end


@implementation FRTtdiscussV1SmartReviewListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.thread_list = nil;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.has_more = nil;
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserRelationContactcheckRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/contactcheck";
        self._response = @"FRUserRelationContactcheckResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];

    return params;
}

@end


@implementation FRUserRelationContactcheckResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.data = nil;
}
@end

@implementation FRTtdiscussV1CommitThreaddiggRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/threaddigg";
        self._response = @"FRTtdiscussV1CommitThreaddiggResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_thread_id forKey:@"thread_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitThreaddiggResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1ForumRecommendRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/forum/recommend";
        self._response = @"FRTtdiscussV1ForumRecommendResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];

    return params;
}

@end


@implementation FRTtdiscussV1ForumRecommendResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.forum_list = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserRelationMfollowRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/mfollow";
        self._response = @"FRUserRelationMfollowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_to_user_list forKey:@"to_user_list"];
    [params setValue:_source forKey:@"source"];
    [params setValue:_reason forKey:@"reason"];

    return params;
}

@end


@implementation FRUserRelationMfollowResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1ForumListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/forum/list";
        self._response = @"FRTtdiscussV1ForumListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id forKey:@"forum_id"];

    return params;
}

@end


@implementation FRTtdiscussV1ForumListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.has_more = 0;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.forum_info = nil;
    self.finfo_list = nil;
    self.table = nil;
    self.like_time = nil;
    self.login_user_info = nil;
    self.top_thread = nil;
    self.err_tips = nil;
    self.tips = nil;
}
@end

@implementation FRUserRelationUserRecommendV1SupplementRecommendsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/user_recommend/v1/supplement_recommends";
        self._response = @"FRUserRelationUserRecommendV1SupplementRecommendsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_source forKey:@"source"];
    [params setValue:_scene forKey:@"scene"];
    [params setValue:_follow_user_id forKey:@"follow_user_id"];
    [params setValue:_group_id forKey:@"group_id"];

    return params;
}

@end


@implementation FRUserRelationUserRecommendV1SupplementRecommendsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.user_cards = nil;
    self.has_more = nil;
}
@end

@implementation FRTtdiscussV1CommitUnfollowforumRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/unfollowforum";
        self._response = @"FRTtdiscussV1CommitUnfollowforumResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id forKey:@"forum_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitUnfollowforumResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1CommitForumforwardRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/forumforward";
        self._response = @"FRTtdiscussV1CommitForumforwardResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id forKey:@"forum_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitForumforwardResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.forum_id = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1CommitThreaddeleteRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/threaddelete";
        self._response = @"FRTtdiscussV1CommitThreaddeleteResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_thread_id forKey:@"thread_id"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitThreaddeleteResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1LongReviewListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/long/review/list";
        self._response = @"FRTtdiscussV1LongReviewListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_movie_id forKey:@"movie_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_cursor forKey:@"cursor"];
    [params setValue:_sort_type forKey:@"sort_type"];

    return params;
}

@end


@implementation FRTtdiscussV1LongReviewListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.group_list = nil;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.has_more = nil;
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserRelationWeitoutiaoRecommendsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/weitoutiao_recommends";
        self._response = @"FRUserRelationWeitoutiaoRecommendsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];

    return params;
}

@end


@implementation FRUserRelationWeitoutiaoRecommendsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.users = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcActivityFollowRedpackV1OpenRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/activity/follow_redpack/v1/open";
        self._response = @"FRUgcActivityFollowRedpackV1OpenResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_redpack_id forKey:@"redpack_id"];
    [params setValue:_is_login_open forKey:@"is_login_open"];
    [params setValue:_token forKey:@"token"];

    return params;
}

@end


@implementation FRUgcActivityFollowRedpackV1OpenResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.data = nil;
}
@end

@implementation FRTtdiscussV1ForumIntroapplypageRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/forum/introapplypage";
        self._response = @"FRTtdiscussV1ForumIntroapplypageResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];

    return params;
}

@end


@implementation FRTtdiscussV1ForumIntroapplypageResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.user_id = nil;
}
@end

@implementation FRTtdiscussV2UgcVideoUploadVideoUrlRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v2/ugc_video/upload_video_url";
        self._response = @"FRTtdiscussV2UgcVideoUploadVideoUrlResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_upload_id forKey:@"upload_id"];

    return params;
}

@end


@implementation FRTtdiscussV2UgcVideoUploadVideoUrlResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.upload_id = nil;
    self.upload_url = nil;
    self.chunk_size = nil;
    self.bytes = nil;
    self.err_tips = nil;
}
@end

@implementation FRTtdiscussV1CommitMultiownerapplyRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v1/commit/multiownerapply";
        self._response = @"FRTtdiscussV1CommitMultiownerapplyResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_forum_id_list forKey:@"forum_id_list"];
    [params setValue:_reason forKey:@"reason"];

    return params;
}

@end


@implementation FRTtdiscussV1CommitMultiownerapplyResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUserRelationMultiFollowRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"GET";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/user/relation/multi_follow";
        self._response = @"FRUserRelationMultiFollowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_to_user_list forKey:@"to_user_list"];

    return params;
}

@end


@implementation FRUserRelationMultiFollowResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRVerticalMovie1LongReviewsRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/vertical/movie/1/long/reviews";
        self._response = @"FRVerticalMovie1LongReviewsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_cursor forKey:@"cursor"];
    [params setValue:_sort_type forKey:@"sort_type"];

    return params;
}

@end


@implementation FRVerticalMovie1LongReviewsResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.reviews = nil;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.has_more = nil;
    self.err_no = nil;
    self.err_tips = nil;
}
@end

@implementation FRUgcConcernThreadV3ListRequestModel
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"/ugc/concern/thread/v3/list";
        self._response = @"FRUgcConcernThreadV3ListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_min_cursor forKey:@"min_cursor"];
    [params setValue:_max_cursor forKey:@"max_cursor"];

    return params;
}

@end


@implementation FRUgcConcernThreadV3ListResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.err_tips = nil;
    self.tips = nil;
    self.has_more = 0;
    self.min_cursor = nil;
    self.max_cursor = nil;
    self.threads = nil;
}
@end

