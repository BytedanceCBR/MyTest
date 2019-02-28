//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHDetailRelatedNeighborhoodResponseDataItemsModel<NSObject>
@end

@protocol FHDetailRelatedNeighborhoodResponseDataItemsImagesModel<NSObject>
@end

@interface FHDetailRelatedNeighborhoodResponseDataItemsImagesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHDetailRelatedNeighborhoodResponseDataItemsBaseInfoMapModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *builtYear;
@end

@interface FHDetailRelatedNeighborhoodResponseDataItemsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedNeighborhoodResponseDataItemsImagesModel> *images;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *displayStatsInfo;
@property (nonatomic, strong , nullable) FHDetailRelatedNeighborhoodResponseDataItemsBaseInfoMapModel *baseInfoMap ;  
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@end

@interface FHDetailRelatedNeighborhoodResponseDataModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedNeighborhoodResponseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHDetailRelatedNeighborhoodResponseModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailRelatedNeighborhoodResponseDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
