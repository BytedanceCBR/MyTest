//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHDetailRelatedHouseResponseDataItemsModel<NSObject>
@end

@protocol FHDetailRelatedHouseResponseDataItemsBaseInfoModel<NSObject>
@end

@interface FHDetailRelatedHouseResponseDataItemsBaseInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@interface FHDetailRelatedHouseResponseDataItemsBaseInfoMapModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@end

@protocol FHDetailRelatedHouseResponseDataItemsTagsModel<NSObject>
@end

@interface FHDetailRelatedHouseResponseDataItemsTagsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@protocol FHDetailRelatedHouseResponseDataItemsHouseImageModel<NSObject>
@end

@interface FHDetailRelatedHouseResponseDataItemsHouseImageModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@protocol FHDetailRelatedHouseResponseDataItemsCoreInfoModel<NSObject>
@end

@interface FHDetailRelatedHouseResponseDataItemsCoreInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@interface FHDetailRelatedHouseResponseDataItemsModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedHouseResponseDataItemsBaseInfoModel> *baseInfo;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *cellStyle;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, strong , nullable) FHDetailRelatedHouseResponseDataItemsBaseInfoMapModel *baseInfoMap ;  
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedHouseResponseDataItemsTagsModel> *tags;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedHouseResponseDataItemsHouseImageModel> *houseImage;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedHouseResponseDataItemsCoreInfoModel> *coreInfo;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, copy , nullable) NSString *displaySameNeighborhoodTitle;
@end

@interface FHDetailRelatedHouseResponseDataModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedHouseResponseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHDetailRelatedHouseResponseModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailRelatedHouseResponseDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER