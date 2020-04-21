//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHUGCCategoryDataDataModel<NSObject>
@end

@interface FHUGCCategoryDataDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *category;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *iconUrl;
@property (nonatomic, copy , nullable) NSString *concernId;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, copy , nullable) NSString *defaultAdd;
@property (nonatomic, copy , nullable) NSString *recommendScore;
@property (nonatomic, copy , nullable) NSString *channelId;
@property (nonatomic, copy , nullable) NSString *webUrl;
@property (nonatomic, copy , nullable) NSString *flags;
@property (nonatomic, copy , nullable) NSString *feedListStyle;
@property (nonatomic, copy , nullable) NSString *tipNew;
@property (nonatomic, copy , nullable) NSString *iconUrl2;
@property (nonatomic, copy , nullable) NSString *imageUrl;
@property (nonatomic, copy , nullable) NSString *hidden;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *placeholdColor;
@property (nonatomic, copy , nullable) NSString *parentChannelId;
@end

@interface FHUGCCategoryDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *version;
@property (nonatomic, strong , nullable) NSArray<FHUGCCategoryDataDataModel> *data;
@end

@interface FHUGCCategoryModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCCategoryDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
