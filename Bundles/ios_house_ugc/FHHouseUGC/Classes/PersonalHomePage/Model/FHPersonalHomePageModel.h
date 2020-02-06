//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHPersonalHomePageDataFollowersDetailModel<NSObject>
@end

@interface FHPersonalHomePageDataFollowersDetailModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *fansCount;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *packageName;
@property (nonatomic, copy , nullable) NSString *downloadUrl;
@property (nonatomic, copy , nullable) NSString *appleId;
@property (nonatomic, copy , nullable) NSString *appName;
@property (nonatomic, copy , nullable) NSString *icon;
@end

@protocol FHPersonalHomePageDataTopTabModel<NSObject>
@end

@interface FHPersonalHomePageDataTopTabModel : JSONModel 

@property (nonatomic, assign) BOOL isNative;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *showName;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) BOOL disableCommonParams;
@end

@interface FHPersonalHomePageDataModel : JSONModel 

@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, copy , nullable) NSString *currentUserId;
@property (nonatomic, strong , nullable) NSArray<FHPersonalHomePageDataFollowersDetailModel> *followersDetail;
@property (nonatomic, copy , nullable) NSString *fCommentCount;
@property (nonatomic, copy , nullable) NSString *articleLimitEnable;
@property (nonatomic, copy , nullable) NSString *verifiedAgency;
@property (nonatomic, copy , nullable) NSString *privateLetterPermission;
@property (nonatomic, copy , nullable) NSString *followingsCount;
@property (nonatomic, copy , nullable) NSString *pgcLikeCount;
@property (nonatomic, copy , nullable) NSString *publishCount;
@property (nonatomic, copy , nullable) NSString *fDiggCount;
@property (nonatomic, strong , nullable) NSArray<FHPersonalHomePageDataTopTabModel> *topTab;
@property (nonatomic, copy , nullable) NSString *isBlocking;
@property (nonatomic, copy , nullable) NSString *fHomepageAuth;
@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, assign) BOOL hasSponsor;
@property (nonatomic, copy , nullable) NSString *userDecoration;
@property (nonatomic, copy , nullable) NSString *noDisplayPgcIcon;
@property (nonatomic, copy , nullable) NSString *applyAuthEntryTitle;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *showPrivateLetter;
@property (nonatomic, copy , nullable) NSString *followersCount;
@property (nonatomic, copy , nullable) NSString *mplatformFollowersCount;
@property (nonatomic, copy , nullable) NSString *mediaType;
@property (nonatomic, copy , nullable) NSString *userAuthInfo;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *mediaId;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *forumFollowingCount;
@property (nonatomic, copy , nullable) NSString *fFollowSgCount;
@property (nonatomic, copy , nullable) NSString *applyAuthUrl;
@property (nonatomic, copy , nullable) NSString *verifiedContent;
@property (nonatomic, copy , nullable) NSString *followRecommendBarHeight;
@property (nonatomic, copy , nullable) NSString *isBlocked;
@property (nonatomic, copy , nullable) NSString *screenName;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *bigAvatarUrl;
@property (nonatomic, copy , nullable) NSString *logId;
@property (nonatomic, copy , nullable) NSString *gender;
@property (nonatomic, copy , nullable) NSString *flipchatInvite;
@property (nonatomic, copy , nullable) NSString *diggCount;
@property (nonatomic, copy , nullable) NSString *sponsorUrl;
@property (nonatomic, copy , nullable) NSString *ugcPublishMediaId;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, copy , nullable) NSString *hideFollowCount;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@end

@interface FHPersonalHomePageModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *dErrno;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHPersonalHomePageDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
