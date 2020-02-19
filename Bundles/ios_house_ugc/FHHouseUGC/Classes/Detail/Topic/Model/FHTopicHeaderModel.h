//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHTopicHeaderForumExtraModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *themeId;
@property (nonatomic, copy , nullable) NSString *musicId;
@property (nonatomic, copy , nullable) NSString *effectId;
@property (nonatomic, copy , nullable) NSString *data;
@end

@interface FHTopicHeaderForumModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *bannerUrl;
@property (nonatomic, strong , nullable) FHTopicHeaderForumExtraModel *extra ;  
@property (nonatomic, copy , nullable) NSString *forumName;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic)         NSString<Optional>* titleUrl;
@property (nonatomic)         NSString<Optional>* rankInfo;
@property (nonatomic)         NSString<Optional>* hostInfo;
@property (nonatomic, copy , nullable) NSString *concernId;
@property (nonatomic, copy , nullable) NSString *categoryType;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *richContent;
@property (nonatomic)         NSString<Optional>* forumSpot;
@property (nonatomic, copy , nullable) NSString *forumId;
@property (nonatomic, assign) BOOL showFollowButton;
@property (nonatomic, copy , nullable) NSString *headerStyle;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *productType;
@property (nonatomic)         NSString<Optional>* forumLogoUrl;
@property (nonatomic, copy , nullable) NSString *subDesc;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *descRichSpan;
@end

@protocol FHTopicHeaderTabsModel<NSObject>
@end

@interface FHTopicHeaderTabsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *tabEtStatus;
@property (nonatomic, copy , nullable) NSString *needCommonParams;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic)         NSDictionary<Optional>* extra;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *soleName;
@property (nonatomic, copy , nullable) NSString *tabType;
@property (nonatomic, copy , nullable) NSString *banRefresh;
@property (nonatomic, copy , nullable) NSString *tabId;
@property (nonatomic, copy , nullable) NSString *refreshInterval;
@property (nonatomic, copy , nullable) NSString *categoryName;
@end

@interface FHTopicHeaderShareInfoShareTypeModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *qq;
@property (nonatomic, copy , nullable) NSString *pyq;
@property (nonatomic, copy , nullable) NSString *qzone;
@property (nonatomic, copy , nullable) NSString *wx;
@end

@interface FHTopicHeaderShareInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *shareCover;
@property (nonatomic, strong , nullable) FHTopicHeaderShareInfoShareTypeModel *shareType ;  
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *tokenType;
@property (nonatomic, copy , nullable) NSString *shareTitle;
@property (nonatomic, copy , nullable) NSString *shareDesc;
@end

@protocol FHTopicHeaderPublisherControlPublisherTypesModel<NSObject>
@end

@interface FHTopicHeaderPublisherControlPublisherTypesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *icon;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *label;
@end

@interface FHTopicHeaderPublisherControlModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *postContentHint;
@property (nonatomic, copy , nullable) NSString *showEtStatus;
@property (nonatomic, strong , nullable) NSArray<FHTopicHeaderPublisherControlPublisherTypesModel> *publisherTypes;
@end

@interface FHTopicHeaderModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *errTips;
@property (nonatomic, strong , nullable) FHTopicHeaderForumModel *forum ;  
@property (nonatomic, strong , nullable) NSArray<FHTopicHeaderTabsModel> *tabs;
@property (nonatomic, strong , nullable) FHTopicHeaderShareInfoModel *shareInfo ;  
@property (nonatomic, strong , nullable) FHTopicHeaderPublisherControlModel *publisherControl ;  
@property (nonatomic, copy , nullable) NSString *errNo;
@property (nonatomic)         NSString<Optional>* repostParams;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
