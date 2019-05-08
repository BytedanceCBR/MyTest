//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHPriceValuationHistoryDataHistoryHouseListModel<NSObject>
@end

@interface FHPriceValuationHistoryDataHistoryHouseListHouseInfoImageInfoIconModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHPriceValuationHistoryDataHistoryHouseListHouseInfoImageInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) FHPriceValuationHistoryDataHistoryHouseListHouseInfoImageInfoIconModel *icon ;  
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@interface FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *builtYear;
@property (nonatomic, copy , nullable) NSString *floor;
@property (nonatomic, copy , nullable) NSString *totalFloor;
@property (nonatomic, copy , nullable) NSString *facingType;
@property (nonatomic, copy , nullable) NSString *squaremeter;
@property (nonatomic, copy , nullable) NSString *buildingType;
@property (nonatomic, copy , nullable) NSString *floorPlanBath;
@property (nonatomic, copy , nullable) NSString *floorPlanHall;
@property (nonatomic, copy , nullable) NSString *decorationType;
@property (nonatomic, copy , nullable) NSString *estimateId;
@property (nonatomic, copy , nullable) NSString *neighborhoodId;
@property (nonatomic, copy , nullable) NSString *floorPlanRoom;
//自己加的字段
@property (nonatomic, copy , nullable) NSString *neighborhoodName;
@end

@interface FHPriceValuationHistoryDataHistoryHouseListHouseInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *estimatePriceInt;
@property (nonatomic, copy , nullable) NSString *stateDescStr;
@property (nonatomic, copy , nullable) NSString *stateInt;
@property (nonatomic, copy , nullable) NSString *neiborhoodNameStr;
@property (nonatomic, copy , nullable) NSString *rateStr;
@property (nonatomic, strong , nullable) FHPriceValuationHistoryDataHistoryHouseListHouseInfoImageInfoModel *imageInfo ;  
@property (nonatomic, copy , nullable) NSString *houseInfoStr;
@property (nonatomic, copy , nullable) NSString *averagePriceStr;
@property (nonatomic, strong , nullable) FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *houseInfoDict ;  
@end

@interface FHPriceValuationHistoryDataHistoryHouseListModel : JSONModel 

@property (nonatomic, strong , nullable) FHPriceValuationHistoryDataHistoryHouseListHouseInfoModel *houseInfo ;  
@end

@interface FHPriceValuationHistoryDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHPriceValuationHistoryDataHistoryHouseListModel> *historyHouseList;
@end

@interface FHPriceValuationHistoryModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHPriceValuationHistoryDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
