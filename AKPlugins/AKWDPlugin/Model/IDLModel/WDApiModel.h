#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TTRequestModel.h"
#import "TTResponseModel.h"
#import "WDBaseModel.h"

#import "WDCommonURLSetting.h"

typedef NS_ENUM(NSInteger, WDImageType) {
    WDImageTypeDefaultImage = 0,
    WDImageTypeJpeg = 1,
    WDImageTypeGif = 2,
    WDImageTypeBmp = 3,
    WDImageTypePng = 4,
};

typedef NS_ENUM(NSInteger, WDObjectType) {
    WDObjectTypeQUESTION = 1,
    WDObjectTypeANSWER = 2,
    WDObjectTypeCOMMENT = 3,
    WDObjectTypeQUICK_QUESTION = 4,
    WDObjectTypeQUICK_ANSWER = 5,
};

typedef NS_ENUM(NSInteger, WDOPCommentType) {
    WDOPCommentTypeForbidComment = 0,
    WDOPCommentTypeUnForbidComment = 1,
};

typedef NS_ENUM(NSInteger, WDQuestionStatus) {
    WDQuestionStatusNORMAL = 0,
    WDQuestionStatusAUDITING = 1,
    WDQuestionStatusRECOMMEND_MODIFY = 2,
    WDQuestionStatusDENY = 3,
    WDQuestionStatusSELF_DELETE = 4,
    WDQuestionStatusOTHER_DELETE = 5,
};

typedef NS_ENUM(NSInteger, WDAnswerStatus) {
    WDAnswerStatusNORMAL = 0,
    WDAnswerStatusAUDITING = 2,
    WDAnswerStatusAUDIT_DENY = 3,
    WDAnswerStatusSELF_DELETE = 4,
    WDAnswerStatusOTHER_DELETE = 5,
};

typedef NS_ENUM(NSInteger, WDUserInvitedStatus) {
    WDUserInvitedStatusHAS_INVITED = 0,
    WDUserInvitedStatusCAN_INVITE = 1,
    WDUserInvitedStatusIS_ANSWERED = 2,
};

typedef NS_ENUM(NSInteger, WDInvitedQuestionType) {
    WDInvitedQuestionTypeUSER_INVITED = 0,
    WDInvitedQuestionTypeSYSTEM_INVITED = 1,
};

typedef NS_ENUM(NSInteger, WDIconType) {
    WDIconTypeQUESTION_POST = 1,
    WDIconTypeCHANNEL = 2,
    WDIconTypeINVITED = 3,
};

typedef NS_ENUM(NSInteger, WDWendaListCellType) {
    WDWendaListCellTypeANSWER = 0,
};

typedef NS_ENUM(NSInteger, WDWendaListLayoutType) {
    WDWendaListLayoutTypeDEFAULT_ANSWER = 0,
    WDWendaListLayoutTypeLIGHT_ANSWER = 1,
};

typedef NS_ENUM(NSInteger, WDWendaListRequestType) {
    WDWendaListRequestTypeNICE = 0,
    WDWendaListRequestTypeNORMAL = 1,
};

@class WDImageUrlStructModel,WDVideoInfoStructModel,WDMagicUrlStructModel,WDQuestionDescStructModel,WDAbstractStructModel,WDShareStructModel,WDAnswerFoldReasonStructModel,WDUserStructModel,WDActivityStructModel,WDRedPackStructModel,WDUserFullStructModel,WDConcernTagStructModel,WDSimpleQuestionStructModel,WDHighlightStructModel,WDQuestionStructModel,WDAnswerStructModel,WDProfitLabelStructModel,WDAnswerDraftStructModel,WDUserPositionStructModel,WDUserPrivilegeStructModel,WDRelatedWendaStructModel,WDRecommendFirstPageStructModel,WDDetailPermStructModel,WDDetailMediaInfoStructModel,WDDetailRelatedWendaStructModel,WDDetailWendaStructModel,WDDetailImageUrlStructModel,WDDetailImageStructModel,WDWendaCellDataStructModel,WDTipsStructModel,WDWendaInvitedQuestionStructModel,WDWidgetStructModel,WDInviteUserStructModel,WDInviteAggrUserStructModel,WDShowFormatStructModel,WDIcImageStructModel,WDRecommendSponsorStructModel,WDForwardStructModel,WDModuleStructModel,WDProfitStructModel,WDShareProfitStructModel,WDStreamAnswerStructModel,WDStreamQuestionStructModel,WDStreamUserStructModel,WDFilterWorldStructModel,WDAnswerCellDataStructModel,WDWendaAnswerCellStructModel,WDQuestionCellDataStructModel,WDWendaQuestionCellStructModel,WDOrderedItemStructModel,WDOrderedItemInfoStructModel,WDNextPageStructModel,WDWendaAnswerInformationResponseModel,WDWendaAnswerInformationRequestModel,WDNextItemStructModel,WDWendaAnswerListResponseModel,WDWendaAnswerListRequestModel,WDWendaAnswerRawResponseModel,WDWendaAnswerRawRequestModel,WDWendaCategoryBrowResponseModel,WDWendaCategoryBrowRequestModel,WDWendaCommitBuryanswerResponseModel,WDWendaCommitBuryanswerRequestModel,WDWendaCommitDeleteanswerResponseModel,WDWendaCommitDeleteanswerRequestModel,WDWendaCommitDeletequestionResponseModel,WDWendaCommitDeletequestionRequestModel,WDWendaCommitDigganswerResponseModel,WDWendaCommitDigganswerRequestModel,WDWendaCommitEditanswerResponseModel,WDWendaCommitEditanswerRequestModel,WDWendaCommitEditquestionResponseModel,WDWendaCommitEditquestionRequestModel,WDWendaCommitEditquestiontagResponseModel,WDWendaCommitEditquestiontagRequestModel,WDWendaCommitFollowquestionResponseModel,WDWendaCommitFollowquestionRequestModel,WDWendaCommitIgnorequestionResponseModel,WDWendaCommitIgnorequestionRequestModel,WDWendaCommitInviteuserResponseModel,WDWendaCommitInviteuserRequestModel,WDPostAnswerTipsStructModel,WDWendaCommitPostanswerResponseModel,WDWendaCommitPostanswerRequestModel,WDWendaCommitPostquestionResponseModel,WDWendaCommitPostquestionRequestModel,WDWendaCommitReportResponseModel,WDWendaCommitReportRequestModel,WDWendaConcernBrowResponseModel,WDWendaConcernBrowRequestModel,WDWendaConcerntagSearchResponseModel,WDWendaConcerntagSearchRequestModel,WDWendaDeleteDraftResponseModel,WDWendaDeleteDraftRequestModel,WDWendaDiggUserlistResponseModel,WDWendaDiggUserlistRequestModel,WDWendaFetchAnswerdraftResponseModel,WDWendaFetchAnswerdraftRequestModel,WDFetchTipsStructModel,WDWendaFetchTipsResponseModel,WDWendaFetchTipsRequestModel,WDWendaIcimageBrowResponseModel,WDWendaIcimageBrowRequestModel,WDWendaIcimageLoadmoreResponseModel,WDWendaIcimageLoadmoreRequestModel,WDWendaInviteUserlistResponseModel,WDWendaInviteUserlistRequestModel,WDWendaInvitedQuestionbrowResponseModel,WDWendaInvitedQuestionbrowRequestModel,WDLinkCheckStructModel,WDWendaLinkCheckResponseModel,WDWendaLinkCheckRequestModel,WDWendaNativeFeedbrowResponseModel,WDWendaNativeFeedbrowRequestModel,WDWendaOpanswerCommentResponseModel,WDWendaOpanswerCommentRequestModel,WDWendaPostDislikeResponseModel,WDWendaPostDislikeRequestModel,WDWendaPostDraftResponseModel,WDWendaPostDraftRequestModel,WDWendaPostScoringResponseModel,WDWendaPostScoringRequestModel,WDWendaQuestionAssociationResponseModel,WDWendaQuestionAssociationRequestModel,WDWendaQuestionBrowResponseModel,WDWendaQuestionBrowRequestModel,WDWendaQuestionChecktitleResponseModel,WDWendaQuestionChecktitleRequestModel,WDWendaQuestionDefaulttagResponseModel,WDWendaQuestionDefaulttagRequestModel,WDWendaQuestionLoadmoreResponseModel,WDWendaQuestionLoadmoreRequestModel,WDWendaQuestionStatusResponseModel,WDWendaQuestionStatusRequestModel,WDWendaQuestionotherBrowResponseModel,WDWendaQuestionotherBrowRequestModel,WDWendaQuestionotherLoadmoreResponseModel,WDWendaQuestionotherLoadmoreRequestModel,WDDataStructModel,WDTabStructModel,WDWendaRefreshNativewidgetResponseModel,WDWendaRefreshNativewidgetRequestModel,WDSearchUserStructModel,WDWendaSearchInvitelistResponseModel,WDWendaSearchInvitelistRequestModel,WDWendaUploadGetvideouploadurlResponseModel,WDWendaUploadGetvideouploadurlRequestModel,WDUploadImgDataStructModel,WDWendaUploadImageResponseModel,WDWendaUploadImageRequestModel,WDWendaUserAskprivilegeResponseModel,WDWendaUserAskprivilegeRequestModel,WDWendaUsertagBrowResponseModel,WDWendaUsertagBrowRequestModel,WDWendaListCellStructModel,WDRelatedQuestionStructModel,WDWendaV2QuestionBrowResponseModel,WDWendaV2QuestionBrowRequestModel;

