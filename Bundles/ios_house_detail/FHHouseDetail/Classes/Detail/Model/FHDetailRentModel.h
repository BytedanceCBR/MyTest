//
//  FHDetailRentModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "FHDetailBaseModel.h"
#import <FHHouseBase/FHHouseBaseInfoModel.h>
#import <FHHouseBase/FHRentFacilitiesModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHRentDetailResponseDataSubScoreModel <NSObject>

@end

@interface FHRentDetailResponseDataSubScoreModel : JSONModel
@property (nonatomic, assign) NSInteger sourceValue;
@property (nonatomic, copy , nullable) NSString *sourceName;
@property (nonatomic, copy , nullable) NSString *content;
@end

@protocol FHRentDetailResponseDataSchoolInfoModel <NSObject>

@end

@interface FHRentDetailResponseDataSchoolInfoModel : JSONModel
@property (nonatomic, copy , nullable) NSString *schoolId;
@property (nonatomic, copy , nullable) NSString *schoolName;
@property (nonatomic, assign) NSInteger schoolType;

@end

@interface FHRentDetailResponseDataEvaluationInfo : JSONModel
@property (nonatomic, assign) NSInteger totalScore;
@property (nonatomic, copy , nullable) NSString *detailUrl;
@property (nonatomic, strong, nullable) NSArray<FHRentDetailResponseDataSubScoreModel>* subScores;
@end

@protocol FHRentDetailResponseDataBaseInfoModel<NSObject>

@end


@interface  FHRentDetailResponseDataBaseInfoModel  : JSONModel

@property (nonatomic, assign) BOOL isSingle;
@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;

@end



@interface  FHRentDetailResponseDataNeighborhoodInfoModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *areaId;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *gaodeImageUrl;
@property (nonatomic, strong, nullable) FHDetailGaodeImageModel *gaodeImage;//高德地图静态图
@property (nonatomic, copy , nullable) NSString *areaName;
@property (nonatomic, copy , nullable) NSString *districtId;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmV;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, copy , nullable) NSString *districtName;
@property (nonatomic, copy , nullable) NSString *monthUp;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, strong, nullable) FHRentDetailResponseDataEvaluationInfo* evaluationInfo;
@property (nonatomic, strong , nullable) NSArray<FHDetailDataNeighborhoodInfoSchoolItemModel> *schoolDictList;

@end


@protocol FHRentDetailResponseDataHouseImageModel<NSObject>

@end


@interface  FHRentDetailResponseDataHouseImageModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *name;

@end


//@protocol FHRentDetailResponseDataCoreInfoModel<NSObject>
//
//@end
//
//
//@interface  FHRentDetailResponseDataCoreInfoModel  : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *attr;
//@property (nonatomic, copy , nullable) NSString *value;
//
//@end


//@protocol FHRentDetailResponseDataFacilitiesModel<NSObject>
//
//@end
//
//
//@interface  FHRentDetailResponseDataFacilitiesModel  : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *iconUrl;
//@property (nonatomic, assign) BOOL enabled;
//@property (nonatomic, copy , nullable) NSString *id;
//@property (nonatomic, copy , nullable) NSString *name;
//
//@end


@protocol FHRentDetailResponseDataHouseOverviewListDataModel<NSObject>

@end

@interface  FHRentDetailResponseDataHouseOverviewListDataModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *title;

@end

@interface  FHRentDetailResponseDataHouseOverviewModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *reportUrl;
@property (nonatomic, strong , nullable) NSArray<FHRentDetailResponseDataHouseOverviewListDataModel> *list;

@end

@protocol FHRentDetailResponseDataRichTextModel <NSObject>

@end

@interface FHRentDetailResponseDataRichTextModel : JSONModel
@property (nonatomic, copy , nullable) NSString *linkUrl;
@property (nonatomic, copy , nullable) NSArray<NSNumber*> *highlightRange;
@end


@interface  FHRentDetailResponseDataDisclaimerModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSArray<FHRentDetailResponseDataRichTextModel>* richText;

@end

@interface  FHRentDetailResponseDataUserStatusModel  : JSONModel

@property (nonatomic, assign) NSInteger pricingSubStauts;
@property (nonatomic, assign) NSInteger houseSubStatus;

@end

@protocol FHRentDetailResponseDataTagModel <NSObject>

@end

@interface FHRentDetailResponseDataTagModel : JSONModel
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy, nullable) NSString * backgroundColor;
@property (nonatomic, copy , nullable) NSString *textColor;

@end

@protocol FHRentDetailImShareInfoModel <NSObject>

@end

@interface FHRentDetailImShareInfoModel : JSONModel
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *coverImage;
@property (nonatomic, copy , nullable) NSString *description;
@property (nonatomic, copy , nullable) NSString *title;
@end

#pragma mark - base extra

@protocol FHRentDetailDataBaseExtraSecurityInformationDialogContentContentModel<NSObject>
@end

@interface FHRentDetailDataBaseExtraSecurityInformationDialogContentContentModel : JSONModel

@property (nonatomic, copy , nullable) NSString *dialogContentImage;
@property (nonatomic, copy , nullable) NSString *dialogContentTitle;
@property (nonatomic, copy , nullable) NSString *dialogContentText;
@end

@interface FHRentDetailDataBaseExtraSecurityInformationDialogContentModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHRentDetailDataBaseExtraSecurityInformationDialogContentContentModel> *content;
@property (nonatomic, copy , nullable) NSString *comment;
@end

@interface FHRentDetailDataBaseExtraSecurityInformationModel : JSONModel

@property (nonatomic, strong , nullable) FHRentDetailDataBaseExtraSecurityInformationDialogContentModel *dialogContent ;
@property (nonatomic, copy , nullable) NSString *baseContent;
@property (nonatomic, copy , nullable) NSString *baseTitle;
@property (nonatomic, copy , nullable) NSString *tipsIcon;
@property (nonatomic, copy , nullable) NSString *tipsContent;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraDialogsModel *dialogs ;
@end

@interface FHRentDetailDataBaseExtraModel : JSONModel

@property (nonatomic, strong , nullable) FHRentDetailDataBaseExtraSecurityInformationModel *securityInformation ;
@end

@interface  FHRentDetailResponseDataModel  : JSONModel

@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHRentDetailDataBaseExtraModel *baseExtra ;
@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, strong , nullable) FHRentDetailResponseDataNeighborhoodInfoModel *neighborhoodInfo ;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *houseImage;
@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *coreInfo;
@property (nonatomic, strong , nullable) NSArray<FHRentFacilitiesModel> *facilities;
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, strong , nullable) FHRentDetailResponseDataHouseOverviewModel *houseOverview;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong , nullable) FHDisclaimerModel *disclaimer;
@property (nonatomic, copy, nullable) NSString *reportUrl;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact;
@property (nonatomic, strong , nullable) FHDetailShareInfoModel *shareInfo;
@property (nonatomic, strong, nullable) FHRentDetailResponseDataUserStatusModel* userStatus;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy, nullable) NSString *camplaintUrl;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, strong , nullable) FHRentDetailImShareInfoModel *imShareInfo;
@property (nonatomic, strong , nullable) NSArray<FHFillFormAgencyListItemModel> *chooseAgencyList;

@end


@interface  FHRentDetailResponseModel  : JSONModel

@property (nonatomic, strong, nullable) NSString* status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHRentDetailResponseDataModel *data ;
@property (nonatomic, assign) BOOL isInstantData;//是否是列表页带入的

@end




NS_ASSUME_NONNULL_END

