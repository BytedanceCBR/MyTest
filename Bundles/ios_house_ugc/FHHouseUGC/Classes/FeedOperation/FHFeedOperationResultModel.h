//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHFeedOperationResultDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *stickStyle;
@property (nonatomic, assign) BOOL isStick;
@end

@interface FHFeedOperationResultModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHFeedOperationResultDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
