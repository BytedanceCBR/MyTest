//
//  FHSearchHouseModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/26.
//

#import "FHSearchHouseModel.h"
#import "FHDetailBaseModel.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "YYText.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHSingleImageInfoCellModel.h"

@implementation  FHSearchHouseDataItemsBaseInfoMapModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"pricingPerSqm": @"pricing_per_sqm",
                           @"builtYear":@"built_year",
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

@implementation FHHouseListHouseAdvantageTagModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"textColor": @"text_color",
                           @"backgroundColor": @"background_color",
                           @"borderColor": @"border_color",
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


@implementation FHSearchRealHouseExtModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
                           @"fakeText":@"fake_text",
                           @"fakeHouse": @"fake_house",
                           @"enableFakeHouse": @"enable_fake_house",
                           @"fakeHouseTotal": @"fake_house_total",
                           @"houseTotal": @"house_total",
                           @"openUrl": @"open_url",
                           @"totalTitle": @"total_title",
                           @"trueHouseTotal": @"true_house_total",
                           @"trueTitle": @"true_title",
                           @"fakeTitle": @"fake_title",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHSearchRealHouseAgencyInfo

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
                           @"agencyTotal": @"agency_total",
                           @"houseTotal": @"house_total",
                           @"openUrl": @"open_url",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHSearchHouseDataItemsFakeReasonModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
                           @"fakeReasonImage": @"fake_reason_image",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

//@implementation FHRecommendSecondhandHouseDataModel
//
//+ (JSONKeyMapper *)keyMapper {
//    NSDictionary *dict = @{
//                           @"hasMore": @"has_more",
//                           @"recommendTitle": @"recommend_title",
//                           @"searchHint": @"search_hint",
//                           @"searchId": @"search_id",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//
//+ (BOOL)propertyIsOptional:(NSString *)propertyName {
//    return YES;
//}
//
//@end

@implementation FHHouseItemHouseExternalModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
                           @"externalName": @"external_name",
                           @"externalUrl": @"external_url",
                           @"backUrl": @"back_url",
                           @"isExternalSite":@"is_external_site",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation  FHSearchHouseDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"refreshTip": @"refresh_tip",
                           @"redirectTips": @"redirect_tips",
                           @"searchId": @"search_id",
                           @"mapFindHouseOpenUrl": @"map_find_house_open_url",
                           @"houseListOpenUrl": @"house_list_open_url",
                           @"recommendSearchModel": @"recommend_search",
                           @"subscribeInfo": @"subscribe_info",
                           @"externalSite": @"external_site",
                           @"agencyInfo": @"agency_info",
                           @"topTip":@"top_tip",
                           @"bottomTip":@"bottom_tip",
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


//@implementation  FHSearchHouseDataItemsNeighborhoodInfoLogPbModel
//
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"imprId": @"impr_id",
//                           @"groupId": @"group_id",
//                           @"searchId": @"search_id",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//
//@end


//@implementation  FHSearchHouseDataItemsNeighborhoodInfoImagesModel
//
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"urlList": @"url_list",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//
//@end





@implementation  FHSearchHouseDataItemsNeighborhoodInfoBaseInfoMapModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"pricingPerSqm": @"pricing_per_sqm",
                           @"builtYear": @"built_year",
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


//@implementation  FHSearchHouseDataItemsBaseInfoModel
//
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//
//@end


//@implementation  FHSearchHouseDataItemsCoreInfoModel
//
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//
//@end


@implementation  FHSearchHouseDataItemsHouseImageTagModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"backgroundColor": @"background_color",
                           @"textColor": @"text_color",
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


@implementation  FHSearchHouseDataItemsRecommendReasonsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"iconTextColor": @"icon_text_color",
                           @"iconTextAlpha": @"icon_text_alpha",
                           @"backgroundAlpha": @"background_alpha",
                           @"textAlpha": @"text_alpha",
                           @"textColor": @"text_color",
                           @"iconText": @"icon_text",
                           @"backgroundColor": @"background_color",
                           @"iconBackgroundAlpha": @"icon_background_alpha",
                           @"iconBackgroundColor": @"icon_background_color",
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

