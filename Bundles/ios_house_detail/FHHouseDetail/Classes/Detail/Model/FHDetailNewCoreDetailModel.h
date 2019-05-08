//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@interface FHDetailNewCoreDetailDataUserStatusModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *courtOpenSubStatus;
@property (nonatomic, copy , nullable) NSString *pricingSubStatus;
@property (nonatomic, copy , nullable) NSString *courtSubStatus;
@end

@protocol FHDetailNewCoreDetailDataPermitListModel<NSObject>
@end

@interface FHDetailNewCoreDetailDataPermitListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *permitDate;
@property (nonatomic, copy , nullable) NSString *bindBuilding;
@property (nonatomic, copy , nullable) NSString *permit;
@end

@protocol FHDetailNewCoreDetailDataDisclaimerRichTextModel<NSObject>
@end

@interface FHDetailNewCoreDetailDataDisclaimerRichTextModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray *highlightRange;
@property (nonatomic, copy , nullable) NSString *linkUrl;
@end

@interface FHDetailNewCoreDetailDataDisclaimerModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewCoreDetailDataDisclaimerRichTextModel> *richText;
@end

@interface FHDetailNewCoreDetailDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *powerWaterGasDesc;
@property (nonatomic, copy , nullable) NSString *decoration;
@property (nonatomic, copy , nullable) NSString *propertyType;
@property (nonatomic, copy , nullable) NSString *propertyName;
@property (nonatomic, strong , nullable) FHDetailNewCoreDetailDataUserStatusModel *userStatus ;  
@property (nonatomic, copy , nullable) NSString *saleAddress;
@property (nonatomic, copy , nullable) NSString *saleStatus;
@property (nonatomic, copy , nullable) NSString *developerName;
@property (nonatomic, copy , nullable) NSString *generalAddress;
@property (nonatomic, copy , nullable) NSString *parkingNum;
@property (nonatomic, copy , nullable) NSString *openDate;
@property (nonatomic, copy , nullable) NSString *plotRatio;
@property (nonatomic, copy , nullable) NSString *buildingDesc;
@property (nonatomic, copy , nullable) NSString *featureDesc;
@property (nonatomic, copy , nullable) NSString *greenRatio;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewCoreDetailDataPermitListModel> *permitList;
@property (nonatomic, copy , nullable) NSString *circuitDesc;
@property (nonatomic, copy , nullable) NSString *heating;
@property (nonatomic, copy , nullable) NSString *propertyRight;
@property (nonatomic, copy , nullable) NSString *buildingType;
@property (nonatomic, copy , nullable) NSString *buildingCategory;
@property (nonatomic, strong , nullable) FHDetailNewCoreDetailDataDisclaimerModel *disclaimer ;  
@property (nonatomic, copy , nullable) NSString *deliveryDate;
@property (nonatomic, copy , nullable) NSString *propertyPrice;
@end

@interface FHDetailNewCoreDetailModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailNewCoreDetailDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER