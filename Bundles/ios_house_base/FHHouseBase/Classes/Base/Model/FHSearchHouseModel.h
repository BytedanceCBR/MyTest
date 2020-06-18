//
//  FHSearchHouseModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/26.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
#import "FHHouseListModel.h"
#import "FHSugSubscribeModel.h"
#import "FHImageModel.h"
#import "FHHouseCoreInfoModel.h"
#import "FHHouseBaseInfoModel.h"
#import "FHNewHouseItemModel.h"
#import "FHRentFacilitiesModel.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN


@class FHHouseNeighborAgencyModel;
@class FHDetailContactModel,FHClueAssociateInfoModel;
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

@interface FHHouseListHouseAdvantageTagModel : JSONModel

@property (nonatomic, strong , nullable) FHImageModel *icon;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *borderColor;


@end


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




@interface  FHSearchHouseDataItemsModel  : FHSearchBaseItemModel

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

@property (nonatomic, assign) BOOL isRecommendCell;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@property (nonatomic, strong, nullable) NSArray<FHImageModel> *tagImage;  //企业担保图标

@end

@protocol FHRecommendSecondhandHouseTitleModel<NSObject>

@end

//@interface FHRecommendSecondhandHouseDataModel : FHSearchBaseItemModel
//
//@property (nonatomic, strong , nullable) NSArray<NSDictionary *> *items;
//@property (nonatomic, copy , nullable) NSString *total;
//@property (nonatomic, copy , nullable) NSString *searchId;
//@property (nonatomic, copy , nullable) FHImageModel *banner;
//@property (nonatomic, copy , nullable) NSString *recommendTitle;
//@property (nonatomic, copy , nullable) NSString *searchHint;
//@property (nonatomic, assign) BOOL hasMore;
//@property (nonatomic, assign) NSInteger offset;
//
//@end
//
//@interface  FHRecommendSecondhandHouseModel  : JSONModel<FHBaseModelProtocol>
//
//@property (nonatomic, copy , nullable) NSString *status;
//@property (nonatomic, copy , nullable) NSString *message;
//@property (nonatomic, strong , nullable) FHRecommendSecondhandHouseDataModel *data ;
//
//@end


//@protocol FHSearchRealHouseExtModel<NSObject>
//
//@end

@interface FHSearchRealHouseExtModel : FHSearchBaseItemModel

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

@interface FHSearchRealHouseAgencyInfo : FHSearchBaseItemModel

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
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong , nullable) FHSearchHouseDataRedirectTipsModel *redirectTips;
@property (nonatomic, strong, nullable) FHSearchHouseDataModel *recommendSearchModel;

@end


@interface  FHSearchHouseModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSearchHouseDataModel *data ;

@end


@interface FHSearchHouseDataItemsModel (RecommendReason)

-(BOOL)showRecommendReason;

@end

@interface FHHouseNeighborAgencyModel : FHSearchBaseItemModel

@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *neighborhoodName;
@property (nonatomic, copy , nullable) NSString *neighborhoodPrice;
@property (nonatomic, copy , nullable) NSString *displayStatusInfo;
@property (nonatomic, copy , nullable) NSString *realtorType;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong , nullable) FHDetailContactModel *contactModel ;
@property (nonatomic, copy , nullable) NSString *districtAreaName;

@property (nonatomic, strong , nullable) NSDictionary *tracerDict;
@property(nonatomic, weak) UIViewController *belongsVC;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@end

@interface FHHouseReserveAdviserModel : FHSearchBaseItemModel

@property (nonatomic, copy , nullable) NSString *tipText;
@property (nonatomic, copy , nullable) NSString *realtorType;
@property (nonatomic, copy , nullable) NSString *targetId;
@property (nonatomic, copy , nullable) NSString *targetName;
@property (nonatomic, copy , nullable) NSString *districtAreaName;
@property (nonatomic, copy , nullable) NSString *areaPrice;
@property (nonatomic, copy , nullable) NSString *displayStatusInfo;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@property (nonatomic, strong , nullable) NSDictionary *tracerDict;
@property(nonatomic, weak) UIViewController *belongsVC;
@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *subscribeCache;
@property(nonatomic, assign) BOOL isSubcribed;

@end

@interface  FHSearchHouseItemModel  : FHSearchBaseItemModel