@implementation FHHouseItemHouseVideo

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasVideo": @"has_video"
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

@implementation FHSearchHouseVRModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasVr": @"has_vr",
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

@implementation FHSearchHouseVideoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasVideo": @"has_video",
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



@implementation FHSearchHouseDataItemsSkyEyeTagModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"backgroundColor": @"background_color",
                           @"textColor": @"text_color",
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



@implementation  FHSearchHouseDataItemsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"recommendReasons": @"recommend_reasons",
                           @"baseInfo": @"base_info",
                           @"displaySubtitle": @"display_subtitle",
                           @"neighborhoodInfo": @"neighborhood_info",
                           @"displayPrice": @"display_price",
                           @"displayBuiltYear": @"display_built_year",
                           @"displayTitle": @"display_title",
                           @"houseImageTag": @"house_image_tag",
                           @"houseTitleTag": @"title_tag",
                           @"displayDescription": @"display_description",
                           @"displayPricePerSqm": @"display_price_per_sqm",
                           @"uploadAt": @"upload_at",
                           @"imprId": @"impr_id",
                           @"advantageDescription":@"advantage_description",
                           @"vrInfo": @"vr_info",
                           @"groupId": @"group_id",
                           @"searchId": @"search_id",
                           @"cellStyle": @"cell_style",
                           @"houseImage": @"house_image",
                           @"houseType": @"house_type",
                           @"houseVideo": @"house_video",
                           @"displaySameNeighborhoodTitle": @"display_same_neighborhood_title",
                           @"displayNewNeighborhoodTitle":@"display_new_neighborhood_title",
                           @"baseInfoMap": @"base_info_map",
                           @"coreInfo": @"core_info",
                           @"hid":@"id",
                           @"externalInfo":@"external_info",
                           @"originPrice":@"origin_price",
                           @"subscribeInfo": @"subscribe_info",
                           @"bottomText": @"bottom_text",
                           @"fakeReason": @"fake_reason",
                           @"externalInfo": @"external_info",
                           @"skyEyeTag": @"sky_eye_tag",
                           @"associateInfo": @"associate_info",
                           @"tagImage": @"tag_image",
                           @"recommendType": @"recommend_type",
                           @"titleTags": @"title_tags",
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


//@implementation  FHSearchHouseDataItemsLogPbModel
//
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"imprId": @"impr_id",
//                           @"aNewTag": @"new_tag",
//                           @"groupId": @"group_id",
//                           @"searchId": @"search_id",
//                           };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
//
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//
//@end


//@implementation  FHRecommendSecondhandHouseModel
//
//+ (BOOL)propertyIsOptional:(NSString *)propertyName
//{
//    return YES;
//}
//
//@end

@implementation  FHSearchHouseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation FHCourtBillboardPreviewButtonModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
       @"openUrl": @"open_url",
       @"text": @"text",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHCourtBillboardPreviewItemModel : JSONModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
       @"courtId": @"court_id",
       @"openUrl": @"open_url",
       @"title": @"title",
       @"subtitle": @"subtitle",
       @"pricingPerSqm": @"pricing_per_sqm",
       @"img": @"img",
       @"logPb": @"log_pb",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHCourtBillboardPreviewModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
       @"title": @"title",
       @"button": @"button",
       @"items": @"items",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end


#pragma mark - 新model

@implementation  FHListSearchHouseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation  FHListSearchHouseDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"refreshTip": @"refresh_tip",
                           @"redirectTips": @"redirect_tips",
                           @"searchId": @"search_id",
                           @"mapFindHouseOpenUrl": @"map_find_house_open_url",
                           @"searchHistoryOpenUrl": @"search_history_open_url",
                           @"houseListOpenUrl": @"house_list_open_url",
                           @"recommendSearchModel": @"recommend_search",
                           @"subscribeInfo": @"subscribe_info",
                           @"externalSite": @"external_site",
                           @"agencyInfo": @"agency_info",
                           @"topTip":@"top_tip",
                           @"bottomTip":@"bottom_tip",
                           @"courtBillboardPreview": @"court_billboard_preview",
                           //                           @"currentItems":@"items",
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