@protocol WDImageType @end
@protocol WDObjectType @end
@protocol WDOPCommentType @end
@protocol WDQuestionStatus @end
@protocol WDAnswerStatus @end
@protocol WDUserInvitedStatus @end
@protocol WDInvitedQuestionType @end
@protocol WDIconType @end
@protocol WDWendaListCellType @end
@protocol WDWendaListLayoutType @end
@protocol WDWendaListRequestType @end
@protocol WDImageUrlStructModel @end
@protocol WDVideoInfoStructModel @end
@protocol WDMagicUrlStructModel @end
@protocol WDQuestionDescStructModel @end
@protocol WDAbstractStructModel @end
@protocol WDShareStructModel @end
@protocol WDAnswerFoldReasonStructModel @end
@protocol WDUserStructModel @end
@protocol WDActivityStructModel @end
@protocol WDRedPackStructModel @end
@protocol WDUserFullStructModel @end
@protocol WDConcernTagStructModel @end
@protocol WDSimpleQuestionStructModel @end
@protocol WDHighlightStructModel @end
@protocol WDQuestionStructModel @end
@protocol WDAnswerStructModel @end
@protocol WDProfitLabelStructModel @end
@protocol WDAnswerDraftStructModel @end
@protocol WDUserPositionStructModel @end
@protocol WDUserPrivilegeStructModel @end
@protocol WDRelatedWendaStructModel @end
@protocol WDRecommendFirstPageStructModel @end
@protocol WDDetailPermStructModel @end
@protocol WDDetailMediaInfoStructModel @end
@protocol WDDetailRelatedWendaStructModel @end
@protocol WDDetailWendaStructModel @end
@protocol WDDetailImageUrlStructModel @end
@protocol WDDetailImageStructModel @end
@protocol WDWendaCellDataStructModel @end
@protocol WDTipsStructModel @end
@protocol WDWendaInvitedQuestionStructModel @end
@protocol WDWidgetStructModel @end
@protocol WDInviteUserStructModel @end
@protocol WDInviteAggrUserStructModel @end
@protocol WDShowFormatStructModel @end
@protocol WDIcImageStructModel @end
@protocol WDRecommendSponsorStructModel @end
@protocol WDForwardStructModel @end
@protocol WDModuleStructModel @end
@protocol WDProfitStructModel @end
@protocol WDShareProfitStructModel @end
@protocol WDStreamAnswerStructModel @end
@protocol WDStreamQuestionStructModel @end
@protocol WDStreamUserStructModel @end
@protocol WDFilterWorldStructModel @end
@protocol WDAnswerCellDataStructModel @end
@protocol WDWendaAnswerCellStructModel @end
@protocol WDQuestionCellDataStructModel @end
@protocol WDWendaQuestionCellStructModel @end
@protocol WDOrderedItemStructModel @end
@protocol WDOrderedItemInfoStructModel @end
@protocol WDNextPageStructModel @end
@protocol WDNextItemStructModel @end
@protocol WDPostAnswerTipsStructModel @end
@protocol WDFetchTipsStructModel @end
@protocol WDLinkCheckStructModel @end
@protocol WDDataStructModel @end
@protocol WDTabStructModel @end
@protocol WDSearchUserStructModel @end
@protocol WDUploadImgDataStructModel @end
@protocol WDWendaListCellStructModel @end
@protocol WDRelatedQuestionStructModel @end

@interface WDApiRequestModel : JSONModel
@property (strong, nonatomic) NSString *_uri;
@property (strong, nonatomic) NSString *_response;
@property (assign, nonatomic) BOOL _isGet;
@end

@interface WDApiResponseModel : JSONModel
@property (assign, nonatomic) NSInteger error;
@end

@interface  WDImageUrlStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *height;
@property (nonatomic, strong) NSNumber<Optional> *width;
@property (nonatomic, strong) NSString<Optional> *uri;
@property (nonatomic, strong) NSString<Optional> *url;
@property (nonatomic, copy) NSArray<WDMagicUrlStructModel, Optional>* url_list;
@property (nonatomic, assign) WDImageType type;
@end

@interface  WDVideoInfoStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *video_id;
@property (nonatomic, strong) WDImageUrlStructModel<Optional>* cover_pic;
@property (nonatomic, strong) NSNumber<Optional> *duration;
@end

@interface  WDMagicUrlStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *url;
@end

@interface  WDQuestionDescStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *text;
@property (nonatomic, copy) NSArray<WDImageUrlStructModel, Optional>* large_image_list;
@property (nonatomic, copy) NSArray<WDImageUrlStructModel, Optional>* thumb_image_list;
@property (nonatomic, strong) NSNumber<Optional> *question_abstract_fold;
@end

@interface  WDAbstractStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *text;
@property (nonatomic, copy) NSArray<WDImageUrlStructModel, Optional>* large_image_list;
@property (nonatomic, copy) NSArray<WDImageUrlStructModel, Optional>* thumb_image_list;
@property (nonatomic, copy) NSArray<WDVideoInfoStructModel, Optional>* video_list;
@end

@interface  WDShareStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSString<Optional> *image_url;
@property (nonatomic, strong) NSString<Optional> *share_url;
@end

@interface  WDAnswerFoldReasonStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *open_url;
@end

@interface  WDUserStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *user_id;
@property (nonatomic, strong) NSString<Optional> *uname;
@property (nonatomic, strong) NSString<Optional> *user_intro;
@property (nonatomic, strong) NSString<Optional> *avatar_url;
@property (nonatomic, strong) NSNumber<Optional> *is_verify;
@property (nonatomic, strong) NSString<Optional> *user_auth_info;
@property (nonatomic, copy) NSArray<Optional>* medals;
@property (nonatomic, strong) NSNumber<Optional> *is_following;
@property (nonatomic, strong) NSNumber<Optional> *is_followed;
@property (nonatomic, strong) NSNumber<Optional> *invite_status;
@property (nonatomic, strong) NSString<Optional> *user_schema;
@property (nonatomic, strong) NSNumber<Optional> *total_digg;
@property (nonatomic, strong) NSNumber<Optional> *total_answer;
@property (nonatomic, strong) WDActivityStructModel<Optional>* activity;
@property (nonatomic, strong) NSString<Optional> *user_decoration;
@end

@interface  WDActivityStructModel : WDBaseModel
@property (nonatomic, strong) WDRedPackStructModel<Optional>* redpack;
@end

@interface  WDRedPackStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *redpack_id;
@property (nonatomic, strong) NSString<Optional> *token;
@property (nonatomic, strong) NSNumber<Optional> *button_style;
@property (nonatomic, strong) WDUserStructModel<Optional>* user_info;
@property (nonatomic, strong) NSString<Optional> *subtitle;
@property (nonatomic, strong) NSString<Optional> *content;
@end

@interface  WDUserFullStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *user_id;
@property (nonatomic, strong) NSString<Optional> *uname;
@property (nonatomic, strong) NSString<Optional> *user_intro;
@property (nonatomic, strong) NSString<Optional> *avatar_url;
@property (nonatomic, strong) NSNumber<Optional> *is_verify;
@property (nonatomic, strong) NSString<Optional> *user_schema;
@property (nonatomic, strong) NSString<Optional> *v_icon;
@property (nonatomic, strong) NSString<Optional> *user_honor;
@property (nonatomic, strong) NSNumber<Optional> *is_followed;
@property (nonatomic, strong) NSNumber<Optional> *is_following;
@property (nonatomic, strong) NSNumber<Optional> *is_blocking;
@property (nonatomic, strong) NSNumber<Optional> *is_blocked;
@property (nonatomic, strong) NSString<Optional> *user_auth_info;
@end

@interface  WDConcernTagStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *concern_id;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *schema;
@end

@interface  WDSimpleQuestionStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, strong) NSNumber<Optional> *ans_count;
@property (nonatomic, copy) NSArray<WDHighlightStructModel, Optional>* highlight;
@end

@interface  WDHighlightStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *start;
@property (nonatomic, strong) NSNumber<Optional> *end;
@end

@interface  WDQuestionStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSNumber<Optional> *create_time;
@property (nonatomic, strong) WDUserStructModel<Optional>* user;
@property (nonatomic, strong) WDQuestionDescStructModel<Optional>* content;
@property (nonatomic, strong) NSNumber<Optional> *nice_ans_count;
@property (nonatomic, strong) NSNumber<Optional> *normal_ans_count;
@property (nonatomic, strong) WDShareStructModel<Optional>* share_data;
@property (nonatomic, strong) WDAnswerFoldReasonStructModel<Optional>* fold_reason;
@property (nonatomic, strong) NSNumber<Optional> *status;
@property (nonatomic, copy) NSArray<WDConcernTagStructModel, Optional>* concern_tag_list;
@property (nonatomic, strong) NSNumber<Optional> *is_follow;
@property (nonatomic, strong) NSNumber<Optional> *follow_count;
@property (nonatomic, strong) NSNumber<Optional> *can_edit;
@property (nonatomic, strong) NSNumber<Optional> *show_edit;
@property (nonatomic, strong) NSNumber<Optional> *can_delete;
@property (nonatomic, strong) NSNumber<Optional> *show_delete;
@property (nonatomic, strong) NSString<Optional> *post_answer_url;
@property (nonatomic, strong) WDRecommendSponsorStructModel<Optional>* recommend_sponsor;
@end

@interface  WDAnswerStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSNumber<Optional> *create_time;
@property (nonatomic, strong) WDUserStructModel<Optional>* user;
@property (nonatomic, strong) WDAbstractStructModel<Optional>* content_abstract;
@property (nonatomic, strong) NSNumber<Optional> *digg_count;
@property (nonatomic, strong) NSNumber<Optional> *is_digg;
@property (nonatomic, strong) NSString<Optional> *ans_url;
@property (nonatomic, strong) WDShareStructModel<Optional>* share_data;
@property (nonatomic, strong) NSNumber<Optional> *bury_count;
@property (nonatomic, strong) NSNumber<Optional> *is_buryed;
@property (nonatomic, strong) NSNumber<Optional> *is_show_bury;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, strong) NSNumber<Optional> *comment_count;
@property (nonatomic, strong) NSNumber<Optional> *brow_count;
@property (nonatomic, strong) NSNumber<Optional> *forward_count;
@property (nonatomic, strong) NSString<Optional> *comment_schema;
@property (nonatomic, strong) NSNumber<Optional> *modify_time;
@property (nonatomic, strong) WDProfitLabelStructModel<Optional>* profit_label;
@property (nonatomic, strong) NSNumber<Optional> *is_light_answer;
@end

