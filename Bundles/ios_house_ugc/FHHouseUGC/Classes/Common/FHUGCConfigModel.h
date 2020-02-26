//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHUGCConfigDataLeadSuggestModel<NSObject>
@end

@interface FHUGCConfigDataLeadSuggestModel : JSONModel

@property (nonatomic, copy , nullable) NSString *kind;
@property (nonatomic, copy , nullable) NSString *hint;
@end

@protocol FHUGCConfigDataPermissionModel<NSObject>
@end

@interface FHUGCConfigDataPermissionModel : JSONModel

@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, assign) BOOL isHidden;
@end

//给圈子做分类，每个城市的区域以及推荐和关注
@protocol FHUGCConfigDataDistrictModel <NSObject>
@end

@interface FHUGCConfigDataDistrictModel : JSONModel
@property(nonatomic, assign) NSInteger districtId;
@property(nonatomic, copy, nullable) NSString *districtName;
@end

@interface FHPostUGCSelectedGroupModel: JSONModel
@property (nonatomic, copy) NSString *socialGroupId;
@property (nonatomic, copy) NSString *socialGroupName;
@end

@interface FHPostUGCSelectedGroupHistory: JSONModel
@property (nonatomic, strong) NSMutableDictionary<NSString*, FHPostUGCSelectedGroupModel*> *historyInfos;
@end

@interface FHUGCConfigDataModel : JSONModel

@property(nonatomic, strong, nullable) NSArray <FHUGCConfigDataLeadSuggestModel> *leadSuggest;
@property(nonatomic, strong, nullable) NSArray <FHUGCConfigDataPermissionModel> *permission;
@property(nonatomic, strong, nullable) NSArray <FHUGCConfigDataDistrictModel> *ugcDistrict;
@property(nonatomic, copy, nullable) NSString *userAuth;
@end

@interface FHUGCConfigModel : JSONModel

@property(nonatomic, copy, nullable) NSString *status;
@property(nonatomic, copy, nullable) NSString *message;
@property(nonatomic, strong, nullable) FHUGCConfigDataModel *data;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
