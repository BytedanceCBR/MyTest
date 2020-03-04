#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "TTRequestModel.h"
#import "TTResponseModelProtocol.h"
#import "FRCommonURLSetting.h"

typedef NS_ENUM(NSInteger, FRGroupItemType) {
    FRGroupItemTypeJoke = 3,
    FRGroupItemTypeArticle = 4,
};

typedef NS_ENUM(NSInteger, FRGroupMediaType) {
    FRGroupMediaTypeNormalArticle = 1,
    FRGroupMediaTypeViedoArticle = 2,
};

typedef NS_ENUM(NSInteger, FRUserFriendType) {
    FRUserFriendTypeStranger = 0,
    FRUserFriendTypeFriend = 1,
};

typedef NS_ENUM(NSInteger, FRUserFollowingType) {
    FRUserFollowingTypeUnfollowing = 0,
    FRUserFollowingTypeFollowing = 1,
};

typedef NS_ENUM(NSInteger, FRUserFollowedType) {
    FRUserFollowedTypeUnfollowed = 0,
    FRUserFollowedTypeFollowed = 1,
};

typedef NS_ENUM(NSInteger, FRUserBlockedType) {
    FRUserBlockedTypeNotBlocked = 0,
    FRUserBlockedTypeBlocked = 1,
};

typedef NS_ENUM(NSInteger, FRUserBlockingType) {
    FRUserBlockingTypeNotBlocking = 0,
    FRUserBlockingTypeBlocking = 1,
};

typedef NS_ENUM(NSInteger, FRUserVerifyType) {
    FRUserVerifyTypeNotVerify = 0,
    FRUserVerifyTypeVerify = 1,
};

typedef NS_ENUM(NSInteger, FRHasUserDigType) {
    FRHasUserDigTypeNotDig = 0,
    FRHasUserDigTypeDig = 1,
};

typedef NS_ENUM(NSInteger, FRTabIdType) {
    FRTabIdTypeArticleTab = 1,
    FRTabIdTypeMomoTab = 2,
};

typedef NS_ENUM(NSInteger, FRHasMoreType) {
    FRHasMoreTypeTrueMore = 1,
    FRHasMoreTypeFalseMore = 0,
};

typedef NS_ENUM(NSInteger, FRRecommendReasonType) {
    FRRecommendReasonTypeHomepage = 1,
    FRRecommendReasonTypeLikepage = 2,
    FRRecommendReasonTypeFanspage = 3,
    FRRecommendReasonTypeOther = 9,
};

typedef NS_ENUM(NSInteger, FRUserGenderType) {
    FRUserGenderTypeUnknown = 0,
    FRUserGenderTypeMale = 1,
    FRUserGenderTypeFemale = 2,
};

typedef NS_ENUM(NSInteger, FRThreadDelType) {
    FRThreadDelTypeDeleted = 0,
    FRThreadDelTypeNotDeleted = 1,
};

typedef NS_ENUM(NSInteger, FRCellType) {
    FRCellTypeDongtai = 1,
    FRCellTypeFriendCell = 2,
    FRCellTypeHotToday = 3,
};

typedef NS_ENUM(NSInteger, FRTalkType) {
    FRTalkTypeArticleDongtai = 200,
    FRTalkTypeOnlyDongtai = 201,
    FRTalkTypeForwardDongtai = 202,
    FRTalkTypeForumDongtai = 300,
};

typedef NS_ENUM(NSInteger, FRLoginStatusType) {
    FRLoginStatusTypeNotLogin = 0,
    FRLoginStatusTypeLogin = 1,
};

typedef NS_ENUM(NSInteger, FRTabParamType) {
    FRTabParamTypeNotNeedCommonParam = 0,
    FRTabParamTypeNeedCommonParam = 1,
};

typedef NS_ENUM(NSInteger, FRForumTabCommonParamType) {
    FRForumTabCommonParamTypeForumTabNotNeedCommonParam = 0,
    FRForumTabCommonParamTypeForumTabNeedCommonParam = 1,
};

typedef NS_ENUM(NSInteger, FRImageType) {
    FRImageTypeDefaultImage = 0,
    FRImageTypeJpeg = 1,
    FRImageTypeGif = 2,
    FRImageTypeBmp = 3,
    FRImageTypePng = 4,
};

typedef NS_ENUM(NSInteger, FRUserPermType) {
    FRUserPermTypeThreadSetPass = 5,
    FRUserPermTypeThreadSetDelete = 6,
    FRUserPermTypeThreadSetOnly = 7,
    FRUserPermTypeThreadSetStar = 9,
    FRUserPermTypeThreadCancelStar = 10,
    FRUserPermTypeThreadSetTop = 11,
    FRUserPermTypeThreadCancelTop = 12,
    FRUserPermTypeThreadSetRate = 13,
    FRUserPermTypeThreadCancelRate = 14,
};

typedef NS_ENUM(NSInteger, FRRoleDisplayType) {
    FRRoleDisplayTypeRed = 1,
    FRRoleDisplayTypeYellow = 2,
    FRRoleDisplayTypeBlue = 3,
    FRRoleDisplayTypeBlack = 4,
};

typedef NS_ENUM(NSInteger, FRFromWhereType) {
    FRFromWhereTypeAPP_TOUTIAO_IOS = 1,
    FRFromWhereTypeAPP_TOUTIAO_ANDROID = 2,
    FRFromWhereTypeAPP_TOUTIAO = 3,
    FRFromWhereTypeAPP_DISCUSS_IOS = 5,
    FRFromWhereTypeAPP_DISCUSS_ANDROID = 6,
    FRFromWhereTypeAPP_DISCUSS = 7,
    FRFromWhereTypeWEB_ADMIN = 11,
    FRFromWhereTypeWEB_AUDIT_ADMIN = 12,
    FRFromWhereTypeWEB_ASSISTANT = 21,
    FRFromWhereTypeAPP_TOUTIAO_BAOLIAO = 1073741827,
    FRFromWhereTypeDONGTAI_WORKER_STATUS_SYNC = 101,
};

typedef NS_ENUM(NSInteger, FRInnerForumType) {
    FRInnerForumTypeNormal = 0,
    FRInnerForumTypeMovie = 1,
    FRInnerForumTypeCity = 2,
    FRInnerForumTypeColumn = 3,
    FRInnerForumTypeGame = 4,
    FRInnerForumTypeActivity = 5,
    FRInnerForumTypeCar = 6,
    FRInnerForumTypeMicroGame = 72,
};

typedef NS_ENUM(NSInteger, FRConcernTabIdType) {
    FRConcernTabIdTypeAll = 0,
    FRConcernTabIdTypeTHREAD = 1,
    FRConcernTabIdTypeVIDEO = 2,
    FRConcernTabIdTypeWEB = 3,
    FRConcernTabIdTypeFILM_REVIEW = 4,
    FRConcernTabIdTypeWENDA = 5,
};

typedef NS_ENUM(NSInteger, FRUgcVideoTitleType) {
    FRUgcVideoTitleTypeExaggerate = 1,
    FRUgcVideoTitleTypePass = 2,
    FRUgcVideoTitleTypeEmptyString = 702,
    FRUgcVideoTitleTypeErrorCharacterNumber = 703,
    FRUgcVideoTitleTypeIllegalCharacter = 704,
};

typedef NS_ENUM(NSInteger, FRCommentsGroupType) {
    FRCommentsGroupTypeArticle = 0,
    FRCommentsGroupTypeThread = 2,
};

typedef NS_ENUM(NSInteger, FRHashTagType) {
    FRHashTagTypeNone = 0,
    FRHashTagTypeSingleHash = 1,
    FRHashTagTypeDoubleHash = 2,
};

typedef NS_ENUM(NSInteger, FRPostBindCheckType) {
    FRPostBindCheckTypePostBindCheckTypeNone = 0,
    FRPostBindCheckTypePostBindCheckTypeNeed = 1,
};

typedef NS_ENUM(NSInteger, FRPostTypeCode) {
    FRPostTypeCodeTHREAD_TYPE_NORMAL = 200,
    FRPostTypeCodeTHREAD_TYPE_FORWARD_ARTICLE = 211,
    FRPostTypeCodeTHREAD_TYPE_FORWARD_THREAD = 212,
    FRPostTypeCodeTHREAD_TYPE_FORWARD_UGC_VIDEO = 213,
    FRPostTypeCodeTHREAD_TYPE_FORWARD_ANSWER = 214,
};

typedef NS_ENUM(NSInteger, FRRepostTypeCode) {
    FRRepostTypeCodeTHREAD_TYPE_FORWARD_ARTICLE = 211,
    FRRepostTypeCodeTHREAD_TYPE_FORWARD_THREAD = 212,
};

typedef NS_ENUM(NSInteger, FRCommentTypeCode) {
    FRCommentTypeCodeARTICLE = 211,
    FRCommentTypeCodeTHREAD = 212,
    FRCommentTypeCodeUGC_VIDEO = 213,
    FRCommentTypeCodeANSWER = 214,
    FRCommentTypeCodeINNER_LINK = 215,
    FRCommentTypeCodeLVIDEO = 223,
};

typedef NS_ENUM(NSInteger, FRUGCTypeCode) {
    FRUGCTypeCodeCOMMENT = 1,
    FRUGCTypeCodeTHREAD = 2,
    FRUGCTypeCodeREPLY = 3,
    FRUGCTypeCodeITEM = 4,
    FRUGCTypeCodeGROUP = 5,
    FRUGCTypeCodeUGC_VIDEO = 6,
    FRUGCTypeCodeZHENZHEN_POP = 7,
    FRUGCTypeCodeCONCERN = 8,
    FRUGCTypeCodeLIVE = 9,
    FRUGCTypeCodeGOODS = 10,
    FRUGCTypeCodeUSER = 11,
    FRUGCTypeCodeMICRO_APP = 12,
    FRUGCTypeCodeNOVEL = 13,
    FRUGCTypeCodeSUBSCRIBED_COLUMN = 14,
    FRUGCTypeCodeLEARNING = 15,
    FRUGCTypeCodeMICRO_GAME = 16,
    FRUGCTypeCodeLVIDEO_EPISODE = 28,
    FRUGCTypeCodeANSWER = 1025,
    FRUGCTypeCodeQUESTION = 1026,
    FRUGCTypeCodeKUAIDA_ANSWER = 1030,
    FRUGCTypeCodeEYEU_DONGTAI = 1040,
};

typedef NS_ENUM(NSInteger, FRFooterRepostTypeCode) {
    FRFooterRepostTypeCodeTHREAD = 1,
    FRFooterRepostTypeCodeCOMMNENT = 2,
};

typedef NS_ENUM(NSInteger, FRUGCStoryCoverType) {
    FRUGCStoryCoverTypePICTURE_TEXT = 1,
    FRUGCStoryCoverTypeCOVER_TEXT = 2,
    FRUGCStoryCoverTypePURE_TEXT = 3,
    FRUGCStoryCoverTypeTITLE_TEXT = 4,
};

typedef NS_ENUM(NSInteger, FRUGCStoryCoverPictureIconType) {
    FRUGCStoryCoverPictureIconTypeVideo_icon = 1,
    FRUGCStoryCoverPictureIconTypePhotos_Icon = 2,
    FRUGCStoryCoverPictureIconTypeArtielcePicture_Icon = 3,
};

typedef NS_ENUM(NSInteger, FRForumStatusType) {
    FRForumStatusTypeDelete = 0,
    FRForumStatusTypePublish = 1,
    FRForumStatusTypeReviewing = 2,
    FRForumStatusTypeDeit = 3,
};

typedef NS_ENUM(NSInteger, FRForumProductType) {
    FRForumProductTypeTopic = 0,
    FRForumProductTypeSubject = 1,
    FRForumProductTypeActivity = 2,
};

typedef NS_ENUM(NSInteger, FRForumTableType) {
    FRForumTableTypeLightStream = 0,
    FRForumTableTypeWeb = 1,
    FRForumTableTypeChannelArticle = 2,
    FRForumTableTypeChannelWenda = 3,
};

typedef NS_ENUM(NSInteger, FRForumHeaderStyle) {
    FRForumHeaderStyleTopic = 0,
    FRForumHeaderStyleTopicBanner = 1,
    FRForumHeaderStyleTopicNotBanner = 2,
    FRForumHeaderStyleTopicGame = 3,
    FRForumHeaderStyleSubject = 100,
    FRForumHeaderStyleActivityBanner = 200,
    FRForumHeaderStyleActivityNoBanner = 201,
};

