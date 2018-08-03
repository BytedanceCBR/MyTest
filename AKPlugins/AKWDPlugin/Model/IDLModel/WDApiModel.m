#import "WDApiModel.h"
@implementation WDApiRequestModel
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

@implementation WDApiResponseModel
- (instancetype) init {
    self = [super init];
    if (self) {
        self.error = 0;
    }

    return self;
}
@end

@implementation WDImageUrlStructModel
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
    self.url_list = (NSArray<WDMagicUrlStructModel> *)@[];
    self.type = 0;
}
@end

@implementation WDVideoInfoStructModel
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
    self.video_id = nil;
    self.cover_pic = nil;
    self.duration = nil;
}
@end

@implementation WDMagicUrlStructModel
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

@implementation WDQuestionDescStructModel
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
    self.large_image_list = (NSArray<WDImageUrlStructModel> *)@[];
    self.thumb_image_list = (NSArray<WDImageUrlStructModel> *)@[];
    self.question_abstract_fold = nil;
}
@end

@implementation WDAbstractStructModel
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
    self.large_image_list = (NSArray<WDImageUrlStructModel> *)@[];
    self.thumb_image_list = (NSArray<WDImageUrlStructModel> *)@[];
    self.video_list = (NSArray<WDVideoInfoStructModel> *)@[];
}
@end

@implementation WDShareStructModel
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

@implementation WDAnswerFoldReasonStructModel
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
    self.open_url = nil;
}
@end

@implementation WDUserStructModel
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
    self.uname = nil;
    self.user_intro = nil;
    self.avatar_url = nil;
    self.is_verify = nil;
    self.user_auth_info = nil;
    self.medals = @[];
    self.is_following = nil;
    self.is_followed = nil;
    self.invite_status = nil;
    self.user_schema = nil;
    self.total_digg = nil;
    self.total_answer = nil;
    self.activity = nil;
    self.user_decoration = nil;
}
@end

@implementation WDActivityStructModel
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

@implementation WDRedPackStructModel
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
    self.token = nil;
    self.button_style = nil;
    self.user_info = nil;
    self.subtitle = nil;
    self.content = nil;
}
@end

@implementation WDUserFullStructModel
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
    self.uname = nil;
    self.user_intro = nil;
    self.avatar_url = nil;
    self.is_verify = nil;
    self.user_schema = nil;
    self.v_icon = nil;
    self.user_honor = nil;
    self.is_followed = nil;
    self.is_following = nil;
    self.is_blocking = nil;
    self.is_blocked = nil;
    self.user_auth_info = nil;
}
@end

@implementation WDConcernTagStructModel
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
    self.schema = nil;
}
@end

@implementation WDSimpleQuestionStructModel
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
    self.qid = nil;
    self.title = nil;
    self.schema = nil;
    self.ans_count = nil;
    self.highlight = (NSArray<WDHighlightStructModel> *)@[];
}
@end

@implementation WDHighlightStructModel
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
}
@end

@implementation WDQuestionStructModel
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
    self.qid = nil;
    self.title = nil;
    self.create_time = nil;
    self.user = nil;
    self.content = nil;
    self.nice_ans_count = nil;
    self.normal_ans_count = nil;
    self.share_data = nil;
    self.fold_reason = nil;
    self.status = nil;
    self.concern_tag_list = (NSArray<WDConcernTagStructModel> *)@[];
    self.is_follow = nil;
    self.follow_count = nil;
    self.can_edit = nil;
    self.show_edit = nil;
    self.can_delete = nil;
    self.show_delete = nil;
    self.post_answer_url = nil;
    self.recommend_sponsor = nil;
}
@end

@implementation WDAnswerStructModel
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
    self.ansid = nil;
    self.content = nil;
    self.create_time = nil;
    self.user = nil;
    self.content_abstract = nil;
    self.digg_count = nil;
    self.is_digg = nil;
    self.ans_url = nil;
    self.share_data = nil;
    self.bury_count = nil;
    self.is_buryed = nil;
    self.is_show_bury = nil;
    self.schema = nil;
    self.comment_count = nil;
    self.brow_count = nil;
    self.forward_count = nil;
    self.comment_schema = nil;
    self.modify_time = nil;
    self.profit_label = nil;
    self.is_light_answer = nil;
}
@end

