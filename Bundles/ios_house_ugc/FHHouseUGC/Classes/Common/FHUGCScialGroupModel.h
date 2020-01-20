//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import <FHUGCConfigModel.h>
#import "FHUGCShareManager.h"
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

typedef NS_ENUM(NSUInteger, UserCoversationStatus) {
    joinConversation = 1,
    leaveConversation = 2,
    KickOutConversation = 3,
};

@interface FHUGCScialGroupDataChatStatusModel: JSONModel

//群聊的ID
@property (nonatomic, copy) NSString *conversationId;
//用户在当前群聊的状态
@property (nonatomic, assign) UserCoversationStatus conversationStatus;
//群聊的上限
@property (nonatomic, assign) NSUInteger maxConversationCount;
//当前群聊的人数
@property (nonatomic, assign) NSUInteger currentConversationCount;
//群聊的short id
@property (nonatomic, assign) long long conversationShortId;
//创建群聊的幂等id
@property (nonatomic, copy) NSString *idempotentId;

@end

@protocol FHUGCScialGroupDataTabInfoModel<NSObject>
@end

@interface FHUGCScialGroupDataTabInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *tabName;
@property (nonatomic, copy , nullable) NSString *showName;
@property (nonatomic, assign) BOOL isDefault;
@end

@interface FHUGCScialGroupDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *announcement;
@property (nonatomic, copy , nullable) NSString *announcementUrl;
@property (nonatomic, copy , nullable) NSString *contentCount;
@property (nonatomic, copy , nullable) NSString *socialGroupName;
@property (nonatomic, copy , nullable) NSString *suggestReason;
@property (nonatomic, copy , nullable) NSString *followerCount;
@property (nonatomic, copy , nullable) NSString *avatar;
@property (nonatomic, copy , nullable) NSString *countText;
@property (nonatomic, copy , nullable) NSString *contentText;
@property (nonatomic, copy , nullable) NSString *socialGroupId;
@property (nonatomic, copy , nullable) NSString *hasFollow;
@property (nonatomic, strong, nullable) FHUGCSocialGroupOperationModel *operation;
@property (nonatomic, assign) UserAuthType userAuth;
@property (nonatomic, strong, nullable) NSArray <FHUGCConfigDataPermissionModel> *permission;
@property (nonatomic, copy , nullable) NSDictionary *logPb;
@property (nonatomic, strong) FHUGCScialGroupDataChatStatusModel *chatStatus;
@property (nonatomic, strong, nullable)   FHUGCShareInfoModel *shareInfo;
@property (nonatomic, strong , nullable) NSArray<FHUGCScialGroupDataTabInfoModel> *tabInfo;

@end

@interface FHUGCScialGroupModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCScialGroupDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