@interface  WDProfitLabelStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *icon_day_url;
@property (nonatomic, strong) NSString<Optional> *icon_night_url;
@property (nonatomic, strong) NSString<Optional> *text;
@property (nonatomic, strong) NSString<Optional> *amount;
@end

@interface  WDAnswerDraftStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *draft;
@property (nonatomic, strong) NSNumber<Optional> *modify_time;
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *question_title;
@property (nonatomic, strong) WDAbstractStructModel<Optional>* content_abstract;
@property (nonatomic, strong) NSString<Optional> *schema;
@end

@interface  WDUserPositionStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *start;
@property (nonatomic, strong) NSNumber<Optional> *end;
@property (nonatomic, strong) NSString<Optional> *schema;
@end

@interface  WDUserPrivilegeStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *can_delete_answer;
@property (nonatomic, strong) NSNumber<Optional> *can_comment_answer;
@property (nonatomic, strong) NSNumber<Optional> *can_digg_answer;
@end

@interface  WDRelatedWendaStructModel : WDBaseModel
@property (nonatomic, assign) WDObjectType type;
@property (nonatomic, strong) WDQuestionStructModel<Optional>* question;
@property (nonatomic, strong) WDAnswerStructModel<Optional>* answer;
@property (nonatomic, strong) NSString<Optional> *schema;
@end

@interface  WDRecommendFirstPageStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *pos;
@property (nonatomic, strong) NSString<Optional> *text;
@end

@interface  WDDetailPermStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *can_ban_comment;
@property (nonatomic, strong) NSNumber<Optional> *can_delete_answer;
@property (nonatomic, strong) NSNumber<Optional> *can_delete_comment;
@property (nonatomic, strong) NSNumber<Optional> *can_post_answer;
@property (nonatomic, strong) NSNumber<Optional> *can_comment_answer;
@property (nonatomic, strong) NSNumber<Optional> *can_digg_answer;
@property (nonatomic, strong) NSNumber<Optional> *can_edit_answer;
@end

@interface  WDDetailMediaInfoStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *media_id;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *avatar_url;
@property (nonatomic, strong) NSNumber<Optional> *subscribed;
@end

@interface  WDDetailRelatedWendaStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *open_page_url;
@property (nonatomic, strong) NSString<Optional> *type_name;
@property (nonatomic, strong) NSString<Optional> *impr_id;
@end

@interface  WDDetailWendaStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *ansid;
@property (nonatomic, strong) NSNumber<Optional> *ans_count;
@property (nonatomic, strong) NSNumber<Optional> *digg_count;
@property (nonatomic, strong) NSNumber<Optional> *brow_count;
@property (nonatomic, strong) WDDetailPermStructModel<Optional>* perm;
@property (nonatomic, strong) NSNumber<Optional> *is_ban_comment;
@property (nonatomic, strong) NSNumber<Optional> *is_concern_user;
@property (nonatomic, strong) NSNumber<Optional> *is_digg;
@property (nonatomic, strong) NSNumber<Optional> *is_answer_delete;
@property (nonatomic, strong) NSNumber<Optional> *is_question_delete;
@property (nonatomic, strong) NSNumber<Optional> *bury_count;
@property (nonatomic, strong) NSNumber<Optional> *is_buryed;
@property (nonatomic, strong) NSNumber<Optional> *is_show_bury;
@property (nonatomic, strong) NSString<Optional> *edit_answer_url;
@property (nonatomic, strong) NSNumber<Optional> *fans_count;
@end

@interface  WDDetailImageUrlStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *url;
@end

@interface  WDDetailImageStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *url;
@property (nonatomic, strong) NSNumber<Optional> *width;
@property (nonatomic, strong) NSNumber<Optional> *height;
@property (nonatomic, strong) NSString<Optional> *uri;
@property (nonatomic, copy) NSArray<WDDetailImageUrlStructModel, Optional>* url_list;
@end

@interface  WDWendaCellDataStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSString<Optional> *code;
@end

@interface  WDTipsStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *display_info;
@property (nonatomic, strong) NSString<Optional> *open_url;
@property (nonatomic, strong) NSString<Optional> *type;
@property (nonatomic, strong) NSString<Optional> *display_duration;
@property (nonatomic, strong) NSString<Optional> *app_name;
@end

@interface  WDWendaInvitedQuestionStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSNumber<Optional> *nice_ans_count;
@property (nonatomic, strong) NSNumber<Optional> *normal_ans_count;
@property (nonatomic, strong) NSNumber<Optional> *follow_count;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *list_schema;
@property (nonatomic, strong) NSNumber<Optional> *behot_time;
@property (nonatomic, strong) NSString<Optional> *post_answer_schema;
@property (nonatomic, strong) NSString<Optional> *invited_user_desc;
@property (nonatomic, assign) WDInvitedQuestionType invited_question_type;
@property (nonatomic, strong) NSNumber<Optional> *is_answered;
@property (nonatomic, strong) NSNumber<Optional> *background;
@property (nonatomic, strong) WDProfitLabelStructModel<Optional>* profit_label;
@end

@interface  WDWidgetStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *cell_height;
@property (nonatomic, strong) NSString<Optional> *data_url;
@property (nonatomic, strong) NSString<Optional> *template_url;
@property (nonatomic, strong) NSNumber<Optional> *id;
@property (nonatomic, strong) NSNumber<Optional> *refresh_interval;
@property (nonatomic, strong) NSNumber<Optional> *cell_type;
@property (nonatomic, strong) NSNumber<Optional> *is_deleted;
@property (nonatomic, strong) NSNumber<Optional> *behot_time;
@property (nonatomic, strong) NSNumber<Optional> *cursor;
@property (nonatomic, strong) NSString<Optional> *template_md5;
@property (nonatomic, strong) NSString<Optional> *data_callback;
@end

@interface  WDInviteUserStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *user_id;
@property (nonatomic, strong) NSString<Optional> *uname;
@property (nonatomic, strong) NSString<Optional> *user_intro;
@property (nonatomic, strong) NSString<Optional> *avatar_url;
@property (nonatomic, strong) NSNumber<Optional> *is_verify;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, assign) WDUserInvitedStatus invite_status;
@property (nonatomic, strong) NSString<Optional> *user_auth_info;
@property (nonatomic, strong) NSString<Optional> *user_decoration;
@end

@interface  WDInviteAggrUserStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *aggr_message;
@property (nonatomic, copy) NSArray<WDInviteUserStructModel, Optional>* candidate_invite_user;
@end

@interface  WDShowFormatStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *font_size;
@property (nonatomic, strong) NSString<Optional> *answer_full_context_color;
@property (nonatomic, strong) NSNumber<Optional> *show_module;
@end

