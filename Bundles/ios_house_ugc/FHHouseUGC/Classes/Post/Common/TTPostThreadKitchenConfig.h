//
//  TTPostThreadKitchenConfig.h
//  AWEVideoPlayer
//
//  Created by SongChai on 2018/5/19.
//

#import <TTKitchen/TTKitchen.h>

static NSString * const kTTKCommentRepostRepostToCommentText = @"tt_ugc_repost_comment_union.repost_region.title"; // 转发发布器转发并评论文字
static NSString * const kTTKCommentRepostRepostToCommentEnable = @"tt_ugc_repost_comment_union.repost_region.enable"; // 转发发布器转发并评论开关
static NSString * const kTTKCommentRepostRepostToCommentSelected = @"repost_comment_repost_to_comment_selected"; // 转发并评论，上次勾选状态

static NSString * kTTKUGCRepostCommentCheckBoxType = @"tt_hide_comment_check_box.repost_comment_check_box_type"; // 1表示进入发布器总是勾选转发并评论, 2表示进入发布器总是隐藏勾选框，默认勾选

static NSString * kTTKUGCRepostCommentTypes = @"tt_hide_comment_check_box.repost_types"; // [211, 212, 214, 213, 215, 220, 221, 223]

static NSString * const kTTKUGCPostAndRepostContentMaxCount = @"dongtai_post_max_text_length"; // 发布器最多输入字数


static NSString * const kTTKUGCPostAndRepostBanHashtag = @"tt_ugc_post_and_repost.ban_hashtag"; // 发布器ban #?
static NSString * const kTTKUGCPostAndRepostBanAt = @"tt_ugc_post_and_repost.ban_at"; // 发布器ban @?

static NSString * const kTTKUGCDirectRepostAlwaysComment = @"tt_hide_comment_check_box.direct_repost_always_comment";

static NSString * const kTTKGMapKey = @"tt_ugc_base_config.google_api_key";
static NSString * const kTTKGMapServiceAvailable = @"tt_ugc_base_config.google_api_available";

static NSString * const kTTKUGCPostLocationSuggestEnable = @"tt_ugc_base_config.post_location_suggest";
static NSString * const kTTKUGCPostSyncToRocketText = @"tt_ugc_base_config.post_sync_to_rocket_text";

static NSString * const kTTUGCBusinessAllianceChoiceProtocolUrl = @"ugc_business_alliance.choice_alliance_protocol";
static NSString * const kTTKUGCSyncToRocketCheckStatus = @"tt_ugc_base_config.sync_to_rocket_check_status";//同步到R的勾选状态，-1:无状态，0:未勾选，1:勾选
static NSString * const kTTKUGCSyncToRocketFirstChecked = @"tt_ugc_base_config.sync_to_rocket_first_checked";//首次看到同步到R时候的状态
static NSString * const kTTPostThreadSyncToRocketSupportPublishEnterFrom = @"tt_ugc_base_config.sync_to_rocket_support_publish_enter_from";

static NSString * const kTTKCommonUgcPostBindingPhoneNumberKey = @"tt_ugc_post_need_check_bind"; //发帖／转发是否需要绑定手机号


@interface TTKitchenManager (PostThreadConfig)

@end
