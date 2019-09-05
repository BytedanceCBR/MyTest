//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@interface FHFeedContentRawDataVideoPlayAddrModel : JSONModel

@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@end

@interface FHFeedContentRawDataVideoDownloadAddrModel : JSONModel

@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@end

@interface FHFeedContentRawDataVideoOriginCoverModel : JSONModel

@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@end

@interface FHFeedContentRawDataVideoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *ratio;
@property (nonatomic, strong , nullable) FHFeedContentRawDataVideoPlayAddrModel *playAddr ;
@property (nonatomic, copy , nullable) NSString *videoId;
@property (nonatomic, copy , nullable) NSString *height;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) FHFeedContentRawDataVideoDownloadAddrModel *downloadAddr ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataVideoOriginCoverModel *originCover ;
@property (nonatomic, copy , nullable) NSString *duration;
@property (nonatomic, copy , nullable) NSString *size;
@end

@interface FHFeedContentRawDataVoteModel : JSONModel

@property (nonatomic, assign) BOOL needUserLogin;
@property (nonatomic, copy , nullable) NSString *voteId;
@property (nonatomic, copy , nullable) NSString *rightName;
@property (nonatomic, copy , nullable) NSString *leftValue;
@property (nonatomic, copy , nullable) NSString *leftName;
@property (nonatomic, copy , nullable) NSString *rightValue;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *personDesc;
@end

@protocol FHFeedContentRawDataHotTopicListModel<NSObject>
@end

@interface FHFeedContentRawDataHotTopicListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *forumName;
@property (nonatomic, copy , nullable) NSString *concernId;
@property (nonatomic, copy , nullable) NSString *forumId;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *talkCountStr;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *talkCount;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSDictionary *logPb;

@end

@interface FHFeedContentRawDataContentExtraModel : JSONModel

@property (nonatomic, copy , nullable) NSString *answerCount;
@property (nonatomic, copy , nullable) NSString *articleSchema;
@end

@interface FHFeedContentRawDataOriginCommonContentUserInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *originUserId;
@property (nonatomic, copy , nullable) NSString *mediaId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *banStatus;
@property (nonatomic, copy , nullable) NSString *originProfileUrl;
@property (nonatomic, copy , nullable) NSString *userDecoration;
@property (nonatomic, copy , nullable) NSString *verifiedContent;
@property (nonatomic, copy , nullable) NSString *realName;
@property (nonatomic, copy , nullable) NSString *userAuthInfo;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *liveInfoType;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *userVerified;
@property (nonatomic, copy , nullable) NSString *roomSchema;
@property (nonatomic, copy , nullable) NSString *desc;
@end

@interface FHFeedContentRawDataOriginCommonContentUserModel : JSONModel

@property (nonatomic, strong , nullable) FHFeedContentRawDataOriginCommonContentUserInfoModel *info ;
@end

@interface FHFeedContentRawDataCommentBaseActionModel : JSONModel

@property (nonatomic, copy , nullable) NSString *readCount;
@property (nonatomic, copy , nullable) NSString *userBury;
@property (nonatomic, copy , nullable) NSString *buryCount;
@property (nonatomic, copy , nullable) NSString *forwardCount;
@property (nonatomic, copy , nullable) NSString *diggCount;
@property (nonatomic, copy , nullable) NSString *playCount;
@property (nonatomic, copy , nullable) NSString *commentCount;
@property (nonatomic, copy , nullable) NSString *userRepin;
@property (nonatomic, copy , nullable) NSString *shareCount;
@property (nonatomic, copy , nullable) NSString *userDigg;
@end

@interface FHFeedContentRawDataCommentBaseUserInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *originUserId;
@property (nonatomic, copy , nullable) NSString *mediaId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *banStatus;
@property (nonatomic, copy , nullable) NSString *originProfileUrl;
@property (nonatomic, copy , nullable) NSString *userDecoration;
@property (nonatomic, copy , nullable) NSString *verifiedContent;
@property (nonatomic, copy , nullable) NSString *realName;
@property (nonatomic, copy , nullable) NSString *userAuthInfo;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *liveInfoType;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *userVerified;
@property (nonatomic, copy , nullable) NSString *roomSchema;
@property (nonatomic, copy , nullable) NSString *desc;
@end

