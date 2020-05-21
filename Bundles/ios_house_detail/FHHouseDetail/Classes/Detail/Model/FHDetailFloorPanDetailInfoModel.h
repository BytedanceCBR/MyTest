//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHDetailFloorPanDetailInfoDataBaseInfoModel<NSObject>
@end

@interface FHDetailFloorPanDetailInfoDataBaseInfoModel : JSONModel 

@property (nonatomic, assign) BOOL isSingle;
@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@interface FHDetailFloorPanDetailInfoDataContactModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *phone;
@property (nonatomic, copy , nullable) NSString *noticeDesc;
@end

@protocol FHDetailFloorPanDetailInfoDataRecommendModel<NSObject>
@end

@interface FHDetailFloorPanDetailInfoDataRecommendModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *roomCount;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *squaremeter;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, strong , nullable) NSArray<FHImageModel *> *images;
@property (nonatomic, strong , nullable) FHDetailNewDataCoreInfoSaleStatusModel *saleStatus ;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, assign) NSInteger index;
@end

@interface FHDetailFloorPanDetailInfoDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *areaId;
@property (nonatomic, strong , nullable) NSArray<FHDetailFloorPanDetailInfoDataBaseInfoModel> *baseInfo;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *areaName;
@property (nonatomic, copy , nullable) NSString *districtId;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *squaremeter; //面积
@property (nonatomic, copy) NSString *facingDirection; //朝向
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, strong , nullable) NSArray<FHDetailFloorPanDetailInfoDataRecommendModel> *recommend;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
@property (nonatomic, copy , nullable) NSString *districtName;
@property (nonatomic, copy , nullable) NSString *courtId;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong , nullable) FHDetailNewDataCoreInfoSaleStatusModel *saleStatus ;

@property (nonatomic, strong , nullable) FHDetailContactModel *highlightedRealtor;
@property (nonatomic, strong , nullable) NSArray<FHFillFormAgencyListItemModel> *chooseAgencyList;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact ;
@property (nonatomic, strong , nullable) FHDetailNewUserStatusModel *userStatus ;
@property (nonatomic, strong , nullable)  FHClueAssociateInfoModel *highlightedRealtorAssociateInfo;
@property (nonatomic, strong , nullable) FHDetailNewDataDisclaimerModel *disclaimer ;

/// 099 新增楼盘详情页 户型和样板间展示UI
//@property (nonatomic, copy) NSArray<FHImageModel> *imageDictList;
@property (nonatomic, strong , nullable) NSArray<FHHouseDetailImageListDataModel> *imageDictList;
@end

@interface FHDetailFloorPanDetailInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailFloorPanDetailInfoDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
