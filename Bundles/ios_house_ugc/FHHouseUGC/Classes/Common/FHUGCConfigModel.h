//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
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
@end

@interface FHUGCConfigDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHUGCConfigDataLeadSuggestModel> *leadSuggest;
@property (nonatomic, strong , nullable) NSArray<FHUGCConfigDataPermissionModel> *permission;
@end

@interface FHUGCConfigModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCConfigDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER