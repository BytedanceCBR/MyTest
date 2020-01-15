//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHFeedContentModel.h"
#import "FHUGCShareManager.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHFeedUGCContentCommunityModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *socialGroupId;
@property (nonatomic, copy , nullable) NSString *showStatus;
@end

@interface FHFeedUGCContentShareShareCoverModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@end

@interface FHFeedUGCContentShareModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *shareWeiboDesc;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *shareDesc;
@property (nonatomic, strong , nullable) FHFeedUGCContentShareShareCoverModel *shareCover ;  
@property (nonatomic, copy , nullable) NSString *shareTitle;
@end

@interface FHFeedUGCContentForwardInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *forwardCount;
@end

@protocol FHFeedUGCContentDetailCoverListModel<NSObject>
@end

@protocol FHFeedUGCContentDetailCoverListUrlListModel<NSObject>
@end

@interface FHFeedUGCContentDetailCoverListUrlListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@end

@interface FHFeedUGCContentDetailCoverListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCContentDetailCoverListUrlListModel> *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *type;
@end

@protocol FHFeedUGCContentFilterWordsModel<NSObject>
@end

@interface FHFeedUGCContentFilterWordsModel : JSONModel 

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *name;
@end

@protocol FHFeedUGCContentUgcU13CutImageListModel<NSObject>
@end

@protocol FHFeedUGCContentUgcU13CutImageListUrlListModel<NSObject>
@end

@interface FHFeedUGCContentUgcU13CutImageListUrlListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@end

@interface FHFeedUGCContentUgcU13CutImageListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCContentUgcU13CutImageListUrlListModel> *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *type;
@end

@protocol FHFeedUGCContentUgcCutImageListModel<NSObject>
@end

@protocol FHFeedUGCContentUgcCutImageListUrlListModel<NSObject>
@end

@interface FHFeedUGCContentUgcCutImageListUrlListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@end

@interface FHFeedUGCContentUgcCutImageListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCContentUgcCutImageListUrlListModel> *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *type;
@end

@protocol FHFeedUGCContentActionListModel<NSObject>
@end

@interface FHFeedUGCContentActionListExtraModel : JSONModel 

@end

@interface FHFeedUGCContentActionListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *action;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, strong , nullable) FHFeedUGCContentActionListExtraModel *extra ;  
@end

@interface FHFeedUGCContentShareInfoShareTypeModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *qq;
@property (nonatomic, copy , nullable) NSString *pyq;
@property (nonatomic, copy , nullable) NSString *qzone;
@property (nonatomic, copy , nullable) NSString *wx;
@end

@interface FHFeedUGCContentShareInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *weixinCoverImage;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, strong , nullable) FHFeedUGCContentShareInfoShareTypeModel *shareType ;  
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *tokenType;
@property (nonatomic, copy , nullable) NSString *coverImage;
@end

@protocol FHFeedUGCContentThumbImageListModel<NSObject>
@end

@protocol FHFeedUGCContentThumbImageListUrlListModel<NSObject>
@end

@interface FHFeedUGCContentThumbImageListUrlListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@end

@interface FHFeedUGCContentThumbImageListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCContentThumbImageListUrlListModel> *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *type;
@end

@protocol FHFeedUGCContentLargeImageListModel<NSObject>
@end

@protocol FHFeedUGCContentLargeImageListUrlListModel<NSObject>
@end

@interface FHFeedUGCContentLargeImageListUrlListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@end

@interface FHFeedUGCContentLargeImageListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCContentLargeImageListUrlListModel> *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *type;
@end

@interface FHFeedUGCContentForumModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *introdutionUrl;
@property (nonatomic, copy , nullable) NSString *onlookersCount;
@property (nonatomic, copy , nullable) NSString *bannerUrl;
@property (nonatomic, copy , nullable) NSString *forumName;
@property (nonatomic, copy , nullable) NSString *forumId;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *showEtStatus;
@property (nonatomic, copy , nullable) NSString *followerCount;
@property (nonatomic, copy , nullable) NSString *participantCount;
@property (nonatomic, copy , nullable) NSString *talkCount;
@property (nonatomic, copy , nullable) NSString *desc;
@end

@interface FHFeedUGCContentRepostParamsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *optId;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *fwIdType;
@property (nonatomic, copy , nullable) NSString *fwId;
@property (nonatomic, copy , nullable) NSString *fwNativeSchema;
@property (nonatomic, copy , nullable) NSString *coverUrl;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, copy , nullable) NSString *optIdType;
@property (nonatomic, copy , nullable) NSString *titleRichSpan;
@property (nonatomic, copy , nullable) NSString *repostType;
@property (nonatomic, copy , nullable) NSString *fwUserId;
@property (nonatomic, copy , nullable) NSString *fwShareUrl;
@property (nonatomic, copy , nullable) NSString *schema;
@end

@interface FHFeedUGCContentPositionModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *latitude;
@property (nonatomic, copy , nullable) NSString *position;
@property (nonatomic, copy , nullable) NSString *longitude;
@end

@interface FHFeedUGCContentUgcRecommendModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *reason;
@property (nonatomic, copy , nullable) NSString *activity;
@end

@interface FHFeedUGCContentUserModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *isFollowed;
@property (nonatomic, copy , nullable) NSString *isBlocking;
@property (nonatomic, copy , nullable) NSString *verifiedContent;
@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *isFriend;
@property (nonatomic, copy , nullable) NSString *userDecoration;
@property (nonatomic, copy , nullable) NSString *userVerified;
@property (nonatomic, copy , nullable) NSString *remarkName;
@property (nonatomic, copy , nullable) NSString *screenName;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *isFollowing;
@property (nonatomic, copy , nullable) NSString *liveInfoType;
@property (nonatomic, copy , nullable) NSString *isBlocked;
@property (nonatomic, copy , nullable) NSString *userAuthInfo;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong , nullable) NSArray *medals;
@property (nonatomic, copy , nullable) NSString *desc;
@end

