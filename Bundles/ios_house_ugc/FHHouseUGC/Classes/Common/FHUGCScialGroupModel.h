//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import <FHUGCConfigModel.h>
NS_ASSUME_NONNULL_BEGIN

@protocol FHUGCScialGroupDataModel <NSObject>

@end

@interface FHUGCSocialGroupOperationModel : JSONModel
@property (nonatomic, copy , nullable) NSString *imageUrl;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, copy , nullable) NSString *linkUrl;
@property (nonatomic, assign) BOOL hasOperation;
@end

typedef NS_ENUM(NSUInteger, UserAuthType) {
    UserAuthTypeNormal = 0,
    UserAuthTypeAdmin = 1,
    UserAuthTypeSuperAdmin = 2,
};

@interface FHUGCScialGroupDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *announcement;
@property (nonatomic, copy , nullable) NSString *announcementUrl;
@property (nonatomic, copy , nullable) NSString *contentCount;
@property (nonatomic, copy , nullable) NSString *socialGroupName;
@property (nonatomic, copy , nullable) NSString *suggestReason;
@property (nonatomic, copy , nullable) NSString *followerCount;
@property (nonatomic, copy , nullable) NSString *avatar;
@property (nonatomic, copy , nullable) NSString *countText;
@property (nonatomic, copy , nullable) NSString *socialGroupId;
@property (nonatomic, copy , nullable) NSString *hasFollow;
@property (nonatomic, strong, nullable) FHUGCSocialGroupOperationModel *operation;
@property (nonatomic, assign) UserAuthType userAuth;
@property(nonatomic, strong, nullable) NSArray <FHUGCConfigDataPermissionModel> *permission;
@property (nonatomic, copy , nullable) NSDictionary *logPb;

@end

@interface FHUGCScialGroupModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCScialGroupDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
