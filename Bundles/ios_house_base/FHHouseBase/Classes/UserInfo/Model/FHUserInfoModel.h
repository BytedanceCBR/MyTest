//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHUserInfoDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *verifiedAgency;
@property (nonatomic, copy , nullable) NSString *countryCode;
@property (nonatomic, copy , nullable) NSString *recommendHintMessage;
@property (nonatomic, assign) BOOL isToutiao;
@property (nonatomic, copy , nullable) NSString *sessionKey;
@property (nonatomic, assign) BOOL userVerified;
@property (nonatomic, copy , nullable) NSString *isBlocking;
@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *area;
@property (nonatomic, copy , nullable) NSString *userDecoration;
@property (nonatomic, copy , nullable) NSString *userIdStr;
@property (nonatomic, copy , nullable) NSString *userAuthInfo;
@property (nonatomic, copy , nullable) NSString *userPrivacyExtend;
@property (nonatomic, copy , nullable) NSString *email;
@property (nonatomic, copy , nullable) NSString *mediaId;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, copy , nullable) NSString *bgImgUrl;
@property (nonatomic, copy , nullable) NSString *verifiedContent;
@property (nonatomic, copy , nullable) NSString *birthday;
@property (nonatomic, copy , nullable) NSString *isBlocked;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *isRecommendAllowed;
@property (nonatomic, copy , nullable) NSString *screenName;
@property (nonatomic, copy , nullable) NSString *mobile;
@property (nonatomic, copy , nullable) NSString *gender;
@property (nonatomic, copy , nullable) NSString *industry;
@property (nonatomic, copy , nullable) NSString *shareToRepost;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *canBeFoundByPhone;
@property (nonatomic, copy , nullable) NSString *fHomepageAuth;
@end

@interface FHUserInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUserInfoDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
