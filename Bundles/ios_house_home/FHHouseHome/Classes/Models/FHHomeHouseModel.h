//
//  FHHomeHouseModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/25.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHomeHouseDataItemsModel<NSObject>

@end


@protocol FHHomeHouseDataItemsCommentListModel<NSObject>

@end


@interface  FHHomeHouseDataItemsCommentListModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *source;
@property (nonatomic, copy , nullable) NSString *createdTime;
@property (nonatomic, copy , nullable) NSString *fromUrl;
@property (nonatomic, copy , nullable) NSString *userName;
@property (nonatomic, copy , nullable) NSString *id;

@end

@interface  FHHomeHouseImageTagModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *idx;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHHomeHouseDataItemsCommentModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
//@property (nonatomic)         typename<Optional>* userStatus;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsCommentListModel> *list;

@end


@interface  FHHomeHouseDataItemsUserStatusModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *CourtOpenSubscribeStatus;
@property (nonatomic, copy , nullable) NSString *pricingSubStauts;
@property (nonatomic, copy , nullable) NSString *courtSubStatus;

@end


@protocol FHHomeHouseDataItemsGlobalPricingListModel<NSObject>

@end


@interface  FHHomeHouseDataItemsGlobalPricingListModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *agencyName;
@property (nonatomic, copy , nullable) NSString *fromUrl;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;

@end


@interface  FHHomeHouseDataItemsGlobalPricingModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
//@property (nonatomic)         typename<Optional>* userStatus;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsGlobalPricingListModel> *list;

@end


@protocol FHHomeHouseDataItemsTimelineListModel<NSObject>

@end


@interface  FHHomeHouseDataItemsTimelineListModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *createdTime;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *desc;

@end


@interface  FHHomeHouseDataItemsTimelineModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
//@property (nonatomic)         typename<Optional>* userStatus;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsTimelineListModel> *list;

@end


@protocol FHHomeHouseDataItemsTagsModel<NSObject>

@end


@interface  FHHomeHouseDataItemsTagsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHHomeHouseDataItemsContactModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *phone;
@property (nonatomic, copy , nullable) NSString *noticeDesc;

@end


@protocol FHHomeHouseDataItemsFloorpanListListModel<NSObject>

@end


@interface  FHHomeHouseDataItemsFloorpanListListSaleStatusModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@protocol FHHomeHouseDataItemsFloorpanListListImagesModel<NSObject>

@end


@interface  FHHomeHouseDataItemsFloorpanListListImagesModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@interface  FHHomeHouseDataItemsFloorpanListListModel  : JSONModel

@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsFloorpanListListSaleStatusModel *saleStatus ;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *squaremeter;
@property (nonatomic, copy , nullable) NSString *roomCount;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsFloorpanListListImagesModel> *images;
@property (nonatomic, copy , nullable) NSString *id;

@end


@interface  FHHomeHouseDataItemsFloorpanListModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
//@property (nonatomic)         typename<Optional>* userStatus;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsFloorpanListListModel> *list;

@end


@interface  FHHomeHouseDataItemsCoreInfoSaleStatusModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHHomeHouseDataItemsCoreInfoModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *courtAddress;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsCoreInfoSaleStatusModel *saleStatus ;
//@property (nonatomic)         typename<Optional>* properyType;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *constructionOpendate;
@property (nonatomic, copy , nullable) NSString *aliasName;
@property (nonatomic, copy , nullable) NSString *gaodeImageUrl;

@end


@protocol FHHomeHouseDataItemsImagesModel<NSObject>

@end


@interface  FHHomeHouseDataItemsImagesModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end

@interface  FHHomeHouseDataItemsModel  : JSONModel

@property (nonatomic, strong , nullable) FHHomeHouseDataItemsCommentModel *comment ;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsUserStatusModel *userStatus ;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, strong , nullable) FHHomeHouseImageTagModel *houseImageTag ;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsGlobalPricingModel *globalPricing ;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsTimelineModel *timeline ;
@property (nonatomic, copy , nullable) NSString *idx;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displaySameneighborhoodTitle;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmValue;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsContactModel *contact ;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsFloorpanListModel *floorpanList ;
@property (nonatomic, copy , nullable) NSString *cellStyle;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsCoreInfoModel *coreInfo ;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsImagesModel> *images;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsImagesModel> *houseImage;

@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *searchId;
//租房相关
@property (nonatomic, copy , nullable) NSString *pricing;


@end


@interface  FHHomeHouseDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@interface  FHHomeHouseModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHomeHouseDataModel *data ;

@end

NS_ASSUME_NONNULL_END
