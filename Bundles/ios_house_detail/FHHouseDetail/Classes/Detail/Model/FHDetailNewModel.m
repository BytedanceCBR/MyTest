//
//  FHDetailNewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

//GENERATED CODE , DON'T EDIT
#import "FHDetailNewModel.h"

@implementation FHDetailNearbyMapModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHDetailNewDataGlobalPricingModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"userStatus": @"user_status",
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

@implementation FHHouseDetailImageGroupModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailNewDataTimelineModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"userStatus": @"user_status",
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

@implementation FHDetailNewDataCoreInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"courtAddress": @"court_address",
                           @"courtAddressIcon": @"court_address_icon",                           
                           @"areaId": @"area_id",
                           @"cityId": @"city_id",
                           @"saleStatus": @"sale_status",
                           @"properyType": @"propery_type",
                           @"districtId": @"district_id",
                           @"pricingPerSqm": @"pricing_per_sqm",
                           @"gaodeLat": @"gaode_lat",
                           @"aliasName": @"alias_name",
                           @"constructionOpendate": @"construction_opendate",
                           @"areaName": @"area_name",
                           @"districtName": @"district_name",
                           @"gaodeLng": @"gaode_lng",
                           @"shareInfo": @"share_info",
                           @"gaodeImageUrl": @"gaode_image_url",
                           @"gaodeImage": @"gaode_image",
                           @"dataSourceId": @"data_source_id",
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

@implementation FHDetailNewDataFloorpanListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"userStatus": @"user_status",
                           @"totalNumber": @"total_number",
                           @"highlightedRealtor": @"highlighted_realtor",
                           @"chooseAgencyList": @"choose_agency_list",
                           @"highlightedRealtorAssociateInfo":@"highlighted_realtor_associate_info",
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

@implementation FHDetailNewDataFloorpanListListImagesModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"urlList": @"url_list",
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


@implementation FHDetailNewDataFloorpanListListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"roomCount": @"room_count",
                           @"saleStatus": @"sale_status",
                           @"pricingPerSqm": @"pricing_per_sqm",
                           @"facingDirection": @"facing_direction",
                           @"imprId": @"impr_id",
                           @"searchId": @"search_id",
                           @"groupId": @"group_id",
                           @"imOpenUrl":@"im_openurl",
                           @"associateInfo": @"associate_info",
                           @"displayPrice": @"display_price"
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

@implementation FHDetailNewDataTimelineListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"createdTime": @"created_time",
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

@implementation FHDetailNewDataGlobalPricingListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"agencyName": @"agency_name",
                           @"fromUrl": @"from_url",
                           @"pricingPerSqm": @"pricing_per_sqm",
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

@implementation FHDetailNewModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailNewDataDisclaimerModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"richText": @"rich_text",
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

@implementation FHDetailNewDiscountInfoItemModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"itemType": @"item_type",
        @"itemDesc": @"item_desc",
        @"actionType": @"action_type",
        @"actionDesc": @"action_desc",
        @"discountContent": @"discount_content",
        @"discountSubContent": @"discount_sub_content",
        @"discountReportTitle": @"discount_report_title",
        @"discountReportSubTitle": @"discount_report_sub_title",
        @"discountButtonText": @"discount_button_text",
        @"discountReportDoneTitle": @"discount_report_done_title",
        @"associateInfo": @"associate_info",
        @"discountReportDoneSubTitle":@"discount_report_done_sub_title",
        @"activityURLString": @"activity_url"
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

@implementation FHDetailNewSurroundingInfoSurrounding

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"chatOpenurl": @"chat_openurl",
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

@implementation FHDetailNewSurroundingInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"associateInfo": @"associate_info",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
@end


@implementation FHDetailNewTopImage

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"imageGroup": @"image_group",
        @"smallImageGroup": @"small_image_group",
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




@implementation FHDetailNewDataFloorpanListListSaleStatusModel
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

@implementation FHDetailNewDataDisclaimerRichTextModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"highlightRange": @"highlight_range",
                           @"linkUrl": @"link_url",
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

@implementation FHDetailNewBuildingListItem

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"name": @"name",
                           @"layers": @"layers",
                           @"family": @"family"
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

@implementation FHDetailNewBuildingInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"title": @"title",
                           @"buttonText": @"button_text",
                           @"buildingNameText": @"building_name_text",
                           @"layerText": @"layer_text",
                           @"family": @"family",
                           @"list": @"list"
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

@implementation FHDetailNewDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"userStatus": @"user_status",
                           @"globalPricing": @"global_pricing",
                           @"logPb": @"log_pb",
                           @"imageGroup": @"image_group",
                           @"smallImageGroup": @"small_image_group",
                           @"coreInfo": @"core_info",
                           @"imprId": @"impr_id",
                           @"floorpanList": @"floorpan_list",
                           @"shareInfo": @"share_info",
                           @"highlightedRealtor": @"highlighted_realtor",
                           @"chooseAgencyList": @"choose_agency_list",
                           @"recommendedRealtors": @"recommended_realtors",
                           @"recommendedRealtorsTitle": @"recommended_realtors_title",
                           @"recommendedRealtorsSubTitle":@"recommended_realtors_sub_title",
                           @"socialInfo":@"ugc_social_group",
                           @"houseVideo": @"house_video",
                           @"baseInfo": @"base_info",
                           @"discountInfo": @"discount_info",
                           @"relatedCourtInfo": @"related_court_info",
                           @"surroundingInfo": @"surrounding_info",
                           @"topImages": @"top_images",
                           @"topBanner": @"top_banner",
                           @"changePriceNotifyAssociateInfo": @"change_price_notify_associate_info",
                           @"beginSellingNotifyAssociateInfo": @"begin_selling_notify_associate_info",
                           @"recommendRealtorsAssociateInfo": @"recommend_realtors_associate_info",
                           @"imageGroupAssociateInfo": @"image_group_associate_info",
                           @"discountInfoAssociateInfo": @"discount_info_associate_info",
                           @"highlightedRealtorAssociateInfo":@"highlighted_realtor_associate_info",
                           @"isShowTopImageTab": @"is_show_top_image_tab",
                           @"imageAlbumAssociateInfo": @"image_album_associate_info",
                           @"realtorContent": @"realtor_content",
                           @"buildingInfo": @"building_info"
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

@implementation FHDetailNewTimeLineDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"userStatus": @"user_status",
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

@implementation FHDetailNewTimeLineResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailFloorPanListResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


@implementation FHDetailNewDataCoreInfoSaleStatusModel
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
