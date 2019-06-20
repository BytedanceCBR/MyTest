//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHUGCScialGroupModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHUGCDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHUGCScialGroupDataModel> *userFollowSocialGroups;
@end

@interface FHUGCModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