@class FRMapStructModel,
FRGroupStructModel,
FRUserRoleStructModel,
FRUserApplyRoleInfoStructModel,
FRForumRoleInfoStructModel,
FRUserStructModel,
FRSimpleUserStructModel,
FRViceOwnerInfoStructModel,
FRCommentStructModel,
FRMoMoAdStructModel,
FRInterestItemStructModel,
FRInterestForumStructModel,
FROpenForumStructModel,
FRRelatedForumStructModel,
FRForumItemStructModel,
FRForumClassStructModel,
FRImageUrlStructModel,
FRMagicUrlStructModel,
FRTipsStructModel,
FRTabStructModel,
FRTabExtraStructModel,
FRTabRNInfoStructModel,
FRCommentBrowStructModel,
FRUserInfoStructModel,
FRThreadDataStructModel,
FRGeneralThreadStructModel,
FRForumBannerStructModel,
FRMessageListStructModel,
FRMessageListUserInfoStructModel,
FRMessageListDataStructModel,
FRMessageListDataGroupStructModel,
FRForumStructModel,
FRTTForumStructModel,
FRForumSpotStructModel,
FRForumSpotItemStructModel,
FRTTForumTitleImageStructModel,
FRTTForumLogoImageStructModel,
FRTTForumRankInfoStructModel,
FRTTForumExtraStructModel,
FRTagStructModel,
FRForumTagStructModel,
FRButtonListItemStructModel,
FRDataListItemStructModel,
FRUserCommentSpecialStructModel,
FRLoginUserInfoStructModel,
FRGeographyStructModel,
FRRoleMemberStructModel,
FROwnerApplyHistoryItemStructModel,
FROwnerApplyHistorysStructModel,
FROwnerAuditingInfoStructModel,
FROwnerHotForumStructModel,
FRUserIconStructModel,
FROwnerActionStatDataStructModel,
FRForumStatDataStructModel,
FRMovieReviewBasicInfoStructModel,
FRGroupLikeStructModel,
FRUgcDataStructModel,
FRActionStructModel,
FRGroupInfoStructModel,
FRMediaInfoStructModel,
FRNormalThreadStructModel,
FRMovieStructModel,
FRUserPositionStructModel,
FRDiscussCommentStructModel,
FRDiscussCommentBrowStructModel,
FRRelatedNewStructModel,
FRConcernWordsStructModel,
FRHashTagPositionStructModel,
FRConcernForumStructModel,
FRConcernTabStructModel,
FRTTForumTabStructModel,
FRTTForumTabExtraStructModel,
FRTTForumPublisherControllStructModel,
FRTTPublisherTypeStructModel,
FRConcernItemStructModel,
FRConcernStructModel,
FRShareStructModel,
FRConcernForTagStructModel,
FRConcernTagStructModel,
FRRecommendTagStructModel,
FRThreadListStructModel,
FRPublisherPermissionIntroStructModel,
FRPublisherPermissionStructModel,
FRUgcVideoDetailInfoStructModel,
FRUgcVideoStructModel,
FRCommentTabInfoStructModel,
FRNewCommentReplyStructModel,
FRNewCommentQutoedStructModel,
FRNewCommentStructModel,
FRNewCommentDataStructModel,
FRDeleteCommentDataStructModel,
FRRichTextLinkStructModel,
FRRichTextAttributesStructModel,
FRRichTextStructModel,
FRColdStartRecommendUserStructModel,
FRFollowInfoStructModel,
FRPublishConfigStructModel,
FRCommonUserStructModel,
FRCommonUserInfoStructModel,
FRCommonUserRelationStructModel,
FRUserRelationCountStructModel,
FRRecommendCardStructModel,
FRRecommendMultiCardStructModel,
FRRecommendUserLargeCardStructModel,
FRFollowChannelColdBootUserContainerStructModel,
FRFollowChannelColdBootRecommendUserCardStructModel,
FRUserRelationContactFriendsUserStructModel,
FRUserRelationContactFriendsDataStructModel,
FRUGCVideoUserInfoStructModel,
FRUGCVideoUserRelationStructModel,
FRUGCVideoUserRelationCountStructModel,
FRUGCVideoUserStructModel,
FRUGCVideoActionStructModel,
FRUGCVideoPublishReasonStructModel,
FRUGCVideoRawDataStructModel,
FRUGCVideoDataStructModel,
FRRecommendSponsorStructModel,
FRRedpackStructModel,
FRActivityStructModel,
FRUserExpressionConfigStructModel,
FRTextUrlStructModel,
FRBonusStructModel,
FRRedpacketOpenResultStructModel,
FRAddFriendsUserWrapperStructModel,
FRInviteFriendsUserWrapperStructModel,
FRAddFriendsDataStructModel,
FRInviteFriendsDataStructModel,
FRContactsRedpacketCheckResultStructModel,
FRContactsRedpacketOpenResultStructModel,
FRMomentsRecommendUserStructModel,
FRActionDataStructModel,
FRShareInfoStructModel,
FRTokenShareInfoStructModel,
FRTokenShareTypeStructModel,
FRUserBlockedAndBlockingStructModel,
FRPublishPostUserInfoStructModel,
FRPublishPostUserRelationCountStructModel,
FRPublishPostUserRelationStructModel,
FRPublishPostUserStructModel,
FRPublishPostUserHighlightStructModel,
FRPublishPostSearchUserStructModel,
FRPublishPostSearchUserContactStructModel,
FRPublishPostSearchUserSuggestStructModel,
FRRecommendRedpacketDataStructModel,
FRRecommendRedpacketResultStructModel,
FRShareImageUrlStructModel,
FRPublishPostSearchHashtagItemStructModel,
FRPublishPostHashtagHighlightStructModel,
FRPublishPostSearchHashtagStructModel,
FRPublishPostSearchHashtagHotStructModel,
FRPublishPostSearchHashtagSuggestStructModel,
FRRepostCommonContentStructModel,
FRRepostParamStructModel,
FRUserRelationContactCheckDataStructModel,
FRContactUploadSettingsStructModel,
FRFooterRepostStructModel,
FRRecommendUserStoryCardStructModel,
FRRecommendUserStoryVerifyInfoStructModel,
FRUGCThreadStoryDataStructModel,
FRUGCStoryCoverDataStructModel,
FRUGCStoryCoverShowMoreStructModel,
FRUserDecorationStructModel,
FRRecommendUserStoryHasMoreStructModel,
FRQRCodeLinkInfoStructModel,
FRProfileAuthCheckDataStructModel,
FRListInteractUserInfoStructModel,
FRListInteractStyleCtrlsStructModel,
FRListRawReplyDataStructModel,
FRListReplyDataStructModel,
FRListCommentDataStructModel,
FRListInteractRecommendReasonStructModel,
FRListInteractDataStructModel,
FRUGCPublishGuideInfoStructModel,
FRRecommendCardRelatedControlStructModel,
FRRelationShipUserInfoStructModel,
FRRelationShipFansPlatformInfoStructModel,
FRRelationShipFansPlatformDataStructModel,
FRRelationShipFansInteractionStructModel,
FRRelationShipFollowersDataStructModel,
FRRelationShipFansDataStructModel,
FRGifImageDataStructModel,
FRGifImageDataListStructModel,
FRConcernShareInfoStructModel,
FRTTForumShareInfoStructModel,
FRBusinessAllianceStructModel,
FRBusinessToolboxItemStructModel,
FRBusinessToolboxDataStructModel,
FRUgcUserDecorationV1ResponseModel,
FRUgcUserDecorationV1RequestModel,
FRTtdiscussV1ShareResponseModel,
FRTtdiscussV1ShareRequestModel,
FRUserRelationFansV2ResponseModel,
FRUserRelationFansV2RequestModel,
FRTtdiscussV1ForumSearchResponseModel,
FRTtdiscussV1ForumSearchRequestModel,
FRTtdiscussV1CommitCommentdeleteResponseModel,
FRTtdiscussV1CommitCommentdeleteRequestModel,
FRTtdiscussV1MovieListResponseModel,
FRTtdiscussV1MovieListRequestModel,
FRUserRelationUserRecommendV1DislikeCardResponseModel,
FRUserRelationUserRecommendV1DislikeCardRequestModel,
FRTtdiscussV2UgcVideoCheckTitleResponseModel,
FRTtdiscussV2UgcVideoCheckTitleRequestModel,
FRConcernV1HomeHeadResponseModel,
FRConcernV1HomeHeadRequestModel,
FRTtdiscussV2CommitPublishResponseModel,
FRTtdiscussV2CommitPublishRequestModel,
FRTtdiscussV2LongReviewListResponseModel,
FRTtdiscussV2LongReviewListRequestModel,
FRTtdiscussV1CommitThreadforwardResponseModel,
FRTtdiscussV1CommitThreadforwardRequestModel,
FRUgcActivityVideoIntroRedpackV1OpenResponseModel,
FRUgcActivityVideoIntroRedpackV1OpenRequestModel,
FRUgcBusinessAllianceUserInfoResponseModel,
FRUgcBusinessAllianceUserInfoRequestModel,
FRUgcPublishPostV1ContactResponseModel,
FRUgcPublishPostV1ContactRequestModel,
FRConcernV1CommitDiscareResponseModel,
FRConcernV1CommitDiscareRequestModel,
FRForumHomeV1InfoResponseModel,
FRForumHomeV1InfoRequestModel,
FRUserProfileEvaluationResponseModel,
FRUserProfileEvaluationRequestModel,
FRTtdiscussV1CommitPublishResponseModel,
FRTtdiscussV1CommitPublishRequestModel,
FRTtdiscussV1CommitOpthreadResponseModel,
FRTtdiscussV1CommitOpthreadRequestModel,
FRArticleV2TabCommentsResponseModel,
FRArticleV2TabCommentsRequestModel,
FRUgcPublishPostV1CheckResponseModel,
FRUgcPublishPostV1CheckRequestModel,
FRUserRelationFriendsV1ResponseModel,
FRUserRelationFriendsV1RequestModel,
FRConcernV1CommitCareResponseModel,
FRConcernV1CommitCareRequestModel,
FRUserRelationUserRecommendV1FollowChannelRecommendsResponseModel,
FRUserRelationUserRecommendV1FollowChannelRecommendsRequestModel,
FRUgcPublishPostV1ModifyResponseModel,
FRUgcPublishPostV1ModifyRequestModel,
FRDongtaiGroupCommentDeleteResponseModel,
FRDongtaiGroupCommentDeleteRequestModel,
FRTtdiscussV1CommitOwnerapplyResponseModel,
FRTtdiscussV1CommitOwnerapplyRequestModel,
FR2DataV4PostMessageResponseModel,
FR2DataV4PostMessageRequestModel,
FRTtdiscussV1ForumFollowResponseModel,
FRTtdiscussV1ForumFollowRequestModel,
FRTtdiscussV2MovieListResponseModel,
FRTtdiscussV2MovieListRequestModel,
FRUserRelationFriendsInviteResponseModel,
FRUserRelationFriendsInviteRequestModel,
FRUgcPublishVideoV4CheckAuthResponseModel,
FRUgcPublishVideoV4CheckAuthRequestModel,
FRUgcThreadDetailV3InfoResponseModel,
FRUgcThreadDetailV3InfoRequestModel,
FRUserRelationUserRecommendV1SupplementCardsResponseModel,
FRUserRelationUserRecommendV1SupplementCardsRequestModel,
FRUserRelationSetCanBeFoundByPhoneResponseModel,
FRUserRelationSetCanBeFoundByPhoneRequestModel,
FRUserRelationFollowingV2ResponseModel,
FRUserRelationFollowingV2RequestModel,
FRTtdiscussV1ThreadListResponseModel,
FRTtdiscussV1ThreadListRequestModel,
FRUgcActivityUploadContactRedpackV1OpenResponseModel,
FRUgcActivityUploadContactRedpackV1OpenRequestModel,
FRTtdiscussV2CommitCommentResponseModel,
FRTtdiscussV2CommitCommentRequestModel,
FRTtdiscussV1CommitCommentdiggResponseModel,
FRTtdiscussV1CommitCommentdiggRequestModel,
FRUgcThreadDetailV2InfoResponseModel,
FRUgcThreadDetailV2InfoRequestModel,
FRTtdiscussV1CommitCommentResponseModel,
FRTtdiscussV1CommitCommentRequestModel,
FRTtdiscussV1DiggUserResponseModel,
FRTtdiscussV1DiggUserRequestModel,
FRUgcPublishImageV1SuggestResponseModel,
FRUgcPublishImageV1SuggestRequestModel,
FRUserRelationUserRecommendV1DislikeUserResponseModel,
FRUserRelationUserRecommendV1DislikeUserRequestModel,
FRTtdiscussV1CommitCancelthreaddiggResponseModel,
FRTtdiscussV1CommitCancelthreaddiggRequestModel,
FRTtdiscussV1CommitFollowforumResponseModel,
FRTtdiscussV1CommitFollowforumRequestModel,
FRUserProfileAuthCheckResponseModel,
FRUserProfileAuthCheckRequestModel,
FRUserExpressionConfigResponseModel,
FRUserExpressionConfigRequestModel,
FRUgcPublishPostV1SuggestResponseModel,
FRUgcPublishPostV1SuggestRequestModel,
FRTtdiscussV1ForumIntroductionResponseModel,
FRTtdiscussV1ForumIntroductionRequestModel,
FRUgcPublishVideoV4CommitResponseModel,
FRUgcPublishVideoV4CommitRequestModel,
FRUserRelationContactinfoResponseModel,
FRUserRelationContactinfoRequestModel,
FRTtdiscussV1MomentListResponseModel,
FRTtdiscussV1MomentListRequestModel,
FRTfeRouteUgcVoteCommitResponseModel,
FRTfeRouteUgcVoteCommitRequestModel,
FRUgcBusinessAllianceUpdateProtocolStatusResponseModel,
FRUgcBusinessAllianceUpdateProtocolStatusRequestModel,
FRUgcBusinessAllianceUpdateBusinessTagResponseModel,
FRUgcBusinessAllianceUpdateBusinessTagRequestModel,
FRUgcPublishShareV1SetConfigResponseModel,
FRUgcPublishShareV1SetConfigRequestModel,
FRVerticalMovie1ReviewsResponseModel,
FRVerticalMovie1ReviewsRequestModel,
FRTtdiscussV1CommentRecommendforumResponseModel,
FRTtdiscussV1CommentRecommendforumRequestModel,
FRUgcPublishPostV1HashtagResponseModel,
FRUgcPublishPostV1HashtagRequestModel,
FRTtdiscussV1CommitOpcommentResponseModel,
FRTtdiscussV1CommitOpcommentRequestModel,
FRTtdiscussV1ThreadDetailResponseModel,
FRTtdiscussV1ThreadDetailRequestModel,
FRUgcThreadStoryVResponseModel,
FRUgcThreadStoryVRequestModel,
FRTtdiscussV2ForumListResponseModel,
FRTtdiscussV2ForumListRequestModel,
FRUserRelationContactfriendsResponseModel,
FRUserRelationContactfriendsRequestModel,
FRUgcBusinessAllianceBusinessBoxInfoResponseModel,
FRUgcBusinessAllianceBusinessBoxInfoRequestModel,
FRUgcThreadDetailV2ContentResponseModel,
FRUgcThreadDetailV2ContentRequestModel,
FRUgcPublishPostV1HotForumResponseModel,
FRUgcPublishPostV1HotForumRequestModel,
FRTtdiscussV1ThreadDetailCommentResponseModel,
FRTtdiscussV1ThreadDetailCommentRequestModel,
FRUgcThreadLinkV1ConvertResponseModel,
FRUgcThreadLinkV1ConvertRequestModel,
FRUgcPublishShareV3NotifyResponseModel,
FRUgcPublishShareV3NotifyRequestModel,
FRUgcCommentAuthorActionV2DeleteResponseModel,
FRUgcCommentAuthorActionV2DeleteRequestModel,
FRVerticalMovie1ShortReviewsResponseModel,
FRVerticalMovie1ShortReviewsRequestModel,
FRUgcRepostV1ListResponseModel,
FRUgcRepostV1ListRequestModel,
FRUserProfileUnstickV1ResponseModel,
FRUserProfileUnstickV1RequestModel,
FRUgcPublishPostV5CommitResponseModel,
FRUgcPublishPostV5CommitRequestModel,
FRUserProfileStickV1ResponseModel,
FRUserProfileStickV1RequestModel,
FRUgcDiggV1ListResponseModel,
FRUgcDiggV1ListRequestModel,
FRConcernV2CommitPublishResponseModel,
FRConcernV2CommitPublishRequestModel,
FRConcernV1ThreadListResponseModel,
FRConcernV1ThreadListRequestModel,
FRTtdiscussV1ThreadCommentsResponseModel,
FRTtdiscussV1ThreadCommentsRequestModel,
FRUserRelationInteractionFansV1ResponseModel,
FRUserRelationInteractionFansV1RequestModel,
FRUserRelationCredibleFriendsResponseModel,
FRUserRelationCredibleFriendsRequestModel,
FRArticleV1TabCommentsResponseModel,
FRArticleV1TabCommentsRequestModel,
FRTtdiscussV1SmartReviewListResponseModel,
FRTtdiscussV1SmartReviewListRequestModel,
FRUserRelationContactcheckResponseModel,
FRUserRelationContactcheckRequestModel,
FRUserRelationSetUserPrivacyExtendResponseModel,
FRUserRelationSetUserPrivacyExtendRequestModel,
FRTtdiscussV1CommitThreaddiggResponseModel,
FRTtdiscussV1CommitThreaddiggRequestModel,
FRTtdiscussV1ForumRecommendResponseModel,
FRTtdiscussV1ForumRecommendRequestModel,
FRUgcPublishRepostV8CommitResponseModel,
FRUgcPublishRepostV8CommitRequestModel,
FRUserRelationMfollowResponseModel,
FRUserRelationMfollowRequestModel,
FRTtdiscussV1ForumListResponseModel,
FRTtdiscussV1ForumListRequestModel,
FRUserRelationUserRecommendV1SupplementRecommendsResponseModel,
FRUserRelationUserRecommendV1SupplementRecommendsRequestModel,
FRTtdiscussV1CommitUnfollowforumResponseModel,
FRTtdiscussV1CommitUnfollowforumRequestModel,
FRTtdiscussV1CommitForumforwardResponseModel,
FRTtdiscussV1CommitForumforwardRequestModel,
FRTtdiscussV1CommitThreaddeleteResponseModel,
FRTtdiscussV1CommitThreaddeleteRequestModel,
FRTtdiscussV1LongReviewListResponseModel,
FRTtdiscussV1LongReviewListRequestModel,
FRUserRelationWeitoutiaoRecommendsResponseModel,
FRUserRelationWeitoutiaoRecommendsRequestModel,
FRUgcActivityFollowRedpackV1OpenResponseModel,
FRUgcActivityFollowRedpackV1OpenRequestModel,
FRTtdiscussV1ForumIntroapplypageResponseModel,
FRTtdiscussV1ForumIntroapplypageRequestModel,
FRTtdiscussV2UgcVideoUploadVideoUrlResponseModel,
FRTtdiscussV2UgcVideoUploadVideoUrlRequestModel,
FRTtdiscussV1CommitMultiownerapplyResponseModel,
FRTtdiscussV1CommitMultiownerapplyRequestModel,
FRUserRelationMultiFollowResponseModel,
FRUserRelationMultiFollowRequestModel,
FRVerticalMovie1LongReviewsResponseModel,
FRVerticalMovie1LongReviewsRequestModel,
FRUgcConcernThreadV3ListResponseModel,
FRUgcConcernThreadV3ListRequestModel;

@protocol FRGroupItemType @end
@protocol FRGroupMediaType @end
@protocol FRUserFriendType @end
@protocol FRUserFollowingType @end
@protocol FRUserFollowedType @end
@protocol FRUserBlockedType @end
@protocol FRUserBlockingType @end
@protocol FRUserVerifyType @end
@protocol FRHasUserDigType @end
@protocol FRTabIdType @end
@protocol FRHasMoreType @end
@protocol FRRecommendReasonType @end
@protocol FRUserGenderType @end
@protocol FRThreadDelType @end
@protocol FRCellType @end
@protocol FRTalkType @end
@protocol FRLoginStatusType @end
@protocol FRTabParamType @end
@protocol FRForumTabCommonParamType @end
@protocol FRImageType @end
@protocol FRUserPermType @end
@protocol FRRoleDisplayType @end
@protocol FRFromWhereType @end
@protocol FRInnerForumType @end
@protocol FRConcernTabIdType @end
@protocol FRUgcVideoTitleType @end
@protocol FRCommentsGroupType @end
@protocol FRHashTagType @end
@protocol FRPostBindCheckType @end
@protocol FRPostTypeCode @end
@protocol FRRepostTypeCode @end
@protocol FRCommentTypeCode @end
@protocol FRUGCTypeCode @end
@protocol FRFooterRepostTypeCode @end
@protocol FRUGCStoryCoverType @end
@protocol FRUGCStoryCoverPictureIconType @end
@protocol FRForumStatusType @end
@protocol FRForumProductType @end
@protocol FRForumTableType @end
@protocol FRForumHeaderStyle @end
@protocol FRMapStructModel @end
@protocol FRGroupStructModel @end
@protocol FRUserRoleStructModel @end
@protocol FRUserApplyRoleInfoStructModel @end
@protocol FRForumRoleInfoStructModel @end
@protocol FRUserStructModel @end
@protocol FRSimpleUserStructModel @end
@protocol FRViceOwnerInfoStructModel @end
@protocol FRCommentStructModel @end
@protocol FRMoMoAdStructModel @end
@protocol FRInterestItemStructModel @end
@protocol FRInterestForumStructModel @end
@protocol FROpenForumStructModel @end
@protocol FRRelatedForumStructModel @end
@protocol FRForumItemStructModel @end
@protocol FRForumClassStructModel @end
@protocol FRImageUrlStructModel @end
@protocol FRMagicUrlStructModel @end
@protocol FRTipsStructModel @end
@protocol FRTabStructModel @end
@protocol FRTabExtraStructModel @end
@protocol FRTabRNInfoStructModel @end
@protocol FRCommentBrowStructModel @end
@protocol FRUserInfoStructModel @end
@protocol FRThreadDataStructModel @end
@protocol FRGeneralThreadStructModel @end
@protocol FRForumBannerStructModel @end
@protocol FRMessageListStructModel @end
@protocol FRMessageListUserInfoStructModel @end
@protocol FRMessageListDataStructModel @end
@protocol FRMessageListDataGroupStructModel @end
@protocol FRForumStructModel @end
@protocol FRTTForumStructModel @end
@protocol FRForumSpotStructModel @end
@protocol FRForumSpotItemStructModel @end
@protocol FRTTForumTitleImageStructModel @end
@protocol FRTTForumLogoImageStructModel @end
@protocol FRTTForumRankInfoStructModel @end
@protocol FRTTForumExtraStructModel @end
@protocol FRTagStructModel @end
@protocol FRForumTagStructModel @end
@protocol FRButtonListItemStructModel @end
@protocol FRDataListItemStructModel @end
@protocol FRUserCommentSpecialStructModel @end
@protocol FRLoginUserInfoStructModel @end
@protocol FRGeographyStructModel @end
@protocol FRRoleMemberStructModel @end
@protocol FROwnerApplyHistoryItemStructModel @end
@protocol FROwnerApplyHistorysStructModel @end
@protocol FROwnerAuditingInfoStructModel @end
@protocol FROwnerHotForumStructModel @end
@protocol FRUserIconStructModel @end
@protocol FROwnerActionStatDataStructModel @end
@protocol FRForumStatDataStructModel @end
@protocol FRMovieReviewBasicInfoStructModel @end
@protocol FRGroupLikeStructModel @end
@protocol FRUgcDataStructModel @end
@protocol FRActionStructModel @end
@protocol FRGroupInfoStructModel @end
@protocol FRMediaInfoStructModel @end
@protocol FRNormalThreadStructModel @end
@protocol FRMovieStructModel @end
@protocol FRUserPositionStructModel @end
@protocol FRDiscussCommentStructModel @end
@protocol FRDiscussCommentBrowStructModel @end
@protocol FRRelatedNewStructModel @end
@protocol FRConcernWordsStructModel @end
@protocol FRHashTagPositionStructModel @end
@protocol FRConcernForumStructModel @end
@protocol FRConcernTabStructModel @end
@protocol FRTTForumTabStructModel @end
@protocol FRTTForumTabExtraStructModel @end
@protocol FRTTForumPublisherControllStructModel @end
@protocol FRTTPublisherTypeStructModel @end
@protocol FRConcernItemStructModel @end
@protocol FRConcernStructModel @end
@protocol FRShareStructModel @end
@protocol FRConcernForTagStructModel @end
@protocol FRConcernTagStructModel @end
@protocol FRRecommendTagStructModel @end
@protocol FRThreadListStructModel @end
@protocol FRPublisherPermissionIntroStructModel @end
@protocol FRPublisherPermissionStructModel @end
@protocol FRUgcVideoDetailInfoStructModel @end
@protocol FRUgcVideoStructModel @end
@protocol FRCommentTabInfoStructModel @end
@protocol FRNewCommentReplyStructModel @end
@protocol FRNewCommentQutoedStructModel @end
@protocol FRNewCommentStructModel @end
@protocol FRNewCommentDataStructModel @end
@protocol FRDeleteCommentDataStructModel @end
@protocol FRRichTextLinkStructModel @end
@protocol FRRichTextAttributesStructModel @end
@protocol FRRichTextStructModel @end
@protocol FRColdStartRecommendUserStructModel @end
@protocol FRFollowInfoStructModel @end
@protocol FRPublishConfigStructModel @end
@protocol FRCommonUserStructModel @end
@protocol FRCommonUserInfoStructModel @end
@protocol FRCommonUserRelationStructModel @end
@protocol FRUserRelationCountStructModel @end
@protocol FRRecommendCardStructModel @end
@protocol FRRecommendMultiCardStructModel @end
@protocol FRRecommendUserLargeCardStructModel @end
@protocol FRFollowChannelColdBootUserContainerStructModel @end
@protocol FRFollowChannelColdBootRecommendUserCardStructModel @end
@protocol FRUserRelationContactFriendsUserStructModel @end
@protocol FRUserRelationContactFriendsDataStructModel @end
@protocol FRUGCVideoUserInfoStructModel @end
@protocol FRUGCVideoUserRelationStructModel @end
@protocol FRUGCVideoUserRelationCountStructModel @end
@protocol FRUGCVideoUserStructModel @end
@protocol FRUGCVideoActionStructModel @end
@protocol FRUGCVideoPublishReasonStructModel @end
@protocol FRUGCVideoRawDataStructModel @end
@protocol FRUGCVideoDataStructModel @end
@protocol FRRecommendSponsorStructModel @end
@protocol FRRedpackStructModel @end
@protocol FRActivityStructModel @end
@protocol FRUserExpressionConfigStructModel @end
@protocol FRTextUrlStructModel @end
@protocol FRBonusStructModel @end
@protocol FRRedpacketOpenResultStructModel @end
@protocol FRAddFriendsUserWrapperStructModel @end
@protocol FRInviteFriendsUserWrapperStructModel @end
@protocol FRAddFriendsDataStructModel @end
@protocol FRInviteFriendsDataStructModel @end
@protocol FRContactsRedpacketCheckResultStructModel @end
@protocol FRContactsRedpacketOpenResultStructModel @end
@protocol FRMomentsRecommendUserStructModel @end
@protocol FRActionDataStructModel @end
@protocol FRShareInfoStructModel @end
@protocol FRTokenShareInfoStructModel @end
@protocol FRTokenShareTypeStructModel @end
@protocol FRUserBlockedAndBlockingStructModel @end
@protocol FRPublishPostUserInfoStructModel @end
@protocol FRPublishPostUserRelationCountStructModel @end
@protocol FRPublishPostUserRelationStructModel @end
@protocol FRPublishPostUserStructModel @end
@protocol FRPublishPostUserHighlightStructModel @end
@protocol FRPublishPostSearchUserStructModel @end
@protocol FRPublishPostSearchUserContactStructModel @end
@protocol FRPublishPostSearchUserSuggestStructModel @end
@protocol FRRecommendRedpacketDataStructModel @end
@protocol FRRecommendRedpacketResultStructModel @end
@protocol FRShareImageUrlStructModel @end
@protocol FRPublishPostSearchHashtagItemStructModel @end
@protocol FRPublishPostHashtagHighlightStructModel @end
@protocol FRPublishPostSearchHashtagStructModel @end
@protocol FRPublishPostSearchHashtagHotStructModel @end
@protocol FRPublishPostSearchHashtagSuggestStructModel @end
@protocol FRRepostCommonContentStructModel @end
@protocol FRRepostParamStructModel @end
@protocol FRUserRelationContactCheckDataStructModel @end
@protocol FRContactUploadSettingsStructModel @end
@protocol FRFooterRepostStructModel @end
@protocol FRRecommendUserStoryCardStructModel @end
@protocol FRRecommendUserStoryVerifyInfoStructModel @end
@protocol FRUGCThreadStoryDataStructModel @end
@protocol FRUGCStoryCoverDataStructModel @end
@protocol FRUGCStoryCoverShowMoreStructModel @end
@protocol FRUserDecorationStructModel @end
@protocol FRRecommendUserStoryHasMoreStructModel @end
@protocol FRQRCodeLinkInfoStructModel @end
@protocol FRProfileAuthCheckDataStructModel @end
@protocol FRListInteractUserInfoStructModel @end
@protocol FRListInteractStyleCtrlsStructModel @end
@protocol FRListRawReplyDataStructModel @end
@protocol FRListReplyDataStructModel @end
@protocol FRListCommentDataStructModel @end
@protocol FRListInteractRecommendReasonStructModel @end
@protocol FRListInteractDataStructModel @end
@protocol FRUGCPublishGuideInfoStructModel @end
@protocol FRRecommendCardRelatedControlStructModel @end
@protocol FRRelationShipUserInfoStructModel @end
@protocol FRRelationShipFansPlatformInfoStructModel @end
@protocol FRRelationShipFansPlatformDataStructModel @end
@protocol FRRelationShipFansInteractionStructModel @end
@protocol FRRelationShipFollowersDataStructModel @end
@protocol FRRelationShipFansDataStructModel @end
@protocol FRGifImageDataStructModel @end
@protocol FRGifImageDataListStructModel @end
@protocol FRConcernShareInfoStructModel @end
@protocol FRTTForumShareInfoStructModel @end
@protocol FRBusinessAllianceStructModel @end
@protocol FRBusinessToolboxItemStructModel @end
@protocol FRBusinessToolboxDataStructModel @end

