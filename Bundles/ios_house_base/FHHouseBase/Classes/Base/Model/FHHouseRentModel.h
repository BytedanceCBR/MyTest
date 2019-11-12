//
//  FHHouseRentModel.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/22.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
#import "FHHouseListModel.h"
#import "FHHouseBaseInfoModel.h"
#import "FHHouseCoreInfoModel.h"
#import "FHRentFacilitiesModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseRentDataItemsModel<NSObject>

@end


@interface  FHHouseRentDataItemsHouseImageTagModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHHouseRentDataItemsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *houseImage;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *pricingNum;
@property (nonatomic, copy , nullable) NSString *pricingUnit;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) FHHouseRentDataItemsHouseImageTagModel *houseImageTag ;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong , nullable) NSArray * bottomText;//bottom text 是二维数组

@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *coreInfo;
@property (nonatomic, strong , nullable) NSArray<FHRentFacilitiesModel> *facilities;

@end


@interface  FHHouseRentDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<NSDictionary *> *items;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *mapFindHouseOpenUrl;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, strong , nullable) FHSearchHouseDataRedirectTipsModel *redirectTips;
@property (nonatomic, assign) NSInteger offset;

@end


@interface  FHHouseRentModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseRentDataModel *data ;

@end

@interface FHHouseRentDataItemsModel (RecommendReason)

-(BOOL)showRecommendReason;

@end

NS_ASSUME_NONNULL_END