@implementation FHSearchHouseDataItemsModelBottomText

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation  FHSearchHouseDataItemsNeighborhoodInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"displaySubtitle": @"display_subtitle",
                           @"displayPricePerSqm": @"display_price_per_sqm",
                           @"displayPrice": @"display_price",
                           @"displayTitle": @"display_title",
                           @"displayDescription": @"display_description",
                           @"displayStatsInfo": @"display_stats_info",
                           @"gaodeLat": @"gaode_lat",
                           @"imprId": @"impr_id",
                           @"displayBuiltYear": @"display_built_year",
                           @"houseType": @"house_type",
                           @"gaodeLng": @"gaode_lng",
                           @"baseInfoMap": @"base_info_map",
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



@implementation FHSearchHouseDataItemsModel (RecommendReason)

-(BOOL)showRecommendReason
{    
    for (FHSearchHouseDataItemsRecommendReasonsModel *reason in self.recommendReasons) {
        if (reason.text.length > 0) {
            return YES;
        }
    }
    return NO;
}

@end


@implementation FHHouseNeighborAgencyModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                                   @"id": @"neighborhood_id",
                                   @"neighborhoodName": @"neighborhood_name",
                                   @"neighborhoodPrice": @"neighborhood_price",
                                   @"displayStatusInfo": @"display_status_info",
                                   @"districtAreaName": @"district_area_name",
                                   @"contactModel": @"realtor_info",
                                   @"associateInfo": @"associate_info",
                                   @"realtorType": @"realtor_type",
                                   @"logPb": @"log_pb",
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

@implementation FHHouseReserveAdviserModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                                   @"tipText": @"tip_text",
                                   @"realtorType": @"realtor_type",
                                   @"targetId": @"target_id",
                                   @"targetName": @"target_name",
                                   @"districtAreaName": @"district_area_name",
                                   @"areaPrice": @"area_price",
                                   @"displayStatusInfo": @"display_status_info",
                                   @"associateInfo": @"associate_info",
                                   @"logPb": @"log_pb",
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

@implementation FHSearchHouseItemTitleTagModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{@"isGradient": @"is_gradient",
                           @"textColor": @"text_color",
                           @"backgroundColor": @"background_color",
                           @"topBackgroundColor": @"top_background_color",
                           @"bottomBackgroundColor": @"bottom_background_color",
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

#pragma mark - 后续统一用FHSearchBaseItemModel 和 FHSearchHouseItemModel

@interface FHSearchHouseItemModel ()

@property (nonatomic, copy, nullable, readwrite) NSDictionary *logPbWithTags;

@end

@implementation  FHSearchHouseItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.topMargin = 0;
    }
    return self;
}

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"houseStatus": @"house_status",
                           @"buildingSquareMeter": @"building_square_meter",
                           @"logPb": @"log_pb",
                           @"recommendReasons": @"recommend_reasons",
                           @"baseInfo": @"base_info",
                           @"displaySubtitle": @"display_subtitle",
                           @"neighborhoodInfo": @"neighborhood_info",
                           @"displayPrice": @"display_price",
                           @"displayBuiltYear": @"display_built_year",
                           @"displayTitle": @"display_title",
                           @"houseImageTag": @"house_image_tag",
                           @"houseTitleTag": @"title_tag",
                           @"displayDescription": @"display_description",
                           @"displayPricePerSqm": @"display_price_per_sqm",
                           @"uploadAt": @"upload_at",
                           @"imprId": @"impr_id",
                           @"vrInfo": @"vr_info",
                           @"videoInfo": @"video_info",
                           @"contactModel": @"realtor_info",
                           @"associateInfo": @"associate_info",
                           
                           @"searchId": @"search_id",
                           @"houseImage": @"house_image",
                           @"houseType": @"house_type",
                           @"houseVideo": @"house_video",
                           @"displaySameNeighborhoodTitle": @"display_same_neighborhood_title",
                           @"baseInfoMap": @"base_info_map",
                           @"coreInfo": @"core_info",

                           @"externalInfo":@"external_info",
                           @"originPrice":@"origin_price",
                           @"subscribeInfo": @"subscribe_info",
                           @"bottomText": @"bottom_text",
                           @"fakeReason": @"fake_reason",
                           @"externalInfo": @"external_info",
                           @"skyEyeTag": @"sky_eye_tag",
                           @"advantageDescription":@"advantage_description",
                           @"cellStyles":@"cell_style",
                           @"cardType": @"card_type",
                           @"tagImage": @"tag_image",
                           
                           @"pricePerSqmNum": @"price_per_sqm_num",
                           @"pricePerSqmUnit": @"price_per_sqm_unit",
                           @"globalPricing":@"global_pricing",
                           @"floorpanList":@"floorpan_list",
                           @"userStatus":@"user_status",

                           @"pricingNum": @"pricing_num",
                           @"pricingUnit": @"pricing_unit",

                           @"houseType": @"house_type",
                           @"coreInfo": @"core_info",
                           @"logPb": @"log_pb",

                           @"houseImageTag": @"house_image_tag",
                           @"houseImage": @"house_image",
                           @"bottomText": @"bottom_text",
                           @"baseInfo": @"base_info",
                           @"coreInfo": @"core_info",
                           @"bizTrace": @"biz_trace",

                           @"gaodeLat": @"gaode_lat",
                           @"gaodeLng": @"gaode_lng",
                           @"displayStatsInfo": @"display_stats_info",
                           @"dealStatus": @"deal_status",
                           @"dealOpenUrl": @"deal_open_url",
                           @"reasonTags": @"reason_tags",
                           @"addrData": @"addr_data",
                           @"recommendType":@"recommend_type",
                           @"titleTags": @"title_tags",
                           @"propertyTag": @"property_tag",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (NSString *)cellIdentifierByHouseType:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNewHouse:
            return @"FHHouseSearchNewHouseCell";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"FHHouseSearchSecondHouseCell";
            break;
        case FHHouseTypeRentHouse:
            return @"FHHouseBaseItemCellRent";
            break;
        case FHHouseTypeNeighborhood:
            return @"FHHouseBaseItemCellNeighborhood";
            break;
        default:
            break;
    }
    return @"FHHouseBaseItemCellList";
}