@implementation WDProfitLabelStructModel
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
    self.icon_day_url = nil;
    self.icon_night_url = nil;
    self.text = nil;
    self.amount = nil;
}
@end

@implementation WDAnswerDraftStructModel
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
    self.draft = nil;
    self.modify_time = nil;
    self.qid = nil;
    self.question_title = nil;
    self.content_abstract = nil;
    self.schema = nil;
}
@end

@implementation WDUserPositionStructModel
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

@implementation WDUserPrivilegeStructModel
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
    self.can_delete_answer = nil;
    self.can_comment_answer = nil;
    self.can_digg_answer = nil;
}
@end

@implementation WDRelatedWendaStructModel
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
    self.type = 0;
    self.question = nil;
    self.answer = nil;
    self.schema = nil;
}
@end

@implementation WDRecommendFirstPageStructModel
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
    self.pos = nil;
    self.text = nil;
}
@end

@implementation WDDetailPermStructModel
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
    self.can_ban_comment = nil;
    self.can_delete_answer = nil;
    self.can_delete_comment = nil;
    self.can_post_answer = nil;
    self.can_comment_answer = nil;
    self.can_digg_answer = nil;
    self.can_edit_answer = nil;
}
@end

@implementation WDDetailMediaInfoStructModel
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
    self.media_id = nil;
    self.name = nil;
    self.avatar_url = nil;
    self.subscribed = nil;
}
@end

@implementation WDDetailRelatedWendaStructModel
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
    self.ansid = nil;
    self.title = nil;
    self.open_page_url = nil;
    self.type_name = nil;
    self.impr_id = nil;
}
@end

@implementation WDDetailWendaStructModel
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
    self.ansid = nil;
    self.ans_count = nil;
    self.digg_count = nil;
    self.brow_count = nil;
    self.perm = nil;
    self.is_ban_comment = nil;
    self.is_concern_user = nil;
    self.is_digg = nil;
    self.is_answer_delete = nil;
    self.is_question_delete = nil;
    self.bury_count = nil;
    self.is_buryed = nil;
    self.is_show_bury = nil;
    self.edit_answer_url = nil;
    self.fans_count = nil;
}
@end

@implementation WDDetailImageUrlStructModel
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

@implementation WDDetailImageStructModel
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
    self.width = nil;
    self.height = nil;
    self.uri = nil;
    self.url_list = (NSArray<WDDetailImageUrlStructModel> *)@[];
}
@end

@implementation WDWendaCellDataStructModel
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
    self.content = nil;
    self.code = nil;
}
@end

@implementation WDTipsStructModel
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
    self.open_url = nil;
    self.type = nil;
    self.display_duration = nil;
    self.app_name = nil;
}
@end

@implementation WDWendaInvitedQuestionStructModel
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
    self.qid = nil;
    self.nice_ans_count = nil;
    self.normal_ans_count = nil;
    self.follow_count = nil;
    self.title = nil;
    self.list_schema = nil;
    self.behot_time = nil;
    self.post_answer_schema = nil;
    self.invited_user_desc = nil;
    self.invited_question_type = 0;
    self.is_answered = nil;
    self.background = nil;
    self.profit_label = nil;
}
@end

@implementation WDWidgetStructModel
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
    self.cell_height = nil;
    self.data_url = nil;
    self.template_url = nil;
    self.id = nil;
    self.refresh_interval = nil;
    self.cell_type = nil;
    self.is_deleted = nil;
    self.behot_time = nil;
    self.cursor = nil;
    self.template_md5 = nil;
    self.data_callback = nil;
}
@end

@implementation WDInviteUserStructModel
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
    self.uname = nil;
    self.user_intro = nil;
    self.avatar_url = nil;
    self.is_verify = nil;
    self.schema = nil;
    self.invite_status = 0;
    self.user_auth_info = nil;
    self.user_decoration = nil;
}
@end

@implementation WDInviteAggrUserStructModel
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
    self.aggr_message = nil;
    self.candidate_invite_user = (NSArray<WDInviteUserStructModel> *)@[];
}
@end

@implementation WDShowFormatStructModel
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
    self.font_size = nil;
    self.answer_full_context_color = nil;
    self.show_module = nil;
}
@end

