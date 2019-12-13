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
#import <FHHouseBase/FHImageModel.h>
#import <FHHouseBase/FHHouseCoreInfoModel.h>
#import <FHHouseBase/FHHouseBaseInfoModel.h>
NS_ASSUME_NONNULL_BEGIN

// 和租房共用
//@interface FHDetailDataBaseInfoModel : JSONModel
//
//@property (nonatomic, assign) BOOL isSingle;
//@property (nonatomic, copy , nullable) NSString *attr;
//@property (nonatomic, copy , nullable) NSString *value;
//@end

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


//用户房源评论
@protocol FHUserHouseCommentModel<NSObject>
@end

@interface FHUserHouseCommentModel : JSONModel

@property (nonatomic, copy , nullable) NSString *userName;
@property (nonatomic, copy , nullable) NSString *userAvatar;
@property (nonatomic, copy , nullable) NSString *userContent;
@property (nonatomic, copy , nullable) NSString *evaluationData;

@end

@interface FHDetailOldDataNeighborhoodInfoSchoolConsult : JSONModel

@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *text;

@end

@interface FHDetailOldDataNeighborhoodInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *areaId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *gaodeImageUrl;
@property (nonatomic, strong, nullable) FHDetailGaodeImageModel *gaodeImage;//高德地图静态图
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
@property (nonatomic, strong , nullable) FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoModel *evaluationInfo;
@property (nonatomic, strong , nullable) NSArray<FHDetailDataNeighborhoodInfoSchoolItemModel> *schoolDictList;
@property (nonatomic, assign) BOOL useSchoolIm;
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodInfoSchoolConsult *schoolConsult;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *neighborhoodImage;

@end

@interface FHDetailOldDataNeighborEvalModel : JSONModel

@property (nonatomic, copy , nullable) NSString *score;
@property (nonatomic, copy , nullable) NSString *title;
@end

@interface FHDetailOldDataPriceAnalyzeModel : JSONModel

@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *score;
@property (nonatomic, copy , nullable) NSString *title;
@end

@interface FHDetailOldDataComfortInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *propertyFee;
@property (nonatomic, copy , nullable) NSString *houseCount;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *score;
@property (nonatomic, copy , nullable) NSString *buildingAge;
@property (nonatomic, copy , nullable) NSString *plotRatio;
@end

@interface FHDetailOldDataNeighborhoodPriceRangeModel : JSONModel

@property (nonatomic, copy , nullable) NSString *maxPricePsm;
@property (nonatomic, copy , nullable) NSString *curPricePsm;
@property (nonatomic, copy , nullable) NSString *unit;
@property (nonatomic, copy , nullable) NSString *minPricePsm;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *sameNeighborhoodRoomsSchema;
@end

@interface FHDetailOldDataHousePriceRangeModel : JSONModel

@property (nonatomic, copy , nullable) NSString *curPrice;
@property (nonatomic, copy , nullable) NSString *priceMax;
@property (nonatomic, copy , nullable) NSString *priceMin;
@end

@interface FHDetailOldDataHousePricingRankBuySuggestionModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *type;//(1 建议,2普通,3不建议)
@property (nonatomic, copy , nullable) NSString *score;
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


@protocol FHDetailDataListEntranceItemModel<NSObject>
@end

@interface FHDetailDataListEntranceItemModel : JSONModel

@property (nonatomic, copy , nullable) NSString *icon;
@property (nonatomic, copy , nullable) NSString *listName;
@property (nonatomic, copy , nullable) NSString *entranceUrl;
@end

@protocol FHDetailOldDataHouseImageDictListModel<NSObject>
@end

// 房源详情图片类型
typedef enum : NSInteger {
    FHDetailHouseImageTypeOther             = 0, // 其他
    FHDetailHouseImageTypeApartment         = 2, // 户型
    FHDetailHouseImageTypeLivingroom        = 3, // 客厅
    FHDetailHouseImageTypeBedroom           = 4, // 卧室
    FHDetailHouseImageTypeKitchen           = 5, // 厨房
    FHDetailHouseImageTypeBathroom          = 6, // 卫生间
} FHDetailHouseImageType;

@interface FHDetailOldDataHouseImageDictListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *houseImageTypeName;
@property (nonatomic, assign) FHDetailHouseImageType houseImageType;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *houseImageList;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *instantHouseImageList;
@end


@protocol FHDetailImShareInfoModel <NSObject>

@end