@interface FRApiRequestModel : JSONModel
@property (strong, nonatomic) NSString *_uri;
@property (strong, nonatomic) NSString *_response;
@property (assign, nonatomic) BOOL _isGet;
@end

@interface FRApiResponseModel : JSONModel
@property (assign, nonatomic) NSInteger error;
@end

@interface  FRMapStructModel : JSONModel
@end

@interface  FRGroupStructModel : JSONModel
@property (strong, nonatomic) NSNumber *group_id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *thumb_url;
@property (assign, nonatomic) FRGroupMediaType media_type;
@property (strong, nonatomic) NSString *open_url;
@end

@interface  FRUserRoleStructModel : JSONModel
@property (assign, nonatomic) FRRoleDisplayType role_display_type;
@property (strong, nonatomic) NSString *role_name;
@end

@interface  FRUserApplyRoleInfoStructModel : JSONModel
@property (strong, nonatomic) NSNumber *owner_forum_length;
@property (strong, nonatomic) NSNumber *apply_owner_forum_length;
@property (strong, nonatomic) NSNumber *vice_owner_forum_length;
@property (strong, nonatomic) NSNumber *apply_vice_owner_forum_length;
@property (strong, nonatomic) NSNumber *user_to_forum_owner;
@property (strong, nonatomic) NSNumber *user_to_forum_vice_owner;
@end

@interface  FRForumRoleInfoStructModel : JSONModel
@property (strong, nonatomic) NSNumber *moderator_users_length;
@property (strong, nonatomic) NSNumber *vice_moderator_users_length;
@end

@interface  FRUserStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *is_friend;
@property (strong, nonatomic) NSNumber<Optional> *is_blocked;
@property (strong, nonatomic) NSNumber<Optional> *is_blocking;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSString<Optional> *desc;
@property (strong, nonatomic) NSNumber<Optional> *user_verified;
@property (strong, nonatomic) NSString<Optional> *screen_name;
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSNumber<Optional> *is_following;
@property (strong, nonatomic) FRUserRoleStructModel<Optional> *user_role;
@property (strong, nonatomic) NSString<Optional> *verified_content;
@property (strong, nonatomic) NSArray<FRUserRoleStructModel, Optional> *user_roles;
@property (strong, nonatomic) NSArray<FRUserIconStructModel, Optional> *user_role_icons;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSNumber<Optional> *followers_count;
@property (strong, nonatomic) NSNumber<Optional> *followings_count;
@property (strong, nonatomic) NSString<Optional> *user_decoration;
@end

@interface  FRSimpleUserStructModel : JSONModel
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *verified_content;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSNumber<Optional> *follow;
@property (strong, nonatomic) NSNumber<Optional> *user_verified;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@end

@interface  FRViceOwnerInfoStructModel : JSONModel
@property (strong, nonatomic) FRUserStructModel *user_info;
@property (strong, nonatomic) NSNumber *commit_count;
@property (strong, nonatomic) NSNumber *reply_count;
@property (strong, nonatomic) NSString<Optional> *reason;
@property (strong, nonatomic) NSString<Optional> *apply_time;
@end

@interface  FRCommentStructModel : JSONModel
@property (strong, nonatomic) NSNumber *comment_id;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *create_time;
@property (strong, nonatomic) NSNumber *digg_count;
@property (assign, nonatomic) FRHasUserDigType user_digg;
@property (strong, nonatomic) FRUserStructModel *user;
@property (strong, nonatomic) FRCommentStructModel<Optional> *reply_comment;
@end

@interface  FRMoMoAdStructModel : JSONModel
@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSNumber *ad_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *sname;
@property (strong, nonatomic) NSString *distance;
@property (strong, nonatomic) NSString *sign;
@property (strong, nonatomic) NSNumber *gid;
@property (strong, nonatomic) NSNumber *show_ad_tag;
@end

@interface  FRInterestItemStructModel : JSONModel
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString<Optional> *open_url;
@end

@interface  FRInterestForumStructModel : JSONModel
@property (strong, nonatomic) NSString *reason;
@property (strong, nonatomic) NSArray<FRInterestItemStructModel, Optional> *interest_forum_list;
@end

@interface  FROpenForumStructModel : JSONModel
@property (strong, nonatomic) FRForumStructModel *forum_item;
@property (strong, nonatomic) NSString<Optional> *open_url;
@end

@interface  FRRelatedForumStructModel : JSONModel
@property (strong, nonatomic) NSString *reason;
@property (strong, nonatomic) NSArray<FROpenForumStructModel, Optional> *related_forum_list;
@end

@interface  FRForumItemStructModel : JSONModel
@property (strong, nonatomic) NSString *forum_name;
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSNumber *onlookers_count;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSString *banner_url;
@property (strong, nonatomic) NSNumber *talk_count;
@property (strong, nonatomic) NSNumber<Optional> *like_time;
@property (strong, nonatomic) NSString<Optional> *forum_hot_header;
@property (strong, nonatomic) NSString<Optional> *schema;
@end

@interface  FRForumClassStructModel : JSONModel
@property (strong, nonatomic) NSString *class_name;
@property (strong, nonatomic) NSArray<FRForumItemStructModel, Optional> *forum_list;
@end

@interface  FRImageUrlStructModel : JSONModel
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSNumber *width;
@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSArray<FRMagicUrlStructModel, Optional> *url_list;
@property (strong, nonatomic) NSNumber<Optional> *type;
@property (strong, nonatomic) NSString<Optional> *open_url;
@end

@interface  FRMagicUrlStructModel : JSONModel
@property (strong, nonatomic) NSString *url;
@end

@interface  FRTipsStructModel : JSONModel
@property (strong, nonatomic) NSString *display_info;
@property (strong, nonatomic) NSNumber *display_duration;
@property (strong, nonatomic) NSString *click_url;
@end

@interface  FRTabStructModel : JSONModel
@property (assign, nonatomic) FRTabIdType table_type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *url;
@property (assign, nonatomic) FRTabParamType need_common_params;
@property (strong, nonatomic) NSNumber *refresh_interval;
@property (strong, nonatomic) FRTabExtraStructModel<Optional> *extra;
@end

@interface  FRTabExtraStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *umeng_name;
@property (strong, nonatomic) NSString<Optional> *query_dict;
@property (strong, nonatomic) FRTabRNInfoStructModel<Optional> *rn_info;
@end

@interface  FRTabRNInfoStructModel : JSONModel
@property (strong, nonatomic) NSString *module_name;
@property (strong, nonatomic) NSString *bundle_url;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *props;
@property (strong, nonatomic) NSString<Optional> *md5;
@property (strong, nonatomic) NSString<Optional> *rn_min_version;
@end

@interface  FRCommentBrowStructModel : JSONModel
@property (strong, nonatomic) NSNumber *thread_id;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *total_count;
@property (strong, nonatomic) NSArray<FRCommentStructModel, Optional> *data;
@end

@interface  FRUserInfoStructModel : JSONModel
@property (assign, nonatomic) FRUserFollowingType is_following;
@property (strong, nonatomic) NSNumber *followings_count;
@property (strong, nonatomic) NSString *mobile_hash;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString *verified_agency;
@property (assign, nonatomic) FRUserBlockingType is_blocking;
@property (assign, nonatomic) FRUserVerifyType user_verified;
@property (assign, nonatomic) FRRecommendReasonType reason_type;
@property (assign, nonatomic) FRUserBlockedType is_blocked;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) FRUserGenderType gender;
@property (strong, nonatomic) NSString *screen_name;
@property (strong, nonatomic) NSNumber *user_id;
@property (assign, nonatomic) FRUserFollowedType is_followed;
@property (strong, nonatomic) NSNumber *followers_count;
@property (strong, nonatomic) NSString *verified_content;
@property (strong, nonatomic) NSString *recommend_reason;
@property (strong, nonatomic) NSString *mobile;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@end

@interface  FRThreadDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSNumber *cursor;
@property (strong, nonatomic) NSString *reason;
@property (strong, nonatomic) NSNumber *modify_time;
@property (assign, nonatomic) FRTalkType item_type;
@property (strong, nonatomic) NSNumber *comment_count;
@property (strong, nonatomic) NSNumber *talk_type;
@property (strong, nonatomic) NSNumber *digg_count;
@property (strong, nonatomic) NSNumber *digg_limit;
@property (strong, nonatomic) NSArray<FRUserStructModel, Optional> *digg_list;
@property (strong, nonatomic) NSArray<FRUserStructModel, Optional> *friend_digg_list;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *create_time;
@property (strong, nonatomic) NSString *share_url;
@property (strong, nonatomic) FRForumItemStructModel<Optional> *talk_item;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *large_image_list;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *thumb_image_list;
@property (strong, nonatomic) FRGroupStructModel<Optional> *group;
@property (strong, nonatomic) FRThreadDataStructModel<Optional> *origin_item;
@property (strong, nonatomic) FRUserStructModel *user;
@property (strong, nonatomic) NSArray<FRCommentStructModel, Optional> *comments;
@property (assign, nonatomic) FRHasUserDigType user_digg;
@property (strong, nonatomic) NSNumber *show_comments_num;
@property (strong, nonatomic) FRUserCommentSpecialStructModel<Optional> *user_comment;
@property (strong, nonatomic) FRGeographyStructModel<Optional> *position;
@property (strong, nonatomic) NSNumber *rate;
@property (strong, nonatomic) NSNumber *status;
@property (strong, nonatomic) NSString<Optional> *omitted_content;
@property (strong, nonatomic) NSString<Optional> *time_desc;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString<Optional> *phone;
@property (strong, nonatomic) NSString<Optional> *score;
@property (strong, nonatomic) NSNumber<Optional> *user_repin;
@property (strong, nonatomic) FRFollowInfoStructModel<Optional> *forward_info;
@property (strong, nonatomic) FRRepostParamStructModel<Optional> *repost_params;
@property (strong, nonatomic) NSString<Optional> *brand_info;
@property (strong, nonatomic) NSNumber<Optional> *forum_id;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSNumber<Optional> *flags;
@property (strong, nonatomic) NSNumber<Optional> *read_count;
@property (strong, nonatomic) NSNumber<Optional> *show_origin;
@property (strong, nonatomic) NSString<Optional> *show_tips;
@property (strong, nonatomic) NSNumber<Optional> *forward_num;
@end

@interface  FRGeneralThreadStructModel : JSONModel
@property (strong, nonatomic) FRThreadDataStructModel<Optional> *thread;
@property (strong, nonatomic) FRMoMoAdStructModel<Optional> *momo_ad;
@property (strong, nonatomic) FRInterestForumStructModel<Optional> *interest_forum;
@property (strong, nonatomic) FRRelatedForumStructModel<Optional> *related_forum;
@end

@interface  FRForumBannerStructModel : JSONModel
@property (strong, nonatomic) FRForumItemStructModel<Optional> *forum_info;
@property (strong, nonatomic) FRImageUrlStructModel *banner_imglist;
@property (strong, nonatomic) NSString *banner_header_name;
@property (strong, nonatomic) NSString *jump_url;
@end

@interface  FRMessageListStructModel : JSONModel
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber<Optional> *min_cursor;
@property (strong, nonatomic) NSNumber<Optional> *max_cursor;
@property (strong, nonatomic) NSArray<FRMessageListDataStructModel, Optional> *data;
@end

@interface  FRMessageListUserInfoStructModel : JSONModel
@property (assign, nonatomic) FRUserVerifyType user_verified;
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString *screen_name;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *verified_content;
@end

@interface  FRMessageListDataStructModel : JSONModel
@property (strong, nonatomic) FRMessageListDataGroupStructModel *group;
@property (strong, nonatomic) NSNumber<Optional> *cursor;
@property (strong, nonatomic) NSNumber<Optional> *create_time;
@property (strong, nonatomic) FRMessageListUserInfoStructModel<Optional> *user;
@property (strong, nonatomic) NSNumber<Optional> *dongtai_id;
@property (strong, nonatomic) NSNumber<Optional> *type;
@property (strong, nonatomic) NSNumber<Optional> *msg_id;
@property (strong, nonatomic) NSString<Optional> *content;
@end

@interface  FRMessageListDataGroupStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString<Optional> *thumb_url;
@end

@interface  FRForumStructModel : JSONModel
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSString<Optional> *forum_name;
@property (strong, nonatomic) NSString<Optional> *desc;
@property (strong, nonatomic) NSNumber<Optional> *status;
@property (strong, nonatomic) NSString<Optional> *banner_url;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSNumber<Optional> *follower_count;
@property (strong, nonatomic) NSNumber<Optional> *participant_count;
@property (strong, nonatomic) NSNumber<Optional> *talk_count;
@property (strong, nonatomic) NSNumber<Optional> *onlookers_count;
@property (strong, nonatomic) NSNumber<Optional> *like_time;
@property (strong, nonatomic) NSString<Optional> *share_url;
@property (strong, nonatomic) NSString<Optional> *introdution_url;
@property (strong, nonatomic) NSNumber<Optional> *show_et_status;
@property (strong, nonatomic) NSNumber<Optional> *article_count;
@property (strong, nonatomic) NSNumber<Optional> *forum_type_flags;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *sub_title;
@property (strong, nonatomic) NSNumber<Optional> *label_style;
@property (strong, nonatomic) NSNumber<Optional> *icon_style;
@property (strong, nonatomic) NSNumber<Optional> *concern_id;
@property (strong, nonatomic) NSNumber<Optional> *forum_type;
@property (strong, nonatomic) FRCommonUserStructModel<Optional> *host_info;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSString<Optional> *sub_desc;
@property (strong, nonatomic) NSNumber<Optional> *layout;
@end

@interface  FRTTForumStructModel : JSONModel
@property (assign, nonatomic) FRForumStatusType status;
@property (strong, nonatomic) NSString<Optional> *banner_url;
@property (strong, nonatomic) NSString<Optional> *forum_name;
@property (strong, nonatomic) NSNumber<Optional> *logo_type;
@property (strong, nonatomic) NSNumber<Optional> *forum_id;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *desc;
@property (strong, nonatomic) NSString<Optional> *desc_rich_span;
@property (strong, nonatomic) NSString<Optional> *rich_content;
@property (strong, nonatomic) NSString<Optional> *sub_desc;
@property (assign, nonatomic) FRForumProductType product_type;
@property (strong, nonatomic) NSNumber<Optional> *concern_id;
@property (strong, nonatomic) FRCommonUserStructModel<Optional> *host_info;
@property (strong, nonatomic) FRTTForumExtraStructModel<Optional> *extra;
@property (strong, nonatomic) FRTTForumTitleImageStructModel<Optional> *title_url;
@property (strong, nonatomic) FRTTForumLogoImageStructModel<Optional> *forum_logo_url;
@property (strong, nonatomic) NSNumber<Optional> *category_type;
@property (strong, nonatomic) FRTTForumRankInfoStructModel<Optional> *rank_info;
@property (assign, nonatomic) FRForumHeaderStyle header_style;
@property (strong, nonatomic) FRForumSpotStructModel<Optional> *forum_spot;
@end

@interface  FRForumSpotStructModel : JSONModel
@property (strong, nonatomic) NSArray<FRForumSpotItemStructModel, Optional> *forum_spot_items;
@property (strong, nonatomic) FRImageUrlStructModel<Optional> *icon_image;
@property (strong, nonatomic) NSString<Optional> *title;
@end

@interface  FRForumSpotItemStructModel : JSONModel
@property (strong, nonatomic) FRImageUrlStructModel<Optional> *label_image;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSNumber<Optional> *gid;
@end

@interface  FRTTForumTitleImageStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *day_url;
@property (strong, nonatomic) NSString<Optional> *night_url;
@end

@interface  FRTTForumLogoImageStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *day_url;
@property (strong, nonatomic) NSString<Optional> *night_url;
@end

@interface  FRTTForumRankInfoStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *rank_icon;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSNumber<Optional> *rank;
@property (strong, nonatomic) NSNumber<Optional> *rank_id;
@property (strong, nonatomic) NSString<Optional> *rank_list_schema;
@property (strong, nonatomic) NSString<Optional> *to_ranking_schema;
@end

@interface  FRTTForumExtraStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *music_id;
@property (strong, nonatomic) NSString<Optional> *theme_id;
@property (strong, nonatomic) NSNumber<Optional> *effect_id;
@property (strong, nonatomic) NSString<Optional> *data;
@end

@interface  FRTagStructModel : JSONModel
@property (strong, nonatomic) NSNumber *tag_id;
@property (strong, nonatomic) NSString *tag_name;
@end

@interface  FRForumTagStructModel : JSONModel
@property (strong, nonatomic) NSNumber *tag_id;
@property (strong, nonatomic) NSString *tag_name;
@property (strong, nonatomic) NSArray<FRForumItemStructModel, Optional> *forum_info;
@end

@interface  FRButtonListItemStructModel : JSONModel
@property (strong, nonatomic) NSString *appleid;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *action_url;
@end

@interface  FRDataListItemStructModel : JSONModel
@property (strong, nonatomic) NSArray<FRButtonListItemStructModel, Optional> *button_list;
@property (strong, nonatomic) NSNumber *force_update;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSNumber *latency_seconds;
@property (strong, nonatomic) NSNumber *rule_id;
@property (strong, nonatomic) NSString *title;
@end

@interface  FRUserCommentSpecialStructModel : JSONModel
@property (strong, nonatomic) NSString *show_content;
@property (strong, nonatomic) NSNumber *comment_id;
@end

@interface  FRLoginUserInfoStructModel : JSONModel
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSArray<Optional> *user_perm;
@end

@interface  FRGeographyStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *longitude;
@property (strong, nonatomic) NSNumber<Optional> *latitude;
@property (strong, nonatomic) NSString *position;
@end

@interface  FRRoleMemberStructModel : JSONModel
@property (strong, nonatomic) FRUserRoleStructModel *user_role;
@property (strong, nonatomic) NSArray<FRUserStructModel, Optional> *users;
@end

@interface  FROwnerApplyHistoryItemStructModel : JSONModel
@property (strong, nonatomic) FRForumItemStructModel *forum;
@property (strong, nonatomic) NSNumber *apply_status;
@end

@interface  FROwnerApplyHistorysStructModel : JSONModel
@property (strong, nonatomic) NSNumber *cursor;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSArray<FROwnerApplyHistoryItemStructModel, Optional> *history_list;
@end

@interface  FROwnerAuditingInfoStructModel : JSONModel
@property (strong, nonatomic) FRForumItemStructModel *forum;
@property (strong, nonatomic) NSNumber *apply_count;
@end

@interface  FROwnerHotForumStructModel : JSONModel
@property (strong, nonatomic) FRForumItemStructModel *forum;
@property (strong, nonatomic) NSNumber *is_follow;
@end

@interface  FRUserIconStructModel : JSONModel
@property (strong, nonatomic) FRImageUrlStructModel *icon_url;
@property (strong, nonatomic) NSString<Optional> *action_url;
@end

@interface  FROwnerActionStatDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSString *user_name;
@property (strong, nonatomic) NSNumber *publish_count;
@property (strong, nonatomic) NSNumber *comment_count;
@property (strong, nonatomic) NSNumber *star_count;
@property (strong, nonatomic) NSNumber *delete_count;
@end

@interface  FRForumStatDataStructModel : JSONModel
@property (strong, nonatomic) NSString *data_time;
@property (strong, nonatomic) NSNumber *publish_count;
@property (strong, nonatomic) NSNumber *comment_count;
@property (assign, nonatomic) int64_t new_follow_count;
@property (strong, nonatomic) NSArray<FROwnerActionStatDataStructModel, Optional> *owner_action_stat_data_list;
@end

@interface  FRMovieReviewBasicInfoStructModel : JSONModel
@property (strong, nonatomic) NSString *rate;
@property (strong, nonatomic) NSString *participant_count;
@property (strong, nonatomic) NSString<Optional> *douban_rate;
@property (strong, nonatomic) NSString<Optional> *imdb_rate;
@end

@interface  FRGroupLikeStructModel : JSONModel
@property (strong, nonatomic) NSNumber *group_id;
@property (strong, nonatomic) NSString *schema;
@property (strong, nonatomic) FRUserStructModel *user;
@property (strong, nonatomic) NSNumber *digg_count;
@property (strong, nonatomic) NSNumber *comment_count;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *create_time;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray<FRActionStructModel, Optional> *action_list;
@end

@interface  FRUgcDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSNumber<Optional> *digg_count;
@property (strong, nonatomic) NSNumber<Optional> *comment_count;
@property (strong, nonatomic) NSNumber<Optional> *max_text_line;
@property (strong, nonatomic) NSNumber<Optional> *ui_type;
@property (strong, nonatomic) NSString<Optional> *share_url;
@property (strong, nonatomic) NSNumber<Optional> *inner_ui_flag;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *large_image_list;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *thumb_image_list;
@property (strong, nonatomic) FRUserStructModel<Optional> *user;
@property (strong, nonatomic) NSArray<FRUserStructModel, Optional> *friend_digg_list;
@property (strong, nonatomic) NSArray<FRCommentStructModel, Optional> *comments;
@property (strong, nonatomic) NSArray<FRActionStructModel, Optional> *action_list;
@property (strong, nonatomic) NSNumber<Optional> *user_digg;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) FRForumItemStructModel<Optional> *forum;
@property (strong, nonatomic) FRGroupStructModel<Optional> *group;
@property (strong, nonatomic) FRGeographyStructModel<Optional> *position;
@property (strong, nonatomic) NSString<Optional> *score;
@property (strong, nonatomic) NSNumber<Optional> *behot_time;
@property (strong, nonatomic) NSNumber<Optional> *cursor;
@property (strong, nonatomic) NSNumber<Optional> *cell_type;
@property (strong, nonatomic) NSArray<FRHashTagPositionStructModel, Optional> *title_tags;
@property (strong, nonatomic) NSArray<FRHashTagPositionStructModel, Optional> *content_tags;
@property (strong, nonatomic) NSNumber<Optional> *cell_flag;
@property (strong, nonatomic) NSNumber<Optional> *cell_layout_style;
@property (strong, nonatomic) NSNumber<Optional> *is_stick;
@property (strong, nonatomic) NSNumber<Optional> *stick_style;
@property (strong, nonatomic) NSString<Optional> *stick_label;
@property (strong, nonatomic) NSString<Optional> *label;
@property (strong, nonatomic) NSString<Optional> *reason;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) FRUgcDataStructModel<Optional> *origin_thread;
@property (strong, nonatomic) FRGroupInfoStructModel<Optional> *origin_group;
@property (strong, nonatomic) FRUGCVideoDataStructModel<Optional> *origin_ugc_video;
@property (strong, nonatomic) NSNumber<Optional> *repost_type;
@property (strong, nonatomic) NSNumber<Optional> *status;
@property (strong, nonatomic) NSNumber<Optional> *create_time;
@property (strong, nonatomic) FRFollowInfoStructModel<Optional> *forward_info;
@property (strong, nonatomic) NSNumber<Optional> *default_text_line;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *ugc_cut_image_list;
@property (strong, nonatomic) NSNumber<Optional> *read_count;
@property (strong, nonatomic) NSString<Optional> *brand_info;
@property (strong, nonatomic) NSString<Optional> *content_decoration;
@end

@interface  FRActionStructModel : JSONModel
@property (strong, nonatomic) NSNumber *action;
@property (strong, nonatomic) NSString *desc;
@end

@interface  FRGroupInfoStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *source;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString<Optional> *open_url;
@property (strong, nonatomic) NSNumber<Optional> *behot_time;
@property (strong, nonatomic) NSNumber<Optional> *tip;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *image_list;
@property (strong, nonatomic) NSString<Optional> *city;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *large_image_list;
@property (strong, nonatomic) FRImageUrlStructModel<Optional> *middle_image;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *detail_video_large_image;
@property (strong, nonatomic) FRCommentStructModel<Optional> *comment;
@property (strong, nonatomic) NSNumber<Optional> *ban_comment;
@property (strong, nonatomic) NSNumber<Optional> *article_type;
@property (strong, nonatomic) NSNumber<Optional> *article_sub_type;
@property (strong, nonatomic) NSNumber<Optional> *preload_web;
@property (strong, nonatomic) NSString<Optional> *display_url;
@property (strong, nonatomic) NSString<Optional> *display_title;
@property (strong, nonatomic) NSNumber<Optional> *item_version;
@property (strong, nonatomic) NSString<Optional> *label;
@property (strong, nonatomic) NSNumber<Optional> *subject_group_id;
@property (strong, nonatomic) NSNumber<Optional> *natant_level;
@property (strong, nonatomic) NSNumber<Optional> *group_flags;
@property (strong, nonatomic) NSString<Optional> *tc_head_text;
@property (strong, nonatomic) NSNumber<Optional> *label_style;
@property (strong, nonatomic) NSString<Optional> *info_desc;
@property (strong, nonatomic) NSNumber<Optional> *reback_flag;
@property (strong, nonatomic) NSNumber<Optional> *video_style;
@property (strong, nonatomic) NSString<Optional> *video_id;
@property (strong, nonatomic) NSString<Optional> *reason;
@property (strong, nonatomic) NSNumber<Optional> *video_duration;
@property (strong, nonatomic) NSString<Optional> *stick_label;
@property (strong, nonatomic) NSNumber<Optional> *stick_style;
@property (strong, nonatomic) NSString<Optional> *source_avatar;
@property (strong, nonatomic) NSString<Optional> *source_open_url;
@property (strong, nonatomic) NSString<Optional> *source_desc;
@property (strong, nonatomic) NSString<Optional> *source_desc_open_url;
@property (strong, nonatomic) NSNumber<Optional> *source_icon_style;
@property (strong, nonatomic) NSNumber<Optional> *is_subscribe;
@property (strong, nonatomic) NSArray<FRActionStructModel, Optional> *action_list;
@property (strong, nonatomic) NSNumber<Optional> *cell_flag;
@property (strong, nonatomic) NSNumber<Optional> *like_count;
@property (strong, nonatomic) NSNumber<Optional> *comment_count;
@property (strong, nonatomic) NSString<Optional> *abstract;
@property (strong, nonatomic) NSNumber *group_id;
@property (strong, nonatomic) NSNumber *item_id;
@property (strong, nonatomic) NSNumber<Optional> *aggr_type;
@property (strong, nonatomic) NSNumber<Optional> *cell_type;
@property (strong, nonatomic) FRMediaInfoStructModel<Optional> *media_info;
@property (strong, nonatomic) NSNumber<Optional> *user_like;
@property (strong, nonatomic) NSString<Optional> *share_url;
@property (strong, nonatomic) NSNumber<Optional> *bury_count;
@property (strong, nonatomic) NSNumber<Optional> *ignore_web_transform;
@property (strong, nonatomic) FRMessageListUserInfoStructModel<Optional> *user_info;
@property (strong, nonatomic) NSNumber<Optional> *digg_count;
@property (strong, nonatomic) NSNumber<Optional> *read_count;
@property (strong, nonatomic) NSNumber<Optional> *has_video;
@property (strong, nonatomic) NSString<Optional> *keywords;
@property (strong, nonatomic) NSString<Optional> *article_url;
@property (strong, nonatomic) NSNumber<Optional> *has_m3u8_video;
@property (strong, nonatomic) NSNumber<Optional> *has_mp4_video;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSNumber<Optional> *article_deleted;
@property (strong, nonatomic) NSNumber<Optional> *show_origin;
@property (strong, nonatomic) NSString<Optional> *show_tips;
@end

@interface  FRMediaInfoStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSNumber *media_id;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSNumber *user_verified;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@end

@interface  FRNormalThreadStructModel : JSONModel
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSArray<FRGeneralThreadStructModel, Optional> *finfo_list;
@property (strong, nonatomic) NSArray<FRTabStructModel, Optional> *table;
@property (strong, nonatomic) FRLoginUserInfoStructModel *login_user_info;
@property (strong, nonatomic) NSArray<FRThreadDataStructModel, Optional> *top_thread;
@property (strong, nonatomic) FRTipsStructModel<Optional> *tips;
@end

@interface  FRMovieStructModel : JSONModel
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *english_name;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *area_info;
@property (strong, nonatomic) NSString *actors;
@property (strong, nonatomic) NSString *rate;
@property (strong, nonatomic) NSNumber *days;
@property (strong, nonatomic) NSString *image_url;
@property (strong, nonatomic) NSString *movie_id;
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSString *channel_id;
@property (strong, nonatomic) NSString<Optional> *actor_url;
@property (strong, nonatomic) NSString<Optional> *info_url;
@property (strong, nonatomic) NSString<Optional> *uniqueID;
@property (strong, nonatomic) NSString<Optional> *group_flags;
@property (strong, nonatomic) NSString<Optional> *purchase_url;
@property (strong, nonatomic) NSNumber<Optional> *rate_user_count;
@end

@interface  FRUserPositionStructModel : JSONModel
@property (strong, nonatomic) NSNumber *start;
@property (strong, nonatomic) NSNumber *end;
@property (strong, nonatomic) NSString *schema;
@end

@interface  FRDiscussCommentStructModel : JSONModel
@property (strong, nonatomic) NSNumber *comment_id;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *create_time;
@property (strong, nonatomic) NSNumber *digg_count;
@property (assign, nonatomic) FRHasUserDigType user_digg;
@property (strong, nonatomic) FRUserStructModel *user;
@property (strong, nonatomic) NSArray<FRUserPositionStructModel, Optional> *user_position;
@end

@interface  FRDiscussCommentBrowStructModel : JSONModel
@property (strong, nonatomic) NSNumber *thread_id;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *total_count;
@property (strong, nonatomic) NSArray<FRDiscussCommentStructModel, Optional> *data;
@end

@interface  FRRelatedNewStructModel : JSONModel
@property (strong, nonatomic) NSNumber *aggr_type;
@property (strong, nonatomic) NSNumber *article_sub_type;
@property (strong, nonatomic) NSNumber *article_type;
@property (strong, nonatomic) NSString *article_url;
@property (strong, nonatomic) NSNumber *ban_comment;
@property (strong, nonatomic) NSNumber *behot_time;
@property (strong, nonatomic) NSNumber *bury_count;
@property (strong, nonatomic) NSNumber *comment_count;
@property (strong, nonatomic) NSNumber *digg_count;
@property (strong, nonatomic) NSString *display_title;
@property (strong, nonatomic) NSString *display_url;
@property (strong, nonatomic) NSNumber *group_id;
@property (strong, nonatomic) NSNumber *has_image;
@property (strong, nonatomic) NSNumber *has_m3u8_video;
@property (strong, nonatomic) NSNumber *has_mp4_video;
@property (strong, nonatomic) NSNumber *has_video;
@property (strong, nonatomic) NSNumber *hot;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *image_list;
@property (strong, nonatomic) NSNumber *item_id;
@property (strong, nonatomic) NSString *keywords;
@property (strong, nonatomic) NSNumber *level;
@property (strong, nonatomic) NSString *media_name;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *middle_image;
@property (strong, nonatomic) NSNumber *preload_web;
@property (strong, nonatomic) NSNumber *repin_count;
@property (strong, nonatomic) NSString *share_url;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) NSNumber *tag_id;
@property (strong, nonatomic) NSNumber *tip;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSNumber *is_article;
@property (strong, nonatomic) NSString *tags;
@end

@interface  FRConcernWordsStructModel : JSONModel
@property (strong, nonatomic) NSString *schema;
@property (strong, nonatomic) NSString *word;
@end

@interface  FRHashTagPositionStructModel : JSONModel
@property (strong, nonatomic) NSNumber *start;
@property (strong, nonatomic) NSNumber *end;
@property (strong, nonatomic) NSString *schema;
@end

@interface  FRConcernForumStructModel : JSONModel
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSString *forum_name;
@property (strong, nonatomic) NSNumber *show_et_status;
@end

@interface  FRConcernTabStructModel : JSONModel
@property (assign, nonatomic) FRConcernTabIdType table_type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString<Optional> *url;
@property (assign, nonatomic) FRTabParamType need_common_params;
@property (strong, nonatomic) NSNumber *refresh_interval;
@property (strong, nonatomic) FRTabExtraStructModel<Optional> *extra;
@property (strong, nonatomic) NSString *sole_name;
@property (strong, nonatomic) NSNumber<Optional> *tab_et_status;
@property (strong, nonatomic) NSNumber<Optional> *ban_refresh;
@property (strong, nonatomic) NSString<Optional> *category_name;
@end

@interface  FRTTForumTabStructModel : JSONModel
@property (assign, nonatomic) FRForumTabCommonParamType need_common_params;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) FRTTForumTabExtraStructModel<Optional> *extra;
@property (strong, nonatomic) NSString<Optional> *url;
@property (assign, nonatomic) FRForumTableType tab_type;
@property (strong, nonatomic) NSNumber<Optional> *tab_id;
@property (strong, nonatomic) NSNumber<Optional> *refresh_interval;
@property (strong, nonatomic) NSString<Optional> *category_name;
@property (strong, nonatomic) NSString<Optional> *sole_name;
@property (strong, nonatomic) NSNumber<Optional> *ban_refresh;
@property (strong, nonatomic) NSNumber<Optional> *tab_et_status;
@end

@interface  FRTTForumTabExtraStructModel : JSONModel
@end

@interface  FRTTForumPublisherControllStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *publish_module_id;
@property (strong, nonatomic) NSNumber<Optional> *show_et_status;
@property (strong, nonatomic) NSString<Optional> *post_content_hint;
@property (strong, nonatomic) NSNumber<Optional> *tab_publisher_status;
@property (strong, nonatomic) NSArray<FRPublishConfigStructModel, Optional> *publisher_types;
@end

@interface  FRTTPublisherTypeStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *type;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *icon;
@end

@interface  FRConcernItemStructModel : JSONModel
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) int64_t new_thread_count;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSNumber *concern_count;
@property (strong, nonatomic) NSNumber *discuss_count;
@property (strong, nonatomic) NSNumber *newly;
@property (strong, nonatomic) NSString<Optional> *open_url;
@property (strong, nonatomic) NSNumber *concern_time;
@property (strong, nonatomic) NSNumber *managing;
@property (strong, nonatomic) NSString<Optional> *sub_title;
@end

@interface  FRConcernStructModel : JSONModel
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSNumber *concern_count;
@property (strong, nonatomic) NSNumber *discuss_count;
@property (strong, nonatomic) NSNumber *concern_time;
@property (strong, nonatomic) NSString *share_url;
@property (strong, nonatomic) NSString *introdution_url;
@property (strong, nonatomic) NSString<Optional> *desc;
@property (assign, nonatomic) FRInnerForumType type;
@property (strong, nonatomic) NSString<Optional> *extra;
@property (strong, nonatomic) FRShareStructModel<Optional> *share_data;
@property (strong, nonatomic) NSNumber<Optional> *read_count;
@property (strong, nonatomic) NSString<Optional> *desc_rich_span;
@property (strong, nonatomic) NSString<Optional> *music_id;
@property (strong, nonatomic) NSString<Optional> *theme_id;
@property (strong, nonatomic) NSString<Optional> *effect_id;
@end

@interface  FRShareStructModel : JSONModel
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString<Optional> *image_url;
@property (strong, nonatomic) NSString *share_url;
@end

@interface  FRConcernForTagStructModel : JSONModel
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSNumber *concern_count;
@property (strong, nonatomic) NSNumber *discuss_count;
@property (strong, nonatomic) NSNumber *concern_time;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSNumber *status;
@end

@interface  FRConcernTagStructModel : JSONModel
@property (strong, nonatomic) NSNumber *tag_id;
@property (strong, nonatomic) NSString *tag_name;
@property (strong, nonatomic) NSArray<FRConcernForTagStructModel, Optional> *concern_info;
@end

@interface  FRRecommendTagStructModel : JSONModel
@property (strong, nonatomic) NSNumber *tag_name;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *has_more;
@property (strong, nonatomic) NSArray<FRConcernTagStructModel, Optional> *concern_info;
@end

@interface  FRThreadListStructModel : JSONModel
@property (strong, nonatomic) FRTipsStructModel<Optional> *tips;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSArray<FRUgcDataStructModel, Optional> *threads;
@end

@interface  FRPublisherPermissionIntroStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *normal_intro;
@property (strong, nonatomic) NSNumber<Optional> *video_intro_tips;
@property (strong, nonatomic) NSString<Optional> *video_intro_tips_text;
@property (strong, nonatomic) FRRedpackStructModel<Optional> *redpack;
@end

@interface  FRPublisherPermissionStructModel : JSONModel
@property (strong, nonatomic) NSNumber *post_ugc_status;
@property (strong, nonatomic) NSNumber<Optional> *ban_status;
@property (strong, nonatomic) NSString<Optional> *ban_tips;
@property (strong, nonatomic) NSString<Optional> *post_message_content_hint;
@property (strong, nonatomic) NSNumber<Optional> *show_et_status;
@property (strong, nonatomic) NSString<Optional> *first_tips;
@property (strong, nonatomic) NSNumber<Optional> *publish_entrance_style;
@property (strong, nonatomic) NSNumber<Optional> *disable_entrance;
@property (strong, nonatomic) NSNumber<Optional> *show_wenda;
@property (strong, nonatomic) NSNumber<Optional> *show_author_delete_entrance;
@property (strong, nonatomic) NSArray<FRPublishConfigStructModel, Optional> *main_publisher_type;
@property (strong, nonatomic) FRPublisherPermissionIntroStructModel<Optional> *video_intro;
@property (strong, nonatomic) NSNumber<Optional> *show_article_entrance;
@property (strong, nonatomic) NSNumber<Optional> *share_repost_style;
@property (strong, nonatomic) NSNumber<Optional> *flipchat_sync_entrance;
@end