@interface FHFeedContentRawDataCommentBaseUserBlockModel : JSONModel

@property (nonatomic, copy , nullable) NSString *isBlocking;
@property (nonatomic, copy , nullable) NSString *isBlocked;
@end

@interface FHFeedContentRawDataCommentBaseUserModel : JSONModel

@property (nonatomic, strong , nullable) FHFeedContentRawDataCommentBaseUserInfoModel *info ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataCommentBaseUserBlockModel *block ;
@end

@protocol FHFeedContentRecommendSocialGroupListModel<NSObject>
@end

@interface FHFeedContentRecommendSocialGroupListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *announcement;
@property (nonatomic, copy , nullable) NSString *contentCount;
@property (nonatomic, copy , nullable) NSString *countText;
@property (nonatomic, copy , nullable) NSString *socialGroupId;
@property (nonatomic, copy , nullable) NSString *avatar;
@property (nonatomic, copy , nullable) NSString *suggestReason;
@property (nonatomic, copy , nullable) NSString *socialGroupName;
@property (nonatomic, copy , nullable) NSString *hasFollow;
@property (nonatomic, copy , nullable) NSString *followerCount;
@property (nonatomic, copy , nullable) NSDictionary *logPb;
@end

@interface FHFeedContentCommunityModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *socialGroupId;
@end

@interface FHFeedContentUgcRecommendModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *reason;
@property (nonatomic, copy , nullable) NSString *activity;
@end

@protocol FHFeedContentImageListModel<NSObject>
@end

@protocol FHFeedContentImageListUrlListModel<NSObject>
@end

@interface FHFeedContentImageListUrlListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@end

@interface FHFeedContentImageListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListUrlListModel> *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHFeedContentRawDataOriginCommonContentModel : JSONModel

@property (nonatomic, copy , nullable) NSString *style;
@property (nonatomic, copy , nullable) NSString *richTitle;
@property (nonatomic, copy , nullable) NSString *businessPayload;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, copy , nullable) NSString *titleRichSpan;
@property (nonatomic, strong , nullable) FHFeedContentRawDataOriginCommonContentUserModel *user ;
@property (nonatomic, strong , nullable) FHFeedContentImageListModel *coverImage ;
@property (nonatomic, copy , nullable) NSString *groupIdStr;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *schema;
@end

@interface FHFeedContentForwardInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *forwardCount;
@end

@protocol FHFeedContentFilterWordsModel<NSObject>
@end

@interface FHFeedContentFilterWordsModel : JSONModel 

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *name;
@end

@protocol FHFeedContentActionListModel<NSObject>
@end

@interface FHFeedContentActionListExtraModel : JSONModel 

@end

@interface FHFeedContentActionListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *action;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, strong , nullable) FHFeedContentActionListExtraModel *extra ;  
@end

@protocol FHFeedContentShareInfoWeixinCoverImageUrlListModel<NSObject>
@end

@interface FHFeedContentShareInfoWeixinCoverImageUrlListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@end

@interface FHFeedContentShareInfoWeixinCoverImageModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentShareInfoWeixinCoverImageUrlListModel> *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHFeedContentShareInfoShareTypeModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *qq;
@property (nonatomic, copy , nullable) NSString *pyq;
@property (nonatomic, copy , nullable) NSString *qzone;
@property (nonatomic, copy , nullable) NSString *wx;
@end

@interface FHFeedContentShareInfoModel : JSONModel 

@property (nonatomic, strong , nullable) FHFeedContentShareInfoWeixinCoverImageModel *weixinCoverImage ;  
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, strong , nullable) FHFeedContentShareInfoShareTypeModel *shareType ;  
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *tokenType;
@property (nonatomic, copy , nullable) NSString *coverImage;
@property (nonatomic, copy , nullable) NSString *onSuppress;
@end

@interface FHFeedContentUserInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *followerCount;
@property (nonatomic, assign) BOOL follow;
@property (nonatomic, copy , nullable) NSString *liveInfoType;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, assign) BOOL userVerified;
@property (nonatomic, copy , nullable) NSString *name;
@end

