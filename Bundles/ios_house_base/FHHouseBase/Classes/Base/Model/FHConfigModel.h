//
//  FHConfigModel.h
//  FHBMain
//
//  Created by 谷春晖 on 2018/11/14.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
#import "FHSearchConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHConfigDataOpData2ItemsModel<NSObject>

@end




@protocol FHConfigDataOpData2ItemsImageModel<NSObject>

@end


@interface  FHConfigDataOpData2ItemsImageModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@interface  FHConfigDataOpData2ItemsModel  : JSONModel

@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *descriptionStr;
@property (nonatomic, copy , nullable) NSString *addDescription;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataOpData2ItemsImageModel> *image;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataOpData2ItemsImageModel> *tagImage;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;

@end


@interface  FHConfigDataOpData2Model  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHConfigDataOpData2ItemsModel> *items;
@property (nonatomic, copy , nullable) NSNumber *opStyle;

@end

@protocol FHConfigDataOpData2ListModel<NSObject>

@end


@interface  FHConfigDataOpData2ListModel  : JSONModel

@property (nonatomic, strong , nullable) FHConfigDataOpData2Model *opDataList;
@property (nonatomic, copy , nullable) NSNumber *opData2Type;

@end


@protocol FHConfigDataOpDataItemsModel<NSObject>

@end



@protocol FHConfigDataOpDataItemsImageModel<NSObject>

@end


@interface  FHConfigDataOpDataItemsImageModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@interface  FHConfigDataOpDataItemsModel  : JSONModel

@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataOpDataItemsImageModel> *image;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;

@end


@interface  FHConfigDataOpDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHConfigDataOpDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *opStyle;
@property (nonatomic, copy , nullable) NSNumber *iconRowNum;

@end


@protocol FHConfigDataRentOpDataItemsModel<NSObject>

@end

@protocol FHConfigDataHouseOpDataItemsModel<NSObject>

@end


@protocol FHConfigDataRentOpDataItemsImageModel<NSObject>

@end


@interface  FHConfigDataRentOpDataItemsImageModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@interface  FHConfigDataRentOpDataItemsModel  : JSONModel

@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *descriptionStr;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataRentOpDataItemsImageModel> *image;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;

@end


@interface  FHConfigDataRentOpDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHConfigDataRentOpDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *opStyle;

@end

@interface  FHConfigDataMainPageBannerOpDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHConfigDataRentOpDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *opStyle;

@end

@interface  FHConfigDataHouseOpDataItemsModel  : JSONModel

@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *descriptionStr;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataRentOpDataItemsImageModel> *image;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;

@end


@interface  FHConfigDataHouseOpDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHConfigDataHouseOpDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *opStyle;

@end


@protocol FHConfigDataEntryInfoModel<NSObject>

@end


@interface  FHConfigDataEntryInfoModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *iconUrl;
@property (nonatomic, copy , nullable) NSString *entryId;
@property (nonatomic, copy , nullable) NSString *name;

@end


@interface  FHConfigDataMapSearchModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *centerLatitude;
@property (nonatomic, copy , nullable) NSString *resizeLevel;
@property (nonatomic, copy , nullable) NSString *centerLongitude;

@end


@protocol FHConfigDataHotCityListModel<NSObject>

@end


@interface  FHConfigDataHotCityListModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *cityId;
@property (nonatomic, copy , nullable) NSString *iconUrl;
@property (nonatomic, copy , nullable) NSString *name;

@end


@protocol FHConfigDataCityListModel<NSObject>

@end


@interface  FHConfigDataCityListModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *cityId;
@property (nonatomic, copy , nullable) NSString *fullPinyin;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *simplePinyin;
@property (nonatomic, assign)   BOOL       enable;

@end




@interface  FHConfigDataReviewInfoModel  : JSONModel

@property (nonatomic, assign) BOOL isFLogin;

@end


@protocol FHConfigDataBannersModel<NSObject>

@end


@interface  FHConfigDataBannersImageModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@interface  FHConfigDataBannersModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) FHConfigDataBannersImageModel *image ;
@property (nonatomic, copy , nullable) NSString *id;

@end

@protocol FHConfigDataCityStatsModel<NSObject>

@end


@interface  FHConfigDataCityStatsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *mapOpenUrl;
@property (nonatomic, copy , nullable) NSString *addedNumToday;
@property (nonatomic, copy , nullable) NSString *cityDetailDesc;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *addedNumTodayUnit;
@property (nonatomic, copy , nullable) NSString *addedNumTodayDesc;
@property (nonatomic, copy , nullable) NSString *cityPriceHint;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmDesc;
@property (nonatomic, copy , nullable) NSString *cityName;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *monthUp;
@property (nonatomic, copy , nullable) NSString *cityTitleDesc;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmUnit;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@end

@interface  FHConfigDataAvailabilityModel  : JSONModel

@property (nonatomic, copy , nullable) NSNumber *enable;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) FHConfigDataOpDataItemsImageModel *iconImage;

@end

@interface  FHConfigDataCitySwitchModel  : JSONModel

@property (nonatomic, copy , nullable) NSNumber *enable;
@property (nonatomic, copy , nullable) NSString *cityName;
@property (nonatomic, copy , nullable) NSString *openUrl;

@end


@protocol FHConfigDataRentBannerItemsModel<NSObject>
@end

@protocol FHConfigDataRentBannerItemsImageModel<NSObject>
@end

@interface FHConfigDataRentBannerItemsImageModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHConfigDataRentBannerItemsModel : JSONModel

@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataRentBannerItemsImageModel> *image;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@end

@interface FHConfigDataRentBannerModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHConfigDataRentBannerItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *opStyle;
@end


@interface FHConfigDataEntranceSwitchModel : JSONModel

@property (nonatomic, assign) BOOL isPriceValuationShowHouseTrend;
@end

@protocol FHConfigDataTabConfigModel<NSObject>
@end

@interface FHConfigDataTabConfigModel : JSONModel

@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *key;
@end

@protocol FHConfigCenterTabImageModel<NSObject>
@end

@interface FHConfigCenterTabImageModel : JSONModel

@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, copy , nullable) NSString *height;
@end

@protocol FHConfigCenterTabModel<NSObject>
@end

@interface FHConfigCenterTabModel : JSONModel

@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, strong , nullable) FHConfigCenterTabImageModel *staticImage ;
@property (nonatomic, strong , nullable) FHConfigCenterTabImageModel *activationimage ;
@end

@interface FHConfigDataUgcCategoryConfigModel : JSONModel

@property (nonatomic, copy , nullable) NSString *myJoinList;
@property (nonatomic, copy , nullable) NSString *nearbyList;
@end


@protocol FHRealtorEvaluatioinTagModel<NSObject>

@end

@interface FHRealtorEvaluatioinTagModel : JSONModel

@property (nonatomic, strong , nullable) NSNumber *id;
@property (nonatomic, copy , nullable) NSString *text;

@end

@protocol FHRealtorEvaluatioinConfigModel<NSObject>

@end
@interface FHRealtorEvaluatioinConfigModel : JSONModel

@property (nonatomic, strong , nullable) NSArray *scoreTags;
@property (nonatomic, strong , nullable) NSArray<FHRealtorEvaluatioinTagModel> *goodTags;
@property (nonatomic, strong , nullable) NSArray<FHRealtorEvaluatioinTagModel> *badTags;
@property (nonatomic, copy , nullable) NSString *goodPlaceholder;
@property (nonatomic, copy , nullable) NSString *badPlaceholder;

@end

@interface  FHConfigDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray *houseTypeList;
@property (nonatomic, strong , nullable) FHConfigDataOpData2Model *opData2 ;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataOpData2ListModel> *opData2list;
@property (nonatomic, strong , nullable) FHConfigDataOpData2Model *toolboxData;

//@property (nonatomic, strong , nullable) FHSearchConfigModel *filter ;
@property (nonatomic, strong , nullable) FHConfigDataOpDataModel *opData ;
@property (nonatomic, strong , nullable) FHConfigDataOpDataModel *houseOpData2 ;
@property (nonatomic, strong , nullable) FHConfigDataRentOpDataModel *rentOpData ;
@property (nonatomic, strong , nullable) FHConfigDataMainPageBannerOpDataModel *mainPageBannerOpData ;
@property (nonatomic, strong , nullable) FHConfigDataMainPageBannerOpDataModel *houseListBanner ;
@property (nonatomic, strong , nullable) FHConfigDataOpData2Model *houseOpData ;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataEntryInfoModel> *entryInfo;
@property (nonatomic, copy , nullable) NSString *currentCityId;
@property (nonatomic, strong , nullable) FHConfigDataMapSearchModel *mapSearch ;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataHotCityListModel> *hotCityList;
@property (nonatomic, copy , nullable) NSString *currentCityName;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataCityListModel> *cityList;
@property (nonatomic, strong , nullable) FHConfigDataReviewInfoModel *reviewInfo ;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataBannersModel> *banners;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataCityStatsModel> *cityStats;
@property (nonatomic, copy , nullable) NSString *userPhone;
@property (nonatomic, strong, nullable) FHConfigDataAvailabilityModel *cityAvailability;
@property (nonatomic, strong, nullable) FHConfigDataCitySwitchModel *citySwitch;
@property (nonatomic, strong , nullable) FHConfigDataEntranceSwitchModel *entranceSwitch ;
@property (nonatomic, copy , nullable) NSNumber *houseTypeDefault;

@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *searchTabNeighborhoodFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *rentFilterOrder;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *searchTabCourtFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *neighborhoodFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *searchTabRentFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *filter;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *searchTabFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *courtFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *houseFilterOrder;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *rentFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *neighborhoodFilterOrder;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *saleHistoryFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchFilterConfigItem> *courtFilterOrder;
@property (nonatomic, strong , nullable) FHConfigDataRentBannerModel *rentBanner ;
@property (nonatomic, strong , nullable) NSString *jump2AdRecommend;
@property (nonatomic, assign) BOOL ugcCitySwitch;
@property (nonatomic, strong , nullable) NSString *diffCode;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataTabConfigModel> *tabConfig;
@property (nonatomic, strong , nullable) FHConfigDataUgcCategoryConfigModel *ugcCategoryConfig ;
@property (nonatomic, strong , nullable) FHConfigCenterTabModel *opTab ;
@property (nonatomic, strong , nullable) FHRealtorEvaluatioinConfigModel *realtorEvaluationConfig ;
@property (nonatomic, copy , nullable) NSString *jumpPageOnStartup;

@property (nonatomic, strong , nullable) NSDictionary *originDict;

-(instancetype)initShadowWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err;

@end


@interface  FHConfigModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHConfigDataModel *data ;

@end

NS_ASSUME_NONNULL_END
