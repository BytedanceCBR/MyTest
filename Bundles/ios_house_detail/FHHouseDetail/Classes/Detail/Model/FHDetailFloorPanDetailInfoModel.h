//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface FHDetailFloorPanDetailInfoDataUserStatusModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *courtOpenSubStatus;
@property (nonatomic, copy , nullable) NSString *pricingSubStatus;
@property (nonatomic, copy , nullable) NSString *courtSubStatus;
@end

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
@property (nonatomic, strong , nullable) NSArray<FHDetailHouseDataItemsHouseImageModel *> *images;
@property (nonatomic, copy , nullable) NSString *searchId;
@end


@interface FHDetailFloorPanDetailInfoDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) FHDetailFloorPanDetailInfoDataUserStatusModel *userStatus ;  
@property (nonatomic, copy , nullable) NSString *areaId;
@property (nonatomic, strong , nullable) NSArray<FHDetailFloorPanDetailInfoDataBaseInfoModel> *baseInfo;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *areaName;
@property (nonatomic, copy , nullable) NSString *districtId;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *squaremeter;
@property (nonatomic, strong , nullable) FHDetailFloorPanDetailInfoDataContactModel *contact ;  
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, strong , nullable) NSArray<FHDetailFloorPanDetailInfoDataRecommendModel> *recommend;
@property (nonatomic, strong , nullable) NSArray<FHDetailHouseDataItemsHouseImageModel> *images;
@property (nonatomic, copy , nullable) NSString *districtName;
@property (nonatomic, copy , nullable) NSString *courtId;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *id;
@end

@interface FHDetailFloorPanDetailInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailFloorPanDetailInfoDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
