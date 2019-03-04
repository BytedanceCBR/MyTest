//
//  FHDetailOldModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"

NS_ASSUME_NONNULL_BEGIN

// 和租房共用
@interface FHDetailDataBaseInfoModel : JSONModel

@property (nonatomic, assign) BOOL isSingle;
@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@protocol FHDetailOldDataNeighborhoodInfoEvaluationInfoSubScoresModel<NSObject>
@end

@interface FHDetailOldDataNeighborhoodInfoEvaluationInfoSubScoresModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *scoreName;
@property (nonatomic, copy , nullable) NSString *scoreLevel;
@property (nonatomic, copy , nullable) NSString *scoreValue;
@end

@interface FHDetailOldDataNeighborhoodInfoEvaluationInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *totalScore;
@property (nonatomic, copy , nullable) NSString *detailUrl;
@property (nonatomic, strong , nullable) NSArray<FHDetailOldDataNeighborhoodInfoEvaluationInfoSubScoresModel> *subScores;
@end

@protocol FHDetailOldDataNeighborhoodInfoSchoolInfoModel<NSObject>
@end

@interface FHDetailOldDataNeighborhoodInfoSchoolInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *schoolType;
@property (nonatomic, copy , nullable) NSString *schoolId;
@property (nonatomic, copy , nullable) NSString *schoolName;
@end

@interface FHDetailOldDataNeighborhoodInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
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
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, copy , nullable) NSString *districtName;
@property (nonatomic, copy , nullable) NSString *monthUp;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoModel *evaluationInfo ;
@property (nonatomic, strong , nullable) NSArray<FHDetailOldDataNeighborhoodInfoSchoolInfoModel> *schoolInfo;
@end

@interface FHDetailOldDataHousePriceRangeModel : JSONModel

@property (nonatomic, copy , nullable) NSString *curPrice;
@property (nonatomic, copy , nullable) NSString *priceMax;
@property (nonatomic, copy , nullable) NSString *priceMin;
@end

@interface FHDetailOldDataHousePricingRankBuySuggestionModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *type;//(1 建议,2普通,3不建议)
@end

@interface FHDetailOldDataHousePricingRankModel : JSONModel

@property (nonatomic, strong , nullable) FHDetailOldDataHousePricingRankBuySuggestionModel *buySuggestion ;
@property (nonatomic, copy , nullable) NSString *position;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *analyseDetail;
@end

@interface FHDetailOldDataUserStatusModel : JSONModel

@property (nonatomic, assign) NSInteger pricingSubStauts;
@property (nonatomic, assign) NSInteger houseSubStatus;
@end

@protocol FHDetailOldDataHouseOverreviewListModel<NSObject>
@end

@interface FHDetailOldDataHouseOverreviewListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *title;
@end

@interface FHDetailOldDataHouseOverreviewModel : JSONModel

@property (nonatomic, copy , nullable) NSString *reportUrl;
@property (nonatomic, strong , nullable) NSArray<FHDetailOldDataHouseOverreviewListModel> *list;
@end

@protocol FHDetailOldDataCoreInfoModel<NSObject>
@end

@interface FHDetailOldDataCoreInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;
@end

@protocol FHPriceChangeHistoryPriceChangeHistoryHistoryModel<NSObject>
@end

@interface FHPriceChangeHistoryPriceChangeHistoryHistoryModel : JSONModel

@property (nonatomic, copy , nullable) NSString *changeDesc;
@property (nonatomic, copy , nullable) NSString *dateStr;
@end

@interface FHPriceChangeHistoryPriceChangeHistoryModel : JSONModel

@property (nonatomic, copy , nullable) NSString *detailUrl;
@property (nonatomic, strong , nullable) NSArray *history;
@property (nonatomic, copy , nullable) NSString *priceChangeDesc;
@end

@interface FHDetailOldDataModel : JSONModel

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong , nullable) NSArray<FHDetailDataBaseInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong , nullable) FHDetailOldDataHousePriceRangeModel *housePriceRange ;
@property (nonatomic, strong , nullable) FHDetailOldDataHousePricingRankModel *housePricingRank ;
@property (nonatomic, copy , nullable) NSString *partner;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong , nullable) FHDetailOldDataUserStatusModel *userStatus ;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) FHPriceChangeHistoryPriceChangeHistoryModel *priceChangeHistory;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmV;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *DataSourceId;
@property (nonatomic, strong , nullable) FHDetailOldDataHouseOverreviewModel *houseOverreview ;
@property (nonatomic, strong , nullable) NSArray<FHDetailOldDataCoreInfoModel> *coreInfo;
@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel> *priceTrend;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsTagsModel> *tags;
@property (nonatomic, strong , nullable) NSArray<FHDetailHouseDataItemsHouseImageModel> *houseImage;
@property (nonatomic, strong , nullable) FHDetailShareInfoModel *shareInfo ;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact;
@property (nonatomic, strong , nullable) NSArray<FHDetailContactModel> *recommendedRealtors;
@property (nonatomic, strong , nullable) FHDetailContactModel *highlightedRealtor;
@property (nonatomic, copy , nullable) NSString *abtestVersions;
@property (nonatomic, strong , nullable) FHDisclaimerModel *disclaimer ;
@end

@interface FHDetailOldModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailOldDataModel *data ;
@end

// MARK 自定义类型
//
//@interface FHDetailPhotoHeaderModel : FHDetailBaseModel
//@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsHouseImageModel> *houseImage;
//@end

NS_ASSUME_NONNULL_END
//END OF HEADER

