//
//  FHDetailNewModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
#import "FHDetailBaseModel.h"
#import "FHHouseNewsSocialModel.h"
#import "FHHouseBaseInfoModel.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNearbyMapModel : JSONModel

@property (nonatomic, weak , nullable) UITableViewCell *cell;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *houseId;
@property (nonatomic, copy , nullable) NSString *houseType;

@end


@protocol FHDetailNewDataGlobalPricingListModel<NSObject>
@end

@interface FHDetailNewDataGlobalPricingListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *agencyName;
@property (nonatomic, copy , nullable) NSString *fromUrl;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@end

@interface FHDetailNewDataGlobalPricingModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *userStatus;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataGlobalPricingListModel> *list;
@end

@protocol FHDetailNewDataImageGroupModel<NSObject>
@end

@interface FHDetailNewDataImageGroupModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *name;
@end

@protocol FHDetailNewDataTimelineListModel<NSObject>
@end

@interface FHDetailNewDataTimelineListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *createdTime;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *desc;
@end

@interface FHDetailNewDataTimelineModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *userStatus;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataTimelineListModel> *list;
@end

@protocol FHDetailNewDataSmallImageGroupModel<NSObject>
@end

@interface FHDetailNewDataSmallImageGroupModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *name;
@end

@protocol FHDetailNewDataFloorpanListListModel<NSObject>
@end

@interface FHDetailNewDataFloorpanListListSaleStatusModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@protocol FHDetailNewDataFloorpanListListImagesModel<NSObject>
@end

@interface FHDetailNewDataFloorpanListListImagesModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHDetailNewDataFloorpanListListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *roomCount;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) FHDetailNewDataFloorpanListListSaleStatusModel *saleStatus ;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *squaremeter;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataFloorpanListListImagesModel> *images;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy , nullable) NSString *facingDirection;
@property (nonatomic, copy) NSString *imOpenUrl;
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *associateInfo;

@end

@interface FHDetailNewDataFloorpanListModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) FHDetailNewUserStatusModel *userStatus;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataFloorpanListListModel> *list;
@property (nonatomic, copy , nullable) NSString *courtId;
@property (nonatomic, copy , nullable) NSString *totalNumber;
//@property (nonatomic, strong , nullable) FHDetailNewDataCoreInfoSaleStatusModel *saleStatus ;
@property (nonatomic, strong , nullable) FHDetailContactModel *highlightedRealtor;
@property (nonatomic, strong , nullable) NSArray<FHFillFormAgencyListItemModel> *chooseAgencyList;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact;
@property (nonatomic, strong , nullable)  FHClueAssociateInfoModel *highlightedRealtorAssociateInfo;

@end

@interface FHDetailNewDataCoreInfoSaleStatusModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, assign) NSInteger index;

@end

@interface FHDetailNewDataCoreInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *courtAddress;
@property (nonatomic, copy , nullable) NSString *courtAddressIcon;
@property (nonatomic, copy , nullable) NSString *areaId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *gaodeImageUrl;
@property (nonatomic, strong, nullable) FHDetailGaodeImageModel *gaodeImage;//高德地图静态图
@property (nonatomic, copy , nullable) NSString *cityId;
@property (nonatomic, strong , nullable) FHDetailNewDataCoreInfoSaleStatusModel *saleStatus ;
@property (nonatomic, copy , nullable) NSString *properyType;
@property (nonatomic, copy , nullable) NSString *districtId;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *constructionOpendate;
@property (nonatomic, copy , nullable) NSString *areaName;
@property (nonatomic, copy , nullable) NSString *shareInfo;
@property (nonatomic, copy , nullable) NSString *districtName;
@property (nonatomic, copy , nullable) NSString *aliasName; // todo zjing 废弃
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *dataSourceId;
@end

@protocol FHDetailNewDataDisclaimerRichTextModel<NSObject>
@end

@interface FHDetailNewDataDisclaimerRichTextModel : JSONModel

@property (nonatomic, strong , nullable) NSArray *highlightRange;
@property (nonatomic, copy , nullable) NSString *linkUrl;
@end

@interface FHDetailNewDataDisclaimerModel : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataDisclaimerRichTextModel> *richText;
@end

@protocol FHDetailNewDiscountInfoItemModel <NSObject>


@end

@interface FHDetailNewDiscountInfoItemModel : JSONModel