@interface FHFeedContentMediaInfoModel : JSONModel 

@property (nonatomic, assign) BOOL isStarUser;
@property (nonatomic, copy , nullable) NSString *mediaId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, assign) BOOL userVerified;
@property (nonatomic, copy , nullable) NSString *verifiedContent;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, assign) BOOL follow;
@property (nonatomic, copy , nullable) NSString *recommendReason;
@property (nonatomic, copy , nullable) NSString *recommendType;
@end

@protocol FHFeedContentMiddleImageUrlListModel<NSObject>
@end

@interface FHFeedContentMiddleImageUrlListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@end

@interface FHFeedContentMiddleImageModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentMiddleImageUrlListModel> *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHFeedContentRawDataContentQuestionContentModel : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *thumbImageList;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *largeImageList;
@end

@protocol FHFeedContentRawDataContentQuestionAnswerUserListModel<NSObject>
@end

@interface FHFeedContentRawDataContentQuestionAnswerUserListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *isVerify;
@property (nonatomic, copy , nullable) NSString *userSchema;
@property (nonatomic, copy , nullable) NSString *uname;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *isFollowing;
@property (nonatomic, copy , nullable) NSString *vIcon;
@property (nonatomic, copy , nullable) NSString *userAuthInfo;
@end

@interface FHFeedContentRawDataContentQuestionModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *questionListSchema;
@property (nonatomic, copy , nullable) NSString *isAnonymous;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *writeAnswerSchema;
@property (nonatomic, copy , nullable) NSString *qid;
@property (nonatomic, copy , nullable) NSString *followCount;
@property (nonatomic, copy , nullable) NSString *niceAnsCount;
@property (nonatomic, copy , nullable) NSString *answerCountDescription;
@property (nonatomic, strong , nullable) FHFeedContentRawDataContentQuestionContentModel *content ;
@property (nonatomic, copy , nullable) NSString *isQuestionDelete;
@property (nonatomic, copy , nullable) NSString *createTime;
@property (nonatomic, copy , nullable) NSString *normalAnsCount;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentRawDataContentQuestionAnswerUserListModel> *answerUserList;
@end

@protocol FHFeedContentRawDataContentFilterWordsModel<NSObject>
@end

@interface FHFeedContentRawDataContentFilterWordsModel : JSONModel

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *name;
@end

@interface FHFeedContentRawDataContentUserModel : JSONModel

@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *isVerify;
@property (nonatomic, copy , nullable) NSString *userSchema;
@property (nonatomic, copy , nullable) NSString *uname;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *isFollowing;
@property (nonatomic, copy , nullable) NSString *vIcon;
@property (nonatomic, copy , nullable) NSString *userAuthInfo;
@end

@interface FHFeedContentRawDataContentAnswerModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *largeImageList;
@property (nonatomic, copy , nullable) NSString *answerDetailSchema;
@property (nonatomic, copy , nullable) NSString *abstractText;
@property (nonatomic, copy , nullable) NSString *forwardCount;
@property (nonatomic, copy , nullable) NSString *diggCount;
@property (nonatomic, copy , nullable) NSString *videoType;
@property (nonatomic, copy , nullable) NSString *commentCount;
@property (nonatomic, copy , nullable) NSString *createTime;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *thumbImageList;
@property (nonatomic, copy , nullable) NSString *answerType;
@property (nonatomic, copy , nullable) NSString *browCount;
@property (nonatomic, copy , nullable) NSString *isDigg;
@property (nonatomic, copy , nullable) NSString *ansid;
@end

@interface FHFeedContentRawDataContentRepostParamsModel : JSONModel

@property (nonatomic, copy , nullable) NSString *optId;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *fwIdType;
@property (nonatomic, copy , nullable) NSString *fwId;
@property (nonatomic, copy , nullable) NSString *coverUrl;
@property (nonatomic, copy , nullable) NSString *optIdType;
@property (nonatomic, copy , nullable) NSString *repostType;
@property (nonatomic, copy , nullable) NSString *fwUserId;
@property (nonatomic, copy , nullable) NSString *schema;
@end

