//
//  FHConfigModel.h
//  FHBMain
//
//  Created by 谷春晖 on 2018/11/14.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

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
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHConfigDataOpData2ItemsImageModel> *image;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;

@end


@interface  FHConfigDataOpData2Model  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHConfigDataOpData2ItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *opStyle;

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

@end


@protocol FHConfigDataRentOpDataItemsModel<NSObject>

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
@property (nonatomic, copy , nullable) NSString *description;
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

@end

@interface  FHConfigDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray *houseTypeList;
@property (nonatomic, strong , nullable) FHConfigDataOpData2Model *opData2 ;
@property (nonatomic, strong , nullable) FHConfigDataOpDataModel *opData ;
@property (nonatomic, strong , nullable) FHConfigDataRentOpDataModel *rentOpData ;
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

@end


@interface  FHConfigModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHConfigDataModel *data ;

@end

NS_ASSUME_NONNULL_END
