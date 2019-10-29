//
//  FHSearchHouseModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/26.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>
#import "FHBaseModelProtocol.h"
#import "FHHouseListModel.h"
#import "FHSugSubscribeModel.h"
#import "FHImageModel.h"
#import "FHHouseCoreInfoModel.h"
#import "FHHouseBaseInfoModel.h"

NS_ASSUME_NONNULL_BEGIN


@class FHHouseNeighborAgencyModel;
@class FHDetailContactModel;

@protocol FHSearchHouseDataItemsModel<NSObject>

@end


//@protocol FHSearchHouseDataItemsBaseInfoModel<NSObject>
//
//@end

@protocol FHSearchHouseDataItemsModelBottomText <NSObject>

@end

//@interface  FHSearchHouseDataItemsBaseInfoModel  : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *attr;
//@property (nonatomic, copy , nullable) NSString *value;
//
//@end

//@protocol FHSearchHouseDataItemsNeighborhoodInfoImagesModel<NSObject>
//
//@end
//
//
//@interface  FHSearchHouseDataItemsNeighborhoodInfoImagesModel  : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *url;
//@property (nonatomic, copy , nullable) NSString *width;
//@property (nonatomic, strong , nullable) NSArray *urlList;
//@property (nonatomic, copy , nullable) NSString *uri;
//@property (nonatomic, copy , nullable) NSString *height;
//
//@end


@interface  FHSearchHouseDataItemsNeighborhoodInfoBaseInfoMapModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *builtYear;

@end


@interface  FHSearchHouseDataItemsNeighborhoodInfoModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
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
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
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


//@protocol FHSearchHouseDataItemsCoreInfoModel<NSObject>
//
//@end
//
//
//@interface  FHSearchHouseDataItemsCoreInfoModel  : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *attr;
//@property (nonatomic, copy , nullable) NSString *value;
//
//@end

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

@interface FHSearchHouseDataItemsModelBottomText : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *color;

@end

@interface FHSearchHouseDataItemsFakeReasonModel : JSONModel

@property (nonatomic, copy , nullable) FHImageModel *fakeReasonImage;

@end

@interface FHHouseItemHouseVideo : JSONModel

@property (nonatomic, assign)   BOOL   hasVideo;

@end

@interface FHHouseItemHouseExternalModel : JSONModel

@property (nonatomic, copy , nullable) NSString *externalName;
@property (nonatomic, copy , nullable) NSString *externalUrl;
@property (nonatomic, copy , nullable) NSString *backUrl;
@property (nonatomic, copy , nullable) NSString *isExternalSite;

@end

@interface FHSearchHouseDataItemsSkyEyeTagModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@interface FHSearchHouseVRModel : JSONModel

@property (nonatomic, assign) BOOL hasVr;

@end

@interface  FHSearchHouseDataItemsModel  : JSONModel

@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong, nullable)   FHHouseItemHouseVideo*   houseVideo;
@property (nonatomic, copy , nullable) NSString *hid;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *cellStyle;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, strong, nullable) FHHouseItemHouseExternalModel *externalInfo;
@property (nonatomic, strong, nullable) FHSearchHouseVRModel *vrInfo;
@property (nonatomic, copy , nullable) FHSearchHouseDataItemsFakeReasonModel *fakeReason;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsBaseInfoMapModel *baseInfoMap ;
@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *coreInfo;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *houseImage;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsRecommendReasonsModel> *recommendReasons;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, copy , nullable) NSString *displaySameNeighborhoodTitle;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsHouseImageTagModel *houseImageTag ;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsHouseImageTagModel *houseTitleTag ;
@property (nonatomic, copy , nullable) NSString *originPrice;
@property (nonatomic, strong) NSArray* bottomText;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsSkyEyeTagModel *skyEyeTag ;

@end

@protocol FHRecommendSecondhandHouseTitleModel<NSObject>

@end

@interface FHRecommendSecondhandHouseDataModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) FHImageModel *banner;
@property (nonatomic, copy , nullable) NSString *recommendTitle;
@property (nonatomic, copy , nullable) NSString *searchHint;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSInteger offset;

@end

@interface  FHRecommendSecondhandHouseModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHRecommendSecondhandHouseDataModel *data ;

@end


@protocol FHSearchRealHouseExtModel<NSObject>

@end

@interface FHSearchRealHouseExtModel : JSONModel

@property (nonatomic, copy , nullable) NSString *fakeText;
@property (nonatomic, copy , nullable) NSString *fakeHouse;
@property (nonatomic, copy , nullable) NSString *fakeTitle;
@property (nonatomic, copy , nullable) NSString *enableFakeHouse;
@property (nonatomic, copy , nullable) NSString *fakeHouseTotal;
@property (nonatomic, copy , nullable) NSString *houseTotal;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *trueHouseTotal;
@property (nonatomic, copy , nullable) NSString *trueTitle;
@property (nonatomic, copy , nullable) NSString *totalTitle;

@end

@protocol FHSearchRealHouseAgencyInfo <NSObject>

@end

@interface FHSearchRealHouseAgencyInfo : JSONModel

@property (nonatomic, copy , nullable) NSString *agencyTotal;
@property (nonatomic, copy , nullable) NSString *houseTotal;
@property (nonatomic, copy , nullable) NSString *openUrl;

@end


@interface  FHSearchHouseDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *mapFindHouseOpenUrl;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *topTip;
@property (nonatomic, copy , nullable) NSString *bottomTip;
@property (nonatomic, copy , nullable) FHImageModel *banner;
@property (nonatomic, strong , nullable) FHSearchRealHouseExtModel *externalSite;
@property (nonatomic, strong , nullable) FHSearchRealHouseAgencyInfo *agencyInfo;
@property (nonatomic, strong , nullable) FHSearchHouseDataRedirectTipsModel *redirectTips;
@property (nonatomic, strong, nullable) FHRecommendSecondhandHouseDataModel *recommendSearchModel;
@property (nonatomic, strong, nullable) FHSugSubscribeDataDataSubscribeInfoModel *subscribeInfo;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong , nullable) FHHouseNeighborAgencyModel *neighborhoodRealtorCard;


@end


@interface  FHSearchHouseModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSearchHouseDataModel *data ;

@end

@interface FHSearchHouseDataItemsModel (RecommendReason)

-(BOOL)showRecommendReason;

@end


@interface FHHouseNeighborAgencyModel : JSONModel

@property (nonatomic, copy , nullable) NSString *neighborhoodName;
@property (nonatomic, copy , nullable) NSString *neighborhoodPrice;
@property (nonatomic, copy , nullable) NSString *displayStatusInfo;
@property (nonatomic, strong , nullable) FHDetailContactModel *contactModel ;


@end

NS_ASSUME_NONNULL_END