@property (nonatomic, assign) NSInteger itemType;
@property (nonatomic, copy , nullable) NSString *itemDesc;
@property (nonatomic, assign) NSInteger actionType;
@property (nonatomic, copy , nullable) NSString *actionDesc;
@property (nonatomic, copy , nullable) NSString *discountContent;
@property (nonatomic, copy , nullable) NSString *discountSubContent;

@property (nonatomic, copy , nullable) NSString *discountReportTitle;
@property (nonatomic, copy , nullable) NSString *discountReportSubTitle;
@property (nonatomic, copy , nullable) NSString *discountButtonText;
@property (nonatomic, copy , nullable) NSString *discountReportDoneTitle;
@property (nonatomic, copy , nullable) NSString *discountReportDoneSubTitle;
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;
@property (nonatomic, strong) NSString *activityURLString;

@end

@interface FHDetailNewSurroundingInfoSurrounding : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *chatOpenurl;

@end

@interface FHDetailNewSurroundingInfo : JSONModel

@property (nonatomic, copy , nullable) NSString *location;
@property (nonatomic, strong , nullable) FHDetailNewSurroundingInfoSurrounding *surrounding;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@end

// todo  zjing 与二手房字段保持一致

@protocol FHDetailNewTopImage <NSObject>


@end

@interface FHDetailNewTopImage : JSONModel

@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, assign) FHDetailHouseImageType type;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataImageGroupModel> *imageGroup;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataSmallImageGroupModel> *smallImageGroup;

@end



@interface FHDetailNewDataModel : JSONModel

@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, strong , nullable) FHDetailNewUserStatusModel *userStatus ;
@property (nonatomic, strong , nullable) FHDetailNewDataGlobalPricingModel *globalPricing ;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataImageGroupModel> *imageGroup;
@property (nonatomic, strong , nullable) FHDetailNewDataTimelineModel *timeline ;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataSmallImageGroupModel> *smallImageGroup;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact ;
@property (nonatomic, strong , nullable) FHDetailContactModel *highlightedRealtor;
@property (nonatomic, strong , nullable) FHDetailNewDataFloorpanListModel *floorpanList ;
@property (nonatomic, strong , nullable) FHDetailShareInfoModel *shareInfo ;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong , nullable) FHDetailNewDataCoreInfoModel *coreInfo ;
@property (nonatomic, strong , nullable) FHDetailNewDataDisclaimerModel *disclaimer ;
@property (nonatomic, strong , nullable) NSArray<FHFillFormAgencyListItemModel> *chooseAgencyList;
@property (nonatomic, strong , nullable) FHHouseNewsSocialModel *socialInfo ;
@property (nonatomic, strong , nullable) NSArray<FHDetailContactModel> *recommendedRealtors;
@property (nonatomic, copy , nullable) NSString *recommendedRealtorsTitle; // 推荐经纪人标题文案
@property (nonatomic, copy , nullable) NSString *recommendedRealtorsSubTitle; // 推荐经纪人副标题文案
@property (nonatomic, strong , nullable) FHVideoHouseVideoModel *houseVideo ;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewTopImage> *topImages;
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;

@property (nonatomic, strong , nullable) NSArray<FHDetailNewDiscountInfoItemModel> *discountInfo;
@property (nonatomic, copy , nullable) NSString *relatedCourtInfo;
@property (nonatomic, strong , nullable) FHDetailNewSurroundingInfo *surroundingInfo ;
@property(nonatomic , strong) FHDetailNewTopBanner *topBanner;
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *changePriceNotifyAssociateInfo;
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *beginSellingNotifyAssociateInfo;
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *recommendRealtorsAssociateInfo;
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *imageGroupAssociateInfo;
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *discountInfoAssociateInfo;
@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *highlightedRealtorAssociateInfo;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataStrategyModel *strategy;

@property (nonatomic, assign) BOOL isShowTopImageTab; //是否显示头图的tab标题，如果显示那么隐藏显示全部按钮
@end

@interface FHDetailNewTimeLineDataModel : JSONModel

@property (nonatomic, strong , nullable) FHDetailNewUserStatusModel *userStatus ;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataTimelineListModel> *list;

@end

@interface FHDetailFloorPanListResponseModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailNewDataFloorpanListModel *data ;
@end

@interface FHDetailNewTimeLineResponseModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailNewTimeLineDataModel *data ;
@end

@interface FHDetailNewModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailNewDataModel *data ;
@property (nonatomic, assign) BOOL isInstantData;//是否是列表页带入的
@end

NS_ASSUME_NONNULL_END
//END OF HEADER