@interface FHDetailImShareInfoModel : JSONModel
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *coverImage;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, copy , nullable) NSString *title;
@end

//@protocol FHVideoHouseVideoVideoInfosModel<NSObject>
//@end
//
//@interface FHVideoHouseVideoVideoInfosModel : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *vid;
//@property (nonatomic, assign) NSInteger imageWidth;
//@property (nonatomic, assign) NSInteger vHeight;
//@property (nonatomic, assign) NSInteger imageHeight;
//@property (nonatomic, assign) NSInteger vWidth;
//@property (nonatomic, copy , nullable) NSString *coverImageUrl;
//@end

//@interface FHVideoHouseVideoModel : JSONModel
//
//@property (nonatomic, strong , nullable) NSArray<FHVideoHouseVideoVideoInfosModel> *videoInfos;
//@property (nonatomic, copy , nullable) NSString *infoSubTitle;
//@property (nonatomic, copy , nullable) NSString *infoTitle;
//@end

#pragma mark - extra info
@interface FHDetailDataBaseExtraDetectiveDialogsModel : JSONModel

@property (nonatomic, copy , nullable) NSString *feedbackContent;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *subTitle;
@property (nonatomic, copy , nullable) NSString *icon;
@end

@protocol FHDetailDataBaseExtraDetectiveReasonListItem <NSObject>
@end

@interface FHDetailDataBaseExtraDetectiveReasonListItem : JSONModel

@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, assign) NSInteger status;

@end

@protocol FHDetailDataBaseExtraDetectiveReasonInfo <NSObject>
@end

@interface FHDetailDataBaseExtraDetectiveReasonInfo : JSONModel

@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *subTitle;
@property (nonatomic, copy , nullable) NSString *buttonText;
@property (nonatomic, copy , nullable) NSString *feedbackContent;
@property (nonatomic, strong , nullable) NSArray<FHDetailDataBaseExtraDetectiveReasonListItem> *reasonList;

@end

@protocol FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel<NSObject>
@end

@interface FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *explainContent;
@property (nonatomic, copy , nullable) NSString *subTitle;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *icon;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraDetectiveReasonInfo *reasonInfo;

@end

@interface FHDetailDataBaseExtraDetectiveDetectiveInfoModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel> *detectiveList;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, assign) BOOL showSkyEyeLogo;
@end

@interface FHDetailDataBaseExtraDetectiveModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *baseTitle;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraDetectiveDetectiveInfoModel *detectiveInfo ;
@property (nonatomic, copy , nullable) NSString *warnContent;
@property (nonatomic, copy , nullable) NSString *icon;
@property (nonatomic, copy , nullable) NSString *tips;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraDialogsModel *dialogs ;
@property (nonatomic, assign) BOOL fromDetail;

@end


@interface FHDetailDataBaseExtraOfficialAgencyModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *source;
@property (nonatomic, copy , nullable) FHImageModel *logo;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *nameSubTitle;
@property (nonatomic, copy , nullable) NSString *agencyId;

@end

@interface FHDetailDataBaseExtraOfficialModel : JSONModel

@property (nonatomic, copy , nullable) NSString *baseTitle;
@property (nonatomic, copy , nullable) NSString *icon;
@property (nonatomic, copy , nullable) NSString *agencyLogoUrl;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraOfficialAgencyModel *agency ;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraDialogsModel *dialogs ;
@end

@interface FHDetailDataBaseExtraBudgetModel : JSONModel

@property (nonatomic, copy , nullable) NSString *baseTitle;
@property (nonatomic, copy , nullable) NSString *baseContent;
@property (nonatomic, copy , nullable) NSString *openUrl;

@end

@interface FHDetailDataBaseExtraFloorInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *baseTitle;
@property (nonatomic, copy , nullable) NSString *baseContent;
@property (nonatomic, copy , nullable) NSString *extraContent;
@property (nonatomic, copy , nullable) NSString *openUrl;

@end

@interface FHDetailDataBaseExtraNeighborhoodModel : JSONModel

@property (nonatomic, copy , nullable) NSString *baseTitle;
@property (nonatomic, copy , nullable) NSString *subName;
@property (nonatomic, copy , nullable) NSString *openUrl;

@end


@interface FHDetailDataBaseExtraModel : JSONModel

@property (nonatomic, strong , nullable) FHDetailDataBaseExtraDetectiveModel *detective;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraOfficialModel *official;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraBudgetModel *budget;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraFloorInfoModel *floorInfo;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraNeighborhoodModel *neighborhoodInfo;

