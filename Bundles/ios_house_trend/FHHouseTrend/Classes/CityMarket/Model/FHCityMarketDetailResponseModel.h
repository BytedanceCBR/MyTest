//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHBaseModelProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHCityMarketDetailResponseDataSpecialOldHouseListModel<NSObject>
@end

@interface FHCityMarketDetailResponseDataSpecialOldHouseListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *moreBtnText;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *questionText;
@property (nonatomic, copy , nullable) NSString *answerText;
@property (nonatomic, copy , nullable) NSString *title;
@end

@protocol FHCityMarketDetailResponseDataMarketTrendListModel<NSObject>
@end

@protocol FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel<NSObject>
@end

@protocol FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListValuesModel<NSObject>
@end

@interface FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListValuesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *timeStamp;
@property (nonatomic, copy , nullable) NSString *marketValue;
@property (nonatomic, copy , nullable) NSString *year;
@property (nonatomic, copy , nullable) NSString *soldValue;
@property (nonatomic, copy , nullable) NSString *month;
@end

@interface FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *color;
@property (nonatomic, copy , nullable) NSString *locationId;
@property (nonatomic, copy , nullable) NSString *locationName;
@property (nonatomic, copy , nullable) NSString *locationType;
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListValuesModel> *values;
@end

@interface FHCityMarketDetailResponseDataMarketTrendListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *updateTime;
@property (nonatomic, copy , nullable) NSString *dataSource;
@property (nonatomic, copy , nullable) NSString *onSaleValueDesc;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel> *districtMarketInfoList;
@property (nonatomic, copy , nullable) NSString *soldValueDesc;
@end

@protocol FHCityMarketDetailResponseDataSummaryItemListModel<NSObject>
@end

@interface FHCityMarketDetailResponseDataSummaryItemListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *value;
@property (nonatomic, copy , nullable) NSNumber *showArrow;
@end

@protocol FHCityMarketDetailResponseDataHotListModel<NSObject>
@end

@protocol FHCityMarketDetailResponseDataHotListItemsModel<NSObject>
@end

@interface FHCityMarketDetailResponseDataHotListItemsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *averagePrice;
@property (nonatomic, copy , nullable) NSString *neighborhoodName;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *houseCount;
@end

@interface FHCityMarketDetailResponseDataHotListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *itemType;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *moreBtnText;
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataHotListItemsModel> *items;
@end

@interface FHCityMarketDetailResponseDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *pricePerSqmUnit;
@property (nonatomic, copy , nullable) NSString *dataSource;
@property (nonatomic, strong , nullable) NSArray *districtNameList;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataSpecialOldHouseListModel> *specialOldHouseList;
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataMarketTrendListModel> *marketTrendList;
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataSummaryItemListModel> *summaryItemList;
@property (nonatomic, copy , nullable) NSString *pricePerSqm;
@property (nonatomic, strong , nullable) NSArray<FHCityMarketDetailResponseDataHotListModel> *hotList;
@end

@interface FHCityMarketDetailResponseModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHCityMarketDetailResponseDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