@interface  FRUgcVideoDetailInfoStructModel : JSONModel
@property (strong, nonatomic) NSNumber *group_flags;
@property (strong, nonatomic) NSString *video_id;
@property (strong, nonatomic) NSNumber *video_preloading_flag;
@property (strong, nonatomic) NSNumber *direct_play;
@property (strong, nonatomic) FRImageUrlStructModel *detail_video_large_image;
@property (strong, nonatomic) NSNumber *show_pgc_subscribe;
@end

@interface  FRUgcVideoStructModel : JSONModel
@property (strong, nonatomic) FRUgcVideoDetailInfoStructModel *video_detail_info;
@property (strong, nonatomic) NSNumber *article_type;
@property (strong, nonatomic) NSNumber *publish_time;
@property (strong, nonatomic) NSNumber *video_duration;
@property (strong, nonatomic) NSNumber *video_proportion;
@property (strong, nonatomic) NSNumber *cell_type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *has_video;
@property (strong, nonatomic) NSNumber *show_portrait_article;
@property (strong, nonatomic) FRSimpleUserStructModel *user_info;
@property (strong, nonatomic) NSString<Optional> *source_open_url;
@property (strong, nonatomic) NSNumber *group_flags;
@property (strong, nonatomic) NSString *video_source;
@property (strong, nonatomic) NSNumber *video_proportion_article;
@property (strong, nonatomic) NSNumber *cell_layout_style;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *large_image_list;
@property (strong, nonatomic) NSNumber *item_id;
@property (strong, nonatomic) NSNumber *show_portrait;
@property (strong, nonatomic) NSString *display_url;
@property (strong, nonatomic) NSNumber *cell_flag;
@property (strong, nonatomic) NSString *video_id;
@property (strong, nonatomic) NSNumber *is_subscribe;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSNumber *video_style;
@property (strong, nonatomic) FRMediaInfoStructModel<Optional> *media_info;
@property (strong, nonatomic) NSNumber *group_id;
@end

@interface  FRCommentTabInfoStructModel : JSONModel
@property (strong, nonatomic) NSArray<Optional> *tabs;
@property (strong, nonatomic) NSNumber *current_tab_index;
@end

@interface  FRNewCommentReplyStructModel : JSONModel
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *user_name;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSNumber *user_verified;
@property (strong, nonatomic) NSNumber<Optional> *is_pgc_author;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *author_badge;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@end

@interface  FRNewCommentQutoedStructModel : JSONModel
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *user_name;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@end

@interface  FRNewCommentStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *is_followed;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSNumber<Optional> *reply_count;
@property (strong, nonatomic) NSNumber<Optional> *is_following;
@property (strong, nonatomic) NSArray<FRNewCommentReplyStructModel, Optional> *reply_list;
@property (strong, nonatomic) NSNumber *user_verified;
@property (strong, nonatomic) NSNumber<Optional> *is_blocking;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSNumber *bury_count;
@property (strong, nonatomic) NSArray<Optional> *author_badge;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString<Optional> *verified_reason;
@property (strong, nonatomic) NSString<Optional> *platform;
@property (strong, nonatomic) NSNumber<Optional> *score;
@property (strong, nonatomic) NSString *user_name;
@property (strong, nonatomic) NSString *user_profile_image_url;
@property (strong, nonatomic) NSNumber *user_bury;
@property (strong, nonatomic) NSNumber *user_digg;
@property (strong, nonatomic) NSNumber<Optional> *is_blocked;
@property (strong, nonatomic) NSNumber<Optional> *user_relation;
@property (strong, nonatomic) NSNumber<Optional> *is_pgc_author;
@property (strong, nonatomic) NSNumber *digg_count;
@property (strong, nonatomic) NSNumber *create_time;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@property (strong, nonatomic) FRNewCommentQutoedStructModel<Optional> *reply_to_comment;
@property (strong, nonatomic) NSNumber<Optional> *bind_mobile;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSString<Optional> *user_decoration;
@end

@interface  FRNewCommentDataStructModel : JSONModel
@property (strong, nonatomic) FRNewCommentStructModel *comment;
@property (strong, nonatomic) NSNumber *cell_type;
@end

@interface  FRDeleteCommentDataStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *reply_dongtai_id;
@property (strong, nonatomic) NSString<Optional> *dongtai_comment_id;
@property (strong, nonatomic) NSString *dongtai_id;
@end

@interface  FRRichTextLinkStructModel : JSONModel
@property (strong, nonatomic) NSNumber *start;
@property (strong, nonatomic) NSNumber *length;
@property (strong, nonatomic) NSString<Optional> *link;
@end

@interface  FRRichTextAttributesStructModel : JSONModel
@property (strong, nonatomic) NSArray<FRRichTextLinkStructModel, Optional> *links;
@end

@interface  FRRichTextStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *text;
@property (strong, nonatomic) FRRichTextAttributesStructModel<Optional> *attributes;
@end

@interface  FRColdStartRecommendUserStructModel : JSONModel
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString<Optional> *screen_name;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSNumber<Optional> *gender;
@property (strong, nonatomic) NSString<Optional> *desc;
@property (strong, nonatomic) NSNumber *selected;
@property (strong, nonatomic) NSString<Optional> *dongtai_content;
@property (strong, nonatomic) NSString<Optional> *user_type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString<Optional> *create_time;
@property (strong, nonatomic) NSString<Optional> *media_id;
@property (strong, nonatomic) NSString<Optional> *user_verified;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@end

@interface  FRFollowInfoStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *forward_count;
@end

@interface  FRPublishConfigStructModel : JSONModel
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *icon;
@property (strong, nonatomic) NSString<Optional> *top_icon;
@property (strong, nonatomic) NSString<Optional> *label;
@end

@interface  FRCommonUserStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserInfoStructModel *info;
@property (strong, nonatomic) FRCommonUserRelationStructModel<Optional> *relation;
@property (strong, nonatomic) FRUserRelationCountStructModel<Optional> *relation_count;
@property (strong, nonatomic) FRUserBlockedAndBlockingStructModel<Optional> *block;
@end

@interface  FRCommonUserInfoStructModel : JSONModel
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *desc;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@property (strong, nonatomic) NSNumber<Optional> *user_verified;
@property (strong, nonatomic) NSString<Optional> *verified_content;
@property (strong, nonatomic) NSArray<Optional> *medals;
@property (strong, nonatomic) NSString<Optional> *media_id;
@property (strong, nonatomic) NSString<Optional> *remark_name;
@property (strong, nonatomic) NSString<Optional> *user_decoration;
@property (strong, nonatomic) NSNumber<Optional> *live_info_type;
@property (strong, nonatomic) NSString<Optional> *room_schema;
@end

@interface  FRCommonUserRelationStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *is_friend;
@property (strong, nonatomic) NSNumber<Optional> *is_following;
@property (strong, nonatomic) NSNumber<Optional> *is_followed;
@end

@interface  FRUserRelationCountStructModel : JSONModel
@property (strong, nonatomic) NSNumber *followings_count;
@property (strong, nonatomic) NSNumber *followers_count;
@end

@interface  FRRecommendCardStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserStructModel<Optional> *user;
@property (strong, nonatomic) NSString<Optional> *recommend_reason;
@property (strong, nonatomic) NSNumber<Optional> *recommend_type;
@property (strong, nonatomic) FRActivityStructModel<Optional> *activity;
@property (strong, nonatomic) NSString<Optional> *stats_place_holder;
@property (strong, nonatomic) NSNumber<Optional> *card_type;
@property (strong, nonatomic) NSString<Optional> *profile_user_id;
@property (strong, nonatomic) NSNumber<Optional> *is_action_card;
@property (strong, nonatomic) NSString<Optional> *action_schema;
@property (strong, nonatomic) NSString<Optional> *action_card_title;
@property (strong, nonatomic) NSArray<FRRecommendCardStructModel, Optional> *inner_list;
@property (strong, nonatomic) NSNumber<Optional> *supplement;
@end

@interface  FRRecommendMultiCardStructModel : JSONModel
@property (strong, nonatomic) NSArray<FRRecommendCardStructModel, Optional> *user_cards;
@property (strong, nonatomic) NSNumber<Optional> *card_type;
@property (strong, nonatomic) NSString<Optional> *profile_user_id;
@property (strong, nonatomic) NSNumber<Optional> *count;
@end

@interface  FRRecommendUserLargeCardStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserStructModel *user;
@property (strong, nonatomic) NSString<Optional> *recommend_reason;
@property (strong, nonatomic) NSNumber<Optional> *recommend_type;
@property (strong, nonatomic) NSNumber<Optional> *selected;
@property (strong, nonatomic) NSString<Optional> *stats_place_holder;
@end

@interface  FRFollowChannelColdBootUserContainerStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserStructModel *user;
@property (strong, nonatomic) NSString<Optional> *recommend_reason;
@property (strong, nonatomic) NSNumber<Optional> *selected;
@end

@interface  FRFollowChannelColdBootRecommendUserCardStructModel : JSONModel
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSArray<FRFollowChannelColdBootUserContainerStructModel, Optional> *user_cards;
@property (strong, nonatomic) NSNumber<Optional> *selected;
@end

@interface  FRUserRelationContactFriendsUserStructModel : JSONModel
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *screen_name;
@property (strong, nonatomic) NSString<Optional> *mobile_name;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (assign, nonatomic) FRUserVerifyType user_verified;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@property (strong, nonatomic) NSNumber<Optional> *is_friend;
@property (strong, nonatomic) NSNumber<Optional> *is_following;
@property (strong, nonatomic) NSNumber<Optional> *is_followed;
@property (strong, nonatomic) NSString<Optional> *recommend_reason;
@end

@interface  FRUserRelationContactFriendsDataStructModel : JSONModel
@property (strong, nonatomic) NSArray<FRUserRelationContactFriendsUserStructModel, Optional> *users;
@property (strong, nonatomic) NSString<Optional> *title;
@end

@interface  FRUGCVideoUserInfoStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *user_id;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *verified_content;
@property (strong, nonatomic) NSNumber<Optional> *user_verified;
@property (strong, nonatomic) NSString<Optional> *desc;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@end

@interface  FRUGCVideoUserRelationStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *is_friend;
@property (strong, nonatomic) NSNumber<Optional> *is_following;
@property (strong, nonatomic) NSNumber<Optional> *is_followed;
@end

@interface  FRUGCVideoUserRelationCountStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *following_count;
@property (strong, nonatomic) NSNumber<Optional> *follower_count;
@end

@interface  FRUGCVideoUserStructModel : JSONModel
@property (strong, nonatomic) FRUGCVideoUserInfoStructModel<Optional> *info;
@property (strong, nonatomic) FRUGCVideoUserRelationStructModel<Optional> *relation;
@property (strong, nonatomic) FRUGCVideoUserRelationCountStructModel<Optional> *relation_count;
@end

@interface  FRUGCVideoActionStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *forward_count;
@property (strong, nonatomic) NSNumber<Optional> *comment_count;
@property (strong, nonatomic) NSNumber<Optional> *read_count;
@property (strong, nonatomic) NSNumber<Optional> *digg_count;
@property (strong, nonatomic) NSNumber<Optional> *bury_count;
@property (strong, nonatomic) NSNumber<Optional> *user_digg;
@property (strong, nonatomic) NSNumber<Optional> *user_repin;
@property (strong, nonatomic) NSNumber<Optional> *user_bury;
@property (strong, nonatomic) NSNumber<Optional> *play_count;
@end

@interface  FRUGCVideoPublishReasonStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *verb;
@property (strong, nonatomic) NSString<Optional> *noun;
@end

@interface  FRUGCVideoRawDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *item_id;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSNumber<Optional> *create_time;
@property (strong, nonatomic) NSString<Optional> *app_schema;
@property (strong, nonatomic) NSString<Optional> *detail_schema;
@property (strong, nonatomic) FRUGCVideoUserStructModel<Optional> *user;
@property (strong, nonatomic) FRUGCVideoActionStructModel<Optional> *action;
@property (strong, nonatomic) FRUGCVideoPublishReasonStructModel<Optional> *publish_reason;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *thumb_image_list;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *large_image_list;
@end

@interface  FRUGCVideoDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *group_id;
@property (strong, nonatomic) NSString<Optional> *show_tips;
@property (strong, nonatomic) NSNumber<Optional> *show_origin;
@property (strong, nonatomic) FRUGCVideoRawDataStructModel<Optional> *raw_data;
@end

@interface  FRRecommendSponsorStructModel : JSONModel
@property (strong, nonatomic) NSString *icon_url;
@property (strong, nonatomic) NSString *target_url;
@property (strong, nonatomic) NSString *label;
@end

@interface  FRRedpackStructModel : JSONModel
@property (strong, nonatomic) NSString *redpack_id;
@property (strong, nonatomic) NSNumber<Optional> *button_style;
@property (strong, nonatomic) FRCommonUserInfoStructModel *user_info;
@property (strong, nonatomic) NSString<Optional> *subtitle;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSString *token;
@end

@interface  FRActivityStructModel : JSONModel
@property (strong, nonatomic) FRRedpackStructModel<Optional> *redpack;
@end

@interface  FRUserExpressionConfigStructModel : JSONModel
@property (strong, nonatomic) NSArray<Optional> *default_seq;
@end

@interface  FRTextUrlStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *text;
@property (strong, nonatomic) NSString<Optional> *url;
@end

@interface  FRBonusStructModel : JSONModel
@property (strong, nonatomic) NSString *bonus_id;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) FRTextUrlStructModel<Optional> *show_tips;
@end

@interface  FRRedpacketOpenResultStructModel : JSONModel
@property (strong, nonatomic) NSNumber *status_code;
@property (strong, nonatomic) FRBonusStructModel<Optional> *bonus;
@property (strong, nonatomic) NSString<Optional> *reason;
@property (strong, nonatomic) FRTextUrlStructModel<Optional> *footer;
@end

@interface  FRAddFriendsUserWrapperStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserStructModel *user;
@property (strong, nonatomic) NSString<Optional> *show_name;
@property (strong, nonatomic) NSString<Optional> *real_name;
@property (strong, nonatomic) NSString<Optional> *intro;
@end

@interface  FRInviteFriendsUserWrapperStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserStructModel<Optional> *user;
@property (strong, nonatomic) NSString<Optional> *contact_name;
@property (strong, nonatomic) NSString<Optional> *show_name;
@property (strong, nonatomic) NSNumber<Optional> *is_toutiao_user;
@property (strong, nonatomic) NSString<Optional> *intro;
@property (strong, nonatomic) NSString<Optional> *verify_text;
@end

@interface  FRAddFriendsDataStructModel : JSONModel
@property (strong, nonatomic) NSArray<Optional> *tabs;
@property (strong, nonatomic) NSArray<Optional> *source;
@property (strong, nonatomic) NSArray<Optional> *server_source;
@property (strong, nonatomic) NSArray<FRAddFriendsUserWrapperStructModel, Optional> *recommend_users;
@property (strong, nonatomic) NSNumber<Optional> *has_more;
@property (strong, nonatomic) NSNumber<Optional> *server_follow;
@property (strong, nonatomic) NSNumber<Optional> *count;
@end

@interface  FRInviteFriendsDataStructModel : JSONModel
@property (strong, nonatomic) NSArray<Optional> *server_source;
@property (strong, nonatomic) NSArray<FRInviteFriendsUserWrapperStructModel, Optional> *contact_users;
@property (strong, nonatomic) NSNumber<Optional> *has_more;
@end

@interface  FRContactsRedpacketCheckResultStructModel : JSONModel
@property (strong, nonatomic) NSNumber *status;
@property (strong, nonatomic) NSString *redpack_id;
@property (strong, nonatomic) NSString *token;
@end

@interface  FRContactsRedpacketOpenResultStructModel : JSONModel
@property (strong, nonatomic) NSString *redpack_id;
@property (strong, nonatomic) NSNumber *redpack_amount;
@property (strong, nonatomic) NSString *my_redpacks_url;
@end

@interface  FRMomentsRecommendUserStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserStructModel *user;
@property (strong, nonatomic) NSString<Optional> *real_name;
@property (strong, nonatomic) NSNumber<Optional> *fans;
@property (strong, nonatomic) NSString<Optional> *intro;
@property (strong, nonatomic) NSString<Optional> *stats_place_holder;
@property (strong, nonatomic) NSNumber<Optional> *recommend_type;
@property (strong, nonatomic) NSNumber<Optional> *selected;
@end

@interface  FRActionDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *forward_count;
@property (strong, nonatomic) NSNumber<Optional> *comment_count;
@property (strong, nonatomic) NSNumber<Optional> *read_count;
@property (strong, nonatomic) NSNumber<Optional> *digg_count;
@property (strong, nonatomic) NSNumber<Optional> *bury_count;
@property (strong, nonatomic) NSNumber<Optional> *user_digg;
@property (strong, nonatomic) NSNumber<Optional> *user_repin;
@property (strong, nonatomic) NSNumber<Optional> *user_bury;
@property (strong, nonatomic) NSNumber<Optional> *play_count;
@end

@interface  FRShareInfoStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *share_url;
@property (strong, nonatomic) NSString<Optional> *share_title;
@property (strong, nonatomic) NSString<Optional> *share_desc;
@property (strong, nonatomic) NSString<Optional> *share_weibo_desc;
@property (strong, nonatomic) FRShareImageUrlStructModel<Optional> *share_cover;
@end

@interface  FRTokenShareInfoStructModel : JSONModel
@property (strong, nonatomic) FRTokenShareTypeStructModel<Optional> *share_type;
@property (strong, nonatomic) NSNumber<Optional> *token_type;
@end

@interface  FRTokenShareTypeStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *pyq;
@property (strong, nonatomic) NSNumber<Optional> *qq;
@property (strong, nonatomic) NSNumber<Optional> *qzone;
@property (strong, nonatomic) NSNumber<Optional> *wx;
@end

@interface  FRUserBlockedAndBlockingStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *is_blocking;
@property (strong, nonatomic) NSNumber<Optional> *is_blocked;
@end

@interface  FRPublishPostUserInfoStructModel : JSONModel
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString<Optional> *desc;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@property (strong, nonatomic) NSString<Optional> *user_verified;
@property (strong, nonatomic) NSString<Optional> *verified_content;
@property (strong, nonatomic) NSString<Optional> *media_id;
@property (strong, nonatomic) NSString<Optional> *user_decoration;
@end

@interface  FRPublishPostUserRelationCountStructModel : JSONModel
@property (strong, nonatomic) NSNumber *followings_count;
@property (strong, nonatomic) NSNumber *followers_count;
@end

@interface  FRPublishPostUserRelationStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *remark_name;
@end

@interface  FRPublishPostUserStructModel : JSONModel
@property (strong, nonatomic) FRPublishPostUserInfoStructModel *info;
@property (strong, nonatomic) FRPublishPostUserRelationStructModel<Optional> *relation;
@property (strong, nonatomic) FRPublishPostUserRelationCountStructModel<Optional> *relation_count;
@end

@interface  FRPublishPostUserHighlightStructModel : JSONModel
@property (strong, nonatomic) NSArray<Optional> *name;
@property (strong, nonatomic) NSArray<Optional> *remark_name;
@end

@interface  FRPublishPostSearchUserStructModel : JSONModel
@property (strong, nonatomic) FRPublishPostUserStructModel *user;
@property (strong, nonatomic) FRPublishPostUserHighlightStructModel<Optional> *highlight;
@end

@interface  FRPublishPostSearchUserContactStructModel : JSONModel
@property (strong, nonatomic) NSNumber *offset;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSArray<FRPublishPostSearchUserStructModel, Optional> *recently;
@property (strong, nonatomic) NSArray<FRPublishPostSearchUserStructModel, Optional> *following;
@end

@interface  FRPublishPostSearchUserSuggestStructModel : JSONModel
@property (strong, nonatomic) NSNumber *offset;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (nonatomic, copy)     NSString       *search_id;
@property (strong, nonatomic) NSArray<FRPublishPostSearchUserStructModel, Optional> *following;
@property (strong, nonatomic) NSArray<FRPublishPostSearchUserStructModel, Optional> *suggest;
@end