@implementation WDIcImageStructModel
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
    self.small_img = nil;
    self.medium_img = nil;
    self.img_id = nil;
}
@end

@implementation WDRecommendSponsorStructModel
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

@implementation WDForwardStructModel
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
    self.fw_id_type = nil;
    self.fw_user_id = nil;
    self.opt_id = nil;
    self.opt_id_type = nil;
    self.schema = nil;
    self.title = nil;
    self.cover_url = nil;
}
@end

@implementation WDModuleStructModel
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
    self.day_icon_url = nil;
    self.night_icon_url = nil;
    self.text = nil;
    self.schema = nil;
    self.icon_type = 0;
}
@end

@implementation WDProfitStructModel
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
    self.profit_time = nil;
    self.sponsor_name = nil;
    self.sponsor_url = nil;
    self.sponsor_postfix = nil;
    self.about_text = nil;
    self.about_url = nil;
    self.icon_day_url = nil;
    self.icon_night_url = nil;
    self.content = nil;
    self.highlight = (NSArray<WDHighlightStructModel> *)@[];
}
@end

@implementation WDShareProfitStructModel
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
    self.icon_day_url = nil;
    self.icon_night_url = nil;
    self.schema = nil;
}
@end

@implementation WDStreamAnswerStructModel
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
    self.ansid = nil;
    self.abstract_text = nil;
    self.brow_count = nil;
    self.digg_count = nil;
    self.comment_count = nil;
    self.forward_count = nil;
    self.is_digg = nil;
    self.answer_detail_schema = nil;
    self.thumb_image_list = (NSArray<WDImageUrlStructModel> *)@[];
    self.large_image_list = (NSArray<WDImageUrlStructModel> *)@[];
    self.status = 0;
    self.create_time = nil;
}
@end

@implementation WDStreamQuestionStructModel
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
    self.qid = nil;
    self.title = nil;
    self.content = nil;
    self.question_list_schema = nil;
    self.nice_ans_count = nil;
    self.normal_ans_count = nil;
    self.follow_count = nil;
    self.write_answer_schema = nil;
    self.status = 0;
    self.create_time = nil;
}
@end

@implementation WDStreamUserStructModel
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
    self.uname = nil;
    self.avatar_url = nil;
    self.user_auth_info = nil;
    self.is_following = nil;
    self.is_verify = nil;
    self.v_icon = nil;
    self.user_schema = nil;
    self.user_decoration = nil;
}
@end

@implementation WDFilterWorldStructModel
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
    self.name = nil;
    self.is_selected = nil;
}
@end

@implementation WDAnswerCellDataStructModel
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
    self.question = nil;
    self.answer = nil;
    self.user = nil;
    self.comment_schema = nil;
    self.filter_words = (NSArray<WDFilterWorldStructModel> *)@[];
    self.recommend_reason = nil;
    self.layout_type = nil;
    self.image_type = nil;
    self.default_lines = nil;
    self.max_lines = nil;
    self.jump_type = nil;
    self.repost_params = nil;
}
@end

@implementation WDWendaAnswerCellStructModel
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
    self.content = nil;
}
@end

@implementation WDQuestionCellDataStructModel
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
    self.question = nil;
    self.user = nil;
    self.image_type = nil;
    self.filter_words = (NSArray<WDFilterWorldStructModel> *)@[];
    self.recommend_reason = nil;
    self.layout_type = nil;
    self.repost_params = nil;
}
@end

@implementation WDWendaQuestionCellStructModel
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
    self.content = nil;
}
@end

@implementation WDOrderedItemStructModel
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
    self.open_page_url = nil;
    self.type_name = nil;
    self.impr_id = nil;
    self.item_id = nil;
    self.group_id = nil;
    self.aggr_type = nil;
    self.link = nil;
    self.word = nil;
}
@end

@implementation WDOrderedItemInfoStructModel
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
    self.data = (NSArray<WDOrderedItemStructModel> *)@[];
    self.name = nil;
    self.ad_data = nil;
    self.related_data = nil;
}
@end

@implementation WDNextPageStructModel
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
    self.next_ansid = nil;
    self.next_answer_schema = nil;
    self.all_answer_text = nil;
    self.next_answer_text = nil;
    self.show_toast = nil;
    self.has_next = nil;
}
@end

@implementation WDWendaAnswerInformationRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/answer/information";
        self._response = @"WDWendaAnswerInformationResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:_scope forKey:@"scope"];
    [params setValue:_enter_from forKey:@"enter_from"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];
    [params setValue:_latitude forKey:@"latitude"];
    [params setValue:_longitude forKey:@"longitude"];

    return params;
}

@end


@implementation WDWendaAnswerInformationResponseModel
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
    self.ordered_info = (NSArray<WDOrderedItemInfoStructModel> *)@[];
    self.wenda_data = nil;
    self.share_url = nil;
    self.wendaDelete = nil;
    self.media_info = nil;
    self.group_id = nil;
    self.context = nil;
    self.etag = nil;
    self.next_item_struct = nil;
    self.user_repin = nil;
    self.post_answer_schema = nil;
    self.share_img = nil;
    self.share_title = nil;
    self.recommend_sponsor = nil;
    self.err_no = nil;
    self.err_tips = nil;
    self.question_schema = nil;
    self.activity = nil;
    self.repost_params = nil;
    self.profit_label = nil;
    self.show_tips = nil;
}
@end

@implementation WDNextItemStructModel
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
    self.ansid = nil;
    self.schema = nil;
    self.show_toast = nil;
}
@end

@implementation WDWendaAnswerListRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/answer/list";
        self._response = @"WDWendaAnswerListResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:_scope forKey:@"scope"];
    [params setValue:_enter_from forKey:@"enter_from"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];

    return params;
}

@end


@implementation WDWendaAnswerListResponseModel
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
    self.answer_list = (NSArray<WDNextItemStructModel> *)@[];
}
@end

@implementation WDWendaAnswerRawRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/answer/raw";
        self._response = @"WDWendaAnswerRawResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaAnswerRawResponseModel
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
    self.is_ban_comment = nil;
    self.content = nil;
}
@end

@implementation WDWendaCategoryBrowRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/category/brow";
        self._response = @"WDWendaCategoryBrowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_min_behot_time forKey:@"min_behot_time"];
    [params setValue:_max_behot_time forKey:@"max_behot_time"];
    [params setValue:_wenda_extra forKey:@"wenda_extra"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCategoryBrowResponseModel
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
    self.login_status = nil;
    self.total_number = nil;
    self.has_more = nil;
    self.message = nil;
    self.has_more_to_refresh = nil;
    self.extra = nil;
    self.data = (NSArray<WDWendaCellDataStructModel> *)@[];
    self.tips = nil;
}
@end

@implementation WDWendaCommitBuryanswerRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/f100/wenda/v1/commit/buryanswer";
        self._response = @"WDWendaCommitBuryanswerResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:_bury_type forKey:@"bury_type"];
    [params setValue:_enter_from forKey:@"enter_from"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitBuryanswerResponseModel
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

@implementation WDWendaCommitDeleteanswerRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/deleteanswer";
        self._response = @"WDWendaCommitDeleteanswerResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitDeleteanswerResponseModel
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

@implementation WDWendaCommitDeletequestionRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/deletequestion";
        self._response = @"WDWendaCommitDeletequestionResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitDeletequestionResponseModel
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
    self.qid = nil;
}
@end

@implementation WDWendaCommitDigganswerRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/digganswer";
        self._response = @"WDWendaCommitDigganswerResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:_digg_type forKey:@"digg_type"];
    [params setValue:_enter_from forKey:@"enter_from"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitDigganswerResponseModel
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

@implementation WDWendaCommitEditanswerRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/editanswer";
        self._response = @"WDWendaCommitEditanswerResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:_content forKey:@"content"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_ban_comment forKey:@"ban_comment"];

    return params;
}

@end


@implementation WDWendaCommitEditanswerResponseModel
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
    self.ansid = nil;
    self.schema = nil;
    self.content_abstract = nil;
}
@end

@implementation WDWendaCommitEditquestionRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/editquestion";
        self._response = @"WDWendaCommitEditquestionResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_title forKey:@"title"];
    [params setValue:_content forKey:@"content"];
    [params setValue:_pic_list forKey:@"pic_list"];
    [params setValue:_concern_ids forKey:@"concern_ids"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitEditquestionResponseModel
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
    self.qid = nil;
    self.schema = nil;
}
@end

@implementation WDWendaCommitEditquestiontagRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/editquestiontag";
        self._response = @"WDWendaCommitEditquestiontagResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_concern_ids forKey:@"concern_ids"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitEditquestiontagResponseModel
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
    self.concern_tag_list = (NSArray<WDConcernTagStructModel> *)@[];
}
@end

@implementation WDWendaCommitFollowquestionRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/followquestion";
        self._response = @"WDWendaCommitFollowquestionResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_follow_type forKey:@"follow_type"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitFollowquestionResponseModel
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

@implementation WDWendaCommitIgnorequestionRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/ignorequestion";
        self._response = @"WDWendaCommitIgnorequestionResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitIgnorequestionResponseModel
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

@implementation WDWendaCommitInviteuserRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/inviteuser";
        self._response = @"WDWendaCommitInviteuserResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_to_uid forKey:@"to_uid"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitInviteuserResponseModel
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

@implementation WDPostAnswerTipsStructModel
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
    self.schema = nil;
    self.icon_day_url = nil;
    self.icon_night_url = nil;
}
@end

@implementation WDWendaCommitPostanswerRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/postanswer";
        self._response = @"WDWendaCommitPostanswerResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_content forKey:@"content"];
    [params setValue:_forward_pgc forKey:@"forward_pgc"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_ban_comment forKey:@"ban_comment"];
    [params setValue:_list_entrance forKey:@"list_entrance"];
    [params setValue:_source forKey:@"source"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];

    return params;
}

@end


@implementation WDWendaCommitPostanswerResponseModel
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
    self.qid = nil;
    self.ansid = nil;
    self.schema = nil;
    self.tips = nil;
}
@end

@implementation WDWendaCommitPostquestionRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/postquestion";
        self._response = @"WDWendaCommitPostquestionResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_title forKey:@"title"];
    [params setValue:_content forKey:@"content"];
    [params setValue:_pic_list forKey:@"pic_list"];
    [params setValue:_concern_ids forKey:@"concern_ids"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_list_entrance forKey:@"list_entrance"];
    [params setValue:_source forKey:@"source"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];

    return params;
}

@end


@implementation WDWendaCommitPostquestionResponseModel
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
    self.qid = nil;
    self.schema = nil;
}
@end

@implementation WDWendaCommitReportRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/commit/report";
        self._response = @"WDWendaCommitReportResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:@(_type) forKey:@"type"];
    [params setValue:_gid forKey:@"gid"];
    [params setValue:_report_type forKey:@"report_type"];
    [params setValue:_report_message forKey:@"report_message"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaCommitReportResponseModel
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

@implementation WDWendaConcernBrowRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/concern/brow";
        self._response = @"WDWendaConcernBrowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_concern_id forKey:@"concern_id"];
    [params setValue:_min_behot_time forKey:@"min_behot_time"];
    [params setValue:_max_behot_time forKey:@"max_behot_time"];
    [params setValue:_wenda_extra forKey:@"wenda_extra"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];

    return params;
}

@end


@implementation WDWendaConcernBrowResponseModel
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
    self.login_status = nil;
    self.total_number = nil;
    self.has_more = nil;
    self.message = nil;
    self.has_more_to_refresh = nil;
    self.extra = nil;
    self.data = (NSArray<WDWendaCellDataStructModel> *)@[];
    self.tips = nil;
}
@end

@implementation WDWendaConcerntagSearchRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/concerntag/search";
        self._response = @"WDWendaConcerntagSearchResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_name forKey:@"name"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaConcerntagSearchResponseModel
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
    self.concern_tag_list = (NSArray<WDConcernTagStructModel> *)@[];
    self.name = nil;
}
@end

@implementation WDWendaDeleteDraftRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/delete/draft";
        self._response = @"WDWendaDeleteDraftResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];

    return params;
}

@end


@implementation WDWendaDeleteDraftResponseModel
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

@implementation WDWendaDiggUserlistRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/digg/userlist";
        self._response = @"WDWendaDiggUserlistResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:_cursor forKey:@"cursor"];
    [params setValue:_count forKey:@"count"];

    return params;
}

@end


@implementation WDWendaDiggUserlistResponseModel
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
    self.user_list = (NSArray<WDUserStructModel> *)@[];
    self.cursor = nil;
}
@end

@implementation WDWendaFetchAnswerdraftRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/fetch/answerdraft";
        self._response = @"WDWendaFetchAnswerdraftResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];

    return params;
}

@end


@implementation WDWendaFetchAnswerdraftResponseModel
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
    self.answer = nil;
}
@end

@implementation WDFetchTipsStructModel
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
    self.icon_day_url = nil;
    self.icon_night_url = nil;
    self.text = nil;
    self.schema = nil;
    self.url = nil;
}
@end

@implementation WDWendaFetchTipsRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/fetch/tips";
        self._response = @"WDWendaFetchTipsResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_tips_source forKey:@"tips_source"];

    return params;
}

@end


@implementation WDWendaFetchTipsResponseModel
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
}
@end

@implementation WDWendaIcimageBrowRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/icimage/brow";
        self._response = @"WDWendaIcimageBrowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_text forKey:@"text"];
    [params setValue:_is_title forKey:@"is_title"];
    [params setValue:_only_preview forKey:@"only_preview"];

    return params;
}

@end


@implementation WDWendaIcimageBrowResponseModel
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
    self.img_list = (NSArray<WDIcImageStructModel> *)@[];
    self.offset = nil;
    self.req_count = nil;
    self.has_more = nil;
    self.term = nil;
}
@end

@implementation WDWendaIcimageLoadmoreRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/icimage/loadmore";
        self._response = @"WDWendaIcimageLoadmoreResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_term forKey:@"term"];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_count forKey:@"count"];

    return params;
}

@end


@implementation WDWendaIcimageLoadmoreResponseModel
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
    self.img_list = (NSArray<WDIcImageStructModel> *)@[];
    self.offset = nil;
    self.req_count = nil;
    self.has_more = nil;
    self.term = nil;
}
@end

@implementation WDWendaInviteUserlistRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/invite/userlist";
        self._response = @"WDWendaInviteUserlistResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaInviteUserlistResponseModel
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
    self.invite_user_list = (NSArray<WDInviteAggrUserStructModel> *)@[];
}
@end

@implementation WDWendaInvitedQuestionbrowRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/invited/questionbrow";
        self._response = @"WDWendaInvitedQuestionbrowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_min_behot_time forKey:@"min_behot_time"];
    [params setValue:_max_behot_time forKey:@"max_behot_time"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaInvitedQuestionbrowResponseModel
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
    self.wenda_invited_question_list = (NSArray<WDWendaInvitedQuestionStructModel> *)@[];
    self.has_more = nil;
    self.has_more_to_refresh = nil;
    self.total_number = nil;
    self.tips = nil;
}
@end

@implementation WDLinkCheckStructModel
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
    self.is_legal = nil;
    self.title = nil;
}
@end

@implementation WDWendaLinkCheckRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/link/check";
        self._response = @"WDWendaLinkCheckResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_link forKey:@"link"];

    return params;
}

@end


@implementation WDWendaLinkCheckResponseModel
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
    self.link_data = nil;
}
@end

@implementation WDWendaNativeFeedbrowRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/native/feedbrow";
        self._response = @"WDWendaNativeFeedbrowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_min_behot_time forKey:@"min_behot_time"];
    [params setValue:_max_behot_time forKey:@"max_behot_time"];
    [params setValue:_wenda_extra forKey:@"wenda_extra"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaNativeFeedbrowResponseModel
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
    self.login_status = nil;
    self.total_number = nil;
    self.has_more = nil;
    self.message = nil;
    self.has_more_to_refresh = nil;
    self.extra = nil;
    self.data = (NSArray<WDWendaCellDataStructModel> *)@[];
    self.tips = nil;
    self.api_param = nil;
    self.add_first_page = nil;
}
@end

@implementation WDWendaOpanswerCommentRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/opanswer/comment";
        self._response = @"WDWendaOpanswerCommentResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:@(_op_type) forKey:@"op_type"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaOpanswerCommentResponseModel
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

@implementation WDWendaPostDislikeRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/post/dislike";
        self._response = @"WDWendaPostDislikeResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_item_list forKey:@"item_list"];
    [params setValue:_msg_id forKey:@"msg_id"];
    [params setValue:_cursor forKey:@"cursor"];

    return params;
}

@end


@implementation WDWendaPostDislikeResponseModel
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

@implementation WDWendaPostDraftRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/post/draft";
        self._response = @"WDWendaPostDraftResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_content forKey:@"content"];

    return params;
}

@end


@implementation WDWendaPostDraftResponseModel
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

@implementation WDWendaPostScoringRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/post/scoring";
        self._response = @"WDWendaPostScoringResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_ansid forKey:@"ansid"];
    [params setValue:_score forKey:@"score"];
    [params setValue:_stay_time forKey:@"stay_time"];

    return params;
}

@end


@implementation WDWendaPostScoringResponseModel
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

@implementation WDWendaQuestionAssociationRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/question/association";
        self._response = @"WDWendaQuestionAssociationResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_title forKey:@"title"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaQuestionAssociationResponseModel
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
    self.question_list = (NSArray<WDSimpleQuestionStructModel> *)@[];
    self.title = nil;
}
@end

@implementation WDWendaQuestionBrowRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/question/brow";
        self._response = @"WDWendaQuestionBrowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_scope forKey:@"scope"];
    [params setValue:_enter_from forKey:@"enter_from"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];

    return params;
}

@end


@implementation WDWendaQuestionBrowResponseModel
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
    self.question = nil;
    self.ans_list = (NSArray<WDAnswerStructModel> *)@[];
    self.offset = nil;
    self.has_more = nil;
    self.candidate_invite_user = (NSArray<WDInviteUserStructModel> *)@[];
    self.show_format = nil;
    self.channel_schema = nil;
    self.module_count = nil;
    self.module_list = (NSArray<WDModuleStructModel> *)@[];
    self.question_header_content_fold_max_count = nil;
    self.related_question_banner_type = nil;
    self.related_question_title = nil;
    self.related_question_url = nil;
    self.can_answer = nil;
    self.related_question_reason_url = nil;
    self.profit = nil;
    self.has_profit = nil;
    self.share_profit = nil;
    self.repost_params = nil;
}
@end

@implementation WDWendaQuestionChecktitleRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/question/checktitle";
        self._response = @"WDWendaQuestionChecktitleResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_title forKey:@"title"];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaQuestionChecktitleResponseModel
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
    self.title = nil;
    self.similar_question = nil;
}
@end

@implementation WDWendaQuestionDefaulttagRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/question/defaulttag";
        self._response = @"WDWendaQuestionDefaulttagResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_title forKey:@"title"];
    [params setValue:_content forKey:@"content"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaQuestionDefaulttagResponseModel
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
    self.concern_tags = (NSArray<WDConcernTagStructModel> *)@[];
}
@end

@implementation WDWendaQuestionLoadmoreRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/question/loadmore";
        self._response = @"WDWendaQuestionLoadmoreResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];

    return params;
}

@end


@implementation WDWendaQuestionLoadmoreResponseModel
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
    self.ans_list = (NSArray<WDAnswerStructModel> *)@[];
    self.offset = nil;
    self.has_more = nil;
}
@end

@implementation WDWendaQuestionStatusRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/question/status";
        self._response = @"WDWendaQuestionStatusResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaQuestionStatusResponseModel
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
    self.question = nil;
    self.tips = nil;
    self.tips_url = nil;
    self.candidate_invite_user = (NSArray<WDInviteUserStructModel> *)@[];
}
@end

@implementation WDWendaQuestionotherBrowRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/questionother/brow";
        self._response = @"WDWendaQuestionotherBrowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];

    return params;
}

@end


@implementation WDWendaQuestionotherBrowResponseModel
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
    self.ans_list = (NSArray<WDAnswerStructModel> *)@[];
    self.offset = nil;
    self.has_more = nil;
}
@end

@implementation WDWendaQuestionotherLoadmoreRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/questionother/loadmore";
        self._response = @"WDWendaQuestionotherLoadmoreResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_count forKey:@"count"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];

    return params;
}

@end


@implementation WDWendaQuestionotherLoadmoreResponseModel
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
    self.ans_list = (NSArray<WDAnswerStructModel> *)@[];
    self.offset = nil;
    self.has_more = nil;
}
@end

@implementation WDDataStructModel
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
    self.cell_type = nil;
    self.login_status = nil;
    self.user = nil;
    self.tips = nil;
    self.wenda_description = nil;
    self.schema = nil;
    self.tabs = (NSArray<WDTabStructModel> *)@[];
}
@end

@implementation WDTabStructModel
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
    self.tab_type = nil;
    self.name = nil;
    self.tips = nil;
    self.day_icon = nil;
    self.night_icon = nil;
    self.schema = nil;
}
@end

@implementation WDWendaRefreshNativewidgetRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/refresh/nativewidget";
        self._response = @"WDWendaRefreshNativewidgetResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaRefreshNativewidgetResponseModel
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

@implementation WDSearchUserStructModel
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
    self.highlight = (NSArray<WDHighlightStructModel> *)@[];
}
@end

@implementation WDWendaSearchInvitelistRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/search/invitelist";
        self._response = @"WDWendaSearchInvitelistResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_search_text forKey:@"search_text"];
    [params setValue:_qid forKey:@"qid"];

    return params;
}

@end


@implementation WDWendaSearchInvitelistResponseModel
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
    self.user_list = (NSArray<WDSearchUserStructModel> *)@[];
}
@end

@implementation WDWendaUploadGetvideouploadurlRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/upload/getvideouploadurl";
        self._response = @"WDWendaUploadGetvideouploadurlResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_uplaod_id forKey:@"uplaod_id"];

    return params;
}

@end


@implementation WDWendaUploadGetvideouploadurlResponseModel
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
    self.upload_id = nil;
    self.upload_url = nil;
    self.chunk_size = nil;
}
@end

@implementation WDUploadImgDataStructModel
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
    self.url_list = (NSArray<WDMagicUrlStructModel> *)@[];
    self.web_uri = nil;
}
@end

@implementation WDWendaUploadImageRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/upload/image";
        self._response = @"WDWendaUploadImageResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_ic_id forKey:@"ic_id"];
    [params setValue:_term forKey:@"term"];

    return params;
}

@end


@implementation WDWendaUploadImageResponseModel
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

@implementation WDWendaUserAskprivilegeRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/user/askprivilege";
        self._response = @"WDWendaUserAskprivilegeResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_type forKey:@"type"];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaUserAskprivilegeResponseModel
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
    self.has_privilege = nil;
    self.can_ask = nil;
    self.can_use_ic = nil;
}
@end

@implementation WDWendaUsertagBrowRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v1/usertag/brow";
        self._response = @"WDWendaUsertagBrowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_api_param forKey:@"api_param"];

    return params;
}

@end


@implementation WDWendaUsertagBrowResponseModel
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
    self.start_offset = nil;
    self.end_offset = nil;
    self.tag_list = (NSArray<WDConcernTagStructModel> *)@[];
}
@end

@implementation WDWendaListCellStructModel
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
    self.cell_type = 0;
    self.layout_type = 0;
    self.answer = nil;
    self.show_lines = nil;
    self.max_lines = nil;
}
@end

@implementation WDRelatedQuestionStructModel
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
    self.banner_type = nil;
    self.title = nil;
    self.question_schema = nil;
    self.reason_schema = nil;
}
@end

@implementation WDWendaV2QuestionBrowRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [WDCommonURLSetting baseURL];
        self._uri = @"/f100/wenda/v2/question/brow";
        self._response = @"WDWendaV2QuestionBrowResponseModel";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_qid forKey:@"qid"];
    [params setValue:_api_param forKey:@"api_param"];
    [params setValue:_gd_ext_json forKey:@"gd_ext_json"];
    [params setValue:_offset forKey:@"offset"];
    [params setValue:_count forKey:@"count"];
    [params setValue:@(_request_type) forKey:@"request_type"];

    return params;
}

@end


@implementation WDWendaV2QuestionBrowResponseModel
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
    self.question = nil;
    self.data = (NSArray<WDWendaListCellStructModel> *)@[];
    self.offset = nil;
    self.has_more = nil;
    self.api_param = nil;
    self.module_list = (NSArray<WDModuleStructModel> *)@[];
    self.can_answer = nil;
    self.header_max_lines = nil;
    self.related_question = nil;
    self.has_profit = nil;
    self.profit = nil;
    self.share_profit = nil;
    self.repost_params = nil;
    self.candidate_invite_user = (NSArray<WDInviteUserStructModel> *)@[];
}
@end

