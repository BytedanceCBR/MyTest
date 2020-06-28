//
//  FHHomeHouseModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/25.
//

#import "JSONModel.h"
#import <FHHouseBase/FHImageModel.h>
#import <FHHouseBase/FHHouseCoreInfoModel.h>
#import <FHHouseBase/FHHouseBaseInfoModel.h>
#import "FHHouseTagsModel.h"
#import "FHRentFacilitiesModel.h"
#import "FHSearchHouseModel.h"

@class FHHouseItemHouseVideo;

NS_ASSUME_NONNULL_BEGIN

@protocol FHHomeHouseDataItemsModel<NSObject>

@end

@interface FHHomeHouseDataItemsTitleTagModel : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
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


//@protocol FHHomeHouseDataItemsTagsModel<NSObject>
//
//@end
//
//
//@interface  FHHomeHouseDataItemsTagsModel  : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *content;
//@property (nonatomic, copy , nullable) NSString *backgroundColor;
//@property (nonatomic, copy , nullable) NSString *id;
//@property (nonatomic, copy , nullable) NSString *textColor;
//
//@end


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

@interface FHHomeHouseAdvantageTagModel : JSONModel

@property (nonatomic, strong , nullable) FHHomeHouseDataItemsFloorpanListListImagesModel *icon;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *borderColor;

@end


@protocol FHHomeHouseDataItemsDislikeInfoModel<NSObject>
@end

@interface FHHomeHouseDataItemsDislikeInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray *mutualExclusiveIds;
@property (nonatomic, copy , nullable) NSString *id;
@end


@interface FHHomeHouseVRModel : JSONModel

@property (nonatomic, assign) BOOL hasVr;

@end

//@protocol FHHomeHouseDataItemsImagesModel<NSObject>
//
//@end
//
//
//@interface  FHHomeHouseDataItemsImagesModel  : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *url;
//@property (nonatomic, copy , nullable) NSString *width;
//@property (nonatomic, strong , nullable) NSArray *urlList;
//@property (nonatomic, copy , nullable) NSString *uri;
//@property (nonatomic, copy , nullable) NSString *height;
//
//@end

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
@property (nonatomic, copy , nullable) NSString *buildingSquareMeter;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displaySameneighborhoodTitle;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@property (nonatomic, copy , nullable) NSString *originPrice;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmValue;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsContactModel *contact ;
@property (nonatomic, strong , nullable) FHHomeHouseAdvantageTagModel *advantageDescription ;
@property (nonatomic, strong , nullable) FHHomeHouseVRModel *vrInfo ;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsFloorpanListModel *floorpanList ;
@property (nonatomic, copy , nullable) NSString *cellStyle;
@property (nonatomic, copy , nullable) NSString *cardType;
@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *coreInfoList;
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsCoreInfoModel *coreInfo ;
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *tagImage;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *houseImage;
@property (nonatomic, copy , nullable) NSString *displayPriceColor;
@property (nonatomic, strong, nullable) NSMutableAttributedString *tagString;
@property (nonatomic, strong , nullable) FHDetailContactModel *contactModel ;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;


@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong, nullable)   FHHouseItemHouseVideo*   houseVideo;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *searchId;
//租房相关
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *pricingNum;
@property (nonatomic, copy , nullable) NSString *pricingUnit;
@property (nonatomic, copy , nullable) NSString *pricePerSqmNum;
@property (nonatomic, copy , nullable) NSString *pricePerSqmUnit;
@property (nonatomic, strong , nullable) NSArray<FHRentFacilitiesModel> *facilities;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsDislikeInfoModel> *dislikeInfo;
//标签
@property (nonatomic, strong , nullable) FHHomeHouseDataItemsTitleTagModel *titleTag ;
//埋点使用
@property (nonatomic, strong , nullable) NSDictionary *tracerDict;
@property (nonatomic, copy , nullable) NSString *bizTrace;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *reasonTags;
@property (nonatomic, copy , nullable) NSString *addrData;

@end


@interface  FHHomeHouseDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHHomeHouseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSNumber *triggerTime;

@end


@interface  FHHomeHouseModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHomeHouseDataModel *data ;

@end

NS_ASSUME_NONNULL_END