@interface  FRRecommendRedpacketDataStructModel : JSONModel
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSString *sub_title;
@property (strong, nonatomic) NSString *schema;
@end

@interface  FRRecommendRedpacketResultStructModel : JSONModel
@property (strong, nonatomic) FRRecommendRedpacketDataStructModel *redpack;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray<FRCommonUserStructModel, Optional> *users;
@property (strong, nonatomic) NSString<Optional> *show_label;
@property (strong, nonatomic) NSString<Optional> *button_text;
@property (strong, nonatomic) NSString<Optional> *button_schema;
@end

@interface  FRShareImageUrlStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *uri;
@property (strong, nonatomic) NSArray<Optional> *url_list;
@end

@interface  FRPublishPostSearchHashtagItemStructModel : JSONModel
@property (strong, nonatomic) NSString *forum_name;
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSString<Optional> *desc;
@property (strong, nonatomic) NSString *schema;
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSString<Optional> *talk_count_str;
@property (strong, nonatomic) NSNumber<Optional> *status;
@end

@interface  FRPublishPostHashtagHighlightStructModel : JSONModel
@property (strong, nonatomic) NSArray<Optional> *forum_name;
@end

@interface  FRPublishPostSearchHashtagStructModel : JSONModel
@property (strong, nonatomic) FRPublishPostSearchHashtagItemStructModel *forum;
@property (strong, nonatomic) FRPublishPostHashtagHighlightStructModel<Optional> *highlight;
@end

@interface  FRPublishPostSearchHashtagHotStructModel : JSONModel
@property (strong, nonatomic) NSNumber *offset;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSArray<FRPublishPostSearchHashtagStructModel, Optional> *recently;
@property (strong, nonatomic) NSArray<FRPublishPostSearchHashtagStructModel, Optional> *hot;
@property (strong, nonatomic) NSString<Optional> *suggest_tips;
@end

@interface  FRPublishPostSearchHashtagSuggestStructModel : JSONModel
@property (strong, nonatomic) NSNumber *offset;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSArray<FRPublishPostSearchHashtagStructModel, Optional> *suggest;
@property (strong, nonatomic) FRPublishPostSearchHashtagStructModel<Optional> *fresh_forum;
@end

@interface  FRRepostCommonContentStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) FRImageUrlStructModel<Optional> *cover_image;
@property (strong, nonatomic) NSNumber<Optional> *has_video;
@end

@interface  FRRepostParamStructModel : JSONModel
@property (strong, nonatomic) NSNumber *repost_type;
@property (strong, nonatomic) NSNumber *fw_id;
@property (assign, nonatomic) FRUGCTypeCode fw_id_type;
@property (strong, nonatomic) NSNumber *fw_user_id;
@property (strong, nonatomic) NSNumber *opt_id;
@property (assign, nonatomic) FRUGCTypeCode opt_id_type;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *fw_native_schema;
@property (strong, nonatomic) NSString<Optional> *fw_share_url;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString<Optional> *cover_url;
@end

@interface  FRUserRelationContactCheckDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber *should_popup;
@property (strong, nonatomic) NSNumber *has_collected;
@property (strong, nonatomic) NSNumber<Optional> *popup_type;
@property (strong, nonatomic) NSNumber<Optional> *next_time;
@property (strong, nonatomic) FRContactsRedpacketCheckResultStructModel<Optional> *redpack;
@property (strong, nonatomic) FRContactUploadSettingsStructModel<Optional> *contact_upload_settings;
@end

@interface  FRContactUploadSettingsStructModel : JSONModel
@property (strong, nonatomic) NSString *major_text;
@property (strong, nonatomic) NSString *minor_text;
@property (strong, nonatomic) NSString *privacy_notice;
@property (strong, nonatomic) NSString *button_text;
@property (strong, nonatomic) NSString *diagram_url;
@property (strong, nonatomic) NSString *diagram_url_night;
@property (strong, nonatomic) NSString *friends_list_title;
@property (strong, nonatomic) NSString *friends_list_button_text;
@property (strong, nonatomic) NSNumber<Optional> *confirm_times;
@property (strong, nonatomic) NSString *privacy_notice_schema_text;
@end

@interface  FRFooterRepostStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *id;
@property (assign, nonatomic) FRFooterRepostTypeCode repost_id_type;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) FRCommonUserStructModel<Optional> *user;
@property (strong, nonatomic) NSNumber<Optional> *is_author;
@property (strong, nonatomic) NSString<Optional> *detail_schema;
@property (strong, nonatomic) FRActionDataStructModel<Optional> *action;
@property (strong, nonatomic) NSNumber<Optional> *create_time;
@property (strong, nonatomic) NSArray<FRImageUrlStructModel, Optional> *author_badge;
@end

@interface  FRRecommendUserStoryCardStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserStructModel *user;
@property (strong, nonatomic) NSString<Optional> *open_url;
@property (strong, nonatomic) NSNumber<Optional> *has_new;
@property (strong, nonatomic) NSString<Optional> *stats_place_holder;
@property (strong, nonatomic) FRRecommendUserStoryVerifyInfoStructModel<Optional> *story_label;
@property (strong, nonatomic) NSNumber<Optional> *is_live;
@property (strong, nonatomic) NSNumber<Optional> *live_gid;
@property (strong, nonatomic) NSNumber<Optional> *orientation;
@property (strong, nonatomic) NSNumber<Optional> *multi_live;
@end

@interface  FRRecommendUserStoryVerifyInfoStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString *reason;
@end

@interface  FRUGCThreadStoryDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber *has_more;
@property (strong, nonatomic) NSArray<Optional> *stories;
@property (strong, nonatomic) FRCommonUserStructModel<Optional> *user;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSString<Optional> *tail;
@end

@interface  FRUGCStoryCoverDataStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserStructModel<Optional> *user;
@property (strong, nonatomic) NSNumber *content_id;
@property (strong, nonatomic) FRImageUrlStructModel<Optional> *cover_image;
@property (strong, nonatomic) NSNumber<Optional> *update_time;
@property (strong, nonatomic) NSString<Optional> *content;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSString<Optional> *origin_content;
@property (strong, nonatomic) NSString<Optional> *origin_content_rich_span;
@property (strong, nonatomic) NSString<Optional> *detail_schema;
@property (strong, nonatomic) NSNumber<Optional> *has_video;
@property (strong, nonatomic) NSNumber<Optional> *image_num;
@property (strong, nonatomic) NSNumber<Optional> *video_duration;
@property (assign, nonatomic) FRUGCStoryCoverType display_type;
@property (strong, nonatomic) FRRecommendUserStoryVerifyInfoStructModel<Optional> *story_label;
@property (strong, nonatomic) NSNumber<Optional> *display_sub_type;
@property (strong, nonatomic) NSString<Optional> *recommend_reason;
@property (strong, nonatomic) NSString<Optional> *story_extra;
@property (strong, nonatomic) NSString<Optional> *log_pb;
@property (strong, nonatomic) NSString<Optional> *group_source;
@end

@interface  FRUGCStoryCoverShowMoreStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *text;
@property (strong, nonatomic) NSString<Optional> *url;
@property (strong, nonatomic) NSString<Optional> *icon_day;
@property (strong, nonatomic) NSString<Optional> *icon_night;
@end

@interface  FRUserDecorationStructModel : JSONModel
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *user_decoration;
@end

@interface  FRRecommendUserStoryHasMoreStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString<Optional> *icon;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *function_name;
@property (strong, nonatomic) NSString<Optional> *night_icon;
@end

@interface  FRQRCodeLinkInfoStructModel : JSONModel
@property (strong, nonatomic) NSString *url;
@end

@interface  FRProfileAuthCheckDataStructModel : JSONModel
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *show_auth_guidance;
@property (strong, nonatomic) NSString<Optional> *body;
@property (strong, nonatomic) NSString<Optional> *button_schema;
@property (strong, nonatomic) NSString<Optional> *button_text;
@property (strong, nonatomic) NSNumber<Optional> *popup_style;
@end

@interface  FRListInteractUserInfoStructModel : JSONModel
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *schema;
@property (strong, nonatomic) NSString<Optional> *user_auth_info;
@end

@interface  FRListInteractStyleCtrlsStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *max_comment_line;
@property (strong, nonatomic) NSNumber<Optional> *max_digg_line;
@property (strong, nonatomic) NSNumber<Optional> *comment_entrance;
@property (strong, nonatomic) NSString<Optional> *comment_show_more_text;
@property (strong, nonatomic) NSString<Optional> *digg_show_more_text;
@property (strong, nonatomic) NSString<Optional> *comment_show_more_schema;
@property (strong, nonatomic) NSString<Optional> *digg_show_more_schema;
@property (strong, nonatomic) NSNumber<Optional> *ban_comment;
@property (strong, nonatomic) NSNumber<Optional> *ban_face;
@property (strong, nonatomic) NSNumber<Optional> *ban_pic_comment;
@property (strong, nonatomic) NSNumber<Optional> *show_repost_entrance;
@property (strong, nonatomic) NSNumber<Optional> *style_type;
@end

@interface  FRListRawReplyDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber *reply_id;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) FRListInteractUserInfoStructModel *user_info;
@end

@interface  FRListReplyDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber *reply_id;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) FRListInteractUserInfoStructModel *user_info;
@property (strong, nonatomic) FRListRawReplyDataStructModel<Optional> *reply_to_reply;
@end

@interface  FRListCommentDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber *comment_id;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) FRListInteractUserInfoStructModel *user_info;
@property (strong, nonatomic) NSArray<FRListReplyDataStructModel, Optional> *reply_list;
@end

@interface  FRListInteractRecommendReasonStructModel : JSONModel
@property (strong, nonatomic) NSString *reason;
@property (strong, nonatomic) NSString<Optional> *schema;
@end

@interface  FRListInteractDataStructModel : JSONModel
@property (strong, nonatomic) NSArray<FRListInteractUserInfoStructModel, Optional> *digg_user_list;
@property (strong, nonatomic) NSArray<FRListCommentDataStructModel, Optional> *comment_list;
@property (strong, nonatomic) NSArray<FRListReplyDataStructModel, Optional> *reply_list;
@property (strong, nonatomic) FRListInteractStyleCtrlsStructModel *style_ctrls;
@property (strong, nonatomic) FRListInteractRecommendReasonStructModel<Optional> *recommend_reason;
@end

@interface  FRUGCPublishGuideInfoStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *guide_type;
@property (strong, nonatomic) NSString<Optional> *major_text;
@property (strong, nonatomic) NSString<Optional> *minor_text;
@property (strong, nonatomic) NSString<Optional> *privacy_notice;
@property (strong, nonatomic) NSString<Optional> *button_text;
@property (strong, nonatomic) NSString<Optional> *diagram_url;
@property (strong, nonatomic) NSString<Optional> *diagram_url_night;
@property (strong, nonatomic) NSString<Optional> *jump_url;
@end

@interface  FRRecommendCardRelatedControlStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *show_related_card;
@property (strong, nonatomic) NSNumber<Optional> *minimum_rate;
@end

@interface  FRRelationShipUserInfoStructModel : JSONModel
@property (strong, nonatomic) FRCommonUserStructModel<Optional> *user;
@property (strong, nonatomic) NSString<Optional> *recommend_reason;
@property (strong, nonatomic) NSString<Optional> *fans;
@property (strong, nonatomic) NSString<Optional> *stats_place_holder;
@property (strong, nonatomic) NSNumber<Optional> *interaction;
@end

@interface  FRRelationShipFansPlatformInfoStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *fans_count;
@property (strong, nonatomic) NSString<Optional> *apple_id;
@property (strong, nonatomic) NSString<Optional> *open_url;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *package_name;
@property (strong, nonatomic) NSString<Optional> *app_name;
@property (strong, nonatomic) NSString<Optional> *download_url;
@property (strong, nonatomic) NSString<Optional> *icon;
@end

@interface  FRRelationShipFansPlatformDataStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *mplatform_followers_count;
@property (strong, nonatomic) NSArray<FRRelationShipFansPlatformInfoStructModel, Optional> *followers_detail;
@end

@interface  FRRelationShipFansInteractionStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString<Optional> *more_info;
@property (strong, nonatomic) NSString<Optional> *open_url;
@property (strong, nonatomic) NSArray<FRRelationShipUserInfoStructModel, Optional> *users;
@end

@interface  FRRelationShipFollowersDataStructModel : JSONModel
@property (strong, nonatomic) NSArray<FRRelationShipUserInfoStructModel, Optional> *users;
@end

@interface  FRRelationShipFansDataStructModel : JSONModel
@property (strong, nonatomic) FRRelationShipFansPlatformDataStructModel<Optional> *fans_detail;
@property (strong, nonatomic) FRRelationShipFansInteractionStructModel<Optional> *interaction;
@property (strong, nonatomic) NSArray<FRRelationShipUserInfoStructModel, Optional> *users;
@property (strong, nonatomic) NSNumber<Optional> *anonymous_fans;
@end

@interface  FRGifImageDataStructModel : JSONModel
@property (strong, nonatomic) FRImageUrlStructModel<Optional> *large_image;
@property (strong, nonatomic) FRImageUrlStructModel<Optional> *thumb_image;
@end

@interface  FRGifImageDataListStructModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *count;
@property (strong, nonatomic) NSNumber<Optional> *offset;
@property (strong, nonatomic) NSNumber<Optional> *has_more;
@property (strong, nonatomic) NSString<Optional> *keyword;
@property (strong, nonatomic) NSArray<FRGifImageDataStructModel, Optional> *images;
@end

@interface  FRConcernShareInfoStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *share_cover;
@property (strong, nonatomic) NSString<Optional> *share_title;
@property (strong, nonatomic) NSString<Optional> *share_url;
@property (strong, nonatomic) NSString<Optional> *share_desc;
@property (strong, nonatomic) NSNumber<Optional> *token_type;
@property (strong, nonatomic) FRTokenShareTypeStructModel<Optional> *share_type;
@end

@interface  FRTTForumShareInfoStructModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *share_cover;
@property (strong, nonatomic) NSString<Optional> *share_title;
@property (strong, nonatomic) NSString<Optional> *share_url;
@property (strong, nonatomic) NSString<Optional> *share_desc;
@property (strong, nonatomic) NSNumber<Optional> *token_type;
@property (strong, nonatomic) FRTokenShareTypeStructModel<Optional> *share_type;
@end

@interface  FRBusinessAllianceStructModel : JSONModel
@property (strong, nonatomic) NSNumber *protocol_accepted;
@property (strong, nonatomic) NSNumber *show_shop_icon;
@end

@interface  FRBusinessToolboxItemStructModel : JSONModel
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *source;
@property (strong, nonatomic) NSString<Optional> *extra;
@end

@interface  FRBusinessToolboxDataStructModel : JSONModel
@property (strong, nonatomic) NSArray<FRBusinessToolboxItemStructModel, Optional> *item_list;
@end

@interface  FRUgcUserDecorationV1RequestModel : TTRequestModel
@property (strong, nonatomic) NSString *user_ids;
@end

@interface  FRUgcUserDecorationV1ResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSArray<FRUserDecorationStructModel, Optional> *user_decoration_list;
@end

@interface  FRTtdiscussV1ShareRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *forward_to;
@property (strong, nonatomic) NSString *forward_type;
@property (strong, nonatomic) NSString *forward_id;
@property (strong, nonatomic) NSString *forward_content;
@end

@interface  FRTtdiscussV1ShareResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSString<Optional> *expired_platform;
@end

@interface  FRUserRelationFansV2RequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *cursor;
@end

@interface  FRUserRelationFansV2ResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString *err_tips;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *cursor;
@property (strong, nonatomic) NSNumber *has_more;
@property (strong, nonatomic) FRRelationShipFansDataStructModel<Optional> *data;
@end

@interface  FRTtdiscussV1ForumSearchRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *count;
@end

@interface  FRTtdiscussV1ForumSearchResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSArray<FRForumItemStructModel, Optional> *forum_list;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommitCommentdeleteRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *comment_id;
@end

@interface  FRTtdiscussV1CommitCommentdeleteResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1MovieListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSNumber *movie_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *movie_cursor;
@property (strong, nonatomic) NSNumber *ugc_cursor;
@property (strong, nonatomic) NSNumber<Optional> *sort_type;
@end

@interface  FRTtdiscussV1MovieListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *ugc_min_cursor;
@property (strong, nonatomic) NSNumber *ugc_max_cursor;
@property (strong, nonatomic) NSNumber *movie_min_cursor;
@property (strong, nonatomic) NSNumber *movie_max_cursor;
@property (strong, nonatomic) NSNumber *ugc_has_more;
@property (strong, nonatomic) NSNumber *movie_has_more;
@property (strong, nonatomic) NSArray<FRGroupInfoStructModel, Optional> *group_list;
@property (strong, nonatomic) NSArray<FRUgcDataStructModel, Optional> *thread_list;
@property (strong, nonatomic) FRMovieReviewBasicInfoStructModel<Optional> *review_info;
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUserRelationUserRecommendV1DislikeCardRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *gid;
@property (strong, nonatomic) NSString<Optional> *profile_user_id;
@end

@interface  FRUserRelationUserRecommendV1DislikeCardResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString<Optional> *message;
@property (strong, nonatomic) NSString<Optional> *data;
@end

@interface  FRTtdiscussV2UgcVideoCheckTitleRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSString<Optional> *mention_user;
@property (strong, nonatomic) NSString<Optional> *mention_concern;
@end

@interface  FRTtdiscussV2UgcVideoCheckTitleResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (assign, nonatomic) FRUgcVideoTitleType status;
@property (strong, nonatomic) NSString<Optional> *status_tips;
@end

@interface  FRConcernV1HomeHeadRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSString<Optional> *city;
@property (strong, nonatomic) NSNumber<Optional> *longitude;
@property (strong, nonatomic) NSNumber<Optional> *latitude;
@end

@interface  FRConcernV1HomeHeadResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRConcernStructModel<Optional> *concern_obj;
@property (strong, nonatomic) NSNumber<Optional> *show_et_status;
@property (strong, nonatomic) NSString<Optional> *post_content_hint;
@property (strong, nonatomic) NSArray<FRConcernTabStructModel, Optional> *tabs;
@property (strong, nonatomic) FRThreadListStructModel<Optional> *thread_list;
@property (strong, nonatomic) FRForumStructModel<Optional> *forum;
@property (strong, nonatomic) NSNumber<Optional> *show_describe;
@property (strong, nonatomic) NSNumber<Optional> *describe_max_line_number;
@property (strong, nonatomic) NSString<Optional> *concern_and_discuss_describe;
@property (strong, nonatomic) NSNumber<Optional> *hash_tag_type;
@property (strong, nonatomic) NSArray<FRPublishConfigStructModel, Optional> *publisher_controll;
@property (strong, nonatomic) FRConcernShareInfoStructModel<Optional> *share_info;
@end

@interface  FRTtdiscussV2CommitPublishRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSString<Optional> *image_uris;
@property (strong, nonatomic) NSNumber<Optional> *longitude;
@property (strong, nonatomic) NSNumber<Optional> *latitude;
@property (strong, nonatomic) NSString<Optional> *city;
@property (strong, nonatomic) NSString<Optional> *detail_pos;
@property (strong, nonatomic) NSNumber<Optional> *is_forward;
@property (strong, nonatomic) NSString<Optional> *phone;
@property (strong, nonatomic) NSString<Optional> *title;
@property (assign, nonatomic) FRFromWhereType from_where;
@property (strong, nonatomic) NSNumber<Optional> *rate;
@end

@interface  FRTtdiscussV2CommitPublishResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRUgcDataStructModel *thread;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV2LongReviewListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *movie_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *cursor;
@property (strong, nonatomic) NSNumber<Optional> *sort_type;
@end

@interface  FRTtdiscussV2LongReviewListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSArray<FRGroupLikeStructModel, Optional> *group_list;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSNumber *has_more;
@end

@interface  FRTtdiscussV1CommitThreadforwardRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forward_talk;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *forward_weibo;
@property (strong, nonatomic) NSNumber *forum_id;
@end