@interface FHFeedUGCContentModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *contentDecoration;
@property (nonatomic, copy , nullable) NSString *version;
@property (nonatomic, copy , nullable) NSString *banComment;
@property (nonatomic, copy , nullable) NSString *readCount;
@property (nonatomic, copy , nullable) NSString *abstract;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, strong , nullable) FHFeedUGCContentShareModel *share ;  
@property (nonatomic, copy , nullable) NSString *defaultTextLine;
@property (nonatomic, copy , nullable) NSString *diggCount;
@property (nonatomic, copy , nullable) NSString *articleType;
@property (nonatomic, copy , nullable) NSString *createTime;
@property (nonatomic, strong , nullable) FHFeedUGCContentForwardInfoModel *forwardInfo ;  
@property (nonatomic, assign) BOOL hasM3u8Video;
@property (nonatomic, copy , nullable) NSString *threadId;
@property (nonatomic, copy , nullable) NSString *follow;
@property (nonatomic, copy , nullable) NSString *rid;
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCContentDetailCoverListModel> *detailCoverList;
@property (nonatomic, copy , nullable) NSString *hasMp4Video;
@property (nonatomic, copy , nullable) NSString *videoGroup;
@property (nonatomic, copy , nullable) NSString *tinyToutiaoUrl;
@property (nonatomic, copy , nullable) NSString *cellLayoutStyle;
@property (nonatomic, copy , nullable) NSString *articleSubType;
@property (nonatomic, copy , nullable) NSString *businessPayload;
@property (nonatomic, copy , nullable) NSString *buryCount;
@property (nonatomic, copy , nullable) NSString *innerUiFlag;
@property (nonatomic, copy , nullable) NSString *ignoreWebTransform;
@property (nonatomic, copy , nullable) NSString *tip;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, copy , nullable) NSString *contentRichSpan;
@property (nonatomic, assign) BOOL showPortraitArticle;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *commentCount;
@property (nonatomic, copy , nullable) NSString *hasEdit;
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCContentFilterWordsModel> *filterWords;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *ugcU13CutImageList;
@property (nonatomic, copy , nullable) NSString *groupSource;
@property (nonatomic, assign) BOOL allowDownload;
@property (nonatomic, copy , nullable) NSString *shareCount;
@property (nonatomic, copy , nullable) NSString *composition;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *preload;
@property (nonatomic, copy , nullable) NSString *uiType;
@property (nonatomic, assign) BOOL showDislike;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *ugcCutImageList;
@property (nonatomic, strong , nullable) NSArray<FHFeedUGCContentActionListModel> *actionList;
@property (nonatomic, copy , nullable) NSString *followButtonStyle;
@property (nonatomic, copy , nullable) NSString *richContent;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) FHUGCShareInfoModel *shareInfo ;
@property (nonatomic, copy , nullable) NSString *interactionData;
@property (nonatomic, copy , nullable) NSString *cellType;
@property (nonatomic, copy , nullable) NSString *videoStyle;
@property (nonatomic, copy , nullable) NSString *itemVersion;
@property (nonatomic, copy , nullable) NSString *verifiedContent;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *thumbImageList;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *largeImageList;
@property (nonatomic, copy , nullable) NSString *maxTextLine;
@property (nonatomic, copy , nullable) NSString *userDigg;
@property (nonatomic, assign) BOOL isSubject;
@property (nonatomic, copy , nullable) NSString *threadIdStr;
@property (nonatomic, assign) BOOL showPortrait;
@property (nonatomic, copy , nullable) NSString *distance;
@property (nonatomic, copy , nullable) NSString *distanceInfo;
@property (nonatomic, strong , nullable) FHFeedUGCContentForumModel *forum ;  
@property (nonatomic, copy , nullable) NSString *level;
@property (nonatomic, copy , nullable) NSString *cellFlag;
@property (nonatomic, copy , nullable) NSString *diggIconKey;
@property (nonatomic, copy , nullable) NSString *needClientImprRecycle;
@property (nonatomic, copy , nullable) NSString *userVerified;
@property (nonatomic, copy , nullable) NSString *commentSchema;
@property (nonatomic, copy , nullable) NSString *behotTime;
@property (nonatomic, copy , nullable) NSString *hot;
@property (nonatomic, copy , nullable) NSString *cursor;
@property (nonatomic, strong , nullable) FHFeedUGCContentRepostParamsModel *repostParams ;  
@property (nonatomic, copy , nullable) NSString *communityInfo;
@property (nonatomic, copy , nullable) NSString *userRepin;
@property (nonatomic, copy , nullable) NSString *brandInfo;
@property (nonatomic, strong , nullable) FHFeedUGCContentPositionModel *position ;  
@property (nonatomic, copy , nullable) NSString *cellUiType;
@property (nonatomic, strong , nullable) FHFeedUGCContentUgcRecommendModel *ugcRecommend ;  
@property (nonatomic, strong , nullable) FHFeedUGCContentUserModel *user ;
@property (nonatomic, strong , nullable) FHFeedUGCContentCommunityModel *community ;
@property (nonatomic, assign)   NSInteger       ugcStatus;
@property (nonatomic, assign)   BOOL       isFromDetail;              // 详情页
@property (nonatomic, assign)   BOOL       isStick;                   // 是否置顶
@property (nonatomic, assign)   FHFeedContentStickStyle stickStyle;// 置顶类型：精华或其它

@end


NS_ASSUME_NONNULL_END
//END OF HEADER