- (NSDictionary *)logPbWithTags {
    if (!_logPbWithTags) {
        if (self.logPb && [self.logPb isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mutablLogPb = self.logPb.mutableCopy;
            if (self.tags) {
                NSAttributedString *tagsString = [FHSingleImageInfoCellModel tagsStringWithTagList:self.tags];
                mutablLogPb[@"app_house_tags"] = [[self.tags btd_filter:^BOOL(id  _Nonnull obj) {
                    if (obj && [obj isKindOfClass:[FHHouseTagsModel class]]) {
                        FHHouseTagsModel *tagModel = (FHHouseTagsModel *)obj;
                        if (tagModel.content && [tagsString.string containsString:tagModel.content]) {
                            return YES;
                        }
                    }
                    return NO;
                }] btd_map:^id _Nullable(id  _Nonnull obj) {
                    if (obj && [obj isKindOfClass:[FHHouseTagsModel class]]) {
                        FHHouseTagsModel *tagModel = (FHHouseTagsModel *)obj;
                        return tagModel.content;
                    }
                    return @"";
                }];
            }
            if (self.titleTags) {//FHSearchHouseItemTitleTagModel
                mutablLogPb[@"app_marketing_tags"] = [self.titleTags btd_map:^id _Nullable(id  _Nonnull obj) {
                    if (obj && [obj isKindOfClass:[FHSearchHouseItemTitleTagModel class]]) {
                        FHSearchHouseItemTitleTagModel *tagModel = (FHSearchHouseItemTitleTagModel *)obj;
                        return tagModel.text;
                    }
                    return @"";
                }];
            }
            _logPbWithTags = mutablLogPb.copy;
            return _logPbWithTags;
        }
        return self.logPb;
    }
    return _logPbWithTags;
}

- (void)setTags:(NSArray<FHHouseTagsModel> *)tags {
    _tags = tags;
    if (tags.count >0) {
            _tagString = [[NSMutableAttributedString alloc]init];
            for (int m = 0; m<tags.count; m ++) {
                FHHouseTagsModel *element = (FHHouseTagsModel*)tags[m];
                NSDictionary * attDic = @{ NSFontAttributeName:[UIFont themeFontRegular:12] ,NSForegroundColorAttributeName:element.textColor?[UIColor colorWithHexStr:element.textColor]:[UIColor themeOrange1]
                };
                if (_tagString.length >0) {
                    CGSize size1 = [self getStringRect:_tagString size:CGSizeMake( [self tagShowMaxWidth], 14)];
                    CGSize size2 =   [self getStringRect:[[NSAttributedString alloc]initWithString:element.content attributes:attDic] size:CGSizeMake( [self tagShowMaxWidth], 14)];
                    if (size1.width +size2.width > [self tagShowMaxWidth]) {
                        break;
                    }else {
                        [_tagString appendAttributedString: [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" "]  attributes:nil]];
                        [_tagString appendAttributedString: [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ ",element.content]  attributes:attDic]];
                        NSRange substringRange = [_tagString.string rangeOfString:element.content];
                        YYTextBorder *border = [YYTextBorder borderWithFillColor:[UIColor colorWithHexStr:element.backgroundColor] cornerRadius:2];
                        [border setInsets:UIEdgeInsetsMake(0, -4, 0, -4)];
                        [_tagString yy_setTextBackgroundBorder:border range:substringRange];
                    }
                    
                }else {
                    _tagString =  [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ ",element.content]  attributes:attDic];
                    YYTextBorder *border = [YYTextBorder borderWithFillColor:[UIColor colorWithHexStr:element.backgroundColor] cornerRadius:2];
                    [border setInsets:UIEdgeInsetsMake(0, -4, 0, -4)];
                    NSRange substringRange = [_tagString.string rangeOfString:element.content];
                    [_tagString yy_setTextBackgroundBorder:border range:substringRange];
                    CGSize size = [self getStringRect:_tagString size:CGSizeMake( [self tagShowMaxWidth], 14)];
                    if (size.width > [self tagShowMaxWidth]) {
                        _tagString = @"";
                    }
                }
            }
        }
}

- (CGSize)getStringRect:(NSAttributedString *)aString size:(CGSize )sizes
{
    CGRect strSize = [aString boundingRectWithSize:CGSizeMake(sizes.width, sizes.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return  CGSizeMake(strSize.size.width, strSize.size.height);
}

- (CGFloat)tagShowMaxWidth {
    //屏幕宽度-视图左右间距-mainImage-mainImageLeftMargin-rightMargin
    return [UIScreen mainScreen].bounds.size.width - 30 - 85 - 12  - 50;
}
@end

@implementation FHSearchHouseItemModel (RecommendReason)

-(BOOL)showRecommendReason
{
    for (FHSearchHouseDataItemsRecommendReasonsModel *reason in self.recommendReasons) {
        if (reason.text.length > 0) {
            return YES;
        }
    }
    return NO;
}

@end


#pragma mark - 搜索混排卡片整合
// 过滤文本卡片 （已为您过滤xxx套可疑房源）
@implementation  FHSearchFilterHouseTipModel

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

// 猜你想找Tips
@implementation  FHSearchGuessYouWantTipsModel


+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

// 猜你想找文本
@implementation  FHSearchGuessYouWantContentModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHSearchFindHouseHelperModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"cardType": @"card_type",
                           @"buttonText": @"button_text",
                           @"openUrl": @"open_url",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

@end

@implementation FHDynamicLynxModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"cardType": @"card_type",
    @"cellStyle": @"cell_style",
    @"lynxData": @"lynx_data",
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

@implementation FHDynamicLynxCellModel

@end