@interface  FRTtdiscussV1CommitThreadforwardResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRThreadDataStructModel *thread;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcActivityVideoIntroRedpackV1OpenRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *redpack_id;
@property (strong, nonatomic) NSNumber<Optional> *is_login_open;
@property (strong, nonatomic) NSString *token;
@end

@interface  FRUgcActivityVideoIntroRedpackV1OpenResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRRedpacketOpenResultStructModel *data;
@end

@interface  FRUgcBusinessAllianceUserInfoRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *user_id;
@end

@interface  FRUgcBusinessAllianceUserInfoResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_msg;
@property (strong, nonatomic) FRBusinessAllianceStructModel<Optional> *data;
@end

@interface  FRUgcPublishPostV1ContactRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *offset;
@end

@interface  FRUgcPublishPostV1ContactResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString<Optional> *status;
@property (strong, nonatomic) NSString<Optional> *message;
@property (strong, nonatomic) FRPublishPostSearchUserContactStructModel *data;
@end

@interface  FRConcernV1CommitDiscareRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *concern_id;
@end

@interface  FRConcernV1CommitDiscareResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRForumHomeV1InfoRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber<Optional> *forum_id;
@property (strong, nonatomic) NSNumber<Optional> *is_preview;
@property (strong, nonatomic) NSNumber<Optional> *request_source;
@end

@interface  FRForumHomeV1InfoResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRTTForumStructModel<Optional> *forum;
@property (strong, nonatomic) NSArray<FRTTForumTabStructModel, Optional> *tabs;
@property (strong, nonatomic) FRTTForumShareInfoStructModel<Optional> *share_info;
@property (strong, nonatomic) FRTTForumPublisherControllStructModel<Optional> *publisher_control;
@end

@interface  FRUserProfileEvaluationRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *log_action;
@property (strong, nonatomic) NSNumber *disable;
@end

@interface  FRUserProfileEvaluationResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSNumber *score;
@property (strong, nonatomic) NSNumber *beat_pct;
@property (strong, nonatomic) NSNumber *show;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *avatar_url;
@property (strong, nonatomic) NSNumber *is_name_valid;
@property (strong, nonatomic) NSNumber *is_avatar_valid;
@property (strong, nonatomic) NSString<Optional> *apply_auth_url;
@end

@interface  FRTtdiscussV1CommitPublishRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSString<Optional> *image_uris;
@property (strong, nonatomic) NSNumber<Optional> *longitude;
@property (strong, nonatomic) NSNumber<Optional> *latitude;
@property (strong, nonatomic) NSString<Optional> *city;
@property (strong, nonatomic) NSString<Optional> *detail_pos;
@property (strong, nonatomic) NSNumber<Optional> *is_forward;
@property (strong, nonatomic) NSString<Optional> *phone;
@property (strong, nonatomic) NSString<Optional> *title;
@property (assign, nonatomic) FRFromWhereType from_where;
@property (strong, nonatomic) NSNumber<Optional> *rate;
@end

@interface  FRTtdiscussV1CommitPublishResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRThreadDataStructModel *thread;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommitOpthreadRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSNumber *action_type;
@property (strong, nonatomic) NSNumber<Optional> *forum_id;
@property (strong, nonatomic) NSNumber<Optional> *op_reason_no;
@property (strong, nonatomic) NSString<Optional> *op_extra_reason;
@end

@interface  FRTtdiscussV1CommitOpthreadResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRArticleV2TabCommentsRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *group_id;
@property (strong, nonatomic) NSString *item_id;
@property (strong, nonatomic) NSString *forum_id;
@property (assign, nonatomic) FRCommentsGroupType group_type;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber<Optional> *fold;
@property (strong, nonatomic) NSString<Optional> *msg_id;
@end

@interface  FRArticleV2TabCommentsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *total_number;
@property (strong, nonatomic) NSNumber<Optional> *ban_comment;
@property (strong, nonatomic) NSNumber<Optional> *has_more;
@property (strong, nonatomic) NSNumber<Optional> *detail_no_comment;
@property (strong, nonatomic) NSNumber<Optional> *go_topic_detail;
@property (strong, nonatomic) NSNumber<Optional> *show_add_forum;
@property (strong, nonatomic) FRCommentTabInfoStructModel<Optional> *tab_info;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSArray<FRNewCommentDataStructModel, Optional> *data;
@property (strong, nonatomic) NSNumber<Optional> *fold_comment_count;
@property (strong, nonatomic) NSNumber<Optional> *stick_has_more;
@property (strong, nonatomic) NSNumber<Optional> *stick_total_number;
@property (strong, nonatomic) NSArray<FRNewCommentDataStructModel, Optional> *stick_comments;
@property (strong, nonatomic) NSNumber<Optional> *ban_face;
@end

@interface  FRUgcPublishPostV1CheckRequestModel : TTRequestModel
@end

@interface  FRUgcPublishPostV1CheckResponseModel : JSONModel<TTResponseModelProtocol>
@property (assign, nonatomic) FRPostBindCheckType bind_mobile;
@end

@interface  FRUserRelationFriendsV1RequestModel : TTRequestModel
@property (strong, nonatomic) NSString<Optional> *tab;
@property (strong, nonatomic) NSNumber<Optional> *offset;
@property (strong, nonatomic) NSNumber<Optional> *count;
@property (strong, nonatomic) NSString<Optional> *from_page;
@property (strong, nonatomic) NSString<Optional> *profile_user_id;
@end

@interface  FRUserRelationFriendsV1ResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) FRAddFriendsDataStructModel *data;
@property (strong, nonatomic) NSString<Optional> *error_tips;
@end

@interface  FRConcernV1CommitCareRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *concern_id;
@end

@interface  FRConcernV1CommitCareResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUserRelationUserRecommendV1FollowChannelRecommendsRequestModel : TTRequestModel
@end

@interface  FRUserRelationUserRecommendV1FollowChannelRecommendsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSNumber<Optional> *auto_skip;
@property (strong, nonatomic) NSString<Optional> *unselected_tips;
@property (strong, nonatomic) NSString<Optional> *selected_tips;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSArray<FRFollowChannelColdBootRecommendUserCardStructModel, Optional> *recommends;
@end

@interface  FRUgcPublishPostV1ModifyRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSString<Optional> *image_uris;
@property (strong, nonatomic) NSNumber<Optional> *longitude;
@property (strong, nonatomic) NSNumber<Optional> *latitude;
@property (strong, nonatomic) NSString<Optional> *city;
@property (strong, nonatomic) NSString<Optional> *detail_pos;
@property (strong, nonatomic) NSNumber<Optional> *is_forward;
@property (strong, nonatomic) NSString<Optional> *phone;
@property (strong, nonatomic) NSString<Optional> *title;
@property (assign, nonatomic) FRFromWhereType from_where;
@property (strong, nonatomic) NSNumber<Optional> *score;
@property (strong, nonatomic) NSString<Optional> *category_id;
@property (strong, nonatomic) NSNumber<Optional> *enter_from;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSString<Optional> *mention_user;
@property (strong, nonatomic) NSString<Optional> *mention_concern;
@property (strong, nonatomic) NSString *post_id;
@property (strong, nonatomic) NSString<Optional> *forum_names;
@property (strong, nonatomic) NSString<Optional> *sdk_params;
@end

@interface  FRUgcPublishPostV1ModifyResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRUgcDataStructModel<Optional> *thread;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRDongtaiGroupCommentDeleteRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSNumber *is_answer;
@end

@interface  FRDongtaiGroupCommentDeleteResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString<Optional> *message;
@property (strong, nonatomic) FRDeleteCommentDataStructModel *data;
@end

@interface  FRTtdiscussV1CommitOwnerapplyRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSString *reason;
@end

@interface  FRTtdiscussV1CommitOwnerapplyResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FR2DataV4PostMessageRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *group_id;
@property (strong, nonatomic) NSString *item_id;
@property (strong, nonatomic) NSString *forum_id;
@property (strong, nonatomic) NSNumber *is_comment;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSNumber *comment_duration;
@property (strong, nonatomic) NSNumber *read_pct;
@property (strong, nonatomic) NSString *staytime_ms;
@property (strong, nonatomic) NSString *reply_to_comment_id;
@property (strong, nonatomic) NSString *dongtai_comment_id;
@property (assign, nonatomic) FRCommentsGroupType group_type;
@end

@interface  FR2DataV4PostMessageResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *group_id;
@property (strong, nonatomic) NSNumber *tag_id;
@property (strong, nonatomic) NSString<Optional> *tag;
@property (strong, nonatomic) FRNewCommentStructModel<Optional> *data;
@end

@interface  FRTtdiscussV1ForumFollowRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *user_id;
@end

@interface  FRTtdiscussV1ForumFollowResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSArray<FRForumItemStructModel, Optional> *forum_list;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV2MovieListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSString *movie_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *movie_cursor;
@property (strong, nonatomic) NSNumber *ugc_cursor;
@property (strong, nonatomic) NSNumber<Optional> *sort_type;
@end

@interface  FRTtdiscussV2MovieListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *ugc_min_cursor;
@property (strong, nonatomic) NSNumber *ugc_max_cursor;
@property (strong, nonatomic) NSNumber *movie_min_cursor;
@property (strong, nonatomic) NSNumber *movie_max_cursor;
@property (strong, nonatomic) NSNumber *ugc_has_more;
@property (strong, nonatomic) NSNumber *movie_has_more;
@property (strong, nonatomic) NSArray<FRGroupLikeStructModel, Optional> *group_list;
@property (strong, nonatomic) NSArray<FRUgcDataStructModel, Optional> *thread_list;
@property (strong, nonatomic) NSArray<FRMovieReviewBasicInfoStructModel, Optional> *review_info;
@end

@interface  FRUserRelationFriendsInviteRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *count;
@end

@interface  FRUserRelationFriendsInviteResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) FRInviteFriendsDataStructModel *data;
@property (strong, nonatomic) NSString<Optional> *error_tips;
@end

@interface  FRUgcPublishVideoV4CheckAuthRequestModel : TTRequestModel
@end

@interface  FRUgcPublishVideoV4CheckAuthResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRPublisherPermissionStructModel *publisher_permission_control;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcThreadDetailV3InfoRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *thread_id;
@end

@interface  FRUgcThreadDetailV3InfoResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSString<Optional> *ad;
@property (strong, nonatomic) NSString<Optional> *h5_extra;
@property (strong, nonatomic) NSString<Optional> *like_desc;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSNumber<Optional> *repost_type;
@property (strong, nonatomic) FRForumStructModel<Optional> *forum_info;
@property (strong, nonatomic) FRThreadDataStructModel *thread;
@property (strong, nonatomic) FRUgcDataStructModel<Optional> *origin_thread;
@property (strong, nonatomic) FRGroupInfoStructModel<Optional> *origin_group;
@property (strong, nonatomic) FRUGCVideoDataStructModel<Optional> *origin_ugc_video;
@property (strong, nonatomic) FRRecommendSponsorStructModel<Optional> *recommend_sponsor;
@property (strong, nonatomic) FRRepostCommonContentStructModel<Optional> *origin_common_content;
@property (strong, nonatomic) FRTokenShareInfoStructModel<Optional> *share_info;
@end

@interface  FRUserRelationUserRecommendV1SupplementCardsRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString *follow_user_id;
@property (strong, nonatomic) NSNumber *count;
@end

@interface  FRUserRelationUserRecommendV1SupplementCardsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *message;
@property (strong, nonatomic) FRRecommendMultiCardStructModel<Optional> *data;
@property (strong, nonatomic) NSString<Optional> *error_tips;
@end

@interface  FRUserRelationSetCanBeFoundByPhoneRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *can_be_found_by_phone;
@end

@interface  FRUserRelationSetCanBeFoundByPhoneResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUserRelationFollowingV2RequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber<Optional> *user_id;
@property (strong, nonatomic) NSNumber<Optional> *offset;
@property (strong, nonatomic) NSNumber<Optional> *count;
@property (strong, nonatomic) NSNumber<Optional> *cursor;
@end

@interface  FRUserRelationFollowingV2ResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString *err_tips;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *cursor;
@property (strong, nonatomic) NSNumber *has_more;
@property (strong, nonatomic) FRRelationShipFollowersDataStructModel<Optional> *data;
@end

@interface  FRTtdiscussV1ThreadListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSNumber *forum_id;
@end

@interface  FRTtdiscussV1ThreadListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSArray<FRGeneralThreadStructModel, Optional> *finfo_list;
@property (strong, nonatomic) FRLoginUserInfoStructModel *login_user_info;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRTipsStructModel *tips;
@end

@interface  FRUgcActivityUploadContactRedpackV1OpenRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *redpack_id;
@property (strong, nonatomic) NSString *token;
@end

@interface  FRUgcActivityUploadContactRedpackV1OpenResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRContactsRedpacketOpenResultStructModel *data;
@end

@interface  FRTtdiscussV2CommitCommentRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forward_talk;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *forward_weibo;
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSNumber *reply_comment_id;
@property (strong, nonatomic) NSNumber *reply_user_id;
@end

@interface  FRTtdiscussV2CommitCommentResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSNumber *comment_id;
@property (strong, nonatomic) FRDiscussCommentStructModel *comment;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommitCommentdiggRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *comment_id;
@end

@interface  FRTtdiscussV1CommitCommentdiggResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcThreadDetailV2InfoRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *thread_id;
@end

@interface  FRUgcThreadDetailV2InfoResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSString<Optional> *ad;
@property (strong, nonatomic) NSString<Optional> *h5_extra;
@property (strong, nonatomic) NSString<Optional> *like_desc;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSNumber<Optional> *repost_type;
@property (strong, nonatomic) FRForumStructModel<Optional> *forum_info;
@property (strong, nonatomic) FRThreadDataStructModel *thread;
@property (strong, nonatomic) FRUgcDataStructModel<Optional> *origin_thread;
@property (strong, nonatomic) FRGroupInfoStructModel<Optional> *origin_group;
@property (strong, nonatomic) FRUGCVideoDataStructModel<Optional> *origin_ugc_video;
@property (strong, nonatomic) FRRecommendSponsorStructModel<Optional> *recommend_sponsor;
@property (strong, nonatomic) FRRepostCommonContentStructModel<Optional> *origin_common_content;
@end

@interface  FRTtdiscussV1CommitCommentRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forward_talk;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *forward_weibo;
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSNumber *reply_comment_id;
@property (strong, nonatomic) NSNumber *reply_user_id;
@end

@interface  FRTtdiscussV1CommitCommentResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSNumber *comment_id;
@property (strong, nonatomic) FRCommentStructModel *comment;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1DiggUserRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSNumber *offset;
@end

@interface  FRTtdiscussV1DiggUserResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSNumber *anonymous_count;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *total_count;
@property (strong, nonatomic) NSArray<FRUserStructModel, Optional> *user_lists;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcPublishImageV1SuggestRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) NSNumber *offset;
@end

@interface  FRUgcPublishImageV1SuggestResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRGifImageDataListStructModel<Optional> *data;
@end

@interface  FRUserRelationUserRecommendV1DislikeUserRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *dislike_user_id;
@end

@interface  FRUserRelationUserRecommendV1DislikeUserResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommitCancelthreaddiggRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *thread_id;
@end

@interface  FRTtdiscussV1CommitCancelthreaddiggResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommitFollowforumRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forum_id;
@end

@interface  FRTtdiscussV1CommitFollowforumResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUserProfileAuthCheckRequestModel : TTRequestModel
@end

@interface  FRUserProfileAuthCheckResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) FRProfileAuthCheckDataStructModel *data;
@end

@interface  FRUserExpressionConfigRequestModel : TTRequestModel
@end

@interface  FRUserExpressionConfigResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRUserExpressionConfigStructModel<Optional> *data;
@end

@interface  FRUgcPublishPostV1SuggestRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSString *words;
@property (nonatomic, copy)     NSString       *search_id;
@property (nonatomic, copy)     NSString       *type;
@end

@interface  FRUgcPublishPostV1SuggestResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString<Optional> *status;
@property (strong, nonatomic) NSString<Optional> *message;
@property (strong, nonatomic) FRPublishPostSearchUserSuggestStructModel *data;
@end

@interface  FRTtdiscussV1ForumIntroductionRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forum_id;
@end

@interface  FRTtdiscussV1ForumIntroductionResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSArray<FRRoleMemberStructModel, Optional> *role_members;
@property (strong, nonatomic) NSString *qr_code_uri;
@property (strong, nonatomic) FRForumStructModel *forum;
@property (strong, nonatomic) NSArray<Optional> *notice_list;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSString *req_params;
@property (strong, nonatomic) FRUserApplyRoleInfoStructModel<Optional> *user_apply_info;
@property (strong, nonatomic) FRForumRoleInfoStructModel<Optional> *forum_role_info;
@property (strong, nonatomic) NSArray<FRForumStatDataStructModel, Optional> *forum_stat_data_list;
@end

@interface  FRUgcPublishVideoV4CommitRequestModel : TTRequestModel
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSString *video_id;
@property (strong, nonatomic) NSString *video_name;
@property (strong, nonatomic) NSString *thumb_uri;
@property (strong, nonatomic) NSNumber *video_type;
@property (strong, nonatomic) NSNumber *video_duration;
@property (strong, nonatomic) NSNumber *width;
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSNumber<Optional> *thumb_source;
@property (strong, nonatomic) NSNumber<Optional> *enter_from;
@property (strong, nonatomic) NSString<Optional> *title_rich_span;
@property (strong, nonatomic) NSString<Optional> *mention_user;
@property (strong, nonatomic) NSString<Optional> *mention_concern;
@property (strong, nonatomic) NSString<Optional> *category;
@property (strong, nonatomic) NSString<Optional> *music_id;
@property (strong, nonatomic) NSString<Optional> *challenge_group_id;
@property (strong, nonatomic) NSString<Optional> *theme_id;
@property (strong, nonatomic) NSString<Optional> *effect_id;
@property (strong, nonatomic) NSNumber<Optional> *beautify_face;
@property (strong, nonatomic) NSNumber<Optional> *beautify_eye;
@property (strong, nonatomic) NSString<Optional> *role_name;
@property (strong, nonatomic) NSNumber<Optional> *role_type;
@property (strong, nonatomic) NSNumber<Optional> *video_latitude;
@property (strong, nonatomic) NSNumber<Optional> *video_longitude;
@property (strong, nonatomic) NSNumber<Optional> *is_duet;
@property (strong, nonatomic) NSString<Optional> *origin_group_id;
@property (strong, nonatomic) NSNumber<Optional> *forum_type;
@property (strong, nonatomic) NSString<Optional> *filter_id;
@property (strong, nonatomic) NSString<Optional> *game_id;
@property (strong, nonatomic) NSNumber<Optional> *game_type;
@property (strong, nonatomic) NSString<Optional> *vertical_extra;
@property (strong, nonatomic) NSString<Optional> *tma_id;
@property (strong, nonatomic) NSNumber<Optional> *tma_type;
@property (strong, nonatomic) NSNumber<Optional> *dub_type;
@property (strong, nonatomic) NSString<Optional> *effect_type;
@property (strong, nonatomic) NSNumber<Optional> *is_ad;
@property (strong, nonatomic) NSNumber<Optional> *flipchat_sync;
@end

@interface  FRUgcPublishVideoV4CommitResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRUgcVideoStructModel *data;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRUGCPublishGuideInfoStructModel<Optional> *guide_info;
@end

@interface  FRUserRelationContactinfoRequestModel : TTRequestModel
@end

@interface  FRUserRelationContactinfoResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSNumber *is_collected;
@end

@interface  FRTtdiscussV1MomentListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@end

@interface  FRTtdiscussV1MomentListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (assign, nonatomic) FRLoginStatusType login_status;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSArray<FRThreadDataStructModel, Optional> *data_list;
@property (strong, nonatomic) FRTipsStructModel *tips;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTfeRouteUgcVoteCommitRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber<Optional> *option_id;
@end

@interface  FRTfeRouteUgcVoteCommitResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *record_id;
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcBusinessAllianceUpdateProtocolStatusRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSNumber *status;
@end

