//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHUGCDataUserFollowSocialGroupsModel<NSObject>
@end

@interface FHUGCDataUserFollowSocialGroupsAvatarModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *imageType;
@end

@interface FHUGCDataUserFollowSocialGroupsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *contentCount;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *followCount;
@property (nonatomic, copy , nullable) NSString *forumId;
@property (nonatomic, strong , nullable) FHUGCDataUserFollowSocialGroupsAvatarModel *avatar ;  
@property (nonatomic, copy , nullable) NSString *socialGroupId;
@property (nonatomic, copy , nullable) NSString *type;
@end

@interface FHUGCDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHUGCDataUserFollowSocialGroupsModel> *userFollowSocialGroups;
@end

@interface FHUGCModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER