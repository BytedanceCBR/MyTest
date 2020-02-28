//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHSuggestionListModelDataItemsModel<NSObject>
@end

@protocol FHSuggestionListModelDataItemsBaseInfoModel<NSObject>
@end

@interface FHSuggestionListModelDataItemsBaseInfoModel : JSONModel 

@property (nonatomic, assign) BOOL isSingle;
@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@interface FHSuggestionListModelDataItemsNeighborhoodInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *areaId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *gaodeImageUrl;
@property (nonatomic, copy , nullable) NSString *cityId;
@property (nonatomic)         typename<Optional>* neighborhoodImages;
@property (nonatomic, copy , nullable) NSString *areaName;
@property (nonatomic, copy , nullable) NSString *districtId;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmV;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *locationFullName;
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, copy , nullable) NSString *districtName;
@property (nonatomic, copy , nullable) NSString *monthUp;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *id;
@end

@protocol FHSuggestionListModelDataItemsImagesModel<NSObject>
@end

@interface FHSuggestionListModelDataItemsImagesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *imageType;
@end

@interface FHSuggestionListModelDataItemsBaseInfoMapModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *builtYear;
@end

@interface FHSuggestionListModelDataItemsHouseVideoModel : JSONModel 

@property (nonatomic, assign) BOOL hasVideo;
@end

@interface FHSuggestionListModelDataItemsModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *pricePerSqmUnit;
@property (nonatomic, strong , nullable) NSArray<FHSuggestionListModelDataItemsBaseInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHSuggestionListModelDataItemsNeighborhoodInfoModel *neighborhoodInfo ;  
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, strong , nullable) NSArray<FHSuggestionListModelDataItemsImagesModel> *images;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *pricePerSqmNum;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displayStatsInfo;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *cellStyle;
@property (nonatomic, strong , nullable) FHSuggestionListModelDataItemsBaseInfoMapModel *baseInfoMap ;  
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) FHSuggestionListModelDataItemsHouseVideoModel *houseVideo ;  
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@property (nonatomic, copy , nullable) NSString *cardType;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@end

@interface FHSuggestionListModelDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *searchHistoryOpenUrl;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHSuggestionListModelDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSString *offset;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHSuggestionListModelModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSuggestionListModelDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER