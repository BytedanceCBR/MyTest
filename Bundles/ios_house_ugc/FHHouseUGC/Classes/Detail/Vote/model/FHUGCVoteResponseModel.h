//GENERATED CODE , DON'T EDIT
#import "FHBaseModelProtocol.h"
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHUGCVoteResponseDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray *optionIds;
@end

@interface FHUGCVoteResponseModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCVoteResponseDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