@interface FHFeedContentRawDataContentModel : JSONModel

@property (nonatomic, copy , nullable) NSString *defaultLines;
@property (nonatomic, copy , nullable) NSString *imageType;
@property (nonatomic, strong , nullable) FHFeedContentRawDataContentQuestionModel *question ;
@property (nonatomic, copy , nullable) NSString *commentSchema;
@property (nonatomic, copy , nullable) NSString *maxLines;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentRawDataContentFilterWordsModel> *filterWords;
@property (nonatomic, strong , nullable) FHFeedContentRawDataContentUserModel *user ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataContentAnswerModel *answer ;
@property (nonatomic, copy , nullable) NSString *recommendReason;
@property (nonatomic, copy , nullable) NSString *layoutType;
@property (nonatomic, strong , nullable) FHFeedContentRawDataContentRepostParamsModel *repostParams ;
@property (nonatomic, copy , nullable) NSString *jumpType;
@property (nonatomic, strong , nullable) FHFeedContentRawDataContentExtraModel *extra ;
@end

@interface FHFeedContentRawDataOriginGroupModel : JSONModel

@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *source;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, copy , nullable) NSString *titleRichSpan;
@property (nonatomic, copy , nullable) NSString *itemIdStr;
@property (nonatomic, copy , nullable) NSString *articleUrl;
@property (nonatomic, copy , nullable) NSString *itemId;
@property (nonatomic, copy , nullable) NSString *groupIdStr;
@property (nonatomic, strong , nullable) FHFeedContentImageListModel *middleImage ;
@property (nonatomic, copy , nullable) NSString *aggrType;
@end

@interface FHFeedContentRawDataCommentBaseModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *contentDecoration;
@property (nonatomic, copy , nullable) NSString *richContent;
@property (nonatomic, copy , nullable) NSString *detailSchema;
@property (nonatomic, copy , nullable) NSString *commentSchema;
@property (nonatomic, copy , nullable) NSString *contentRichSpan;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *createTime;
@property (nonatomic, copy , nullable) NSString *groupSource;
@property (nonatomic, copy , nullable) NSString *itemId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *composition;
@property (nonatomic, copy , nullable) NSString *repostStatus;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *imageList;
@property (nonatomic, strong , nullable) FHFeedContentRawDataCommentBaseActionModel *action ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataCommentBaseUserModel *user ;
@end

@interface FHFeedContentRawDataOperationModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *imageList;
@end

@interface FHFeedContentRawDataModel : JSONModel

@property (nonatomic, strong , nullable) FHFeedContentRawDataOperationModel *operation ;
@property (nonatomic, strong , nullable) FHFeedContentCommunityModel *community ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataContentModel *content ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataCommentBaseModel *commentBase ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataOriginGroupModel *originGroup ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataOriginCommonContentModel *originCommonContent ;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentRecommendSocialGroupListModel> *recommendSocialGroupList;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentRawDataHotTopicListModel> *hotTopicList;
@property (nonatomic, strong , nullable) FHFeedContentRawDataVoteModel *vote ;
@property (nonatomic, copy , nullable) NSString *articleSchema;
@property (nonatomic, copy , nullable) NSString *itemId;
@property (nonatomic, copy , nullable) NSString *groupId;
//视频相关
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *detailSchema;
@property (nonatomic, copy , nullable) NSString *titleRichSpan;
@property (nonatomic, copy , nullable) NSString *createTime;
@property (nonatomic, strong , nullable) FHFeedContentRawDataVideoModel *video ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataCommentBaseUserModel *user ;
@property (nonatomic, copy , nullable) NSString *videoContent;
@property (nonatomic, strong , nullable) FHFeedContentRawDataCommentBaseActionModel *action ;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *firstFrameImageList;

@end

@interface FHFeedContentModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *contentDecoration;
@property (nonatomic, copy , nullable) NSString *mediaName;
@property (nonatomic, copy , nullable) NSString *banComment;
@property (nonatomic, copy , nullable) NSString *abstract;
@property (nonatomic, strong , nullable) FHFeedContentUgcRecommendModel *ugcRecommend ;  
@property (nonatomic, copy , nullable) NSString *tag;
@property (nonatomic, copy , nullable) NSString *readCount;
@property (nonatomic, assign) BOOL isSubject;
@property (nonatomic, copy , nullable) NSString *articleType;
@property (nonatomic, assign) BOOL showDislike;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, assign) BOOL hasM3u8Video;
@property (nonatomic, copy , nullable) NSString *cellType;
@property (nonatomic, copy , nullable) NSString *keywords;
@property (nonatomic, copy , nullable) NSString *rid;
@property (nonatomic, copy , nullable) NSString *hasMp4Video;
@property (nonatomic, copy , nullable) NSString *aggrType;
@property (nonatomic, copy , nullable) NSString *cellLayoutStyle;
@property (nonatomic, copy , nullable) NSString *articleSubType;
@property (nonatomic, copy , nullable) NSString *buryCount;
@property (nonatomic, copy , nullable) NSString *needClientImprRecycle;
@property (nonatomic, copy , nullable) NSString *ignoreWebTransform;
@property (nonatomic, copy , nullable) NSString *sourceIconStyle;
@property (nonatomic, copy , nullable) NSString *tip;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, strong , nullable) FHFeedContentForwardInfoModel *forwardInfo ;  
@property (nonatomic, assign) BOOL showPortraitArticle;
@property (nonatomic, copy , nullable) NSString *source;
@property (nonatomic, copy , nullable) NSString *commentCount;
@property (nonatomic, copy , nullable) NSString *articleUrl;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentFilterWordsModel> *filterWords;
@property (nonatomic, copy , nullable) NSString *interactionData;
@property (nonatomic, assign) BOOL allowDownload;
@property (nonatomic, copy , nullable) NSString *shareCount;
@property (nonatomic, copy , nullable) NSString *repinCount;
@property (nonatomic, copy , nullable) NSString *publishTime;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentActionListModel> *actionList;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) FHFeedContentShareInfoModel *shareInfo ;  
@property (nonatomic, copy , nullable) NSString *gallaryImageCount;
@property (nonatomic, copy , nullable) NSString *actionExtra;
@property (nonatomic, copy , nullable) NSString *tagId;
@property (nonatomic, copy , nullable) NSString *videoStyle;
@property (nonatomic, copy , nullable) NSString *verifiedContent;
@property (nonatomic, copy , nullable) NSString *articleVersion;
@property (nonatomic, copy , nullable) NSString *itemId;
@property (nonatomic, assign) BOOL showPortrait;
@property (nonatomic, copy , nullable) NSString *displayUrl;
@property (nonatomic, copy , nullable) NSString *cellFlag;
@property (nonatomic, strong , nullable) FHFeedContentUserInfoModel *userInfo ;  
@property (nonatomic, copy , nullable) NSString *sourceOpenUrl;
@property (nonatomic, copy , nullable) NSString *level;
@property (nonatomic, copy , nullable) NSString *userVerified;
@property (nonatomic, copy , nullable) NSString *diggCount;
@property (nonatomic, copy , nullable) NSString *userDigg;
@property (nonatomic, copy , nullable) NSString *behotTime;
@property (nonatomic, copy , nullable) NSString *hot;
@property (nonatomic, copy , nullable) NSString *cursor;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *preloadWeb;
@property (nonatomic, copy , nullable) NSString *userRepin;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, copy , nullable) NSString *itemVersion;
@property (nonatomic, strong , nullable) FHFeedContentMediaInfoModel *mediaInfo ;  
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, strong , nullable) FHFeedContentMiddleImageModel *middleImage ;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *imageList;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *largeImageList;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *sourceDesc;
@property (nonatomic, strong , nullable) FHFeedContentCommunityModel *community ;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentRecommendSocialGroupListModel> *recommendSocialGroupList;
@property (nonatomic, strong , nullable) FHFeedContentRawDataModel *rawData ;
//临时处理服务器打平的逻辑
@property (nonatomic, copy , nullable) NSString *articleSchema;
@property (nonatomic, assign)   BOOL       isFromDetail;// 详情页
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
