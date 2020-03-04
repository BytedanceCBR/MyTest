//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHSpecialTopicHeaderForumExtraModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *curCityCode;
@property (nonatomic, copy , nullable) NSString *musicId;
@property (nonatomic, copy , nullable) NSString *effectId;
@property (nonatomic, copy , nullable) NSString *ncovStringList;
@property (nonatomic, copy , nullable) NSString *ncovImageUrl;
@property (nonatomic, copy , nullable) NSString *themeId;
@property (nonatomic, copy , nullable) NSString *gpsCityCode;
@property (nonatomic, copy , nullable) NSString *data;
@end

@interface FHSpecialTopicHeaderForumModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *modifyTime;
@property (nonatomic, copy , nullable) NSString *productType;
@property (nonatomic, copy , nullable) NSString *bannerUrl;
@property (nonatomic, strong , nullable) FHSpecialTopicHeaderForumExtraModel *extra ;  
@property (nonatomic, copy , nullable) NSString *richContent;
@property (nonatomic, copy , nullable) NSString *forumName;
@property (nonatomic, copy , nullable) NSString *concernId;
@property (nonatomic, assign) BOOL showFollowButton;
@property (nonatomic, copy , nullable) NSString *forumId;
@property (nonatomic, copy , nullable) NSString *subDesc;
@property (nonatomic, copy , nullable) NSString *categoryType;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, copy , nullable) NSString *descRichSpan;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *headerStyle;
@property (nonatomic, copy , nullable) NSString *schema;
@end

@protocol FHSpecialTopicHeaderTabsModel<NSObject>
@end

@interface FHSpecialTopicHeaderTabsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *tabEtStatus;
@property (nonatomic, copy , nullable) NSString *needCommonParams;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *soleName;
@property (nonatomic, copy , nullable) NSString *tabType;
@property (nonatomic, copy , nullable) NSString *banRefresh;
@property (nonatomic, copy , nullable) NSString *tabId;
@property (nonatomic, copy , nullable) NSString *refreshInterval;
@property (nonatomic, copy , nullable) NSString *categoryName;
@end

@interface FHSpecialTopicHeaderShareInfoShareTypeModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *qq;
@property (nonatomic, copy , nullable) NSString *pyq;
@property (nonatomic, copy , nullable) NSString *qzone;
@property (nonatomic, copy , nullable) NSString *wx;
@end

@interface FHSpecialTopicHeaderShareInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *shareCover;
@property (nonatomic, strong , nullable) FHSpecialTopicHeaderShareInfoShareTypeModel *shareType ;  
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *tokenType;
@property (nonatomic, copy , nullable) NSString *shareTitle;
@property (nonatomic, copy , nullable) NSString *shareDesc;
@end

@protocol FHSpecialTopicHeaderPublisherControlPublisherTypesModel<NSObject>
@end

@interface FHSpecialTopicHeaderPublisherControlPublisherTypesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *icon;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *label;
@end

@interface FHSpecialTopicHeaderPublisherControlModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *postContentHint;
@property (nonatomic, copy , nullable) NSString *showEtStatus;
@property (nonatomic, strong , nullable) NSArray<FHSpecialTopicHeaderPublisherControlPublisherTypesModel> *publisherTypes;
@end

@protocol FHSpecialTopicHeaderInsertControlModel<NSObject>
@end

@interface FHSpecialTopicHeaderInsertControlModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray *categoryName;
@end

@interface FHSpecialTopicHeaderRepostParamsModel : JSONModel 

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

@interface FHSpecialTopicHeaderModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *errTips;
@property (nonatomic, strong , nullable) FHSpecialTopicHeaderForumModel *forum ;  
@property (nonatomic, strong , nullable) NSArray<FHSpecialTopicHeaderTabsModel> *tabs;
@property (nonatomic, strong , nullable) FHSpecialTopicHeaderShareInfoModel *shareInfo ;  
@property (nonatomic, strong , nullable) FHSpecialTopicHeaderPublisherControlModel *publisherControl ;  
@property (nonatomic, strong , nullable) NSArray<FHSpecialTopicHeaderInsertControlModel> *insertControl;
@property (nonatomic, copy , nullable) NSString *errNo;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSpecialTopicHeaderRepostParamsModel *repostParams ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
