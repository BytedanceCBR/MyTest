//
//  FHDetailNeighborhoodModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHDetailNeighborhoodDataStatsInfoModel<NSObject>
@end

@interface FHDetailNeighborhoodDataStatsInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@protocol FHDetailNeighborhoodDataBaseInfoModel<NSObject>
@end

@interface FHDetailNeighborhoodDataBaseInfoModel : JSONModel

@property (nonatomic, assign) BOOL isSingle;
@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@protocol FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoSubScoresModel<NSObject>
@end

@interface FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoSubScoresModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *scoreName;
@property (nonatomic, copy , nullable) NSString *scoreLevel;
@property (nonatomic, copy , nullable) NSString *scoreValue;
@end

@interface FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *totalScore;
@property (nonatomic, copy , nullable) NSString *detailUrl;
@property (nonatomic, strong , nullable) NSArray<FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoSubScoresModel> *subScores;
@end

@protocol FHDetailNeighborhoodNeighborhoodInfoSchoolInfoModel<NSObject>
@end

@interface FHDetailNeighborhoodNeighborhoodInfoSchoolInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *schoolType;
@property (nonatomic, copy , nullable) NSString *schoolId;
@property (nonatomic, copy , nullable) NSString *schoolName;
@end

@interface FHDetailNeighborhoodDataNeighborhoodInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *areaId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *gaodeImageUrl;
@property (nonatomic, copy , nullable) NSString *cityId;
@property (nonatomic, copy , nullable) NSString *areaName;
@property (nonatomic, copy , nullable) NSString *districtId;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmV;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *locationFullName;
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, copy , nullable) NSString *districtName;
@property (nonatomic, copy , nullable) NSString *monthUp;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *id;
@end

@protocol FHDetailNeighborhoodDataTotalSalesListModel<NSObject>
@end

@interface FHDetailNeighborhoodDataTotalSalesListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *dataSource;
@property (nonatomic, copy , nullable) NSString *floorplan;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *squaremeter;
@property (nonatomic, copy , nullable) NSString *agencyName;
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *dealDate;
@end

@interface FHDetailNeighborhoodDataTotalSalesModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *userStatus;
@property (nonatomic, strong , nullable) NSArray<FHDetailNeighborhoodDataTotalSalesListModel> *list;
@end

@interface FHDetailNeighborhoodDataNeighbordhoodStatusModel : JSONModel

@property (nonatomic, copy , nullable) NSString *neighborhoodSubStatus;
@end

@protocol FHDetailNeighborhoodDataCoreInfoModel<NSObject>
@end

@interface FHDetailNeighborhoodDataCoreInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@interface FHDetailNeighborhoodDataModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel> *priceTrend;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong , nullable) NSArray<FHDetailNeighborhoodDataStatsInfoModel> *statsInfo;
@property (nonatomic, strong , nullable) NSArray<FHDetailNeighborhoodDataBaseInfoModel> *baseInfo;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, strong , nullable) FHDetailShareInfoModel *shareInfo ;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataTotalSalesModel *totalSales ;
@property (nonatomic, copy , nullable) NSString *totalSalesCount;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataNeighbordhoodStatusModel *neighbordhoodStatus ;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *abtestVersions;
@property (nonatomic, strong , nullable) NSArray<FHDetailHouseDataItemsHouseImageModel> *neighborhoodImage;
@property (nonatomic, strong , nullable) NSArray<FHDetailNeighborhoodDataCoreInfoModel> *coreInfo;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoModel *evaluationInfo ;
@end

@interface FHDetailNeighborhoodModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataModel *data ;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
