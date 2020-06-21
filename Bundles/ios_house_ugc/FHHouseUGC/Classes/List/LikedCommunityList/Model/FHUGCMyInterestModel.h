//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
#import "FHUGCScialGroupModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHUGCMyInterestDataRecommendSocialGroupsModel<NSObject>
@end

@interface FHUGCMyInterestDataRecommendSocialGroupsSocialGroupModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *announcement;
@property (nonatomic, copy , nullable) NSString *contentCount;
@property (nonatomic, copy , nullable) NSString *socialGroupName;
@property (nonatomic, copy , nullable) NSString *suggestReason;
@property (nonatomic, copy , nullable) NSString *followerCount;
@property (nonatomic, copy , nullable) NSString *avatar;
@property (nonatomic, copy , nullable) NSString *countText;
@property (nonatomic, copy , nullable) NSString *socialGroupId;
@property (nonatomic, copy , nullable) NSString *UpdatedAt;
@property (nonatomic, copy , nullable) NSString *hasFollow;
@property (nonatomic, copy , nullable) NSString *CreatedAt;
@end

@protocol FHUGCMyInterestDataRecommendSocialGroupsThreadInfoImagesModel<NSObject>
@end

@interface FHUGCMyInterestDataRecommendSocialGroupsThreadInfoImagesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHUGCMyInterestDataRecommendSocialGroupsThreadInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, strong , nullable) NSArray<FHUGCMyInterestDataRecommendSocialGroupsThreadInfoImagesModel> *images;
@end

@interface FHUGCMyInterestDataRecommendSocialGroupsModel : JSONModel 

@property (nonatomic, strong , nullable) FHUGCScialGroupDataModel *socialGroup ;
@property (nonatomic, strong , nullable) FHUGCMyInterestDataRecommendSocialGroupsThreadInfoModel *threadInfo ;  
@end

@interface FHUGCMyInterestDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHUGCMyInterestDataRecommendSocialGroupsModel> *recommendSocialGroups;
@end

@interface FHUGCMyInterestModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCMyInterestDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
