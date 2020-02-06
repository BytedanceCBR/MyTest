//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHUGCUserFollowDataAdminListModel<NSObject>
@end

@interface FHUGCUserFollowDataAdminListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *userName;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, assign) BOOL homepageAuth;
@property (nonatomic, copy , nullable) NSString *followTime;
@property (nonatomic, copy , nullable) NSString *schema;
@end

@protocol FHUGCUserFollowDataFollowListModel<NSObject>
@end

@interface FHUGCUserFollowDataFollowListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *userId;
@property (nonatomic, copy , nullable) NSString *userName;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, assign) BOOL homepageAuth;
@property (nonatomic, copy , nullable) NSString *followTime;
@property (nonatomic, copy , nullable) NSString *schema;
@end

@interface FHUGCUserFollowDataModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHUGCUserFollowDataFollowListModel> *adminList;
@property (nonatomic, strong , nullable) NSArray<FHUGCUserFollowDataFollowListModel> *followList;
@property (nonatomic, strong , nullable) NSArray<FHUGCUserFollowDataFollowListModel> *suggestList;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign)   NSInteger       adminCount;
@property (nonatomic, assign)   NSInteger       followCount;

@end

@interface FHUGCUserFollowModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCUserFollowDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
