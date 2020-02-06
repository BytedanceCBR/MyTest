//
//  FHHouseNeighborModel.h
//  FHHouseBase
//
//  Created by 张静 on 2018/12/13.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
#import "FHHouseListModel.h"
#import "FHHouseBaseInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseNeighborDataItemsModel<NSObject>

@end


@interface  FHHouseNeighborDataItemsBaseInfoMapModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *builtYear;

@end

@interface FHHouseNeighborItemHouseVideo : JSONModel

@property (nonatomic, assign)   BOOL   hasVideo;

@end


@interface  FHHouseNeighborDataItemsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong, nullable)   FHHouseNeighborItemHouseVideo*   houseVideo;
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *displayStatsInfo;
@property (nonatomic, strong , nullable) FHHouseNeighborDataItemsBaseInfoMapModel *baseInfoMap ;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;
@property (nonatomic, assign) BOOL dealStatus;
@property (nonatomic, copy , nullable) NSString *dealOpenUrl;
@property (nonatomic, strong , nullable) NSDictionary *neighborhoodInfo; //带入详情页，当前不解析
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;
@property (nonatomic, copy , nullable) NSString *pricePerSqmNum;
@property (nonatomic, copy , nullable) NSString *pricePerSqmUnit;

@end


@interface  FHHouseNeighborDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHHouseNeighborDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSString *searchHistoryOpenUrl;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, strong , nullable) FHSearchHouseDataRedirectTipsModel *redirectTips;
@property (nonatomic, assign) NSInteger offset;

@end


@interface  FHHouseNeighborModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseNeighborDataModel *data ;

@end


@interface FHHouseNeighborDataItemsModel (RecommendReason)

-(BOOL)showRecommendReason;

@end


NS_ASSUME_NONNULL_END