@end

@protocol FHDetailHouseReviewCommentModel
@end
@interface FHDetailHouseReviewCommentModel: JSONModel
@property (nonatomic, copy , nullable) NSString *commentId;
@property (nonatomic, strong , nullable) FHDetailContactModel *realtorInfo;
@property (nonatomic, copy , nullable) NSString *commentText;
@property (nonatomic, copy , nullable) NSString *commentData;
@property (nonatomic, assign) BOOL isExpended;//标识是否全文展开，非服务端字段
@property (nonatomic, assign) CGFloat commentHeight;//标识评论高度，非服务端字段
@property (nonatomic, assign) BOOL addFoldDirect;//标识评论高度，非服务端字段
@end

@interface FHDetailHouseVRDataModel: JSONModel
@property (nonatomic, assign) BOOL hasVr;
@property (nonatomic, strong , nullable) FHImageModel *vrImage;
@property (nonatomic, copy , nullable) NSString *openUrl;
@end

@protocol FHDetailDataQuickQuestionItemModel
@end
@interface FHDetailDataQuickQuestionItemModel : JSONModel

@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *openUrl;

@end

@interface FHDetailDataQuickQuestionModel : JSONModel

@property (nonatomic, copy , nullable) NSString *buttonContent;
@property (nonatomic, strong , nullable) NSArray<FHDetailDataQuickQuestionItemModel> *questionItems;

@end

@interface FHDetailOldDataModel : JSONModel

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, strong , nullable) FHDetailOldDataHousePriceRangeModel *housePriceRange ;
@property (nonatomic, strong , nullable) FHDetailOldDataHousePricingRankModel *housePricingRank ;
@property (nonatomic, strong , nullable) FHDetailHouseVRDataModel *vrData ;
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
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *houseImage;
@property (nonatomic, strong , nullable) NSArray<FHDetailOldDataHouseImageDictListModel> *houseImageDictList;
@property (nonatomic, strong , nullable) FHVideoHouseVideoModel *houseVideo ;
@property (nonatomic, strong , nullable) FHDetailShareInfoModel *shareInfo ;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact;
@property (nonatomic, copy , nullable) NSString *recommendedRealtorsTitle;
@property (nonatomic, strong , nullable) NSArray<FHDetailContactModel> *recommendedRealtors;
@property (nonatomic, strong , nullable) NSArray<FHUserHouseCommentModel> *userHouseComments;
@property (nonatomic, strong , nullable) FHDetailContactModel *highlightedRealtor;
@property (nonatomic, copy , nullable) NSString *abtestVersions;
@property (nonatomic, strong , nullable) FHDisclaimerModel *disclaimer ;
@property (nonatomic, strong , nullable) FHDetailDataCertificateModel *certificate ;
@property (nonatomic, strong , nullable) NSArray<FHDetailDataListEntranceItemModel> *listEntrance;
@property (nonatomic, strong , nullable) FHDetailShareInfoModel *imShareInfo;
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborEvalModel *neighborEval ;
@property (nonatomic, strong , nullable) FHDetailOldDataPriceAnalyzeModel *priceAnalyze ;
@property (nonatomic, strong , nullable) FHDetailOldDataComfortInfoModel *comfortInfo ;
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodPriceRangeModel *neighborhoodPriceRange ;
@property (nonatomic, strong , nullable) NSArray<FHFillFormAgencyListItemModel> *chooseAgencyList;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraModel *baseExtra;
@property (nonatomic, strong , nullable) FHDetailCommunityEntryModel *ugcSocialGroup;
@property (nonatomic, strong , nullable) NSArray<FHDetailHouseReviewCommentModel> *houseReviewComment;
@property (nonatomic, strong , nullable) FHDetailDataQuickQuestionModel *quickQuestion;
@property (nonatomic, copy , nullable) NSString *recommendedHouseTitle;
@property (nonatomic, copy , nullable) NSString *subscriptionToast;
@property (nonatomic, copy , nullable) NSString *reportToast;
@property (nonatomic, copy , nullable) NSString *reportDoneToast;

@end

@interface FHDetailOldModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailOldDataModel *data ;
@property (nonatomic, assign) BOOL isInstantData;//是否是列表页带入的
@end

// MARK 自定义类型
//
//@interface FHDetailPhotoHeaderModel : FHDetailBaseModel
//@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsHouseImageModel> *houseImage;
//@end

NS_ASSUME_NONNULL_END
//END OF HEADER