@interface  FRUgcBusinessAllianceUpdateProtocolStatusResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_msg;
@end

@interface  FRUgcBusinessAllianceUpdateBusinessTagRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSNumber *tag;
@end

@interface  FRUgcBusinessAllianceUpdateBusinessTagResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_msg;
@end

@interface  FRUgcPublishShareV1SetConfigRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *share_repost;
@end

@interface  FRUgcPublishShareV1SetConfigResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRVerticalMovie1ReviewsRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *review_cursor;
@property (strong, nonatomic) NSNumber *post_cursor;
@property (strong, nonatomic) NSNumber<Optional> *sort_type;
@end

@interface  FRVerticalMovie1ReviewsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *post_min_cursor;
@property (strong, nonatomic) NSNumber *post_max_cursor;
@property (strong, nonatomic) NSNumber *review_min_cursor;
@property (strong, nonatomic) NSNumber *review_max_cursor;
@property (strong, nonatomic) NSNumber *post_has_more;
@property (strong, nonatomic) NSNumber *review_has_more;
@property (strong, nonatomic) NSArray<FRGroupInfoStructModel, Optional> *reviews;
@property (strong, nonatomic) NSArray<FRUgcDataStructModel, Optional> *posts;
@property (strong, nonatomic) FRMovieReviewBasicInfoStructModel<Optional> *review_info;
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommentRecommendforumRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSNumber *group_id;
@end

@interface  FRTtdiscussV1CommentRecommendforumResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSArray<FRForumItemStructModel, Optional> *forum_info;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcPublishPostV1HashtagRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSString *words;
@property (strong, nonatomic) NSNumber<Optional> *forum_flag;
@end

@interface  FRUgcPublishPostV1HashtagResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRPublishPostSearchHashtagSuggestStructModel *data;
@end

@interface  FRTtdiscussV1CommitOpcommentRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) NSNumber *comment_id;
@property (strong, nonatomic) NSNumber *action_type;
@property (strong, nonatomic) NSNumber<Optional> *forum_id;
@end

@interface  FRTtdiscussV1CommitOpcommentResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1ThreadDetailRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSNumber<Optional> *forum_id;
@end

@interface  FRTtdiscussV1ThreadDetailResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRThreadDataStructModel *thread;
@property (strong, nonatomic) FRCommentBrowStructModel *comments;
@property (strong, nonatomic) FRCommentBrowStructModel *hot_comments;
@property (strong, nonatomic) FRLoginUserInfoStructModel *login_user_info;
@property (strong, nonatomic) FRForumStructModel *forum_info;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSString<Optional> *openurl;
@end

@interface  FRUgcThreadStoryVRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *is_preload;
@property (strong, nonatomic) NSNumber<Optional> *is_live;
@property (strong, nonatomic) NSNumber<Optional> *live_gid;
@property (strong, nonatomic) NSString<Optional> *extra;
@end

@interface  FRUgcThreadStoryVResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) FRUGCThreadStoryDataStructModel *data;
@end

@interface  FRTtdiscussV2ForumListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSString<Optional> *city;
@property (strong, nonatomic) NSString<Optional> *remote_ip;
@end

@interface  FRTtdiscussV2ForumListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (assign, nonatomic) FRInnerForumType type;
@property (strong, nonatomic) FRForumStructModel *forum_info;
@property (strong, nonatomic) FRNormalThreadStructModel<Optional> *normal_thread_info;
@property (strong, nonatomic) FRMovieStructModel<Optional> *movie_info;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUserRelationContactfriendsRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *contact_source;
@end

@interface  FRUserRelationContactfriendsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) FRUserRelationContactFriendsDataStructModel *data;
@property (strong, nonatomic) NSNumber<Optional> *auto_follow;
@end

@interface  FRUgcBusinessAllianceBusinessBoxInfoRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *user_id;
@end

@interface  FRUgcBusinessAllianceBusinessBoxInfoResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_msg;
@property (strong, nonatomic) FRBusinessToolboxDataStructModel<Optional> *data;
@end

@interface  FRUgcThreadDetailV2ContentRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *thread_id;
@end

@interface  FRUgcThreadDetailV2ContentResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcPublishPostV1HotForumRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber<Optional> *forum_flag;
@end

@interface  FRUgcPublishPostV1HotForumResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRPublishPostSearchHashtagHotStructModel *data;
@end

@interface  FRTtdiscussV1ThreadDetailCommentRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSNumber *offset;
@end

@interface  FRTtdiscussV1ThreadDetailCommentResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSNumber *comment_number;
@property (strong, nonatomic) FRDiscussCommentBrowStructModel *comments;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcThreadLinkV1ConvertRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *url;
@end

@interface  FRUgcThreadLinkV1ConvertResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRQRCodeLinkInfoStructModel *url_info;
@end

@interface  FRUgcPublishShareV3NotifyRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *share_id;
@property (strong, nonatomic) NSString *share_channel;
@property (strong, nonatomic) NSNumber *item_type;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *repost_type;
@property (strong, nonatomic) NSString<Optional> *cover_url;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSString<Optional> *fw_user_id;
@property (strong, nonatomic) NSString<Optional> *fw_id;
@property (assign, nonatomic) FRUGCTypeCode fw_id_type;
@property (strong, nonatomic) NSString<Optional> *opt_id;
@property (assign, nonatomic) FRUGCTypeCode opt_id_type;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *title;
@end

@interface  FRUgcPublishShareV3NotifyResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcCommentAuthorActionV2DeleteRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *comment_id;
@property (strong, nonatomic) NSNumber<Optional> *thread_id;
@property (strong, nonatomic) NSNumber<Optional> *reply_id;
@property (strong, nonatomic) NSNumber *action_type;
@property (strong, nonatomic) NSNumber *group_id;
@end

@interface  FRUgcCommentAuthorActionV2DeleteResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRVerticalMovie1ShortReviewsRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *cursor;
@property (strong, nonatomic) NSNumber<Optional> *sort_type;
@end

@interface  FRVerticalMovie1ShortReviewsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSArray<FRUgcDataStructModel, Optional> *posts;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSNumber *has_more;
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcRepostV1ListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber<Optional> *id;
@property (assign, nonatomic) FRUGCTypeCode type;
@property (strong, nonatomic) NSNumber<Optional> *msg_id;
@property (strong, nonatomic) NSNumber<Optional> *count;
@property (strong, nonatomic) NSNumber<Optional> *offset;
@end

@interface  FRUgcRepostV1ListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSNumber<Optional> *has_more;
@property (strong, nonatomic) NSNumber<Optional> *offset;
@property (strong, nonatomic) NSNumber<Optional> *total_number;
@property (strong, nonatomic) NSArray<FRFooterRepostStructModel, Optional> *reposts;
@property (strong, nonatomic) NSArray<FRFooterRepostStructModel, Optional> *stick_reposts;
@end

@interface  FRUserProfileUnstickV1RequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *id;
@end

@interface  FRUserProfileUnstickV1ResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString *err_tips;
@end

@interface  FRUgcPublishPostV5CommitRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSString<Optional> *image_uris;
@property (strong, nonatomic) NSNumber<Optional> *longitude;
@property (strong, nonatomic) NSNumber<Optional> *latitude;
@property (strong, nonatomic) NSString<Optional> *city;
@property (strong, nonatomic) NSString<Optional> *detail_pos;
@property (strong, nonatomic) NSNumber<Optional> *is_forward;
@property (strong, nonatomic) NSString<Optional> *phone;
@property (strong, nonatomic) NSString<Optional> *title;
@property (assign, nonatomic) FRFromWhereType from_where;
@property (strong, nonatomic) NSNumber<Optional> *score;
@property (strong, nonatomic) NSString<Optional> *category_id;
@property (strong, nonatomic) NSNumber<Optional> *enter_from;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSString<Optional> *mention_user;
@property (strong, nonatomic) NSString<Optional> *mention_concern;
@property (strong, nonatomic) NSString<Optional> *community_id;
@property (strong, nonatomic) NSString<Optional> *business_payload;
@property (strong, nonatomic) NSString<Optional> *forum_names;
@property (strong, nonatomic) NSString<Optional> *promotion_id;
@property (strong, nonatomic) NSNumber<Optional> *flipchat_sync;
@property (strong, nonatomic) NSString<Optional> *sdk_params;
@property (nonatomic, copy)     NSString<Optional>       *social_group_id;
@property (strong, nonatomic) NSNumber<Optional> *bind_type;
@property (nonatomic, copy)   NSDictionary<Optional> * extraTrack;
// 小区点评相关参数
@property (nonatomic, copy) NSString<Optional> *neighborhoodId; // 小区id
@property (nonatomic, copy) NSString<Optional> *source;
@property (nonatomic, copy) NSString<Optional> *neighborhoodTags; // 小区点评标签 json String
@property (nonatomic, copy) NSString<Optional> *scores; // 小区点评评分 json string
@end

@interface  FRUgcPublishPostV5CommitResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRUgcDataStructModel<Optional> *thread;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRUGCPublishGuideInfoStructModel<Optional> *guide_info;
@end

@interface FHUgcPublishPostResponseModel : JSONModel<TTResponseModelProtocol>
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) NSDictionary *data ;
@end

@interface  FRUserProfileStickV1RequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *id;
@end

@interface  FRUserProfileStickV1ResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString *err_tips;
@end

@interface  FRUgcDiggV1ListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber<Optional> *id;
@property (assign, nonatomic) FRUGCTypeCode type;
@property (strong, nonatomic) NSNumber<Optional> *msg_id;
@property (strong, nonatomic) NSNumber<Optional> *count;
@property (strong, nonatomic) NSNumber<Optional> *offset;
@end

@interface  FRUgcDiggV1ListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSNumber<Optional> *has_more;
@property (strong, nonatomic) NSNumber<Optional> *offset;
@property (strong, nonatomic) NSNumber<Optional> *total_number;
@property (strong, nonatomic) NSNumber<Optional> *anoy_number;
@property (strong, nonatomic) NSArray<FRCommonUserStructModel, Optional> *digg_users;
@property (strong, nonatomic) NSArray<FRCommonUserStructModel, Optional> *stick_users;
@end

@interface  FRConcernV2CommitPublishRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSString<Optional> *image_uris;
@property (strong, nonatomic) NSNumber<Optional> *longitude;
@property (strong, nonatomic) NSNumber<Optional> *latitude;
@property (strong, nonatomic) NSString<Optional> *city;
@property (strong, nonatomic) NSString<Optional> *detail_pos;
@property (strong, nonatomic) NSNumber<Optional> *is_forward;
@property (strong, nonatomic) NSString<Optional> *phone;
@property (strong, nonatomic) NSString<Optional> *title;
@property (assign, nonatomic) FRFromWhereType from_where;
@property (strong, nonatomic) NSNumber<Optional> *score;
@property (strong, nonatomic) NSString<Optional> *category_id;
@property (strong, nonatomic) NSNumber<Optional> *enter_from;
@end

@interface  FRConcernV2CommitPublishResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRUgcDataStructModel<Optional> *thread;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRConcernV1ThreadListRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@end

@interface  FRConcernV1ThreadListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRTipsStructModel<Optional> *tips;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSArray<FRUgcDataStructModel, Optional> *threads;
@end

@interface  FRTtdiscussV1ThreadCommentsRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *thread_id;
@property (strong, nonatomic) NSNumber *offset;
@end

@interface  FRTtdiscussV1ThreadCommentsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRCommentBrowStructModel *comments;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUserRelationInteractionFansV1RequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber<Optional> *offset;
@property (strong, nonatomic) NSNumber<Optional> *count;
@property (strong, nonatomic) NSString<Optional> *user_id;
@end

@interface  FRUserRelationInteractionFansV1ResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString *err_tips;
@property (strong, nonatomic) NSNumber *has_more;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSArray<FRRelationShipUserInfoStructModel, Optional> *data;
@end

@interface  FRUserRelationCredibleFriendsRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *user_ids;
@property (strong, nonatomic) NSString *redpack_id;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSNumber<Optional> *rel_type;
@end

@interface  FRUserRelationCredibleFriendsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) FRRecommendRedpacketResultStructModel<Optional> *data;
@property (strong, nonatomic) NSString<Optional> *error_tips;
@end

@interface  FRArticleV1TabCommentsRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *group_id;
@property (strong, nonatomic) NSString *item_id;
@property (strong, nonatomic) NSString *forum_id;
@property (assign, nonatomic) FRCommentsGroupType group_type;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *offset;
@property (strong, nonatomic) NSNumber *fold;
@end

@interface  FRArticleV1TabCommentsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber<Optional> *total_number;
@property (strong, nonatomic) NSNumber<Optional> *ban_comment;
@property (strong, nonatomic) NSNumber<Optional> *has_more;
@property (strong, nonatomic) NSNumber<Optional> *detail_no_comment;
@property (strong, nonatomic) NSNumber<Optional> *go_topic_detail;
@property (strong, nonatomic) NSNumber<Optional> *show_add_forum;
@property (strong, nonatomic) FRCommentTabInfoStructModel<Optional> *tab_info;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSArray<FRNewCommentDataStructModel, Optional> *data;
@property (strong, nonatomic) NSNumber<Optional> *fold_comment_count;
@property (strong, nonatomic) NSNumber<Optional> *ban_face;
@end

@interface  FRTtdiscussV1SmartReviewListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *cursor;
@property (strong, nonatomic) NSNumber<Optional> *sort_type;
@end

@interface  FRTtdiscussV1SmartReviewListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSArray<FRUgcDataStructModel, Optional> *thread_list;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSNumber *has_more;
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUserRelationContactcheckRequestModel : TTRequestModel
@end

@interface  FRUserRelationContactcheckResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRUserRelationContactCheckDataStructModel *data;
@end

@interface  FRUserRelationSetUserPrivacyExtendRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *share_with_avatar;
@end

@interface  FRUserRelationSetUserPrivacyExtendResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommitThreaddiggRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *thread_id;
@end

@interface  FRTtdiscussV1CommitThreaddiggResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1ForumRecommendRequestModel : TTRequestModel
@end

@interface  FRTtdiscussV1ForumRecommendResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSArray<FRForumItemStructModel, Optional> *forum_list;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcPublishRepostV8CommitRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSNumber *repost_type;
@property (strong, nonatomic) NSString<Optional> *cover_url;
@property (strong, nonatomic) NSString<Optional> *content_rich_span;
@property (strong, nonatomic) NSString<Optional> *fw_user_id;
@property (strong, nonatomic) NSString<Optional> *fw_id;
@property (assign, nonatomic) FRUGCTypeCode fw_id_type;
@property (strong, nonatomic) NSString<Optional> *opt_id;
@property (assign, nonatomic) FRUGCTypeCode opt_id_type;
@property (strong, nonatomic) NSString<Optional> *mention_user;
@property (strong, nonatomic) NSString<Optional> *mention_concern;
@property (strong, nonatomic) NSString<Optional> *schema;
@property (strong, nonatomic) NSString<Optional> *fw_native_schema;
@property (strong, nonatomic) NSString<Optional> *fw_share_url;
@property (strong, nonatomic) NSString<Optional> *title;
@property (strong, nonatomic) NSNumber<Optional> *repost_to_comment;
@property (strong, nonatomic) NSString<Optional> *sdk_params;
@property (strong, nonatomic) NSString<Optional> *forum_names;
@property (strong, nonatomic) NSString<Optional> *business_payload;
@end

@interface  FRUgcPublishRepostV8CommitResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) FRUgcDataStructModel<Optional> *thread;
@end

@interface  FRUserRelationMfollowRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *to_user_list;
@property (strong, nonatomic) NSNumber *source;
@property (strong, nonatomic) NSNumber *reason;
@end

@interface  FRUserRelationMfollowResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1ForumListRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forum_id;
@end

@interface  FRTtdiscussV1ForumListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) FRForumStructModel *forum_info;
@property (strong, nonatomic) NSArray<FRGeneralThreadStructModel, Optional> *finfo_list;
@property (strong, nonatomic) NSArray<FRTabStructModel, Optional> *table;
@property (strong, nonatomic) NSNumber *like_time;
@property (strong, nonatomic) FRLoginUserInfoStructModel *login_user_info;
@property (strong, nonatomic) NSArray<FRThreadDataStructModel, Optional> *top_thread;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRTipsStructModel<Optional> *tips;
@end

@interface  FRUserRelationUserRecommendV1SupplementRecommendsRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString<Optional> *scene;
@property (strong, nonatomic) NSString<Optional> *follow_user_id;
@property (strong, nonatomic) NSString<Optional> *group_id;
@end

@interface  FRUserRelationUserRecommendV1SupplementRecommendsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) NSArray<FRRecommendCardStructModel, Optional> *user_cards;
@property (strong, nonatomic) NSNumber<Optional> *has_more;
@property (strong, nonatomic) FRRecommendCardRelatedControlStructModel<Optional> *related_control;
@end

@interface  FRTtdiscussV1CommitUnfollowforumRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forum_id;
@end

@interface  FRTtdiscussV1CommitUnfollowforumResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommitForumforwardRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *forum_id;
@end

@interface  FRTtdiscussV1CommitForumforwardResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSNumber *forum_id;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommitThreaddeleteRequestModel : TTRequestModel
@property (strong, nonatomic) NSNumber *thread_id;
@end

@interface  FRTtdiscussV1CommitThreaddeleteResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1LongReviewListRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *movie_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *cursor;
@property (strong, nonatomic) NSNumber<Optional> *sort_type;
@end

@interface  FRTtdiscussV1LongReviewListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSArray<FRGroupInfoStructModel, Optional> *group_list;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSNumber *has_more;
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUserRelationWeitoutiaoRecommendsRequestModel : TTRequestModel
@end

@interface  FRUserRelationWeitoutiaoRecommendsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSArray<FRColdStartRecommendUserStructModel, Optional> *users;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcActivityFollowRedpackV1OpenRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *redpack_id;
@property (strong, nonatomic) NSNumber<Optional> *is_login_open;
@property (strong, nonatomic) NSString *token;
@end

@interface  FRUgcActivityFollowRedpackV1OpenResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRRedpacketOpenResultStructModel *data;
@end

@interface  FRTtdiscussV1ForumIntroapplypageRequestModel : TTRequestModel
@end

@interface  FRTtdiscussV1ForumIntroapplypageResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSNumber *user_id;
@end

@interface  FRTtdiscussV2UgcVideoUploadVideoUrlRequestModel : TTRequestModel
@property (strong, nonatomic) NSString<Optional> *upload_id;
@end

@interface  FRTtdiscussV2UgcVideoUploadVideoUrlResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString *upload_id;
@property (strong, nonatomic) NSString *upload_url;
@property (strong, nonatomic) NSNumber *chunk_size;
@property (strong, nonatomic) NSNumber *bytes;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRTtdiscussV1CommitMultiownerapplyRequestModel : TTRequestModel
@property (strong, nonatomic) NSArray<Optional> *forum_id_list;
@property (strong, nonatomic) NSString *reason;
@end

@interface  FRTtdiscussV1CommitMultiownerapplyResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUserRelationMultiFollowRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *to_user_list;
@end

@interface  FRUserRelationMultiFollowResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRVerticalMovie1LongReviewsRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *cursor;
@property (strong, nonatomic) NSNumber<Optional> *sort_type;
@end

@interface  FRVerticalMovie1LongReviewsResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSArray<FRGroupInfoStructModel, Optional> *reviews;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSNumber *has_more;
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@end

@interface  FRUgcConcernThreadV3ListRequestModel : TTRequestModel
@property (strong, nonatomic) NSString *concern_id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@end

@interface  FRUgcConcernThreadV3ListResponseModel : JSONModel<TTResponseModelProtocol>
@property (strong, nonatomic) NSNumber *err_no;
@property (strong, nonatomic) NSString<Optional> *err_tips;
@property (strong, nonatomic) FRTipsStructModel<Optional> *tips;
@property (assign, nonatomic) FRHasMoreType has_more;
@property (strong, nonatomic) NSNumber *min_cursor;
@property (strong, nonatomic) NSNumber *max_cursor;
@property (strong, nonatomic) NSArray<Optional> *threads;
@end