@property (nonatomic, copy , nullable) NSString *buildingSquareMeter;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong, nullable)   FHHouseItemHouseVideo*   houseVideo;

@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *imprId;

@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, assign) NSInteger cellStyles;
@property (nonatomic, strong, nullable) NSMutableAttributedString *tagString;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *tagImage;
@property (nonatomic, copy , nullable) NSString *displayPriceColor;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, strong, nullable) FHHouseItemHouseExternalModel *externalInfo; // 已下线
@property (nonatomic, strong, nullable) FHSearchHouseVRModel *vrInfo;
@property (nonatomic, copy , nullable) FHSearchHouseDataItemsFakeReasonModel *fakeReason;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsBaseInfoMapModel *baseInfoMap ;

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *houseImage;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsRecommendReasonsModel> *recommendReasons;// 已下线
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, copy , nullable) NSString *displaySameNeighborhoodTitle;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsHouseImageTagModel *houseImageTag ;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsHouseImageTagModel *houseTitleTag ;
@property (nonatomic, copy , nullable) NSString *originPrice;
@property (nonatomic, strong) NSArray* bottomText;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsSkyEyeTagModel *skyEyeTag ; // 先下线
@property (nonatomic, strong , nullable) FHHouseListHouseAdvantageTagModel *advantageDescription ;
@property (nonatomic, strong , nullable) FHDetailContactModel *contactModel ;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *pricePerSqmNum;
@property (nonatomic, copy , nullable) NSString *pricePerSqmUnit;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
@property (nonatomic, strong , nullable) FHNewHouseItemCoreInfoModel *coreInfo ;
@property (nonatomic, strong , nullable) NSDictionary *timeline;
@property (nonatomic, strong , nullable) NSDictionary *comment;
@property (nonatomic, strong , nullable) NSDictionary *globalPricing;
@property (nonatomic, strong , nullable) NSDictionary *floorpanList;
@property (nonatomic, strong , nullable) NSDictionary *contact;
@property (nonatomic, strong , nullable) NSDictionary *userStatus;


@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *pricingNum;
@property (nonatomic, copy , nullable) NSString *pricingUnit;
@property (nonatomic, strong , nullable) NSArray<FHRentFacilitiesModel> *facilities;

@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *displayStatsInfo;
@property (nonatomic, assign) BOOL dealStatus;
@property (nonatomic, copy , nullable) NSString *dealOpenUrl;

@property (nonatomic, copy , nullable) NSString *bizTrace;

@property (nonatomic, assign) BOOL isRecommendCell;
@property (nonatomic, assign) BOOL isLastCell;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *reasonTags;
@property (nonatomic, copy , nullable) NSString *addrData;

+ (NSString *)cellIdentifierByHouseType:(FHHouseType)houseType;

@end

@interface FHSearchHouseItemModel (RecommendReason)

-(BOOL)showRecommendReason;

@end

#pragma mark - 搜索混排卡片整合
// 过滤文本卡片 （已为您过滤xxx套可疑房源）
@interface FHSearchFilterHouseTipModel : FHSearchBaseItemModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *openUrl;

@end
// 猜你想找Tips
@interface FHSearchGuessYouWantTipsModel : FHSearchBaseItemModel

@property (nonatomic, copy , nullable) NSString *text;

@end


// 猜你想找文本
@interface FHSearchGuessYouWantContentModel : FHSearchBaseItemModel

@property (nonatomic, copy , nullable) NSString *text;

@end

#pragma mark - zjing 新model
@interface  FHListSearchHouseDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSString *searchHistoryOpenUrl;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *mapFindHouseOpenUrl;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *topTip;
@property (nonatomic, copy , nullable) NSString *bottomTip;
@property (nonatomic, copy , nullable) FHImageModel *banner;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseItemModel *> *items;
@property (nonatomic, strong , nullable) NSArray<FHSearchBaseItemModel *> *searchItems;
@property (nonatomic, strong , nullable) FHSearchHouseDataRedirectTipsModel *redirectTips;
@property (nonatomic, strong, nullable) FHListSearchHouseDataModel *recommendSearchModel;

@end

@interface  FHListSearchHouseModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHListSearchHouseDataModel *data ;

@end
NS_ASSUME_NONNULL_END
