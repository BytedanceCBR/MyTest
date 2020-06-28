//
//  FHDetailOldModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

//GENERATED CODE , DON'T EDIT
#import "FHDetailOldModel.h"
@implementation FHDetailOldDataHousePricingRankModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"buySuggestion": @"buy_suggestion",
                           @"analyseDetail": @"analyse_detail",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataCoreInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataUserStatusModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"pricingSubStauts": @"pricing_sub_stauts",
                           @"houseSubStatus": @"house_sub_status",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataNeighborhoodInfoEvaluationInfoSubScoresModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"scoreLevel": @"score_level",
                           @"scoreName": @"score_name",
                           @"scoreValue": @"score_value",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataNeighborhoodInfoEvaluationInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"totalScore": @"total_score",
                           @"detailUrl": @"detail_url",
                           @"subScores": @"sub_scores",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataNeighborhoodInfoSchoolConsult
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"openUrl": @"open_url",
                           @"associateInfo": @"associate_info",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


@implementation FHDetailOldDataNeighborhoodInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"areaId": @"area_id",
                           @"groupId": @"group_id",
                           @"cityId": @"city_id",
                           @"areaName": @"area_name",
                           @"pricingPerSqmV": @"pricing_per_sqm_v",
                           @"districtId": @"district_id",
                           @"pricingPerSqm": @"pricing_per_sqm",
                           @"gaodeLat": @"gaode_lat",
                           @"imprId": @"impr_id",
                           @"districtName": @"district_name",
                           @"monthUp": @"month_up",
                           @"gaodeLng": @"gaode_lng",
                           @"searchId": @"search_id",
                           @"gaodeImageUrl": @"gaode_image_url",
                           @"evaluationInfo": @"evaluation_info",
                           @"schoolDictList": @"school_dict_list",
                           @"neighborhoodImage":@"neighborhood_images",
                           @"useSchoolIm": @"use_school_im",
                           @"schoolConsult": @"school_consult",
                           @"gaodeImage": @"gaode_image",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataComfortInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"buildingAge": @"building_age",
                           @"plotRatio": @"plot_ratio",
                           @"propertyFee": @"property_fee",
                           @"houseCount": @"house_count",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataNeighborhoodPriceRangeModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"maxPricePsm": @"max_price_psm",
                           @"curPricePsm": @"cur_price_psm",
                           @"minPricePsm": @"min_price_psm",
                           @"sameNeighborhoodRoomsSchema": @"same_neighborhood_rooms_schema"
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataHousePriceRangeModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"curPrice": @"cur_price",
                           @"priceMin": @"price_min",
                           @"priceMax": @"price_max",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataNeighborEvalModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataPriceAnalyzeModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"houseType": @"house_type",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

//@implementation FHVideoHouseVideoModel
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"videoInfos": @"video_infos",
//                           @"infoSubTitle": @"info_sub_title",
//                           @"infoTitle": @"info_title",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//@end

//@implementation FHVideoHouseVideoVideoInfosModel
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"vHeight": @"v_height",
//                           @"imageHeight": @"image_height",
//                           @"vWidth": @"v_width",
//                           @"imageWidth": @"image_width",
//                           @"coverImageUrl": @"cover_image_url",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//@end

#pragma mark - base extra
@implementation FHDetailDataBaseExtraDetectiveDetectiveInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"detectiveList": @"detective_list",
                           @"showSkyEyeLogo": @"show_skyeye_logo"
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraDetectiveReasonListItem

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraDetectiveReasonInfo
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"subTitle": @"sub_title",
                           @"buttonText": @"button_text",
                           @"reasonList": @"reason_list",
                           @"feedbackContent": @"feedback_content",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"explainContent": @"explain_content",
                           @"subTitle": @"sub_title",
                           @"reasonInfo": @"reason_info",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


@implementation FHDetailDataBaseExtraDetectiveModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"baseTitle": @"base_title",
                           @"warnContent": @"warn_content",
                           @"detectiveInfo": @"detective_info",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHDetailDataBaseExtraOfficialAgencyModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logoUrl": @"logo_url",
                           @"nameSubTitle": @"name_sub_title",
                           @"agencyId":@"agency_id",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraOfficialModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"baseTitle": @"base_title",
                           @"agencyLogoUrl":@"agency_logo_url",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraBudgetModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"baseTitle": @"base_title",
                           @"baseContent":@"base_content",
                           @"extraContent":@"extra_content",
                           @"openUrl":@"open_url",
                           @"associateInfo": @"associate_info",
                           @"canLoan":@"can_loan",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraSuggestInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"buttonText": @"button_text",
                           @"realtorId":@"base_id",
                           @"autoText":@"auto_text",
                           @"openUrl":@"open_url",
                           @"associateInfo":@"associate_info",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraNeighborhoodModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"baseTitle": @"base_title",
                           @"subName":@"title",
                           @"openUrl":@"open_url",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraHouseCertificationModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"baseTitle": @"base_title",
                           @"subName":@"title",
                           @"openUrl":@"open_url",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraFloorInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"baseTitle": @"base_title",
                           @"baseContent":@"base_content",
                           @"extraContent":@"extra_content",
                           @"openUrl":@"open_url",
                           @"associateInfo": @"associate_info",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataBaseExtraModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"floorInfo": @"floor_info",
                           @"neighborhoodInfo": @"neighborhood_info",
                           @"houseCertificationInfo":@"house_certification"
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHDetailHouseReviewCommentModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"commentId": @"comment_id",
            @"realtorInfo": @"realtor_info",
            @"commentText": @"comment_text",
            @"commentData": @"comment_data",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailHouseVRDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                                   @"hasVr": @"has_vr",
                                   @"vrImage": @"vr_image",
                                   @"openUrl":@"open_url"
                                   };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHDetailDataQuickQuestionItemModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"openUrl": @"open_url",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataQuickQuestionModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"buttonContent": @"button_content",
                           @"questionItems": @"question_items",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHDetailPriceChangeNoticeModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"priceAnalysisUrl": @"price_analysis_url",
                           @"showType": @"show_type",
                           @"changeTitle": @"change_title",
                           @"analysisTitle": @"analysis_title"
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHDetailDownPaymentModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"minDownPayment": @"min_down_payment",
                           @"monthlyPayment": @"monthly_payment",
                           @"openUrl": @"open_url",
                           @"calculatorUrl": @"calculator_url",
                           @"associateInfo": @"associate_info",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHDetailOldVouchModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"vouchStatus": @"vouch_status",
                           @"vouchText": @"vouch_text",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHDetailOldDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"priceTrend": @"price_trend",
                           @"userStatus": @"user_status",
                           @"baseInfo": @"base_info",
                           @"neighborhoodInfo": @"neighborhood_info",
                           @"logPb": @"log_pb",
                           @"houseImage": @"house_image",
                           @"houseVideo": @"house_video",
                           @"houseImageDictList": @"house_image_dict_list",
                           @"shareInfo": @"share_info",
                           @"priceChangeHistory": @"price_change_history",
                           @"pricingPerSqmV": @"pricing_per_sqm_v",
                           @"housePriceRange": @"house_price_range",
                           @"imprId": @"impr_id",
                           @"housePricingRank": @"house_pricing_rank",
                           @"abtestVersions": @"abtest_versions",
                           @"houseOverreview": @"house_overreview",
                           @"uploadAt": @"upload_at",
                           @"vrData":@"vr_data",
                           @"coreInfo": @"core_info",
                           @"highlightedRealtor": @"highlighted_realtor",
                           @"recommendedRealtors": @"recommended_realtors",
                           @"listEntrance": @"list_entrance",
                           @"imShareInfo": @"im_share_info",
                           @"neighborEval": @"neighbor_eval",
                           @"priceAnalyze": @"price_analyze",
                           @"neighborhoodPriceRange": @"neighborhood_price_range",
                           @"comfortInfo": @"comfort_info",
                           @"chooseAgencyList": @"choose_agency_list",
                           @"baseExtra": @"base_extra",
                           @"ugcSocialGroup":@"ugc_social_group",
                           @"houseReviewComment":@"house_review_comments",
                           @"userHouseComments": @"user_evaluations",
                           @"recommendedRealtorsTitle": @"recommended_realtors_title",
                           @"quickQuestion": @"quick_question",
                           @"recommendedHouseTitle": @"recommended_house_title",
                           @"subscriptionToast": @"subscription_toast",
                           @"reportToast": @"report_toast",
                           @"reportDoneToast": @"report_done_toast",
                           @"middleSubscriptionAssociateInfo":@"middle_subscription_associate_info",
                           @"houseImageAssociateInfo": @"house_image_associate_info",
                           @"recommendRealtorsAssociateInfo": @"recommend_realtors_associate_info",
                           @"houseReviewCommentAssociateInfo": @"house_review_comment_associate_info",
                           @"highlightedRealtorAssociateInfo":@"highlighted_realtor_associate_info",

                           @"bizTrace": @"biz_trace",

                           @"priceChangeNotice":@"price_change_notice",
                           @"downPaymentInfo":@"down_payment_info",
                           @"vouchModel":@"vouch_info",
                           @"realtorContent":@"realtor_content"
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


@implementation FHPriceChangeHistoryPriceChangeHistoryModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"detailUrl": @"detail_url",
                           @"priceChangeDesc": @"price_change_desc",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHPriceChangeHistoryPriceChangeHistoryHistoryModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"changeDesc": @"change_desc",
                           @"dateStr": @"date_str",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataListEntranceItemModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"listName": @"list_name",
                           @"entranceUrl": @"entrance_url",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


@implementation FHDetailOldDataHousePricingRankBuySuggestionModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


//@implementation FHDetailDataBaseInfoModel
//
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"isSingle": @"is_single",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//@end

@implementation FHDetailImShareInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"coverImage": @"cover_image",
                           @"shareUrl": @"share_url",
                           @"associateInfo": @"associate_info",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHDetailOldDataHouseOverreviewListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldDataHouseOverreviewModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"reportUrl": @"report_url",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailOldModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUserHouseCommentModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"userName": @"user_name",
            @"userAvatar": @"user_avatar",
            @"userContent": @"user_content",
            @"evaluationData": @"evaluation_data",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


// MARK 自定义类型

