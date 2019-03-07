//
//  FHDetailNewModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNearbyMapModel : JSONModel

@property (nonatomic, weak , nullable) UITableViewCell *cell;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *title;

@end


@interface FHDetailNewDataUserStatusModel : JSONModel

@property (nonatomic, copy , nullable) NSString *courtOpenSubStatus;
@property (nonatomic, copy , nullable) NSString *pricingSubStatus;
@property (nonatomic, assign) NSInteger courtSubStatus;
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

@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsHouseImageModel> *images;
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

@property (nonatomic, strong , nullable) NSArray<FHDetailHouseDataItemsHouseImageModel> *images;
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
@end

@interface FHDetailNewDataFloorpanListModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *userStatus;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataFloorpanListListModel> *list;
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
@property (nonatomic, copy , nullable) NSString *areaId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *gaodeImageUrl;
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
@property (nonatomic, copy , nullable) NSString *aliasName;
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

@interface FHDetailNewDataModel : JSONModel

@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, strong , nullable) FHDetailNewDataUserStatusModel *userStatus ;
@property (nonatomic, strong , nullable) FHDetailNewDataGlobalPricingModel *globalPricing ;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsTagsModel> *tags;
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
@end

@interface FHDetailNewTimeLineDataModel : JSONModel

@property (nonatomic, strong , nullable) FHDetailNewDataUserStatusModel *userStatus ;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataTimelineListModel> *list;

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
@end



NS_ASSUME_NONNULL_END
//END OF HEADER

