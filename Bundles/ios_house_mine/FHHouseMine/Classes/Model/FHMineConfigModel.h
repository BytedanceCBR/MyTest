//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHMineConfigDataIconOpDataModel<NSObject>
@end

@protocol FHMineConfigDataIconOpDataMyIconItemsModel<NSObject>
@end

@protocol FHMineConfigDataIconOpDataMyIconItemsImageModel<NSObject>
@end

@interface FHMineConfigDataIconOpDataMyIconItemsImageModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHMineConfigDataIconOpDataMyIconItemsModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong , nullable) NSDictionary *reportParams;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHMineConfigDataIconOpDataMyIconItemsImageModel> *image;
@property (nonatomic, copy , nullable) NSString *tagImage;
@property (nonatomic, copy , nullable) NSString *addDescription;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@end

@interface FHMineConfigDataIconOpDataMyIconModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHMineConfigDataIconOpDataMyIconItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *iconRowNum;
@property (nonatomic, copy , nullable) NSString *opStyle;
@end

@interface FHMineConfigDataIconOpDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *myIconId;
@property (nonatomic, strong , nullable) FHMineConfigDataIconOpDataMyIconModel *myIcon ;  
@property (nonatomic, copy , nullable) NSString *title;
@end

@interface FHMineConfigDataHomePageModel : JSONModel

@property (nonatomic, assign) BOOL showHomePage;
@property (nonatomic, copy , nullable) NSString *homePageContent;
@property (nonatomic, copy , nullable) NSString *schema;
@end

@interface FHMineConfigDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHMineConfigDataIconOpDataModel> *iconOpData;
@property (nonatomic, strong , nullable) FHMineConfigDataHomePageModel *homePage ;
@end

@interface FHMineConfigModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHMineConfigDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