@interface  WDIcImageStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *small_img;
@property (nonatomic, strong) NSString<Optional> *medium_img;
@property (nonatomic, strong) NSNumber<Optional> *img_id;
@end

@interface  WDRecommendSponsorStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *icon_url;
@property (nonatomic, strong) NSString<Optional> *target_url;
@property (nonatomic, strong) NSString<Optional> *label;
@end

@interface  WDForwardStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *repost_type;
@property (nonatomic, strong) NSNumber<Optional> *fw_id;
@property (nonatomic, strong) NSNumber<Optional> *fw_id_type;
@property (nonatomic, strong) NSNumber<Optional> *fw_user_id;
@property (nonatomic, strong) NSNumber<Optional> *opt_id;
@property (nonatomic, strong) NSNumber<Optional> *opt_id_type;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *cover_url;
@end

@interface  WDModuleStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *day_icon_url;
@property (nonatomic, strong) NSString<Optional> *night_icon_url;
@property (nonatomic, strong) NSString<Optional> *text;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, assign) WDIconType icon_type;
@end

@interface  WDProfitStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *profit_time;
@property (nonatomic, strong) NSString<Optional> *sponsor_name;
@property (nonatomic, strong) NSString<Optional> *sponsor_url;
@property (nonatomic, strong) NSString<Optional> *sponsor_postfix;
@property (nonatomic, strong) NSString<Optional> *about_text;
@property (nonatomic, strong) NSString<Optional> *about_url;
@property (nonatomic, strong) NSString<Optional> *icon_day_url;
@property (nonatomic, strong) NSString<Optional> *icon_night_url;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, copy) NSArray<WDHighlightStructModel, Optional>* highlight;
@end

@interface  WDShareProfitStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *text;
@property (nonatomic, strong) NSString<Optional> *icon_day_url;
@property (nonatomic, strong) NSString<Optional> *icon_night_url;
@property (nonatomic, strong) NSString<Optional> *schema;
@end

@interface  WDStreamAnswerStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *abstract_text;
@property (nonatomic, strong) NSNumber<Optional> *brow_count;
@property (nonatomic, strong) NSNumber<Optional> *digg_count;
@property (nonatomic, strong) NSNumber<Optional> *comment_count;
@property (nonatomic, strong) NSNumber<Optional> *forward_count;
@property (nonatomic, strong) NSNumber<Optional> *is_digg;
@property (nonatomic, strong) NSString<Optional> *answer_detail_schema;
@property (nonatomic, copy) NSArray<WDImageUrlStructModel, Optional>* thumb_image_list;
@property (nonatomic, copy) NSArray<WDImageUrlStructModel, Optional>* large_image_list;
@property (nonatomic, assign) WDAnswerStatus status;
@property (nonatomic, strong) NSNumber<Optional> *create_time;
@end

@interface  WDStreamQuestionStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) WDQuestionDescStructModel<Optional>* content;
@property (nonatomic, strong) NSString<Optional> *question_list_schema;
@property (nonatomic, strong) NSNumber<Optional> *nice_ans_count;
@property (nonatomic, strong) NSNumber<Optional> *normal_ans_count;
@property (nonatomic, strong) NSNumber<Optional> *follow_count;
@property (nonatomic, strong) NSString<Optional> *write_answer_schema;
@property (nonatomic, assign) WDQuestionStatus status;
@property (nonatomic, strong) NSNumber<Optional> *create_time;
@end

@interface  WDStreamUserStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *user_id;
@property (nonatomic, strong) NSString<Optional> *uname;
@property (nonatomic, strong) NSString<Optional> *avatar_url;
@property (nonatomic, strong) NSString<Optional> *user_auth_info;
@property (nonatomic, strong) NSNumber<Optional> *is_following;
@property (nonatomic, strong) NSNumber<Optional> *is_verify;
@property (nonatomic, strong) NSString<Optional> *v_icon;
@property (nonatomic, strong) NSString<Optional> *user_schema;
@property (nonatomic, strong) NSString<Optional> *user_decoration;
@end

@interface  WDFilterWorldStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *id;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSNumber<Optional> *is_selected;
@end

@interface  WDAnswerCellDataStructModel : WDBaseModel
@property (nonatomic, strong) WDStreamQuestionStructModel<Optional>* question;
@property (nonatomic, strong) WDStreamAnswerStructModel<Optional>* answer;
@property (nonatomic, strong) WDStreamUserStructModel<Optional>* user;
@property (nonatomic, strong) NSString<Optional> *comment_schema;
@property (nonatomic, copy) NSArray<WDFilterWorldStructModel, Optional>* filter_words;
@property (nonatomic, strong) NSString<Optional> *recommend_reason;
@property (nonatomic, strong) NSNumber<Optional> *layout_type;
@property (nonatomic, strong) NSNumber<Optional> *image_type;
@property (nonatomic, strong) NSNumber<Optional> *default_lines;
@property (nonatomic, strong) NSNumber<Optional> *max_lines;
@property (nonatomic, strong) NSNumber<Optional> *jump_type;
@property (nonatomic, strong) WDForwardStructModel<Optional>* repost_params;
@end

@interface  WDWendaAnswerCellStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *group_id;
@property (nonatomic, strong) WDAnswerCellDataStructModel<Optional>* content;
@end

@interface  WDQuestionCellDataStructModel : WDBaseModel
@property (nonatomic, strong) WDStreamQuestionStructModel<Optional>* question;
@property (nonatomic, strong) WDStreamUserStructModel<Optional>* user;
@property (nonatomic, strong) NSNumber<Optional> *image_type;
@property (nonatomic, copy) NSArray<WDFilterWorldStructModel, Optional>* filter_words;
@property (nonatomic, strong) NSString<Optional> *recommend_reason;
@property (nonatomic, strong) NSNumber<Optional> *layout_type;
@property (nonatomic, strong) WDForwardStructModel<Optional>* repost_params;
@end

@interface  WDWendaQuestionCellStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *group_id;
@property (nonatomic, strong) WDQuestionCellDataStructModel<Optional>* content;
@end

@interface  WDOrderedItemStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *open_page_url;
@property (nonatomic, strong) NSString<Optional> *type_name;
@property (nonatomic, strong) NSString<Optional> *impr_id;
@property (nonatomic, strong) NSNumber<Optional> *item_id;
@property (nonatomic, strong) NSNumber<Optional> *group_id;
@property (nonatomic, strong) NSString<Optional> *aggr_type;
@property (nonatomic, strong) NSString<Optional> *link;
@property (nonatomic, strong) NSString<Optional> *word;
@end

@interface  WDOrderedItemInfoStructModel : WDBaseModel
@property (nonatomic, copy) NSArray<WDOrderedItemStructModel, Optional>* data;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *ad_data;
@property (nonatomic, strong) NSString<Optional> *related_data;
@end

@interface  WDNextPageStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *next_ansid;
@property (nonatomic, strong) NSString<Optional> *next_answer_schema;
@property (nonatomic, strong) NSString<Optional> *all_answer_text;
@property (nonatomic, strong) NSString<Optional> *next_answer_text;
@property (nonatomic, strong) NSNumber<Optional> *show_toast;
@property (nonatomic, strong) NSNumber<Optional> *has_next;
@end

@interface  WDWendaAnswerInformationRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *scope;
@property (nonatomic, strong) NSString<Optional> *enter_from;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@property (nonatomic, strong) NSNumber<Optional> *latitude;
@property (nonatomic, strong) NSNumber<Optional> *longitude;
@end

@interface  WDWendaAnswerInformationResponseModel : TTResponseModel
@property (nonatomic, copy) NSArray<WDOrderedItemInfoStructModel, Optional>* ordered_info;
@property (nonatomic, strong) WDDetailWendaStructModel<Optional>* wenda_data;
@property (nonatomic, strong) NSString<Optional> *share_url;
@property (nonatomic, strong) NSNumber<Optional> *wendaDelete;
@property (nonatomic, strong) WDDetailMediaInfoStructModel<Optional>* media_info;
@property (nonatomic, strong) NSNumber<Optional> *group_id;
@property (nonatomic, strong) NSString<Optional> *context;
@property (nonatomic, strong) NSString<Optional> *etag;
@property (nonatomic, strong) WDNextPageStructModel<Optional>* next_item_struct;
@property (nonatomic, strong) NSNumber<Optional> *user_repin;
@property (nonatomic, strong) NSString<Optional> *post_answer_schema;
@property (nonatomic, strong) NSString<Optional> *share_img;
@property (nonatomic, strong) NSString<Optional> *share_title;
@property (nonatomic, strong) WDRecommendSponsorStructModel<Optional>* recommend_sponsor;
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSString<Optional> *question_schema;
@property (nonatomic, strong) WDActivityStructModel<Optional>* activity;
@property (nonatomic, strong) WDForwardStructModel<Optional>* repost_params;
@property (nonatomic, strong) WDProfitLabelStructModel<Optional>* profit_label;
@property (nonatomic, strong) NSNumber<Optional> *show_tips;
@end

@interface  WDNextItemStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, strong) NSNumber<Optional> *show_toast;
@end

@interface  WDWendaAnswerListRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *scope;
@property (nonatomic, strong) NSString<Optional> *enter_from;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@end

@interface  WDWendaAnswerListResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDNextItemStructModel, Optional>* answer_list;
@end

@interface  WDWendaAnswerRawRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaAnswerRawResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSNumber<Optional> *is_ban_comment;
@property (nonatomic, strong) NSString<Optional> *content;
@end

@interface  WDWendaCategoryBrowRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *concern_id;
@property (nonatomic, strong) NSNumber<Optional> *min_behot_time;
@property (nonatomic, strong) NSNumber<Optional> *max_behot_time;
@property (nonatomic, strong) NSString<Optional> *wenda_extra;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCategoryBrowResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *login_status;
@property (nonatomic, strong) NSNumber<Optional> *total_number;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@property (nonatomic, strong) NSString<Optional> *message;
@property (nonatomic, strong) NSNumber<Optional> *has_more_to_refresh;
@property (nonatomic, strong) NSString<Optional> *extra;
@property (nonatomic, copy) NSArray<WDWendaCellDataStructModel, Optional>* data;
@property (nonatomic, strong) WDTipsStructModel<Optional>* tips;
@end

@interface  WDWendaCommitBuryanswerRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSNumber<Optional> *bury_type;
@property (nonatomic, strong) NSString<Optional> *enter_from;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitBuryanswerResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDWendaCommitDeleteanswerRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitDeleteanswerResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDWendaCommitDeletequestionRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitDeletequestionResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSString<Optional> *qid;
@end

@interface  WDWendaCommitDigganswerRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSNumber<Optional> *digg_type;
@property (nonatomic, strong) NSString<Optional> *enter_from;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitDigganswerResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDWendaCommitEditanswerRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSNumber<Optional> *ban_comment;
@end

@interface  WDWendaCommitEditanswerResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, strong) WDAbstractStructModel<Optional>* content_abstract;
@end

@interface  WDWendaCommitEditquestionRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSString<Optional> *pic_list;
@property (nonatomic, strong) NSString<Optional> *concern_ids;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitEditquestionResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *schema;
@end

@interface  WDWendaCommitEditquestiontagRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *concern_ids;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitEditquestiontagResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDConcernTagStructModel, Optional>* concern_tag_list;
@end

@interface  WDWendaCommitFollowquestionRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSNumber<Optional> *follow_type;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitFollowquestionResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDWendaCommitIgnorequestionRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitIgnorequestionResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDWendaCommitInviteuserRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *to_uid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitInviteuserResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDPostAnswerTipsStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *text;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, strong) NSString<Optional> *icon_day_url;
@property (nonatomic, strong) NSString<Optional> *icon_night_url;
@end

@interface  WDWendaCommitPostanswerRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSNumber<Optional> *forward_pgc;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSNumber<Optional> *ban_comment;
@property (nonatomic, strong) NSString<Optional> *list_entrance;
@property (nonatomic, strong) NSString<Optional> *source;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@end

@interface  WDWendaCommitPostanswerResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, strong) WDPostAnswerTipsStructModel<Optional>* tips;
@end

@interface  WDWendaCommitPostquestionRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSString<Optional> *pic_list;
@property (nonatomic, strong) NSString<Optional> *concern_ids;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSString<Optional> *list_entrance;
@property (nonatomic, strong) NSString<Optional> *source;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@end

@interface  WDWendaCommitPostquestionResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *schema;
@end

@interface  WDWendaCommitReportRequestModel : TTRequestModel
@property (nonatomic, assign) WDObjectType type;
@property (nonatomic, strong) NSString<Optional> *gid;
@property (nonatomic, strong) NSString<Optional> *report_type;
@property (nonatomic, strong) NSString<Optional> *report_message;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaCommitReportResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDWendaConcernBrowRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *concern_id;
@property (nonatomic, strong) NSNumber<Optional> *min_behot_time;
@property (nonatomic, strong) NSNumber<Optional> *max_behot_time;
@property (nonatomic, strong) NSString<Optional> *wenda_extra;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@end

@interface  WDWendaConcernBrowResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *login_status;
@property (nonatomic, strong) NSNumber<Optional> *total_number;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@property (nonatomic, strong) NSString<Optional> *message;
@property (nonatomic, strong) NSNumber<Optional> *has_more_to_refresh;
@property (nonatomic, strong) NSString<Optional> *extra;
@property (nonatomic, copy) NSArray<WDWendaCellDataStructModel, Optional>* data;
@property (nonatomic, strong) WDTipsStructModel<Optional>* tips;
@end

@interface  WDWendaConcerntagSearchRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaConcerntagSearchResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDConcernTagStructModel, Optional>* concern_tag_list;
@property (nonatomic, strong) NSString<Optional> *name;
@end

@interface  WDWendaDeleteDraftRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@end

@interface  WDWendaDeleteDraftResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDWendaDiggUserlistRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSString<Optional> *cursor;
@property (nonatomic, strong) NSNumber<Optional> *count;
@end

@interface  WDWendaDiggUserlistResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDUserStructModel, Optional>* user_list;
@property (nonatomic, strong) NSString<Optional> *cursor;
@end

@interface  WDWendaFetchAnswerdraftRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@end

@interface  WDWendaFetchAnswerdraftResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) WDAnswerDraftStructModel<Optional>* answer;
@end

@interface  WDFetchTipsStructModel : WDBaseModel
@property (nonatomic, strong) NSString<Optional> *icon_day_url;
@property (nonatomic, strong) NSString<Optional> *icon_night_url;
@property (nonatomic, strong) NSString<Optional> *text;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, strong) NSString<Optional> *url;
@end

@interface  WDWendaFetchTipsRequestModel : TTRequestModel
@property (nonatomic, strong) NSNumber<Optional> *tips_source;
@end

@interface  WDWendaFetchTipsResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) WDFetchTipsStructModel<Optional>* tips;
@end

@interface  WDWendaIcimageBrowRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *text;
@property (nonatomic, strong) NSNumber<Optional> *is_title;
@property (nonatomic, strong) NSNumber<Optional> *only_preview;
@end

@interface  WDWendaIcimageBrowResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDIcImageStructModel, Optional>* img_list;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *req_count;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@property (nonatomic, strong) NSString<Optional> *term;
@end

@interface  WDWendaIcimageLoadmoreRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *term;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *count;
@end

@interface  WDWendaIcimageLoadmoreResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDIcImageStructModel, Optional>* img_list;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *req_count;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@property (nonatomic, strong) NSString<Optional> *term;
@end

@interface  WDWendaInviteUserlistRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSNumber<Optional> *count;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaInviteUserlistResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDInviteAggrUserStructModel, Optional>* invite_user_list;
@end

@interface  WDWendaInvitedQuestionbrowRequestModel : TTRequestModel
@property (nonatomic, strong) NSNumber<Optional> *min_behot_time;
@property (nonatomic, strong) NSNumber<Optional> *max_behot_time;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaInvitedQuestionbrowResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDWendaInvitedQuestionStructModel, Optional>* wenda_invited_question_list;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@property (nonatomic, strong) NSNumber<Optional> *has_more_to_refresh;
@property (nonatomic, strong) NSNumber<Optional> *total_number;
@property (nonatomic, strong) WDTipsStructModel<Optional>* tips;
@end

@interface  WDLinkCheckStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *is_legal;
@property (nonatomic, strong) NSString<Optional> *title;
@end

@interface  WDWendaLinkCheckRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *link;
@end

@interface  WDWendaLinkCheckResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) WDLinkCheckStructModel<Optional>* link_data;
@end

@interface  WDWendaNativeFeedbrowRequestModel : TTRequestModel
@property (nonatomic, strong) NSNumber<Optional> *min_behot_time;
@property (nonatomic, strong) NSNumber<Optional> *max_behot_time;
@property (nonatomic, strong) NSString<Optional> *wenda_extra;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaNativeFeedbrowResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *login_status;
@property (nonatomic, strong) NSNumber<Optional> *total_number;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@property (nonatomic, strong) NSString<Optional> *message;
@property (nonatomic, strong) NSNumber<Optional> *has_more_to_refresh;
@property (nonatomic, strong) NSString<Optional> *extra;
@property (nonatomic, copy) NSArray<WDWendaCellDataStructModel, Optional>* data;
@property (nonatomic, strong) WDTipsStructModel<Optional>* tips;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSNumber<Optional> *add_first_page;
@end

@interface  WDWendaOpanswerCommentRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, assign) WDOPCommentType op_type;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaOpanswerCommentResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDWendaPostDislikeRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *item_list;
@property (nonatomic, strong) NSString<Optional> *msg_id;
@property (nonatomic, strong) NSString<Optional> *cursor;
@end

@interface  WDWendaPostDislikeResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSNumber<Optional> *err_tips;
@end

@interface  WDWendaPostDraftRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *content;
@end

@interface  WDWendaPostDraftResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@end

@interface  WDWendaPostScoringRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *ansid;
@property (nonatomic, strong) NSNumber<Optional> *score;
@property (nonatomic, strong) NSNumber<Optional> *stay_time;
@end

@interface  WDWendaPostScoringResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSNumber<Optional> *err_tips;
@end

@interface  WDWendaQuestionAssociationRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaQuestionAssociationResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDSimpleQuestionStructModel, Optional>* question_list;
@property (nonatomic, strong) NSString<Optional> *title;
@end

@interface  WDWendaQuestionBrowRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *scope;
@property (nonatomic, strong) NSString<Optional> *enter_from;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@end

@interface  WDWendaQuestionBrowResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) WDQuestionStructModel<Optional>* question;
@property (nonatomic, copy) NSArray<WDAnswerStructModel, Optional>* ans_list;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@property (nonatomic, copy) NSArray<WDInviteUserStructModel, Optional>* candidate_invite_user;
@property (nonatomic, strong) WDShowFormatStructModel<Optional>* show_format;
@property (nonatomic, strong) NSString<Optional> *channel_schema;
@property (nonatomic, strong) NSNumber<Optional> *module_count;
@property (nonatomic, copy) NSArray<WDModuleStructModel, Optional>* module_list;
@property (nonatomic, strong) NSNumber<Optional> *question_header_content_fold_max_count;
@property (nonatomic, strong) NSNumber<Optional> *related_question_banner_type;
@property (nonatomic, strong) NSString<Optional> *related_question_title;
@property (nonatomic, strong) NSString<Optional> *related_question_url;
@property (nonatomic, strong) NSNumber<Optional> *can_answer;
@property (nonatomic, strong) NSString<Optional> *related_question_reason_url;
@property (nonatomic, strong) WDProfitStructModel<Optional>* profit;
@property (nonatomic, strong) NSNumber<Optional> *has_profit;
@property (nonatomic, strong) WDShareProfitStructModel<Optional>* share_profit;
@property (nonatomic, strong) WDForwardStructModel<Optional>* repost_params;
@end

@interface  WDWendaQuestionChecktitleRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaQuestionChecktitleResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) WDSimpleQuestionStructModel<Optional>* similar_question;
@end

@interface  WDWendaQuestionDefaulttagRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *content;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaQuestionDefaulttagResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDConcernTagStructModel, Optional>* concern_tags;
@end

@interface  WDWendaQuestionLoadmoreRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *count;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@end

@interface  WDWendaQuestionLoadmoreResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDAnswerStructModel, Optional>* ans_list;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@end

@interface  WDWendaQuestionStatusRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaQuestionStatusResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) WDQuestionStructModel<Optional>* question;
@property (nonatomic, strong) NSString<Optional> *tips;
@property (nonatomic, strong) NSString<Optional> *tips_url;
@property (nonatomic, copy) NSArray<WDInviteUserStructModel, Optional>* candidate_invite_user;
@end

@interface  WDWendaQuestionotherBrowRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@end

@interface  WDWendaQuestionotherBrowResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDAnswerStructModel, Optional>* ans_list;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@end

@interface  WDWendaQuestionotherLoadmoreRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *count;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@end

@interface  WDWendaQuestionotherLoadmoreResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDAnswerStructModel, Optional>* ans_list;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@end

@interface  WDDataStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *cell_type;
@property (nonatomic, strong) NSNumber<Optional> *login_status;
@property (nonatomic, strong) WDUserStructModel<Optional>* user;
@property (nonatomic, strong) NSNumber<Optional> *tips;
@property (nonatomic, strong) NSString<Optional> *wenda_description;
@property (nonatomic, strong) NSString<Optional> *schema;
@property (nonatomic, copy) NSArray<WDTabStructModel, Optional>* tabs;
@end

@interface  WDTabStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *tab_type;
@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSNumber<Optional> *tips;
@property (nonatomic, strong) NSString<Optional> *day_icon;
@property (nonatomic, strong) NSString<Optional> *night_icon;
@property (nonatomic, strong) NSString<Optional> *schema;
@end

@interface  WDWendaRefreshNativewidgetRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaRefreshNativewidgetResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) WDDataStructModel<Optional>* data;
@end

@interface  WDSearchUserStructModel : WDBaseModel
@property (nonatomic, strong) WDUserStructModel<Optional>* user;
@property (nonatomic, copy) NSArray<WDHighlightStructModel, Optional>* highlight;
@end

@interface  WDWendaSearchInvitelistRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *search_text;
@property (nonatomic, strong) NSString<Optional> *qid;
@end

@interface  WDWendaSearchInvitelistResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, copy) NSArray<WDSearchUserStructModel, Optional>* user_list;
@end

@interface  WDWendaUploadGetvideouploadurlRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *uplaod_id;
@end

@interface  WDWendaUploadGetvideouploadurlResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSString<Optional> *upload_id;
@property (nonatomic, strong) NSString<Optional> *upload_url;
@property (nonatomic, strong) NSNumber<Optional> *chunk_size;
@end

@interface  WDUploadImgDataStructModel : WDBaseModel
@property (nonatomic, copy) NSArray<WDMagicUrlStructModel, Optional>* url_list;
@property (nonatomic, strong) NSString<Optional> *web_uri;
@end

@interface  WDWendaUploadImageRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *ic_id;
@property (nonatomic, strong) NSString<Optional> *term;
@end

@interface  WDWendaUploadImageResponseModel : TTResponseModel
@property (nonatomic, strong) NSString<Optional> *message;
@property (nonatomic, strong) WDUploadImgDataStructModel<Optional>* data;
@end

@interface  WDWendaUserAskprivilegeRequestModel : TTRequestModel
@property (nonatomic, strong) NSNumber<Optional> *type;
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaUserAskprivilegeResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSNumber<Optional> *has_privilege;
@property (nonatomic, strong) NSNumber<Optional> *can_ask;
@property (nonatomic, strong) NSNumber<Optional> *can_use_ic;
@end

@interface  WDWendaUsertagBrowRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *api_param;
@end

@interface  WDWendaUsertagBrowResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSString<Optional> *err_tips;
@property (nonatomic, strong) NSNumber<Optional> *start_offset;
@property (nonatomic, strong) NSNumber<Optional> *end_offset;
@property (nonatomic, copy) NSArray<WDConcernTagStructModel, Optional>* tag_list;
@end

@interface  WDWendaListCellStructModel : WDBaseModel
@property (nonatomic, assign) WDWendaListCellType cell_type;
@property (nonatomic, assign) WDWendaListLayoutType layout_type;
@property (nonatomic, strong) WDAnswerStructModel<Optional>* answer;
@property (nonatomic, strong) NSNumber<Optional> *show_lines;
@property (nonatomic, strong) NSNumber<Optional> *max_lines;
@end

@interface  WDRelatedQuestionStructModel : WDBaseModel
@property (nonatomic, strong) NSNumber<Optional> *banner_type;
@property (nonatomic, strong) NSString<Optional> *title;
@property (nonatomic, strong) NSString<Optional> *question_schema;
@property (nonatomic, strong) NSString<Optional> *reason_schema;
@end

@interface  WDWendaV2QuestionBrowRequestModel : TTRequestModel
@property (nonatomic, strong) NSString<Optional> *qid;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, strong) NSString<Optional> *gd_ext_json;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *count;
@property (nonatomic, assign) WDWendaListRequestType request_type;
@end

@interface  WDWendaV2QuestionBrowResponseModel : TTResponseModel
@property (nonatomic, strong) NSNumber<Optional> *err_no;
@property (nonatomic, strong) NSNumber<Optional> *err_tips;
@property (nonatomic, strong) WDQuestionStructModel<Optional>* question;
@property (nonatomic, copy) NSArray<WDWendaListCellStructModel, Optional>* data;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *has_more;
@property (nonatomic, strong) NSString<Optional> *api_param;
@property (nonatomic, copy) NSArray<WDModuleStructModel, Optional>* module_list;
@property (nonatomic, strong) NSNumber<Optional> *can_answer;
@property (nonatomic, strong) NSNumber<Optional> *header_max_lines;
@property (nonatomic, strong) WDRelatedQuestionStructModel<Optional>* related_question;
@property (nonatomic, strong) NSNumber<Optional> *has_profit;
@property (nonatomic, strong) WDProfitStructModel<Optional>* profit;
@property (nonatomic, strong) WDShareProfitStructModel<Optional>* share_profit;
@property (nonatomic, strong) WDForwardStructModel<Optional>* repost_params;
@property (nonatomic, copy) NSArray<WDInviteUserStructModel, Optional>* candidate_invite_user;
@end

