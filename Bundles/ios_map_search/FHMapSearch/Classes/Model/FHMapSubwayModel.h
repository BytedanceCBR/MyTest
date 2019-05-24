//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHMapSubwayDataOptionModel<NSObject>
@end

@protocol FHMapSubwayDataOptionOptionsModel<NSObject>
@end

@interface FHMapSubwayDataOptionOptionsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *isNoLimit;
@property (nonatomic, copy , nullable) NSString *value;
@end

@interface FHMapSubwayDataOptionModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHMapSubwayDataOptionOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *value;
@end

@interface FHMapSubwayDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHMapSubwayDataOptionModel> *option;
@end

@interface FHMapSubwayModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHMapSubwayDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER