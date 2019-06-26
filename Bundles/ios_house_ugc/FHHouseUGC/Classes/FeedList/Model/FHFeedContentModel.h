//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
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
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *sourceDesc;
@property (nonatomic, strong , nullable) FHFeedContentCommunityModel *community ;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentRecommendSocialGroupListModel> *recommendSocialGroupList;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
