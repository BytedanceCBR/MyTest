//
//  FHHouseListBaseItemModel.h
//  FHHouseBase
//
//  Created by liuyu on 2020/3/8.
//

#import "JSONModel.h"
#import "FHSearchHouseModel.h"
#import <FHHouseBase/FHHouseType.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHHouseListBaseItemModel<NSObject>

@end

@interface FHHouseListBaseItemModel : FHSearchBaseItemModel
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, assign) FHHouseType houseType;
@property (nonatomic, strong, nullable)   FHHouseItemHouseVideo*   houseVideo;
@property (nonatomic, copy , nullable) NSString *houseid;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, strong, nullable) FHHouseItemHouseExternalModel *externalInfo;
@property (nonatomic, strong, nullable) FHSearchHouseVRModel *vrInfo;
@property (nonatomic, copy , nullable) FHSearchHouseDataItemsFakeReasonModel *fakeReason;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsBaseInfoMapModel *baseInfoMap ;
//@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *coreInfo;
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *houseImage;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsRecommendReasonsModel> *recommendReasons;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *reasonTags;
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
@property (nonatomic, assign) BOOL isSubscribCell;
@property (nonatomic, assign) BOOL isRealHouseTopCell;
@property (nonatomic, assign) BOOL isAgencyInfoCell;
@property (nonatomic, assign) BOOL isNoHousePlaceHoderCell;

@property (nonatomic, strong, nullable) NSAttributedString *tagString;
@property (nonatomic, strong , nullable) NSAttributedString *recommendReasonStr;
///针对于我关注的
@property (nonatomic, copy , nullable) NSString *followId;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *price;
@property (nonatomic, copy , nullable) NSString *salesInfo;
@property (nonatomic, copy , nullable) NSString *pricePerSqm;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;

///针对于消息列表
@property (nonatomic, assign) BOOL isMsgCell;
@property (nonatomic, copy , nullable) NSString *timestamp;
@property (nonatomic, copy , nullable) NSString *moreLabel;
@property (nonatomic, copy , nullable) NSString *dateStr;
@property (nonatomic, copy , nullable) NSString *moreDetail;
@property (nonatomic, strong , nullable) NSArray<FHHouseListBaseItemModel> *items;
@property (nonatomic, assign) BOOL isSoldout;

///针对租房相关
@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *pricingNum;
@property (nonatomic, copy , nullable) NSString *pricingUnit;
@property (nonatomic, strong , nullable) NSArray<FHRentFacilitiesModel> *facilities;
@property (nonatomic, copy , nullable) NSString *addrData;

///针对新房相关
@property (nonatomic, copy , nullable) NSString *pricePerSqmNum;
@property (nonatomic, copy , nullable) NSString *pricePerSqmUnit;
@property (nonatomic, strong , nullable) NSDictionary *timeline;
@property (nonatomic, strong , nullable) NSDictionary *comment;
@property (nonatomic, strong , nullable) NSDictionary *globalPricing;
@property (nonatomic, strong , nullable) NSDictionary *floorpanList;
@property (nonatomic, strong , nullable) NSDictionary *contact;
@property (nonatomic, strong , nullable) NSDictionary *userStatus;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isLast;
@end

@interface  FHHouseListDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHHouseListBaseItemModel> *items;
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
@property (nonatomic, strong, nullable) FHHouseListDataModel *recommendSearchModel;

///针对同房源小区
@property (nonatomic, strong , nullable) FHSearchRealHouseExtModel *externalSite;

///针对于我关注的
@property (nonatomic, strong , nullable) NSArray<FHHouseListBaseItemModel> *followItems;

///针对于消息列表
@property (nonatomic, copy , nullable) NSString *minCursor;

///针对租房相关
@property (nonatomic, copy , nullable) NSString *searchHistoryOpenUrl;
@end

@interface  FHListResultHouseModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseListDataModel *data ;

@end




NS_ASSUME_NONNULL_END
