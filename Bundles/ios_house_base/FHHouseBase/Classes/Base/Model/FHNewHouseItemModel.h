//
//  FHNewHouseItemModel.h
//  AFgzipRequestSerializer
//
//  Created by 张静 on 2018/11/21.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>
#import "FHBaseModelProtocol.h"
#import "FHHouseListModel.h"
NS_ASSUME_NONNULL_BEGIN



@interface  FHNewHouseItemCoreInfoProperyTypeModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end

@interface  FHNewHouseItemCoreInfoSaleStatusModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end

@interface  FHNewHouseItemCoreInfoModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *courtAddress;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, strong , nullable) FHNewHouseItemCoreInfoSaleStatusModel *saleStatus ;
@property (nonatomic, strong , nullable) FHNewHouseItemCoreInfoProperyTypeModel *properyType ;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *constructionOpendate;
@property (nonatomic, copy , nullable) NSString *aliasName;
@property (nonatomic, copy , nullable) NSString *gaodeImageUrl;

@end


@protocol FHFeedNewHouseRawDataItemsModel<NSObject>

@end

@protocol FHNewHouseItemModel<NSObject>

@end

@interface FHNewHouseItemModel : JSONModel

@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *houseId;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *pricePerSqmNum;
@property (nonatomic, copy , nullable) NSString *pricePerSqmUnit;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) FHNewHouseItemCoreInfoModel *coreInfo ;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong , nullable) NSDictionary *timeline;
@property (nonatomic, strong , nullable) NSDictionary *comment;
@property (nonatomic, strong , nullable) NSDictionary *globalPricing;
@property (nonatomic, strong , nullable) NSDictionary *floorpanList;
@property (nonatomic, strong , nullable) NSDictionary *contact;
@property (nonatomic, strong , nullable) NSDictionary *userStatus;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isLast;

@end

@interface  FHNewHouseListDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHNewHouseItemModel> *items;
@property (nonatomic, copy , nullable) NSString *searchHistoryOpenUrl;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, strong , nullable) FHSearchHouseDataRedirectTipsModel *redirectTips;
@property (nonatomic, assign) NSInteger offset;

@end


@interface  FHNewHouseListResponseModel  : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHNewHouseListDataModel *data ;

@end

@interface FHNewHouseItemModel (RecommendReason)

-(BOOL)showRecommendReason;


@end

NS_ASSUME_NONNULL_END
