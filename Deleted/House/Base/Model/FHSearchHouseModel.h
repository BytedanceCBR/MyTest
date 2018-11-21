//
//  FHSearchHouseModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHSearchHouseDataItemsModel<NSObject>

@end


@interface  FHSearchHouseDataItemsLogPbModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *aNewTag;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@protocol FHSearchHouseDataItemsBaseInfoModel<NSObject>

@end


@interface  FHSearchHouseDataItemsBaseInfoModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchHouseDataItemsNeighborhoodInfoLogPbModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@protocol FHSearchHouseDataItemsNeighborhoodInfoImagesModel<NSObject>

@end


@interface  FHSearchHouseDataItemsNeighborhoodInfoImagesModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@interface  FHSearchHouseDataItemsNeighborhoodInfoBaseInfoMapModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *builtYear;

@end


@interface  FHSearchHouseDataItemsNeighborhoodInfoModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsNeighborhoodInfoLogPbModel *logPb ;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displayStatsInfo;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsNeighborhoodInfoImagesModel> *images;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsNeighborhoodInfoBaseInfoMapModel *baseInfoMap ;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;

@end


@interface  FHSearchHouseDataItemsBaseInfoMapModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *builtYear;

@end


@protocol FHSearchHouseDataItemsCoreInfoModel<NSObject>

@end


@interface  FHSearchHouseDataItemsCoreInfoModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;

@end


@protocol FHSearchHouseDataItemsTagsModel<NSObject>

@end


@interface  FHSearchHouseDataItemsTagsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@protocol FHSearchHouseDataItemsHouseImageModel<NSObject>

@end


@interface  FHSearchHouseDataItemsHouseImageModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@protocol FHSearchHouseDataItemsRecommendReasonsModel<NSObject>

@end


@interface  FHSearchHouseDataItemsRecommendReasonsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *iconTextColor;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundAlpha;
@property (nonatomic, copy , nullable) NSString *textAlpha;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *iconText;
@property (nonatomic, copy , nullable) NSString *iconTextAlpha;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *iconBackgroundAlpha;
@property (nonatomic, copy , nullable) NSString *iconBackgroundColor;

@end


@interface  FHSearchHouseDataItemsHouseImageTagModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHSearchHouseDataItemsModel  : JSONModel

@property (nonatomic, strong , nullable) FHSearchHouseDataItemsLogPbModel *logPb ;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsBaseInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *hid;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *cellStyle;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsBaseInfoMapModel *baseInfoMap ;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsCoreInfoModel> *coreInfo;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsTagsModel> *tags;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsHouseImageModel> *houseImage;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsRecommendReasonsModel> *recommendReasons;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, copy , nullable) NSString *displaySameNeighborhoodTitle;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsHouseImageTagModel *houseImageTag ;

@end


@interface  FHSearchHouseDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@interface  FHSearchHouseModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSearchHouseDataModel *data ;

@end

NS_ASSUME_NONNULL_END