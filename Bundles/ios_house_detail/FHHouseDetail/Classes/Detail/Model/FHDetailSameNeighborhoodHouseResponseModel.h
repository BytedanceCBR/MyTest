//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHSearchHouseModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHDetailSameNeighborhoodHouseResponseDataItemsModel<NSObject>
@end

@protocol FHDetailSameNeighborhoodHouseResponseDataItemsBaseInfoModel<NSObject>
@end

@interface FHDetailSameNeighborhoodHouseResponseDataItemsBaseInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@interface FHDetailSameNeighborhoodHouseResponseDataItemsBaseInfoMapModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@end

@protocol FHDetailSameNeighborhoodHouseResponseDataItemsTagsModel<NSObject>
@end

@interface FHDetailSameNeighborhoodHouseResponseDataItemsTagsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@protocol FHDetailSameNeighborhoodHouseResponseDataItemsHouseImageModel<NSObject>
@end

@interface FHDetailSameNeighborhoodHouseResponseDataItemsHouseImageModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@protocol FHDetailSameNeighborhoodHouseResponseDataItemsCoreInfoModel<NSObject>
@end

@interface FHDetailSameNeighborhoodHouseResponseDataItemsCoreInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@interface FHDetailSameNeighborhoodHouseResponseDataItemsModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong , nullable) NSArray<FHDetailSameNeighborhoodHouseResponseDataItemsBaseInfoModel> *baseInfo;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *cellStyle;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataItemsBaseInfoMapModel *baseInfoMap ;  
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHDetailSameNeighborhoodHouseResponseDataItemsTagsModel> *tags;
@property (nonatomic, strong , nullable) NSArray<FHDetailSameNeighborhoodHouseResponseDataItemsHouseImageModel> *houseImage;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHDetailSameNeighborhoodHouseResponseDataItemsCoreInfoModel> *coreInfo;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, copy , nullable) NSString *displaySameNeighborhoodTitle;
@end

@interface FHDetailSameNeighborhoodHouseResponseDataModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHDetailSameNeighborhoodHouseResponseModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
