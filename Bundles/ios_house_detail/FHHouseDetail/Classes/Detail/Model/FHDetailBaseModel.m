//
//  FHDetailBaseModel.m
//  Pods
//
//  Created by 张静 on 2019/1/31.
//

#import "FHDetailBaseModel.h"shadowImage

@implementation FHDetailBaseModel
- (void)setShadowImageType:(FHHouseShdowImageType)shadowImageType {
    _shadowImageType = shadowImageType;
    switch (shadowImageType) {
        case FHHouseShdowImageTypeLR:
            _shadowImage = [[UIImage imageNamed:@"left_right"]resizableImageWithCapInsets:UIEdgeInsetsMake(0,25,0,25) resizingMode:UIImageResizingModeStretch];
            break;
        case FHHouseShdowImageTypeLTR:
            _shadowImage = [[UIImage imageNamed:@"left_top_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(30,25,0,25) resizingMode:UIImageResizingModeStretch];
            break;
        case FHHouseShdowImageTypeLBR:
            _shadowImage = [[UIImage imageNamed:@"left_bottom_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,25,30,25) resizingMode:UIImageResizingModeStretch];
            break;
        case FHHouseShdowImageTypeRound:
            _shadowImage = [[UIImage imageNamed:@"top_left_right_bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(30,25,30,25) resizingMode:UIImageResizingModeStretch];
            break;
        default:
            break;
    }
}

- (void)setShdowImageScopeType:(FHHouseShdowImageScopeType)shdowImageScopeType {
    if (_shdowImageScopeType ==  FHHouseShdowImageScopeTypeDefault) {
               _shdowImageScopeType = shdowImageScopeType;
    }else {
        _shdowImageScopeType = FHHouseShdowImageScopeTypeAll;
    }
}

@end

@implementation FHDetailPhotoHeaderModel

@end

//@implementation FHDetailHouseDataItemsHouseImageModel
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//                           @"urlList": @"url_list",
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

@implementation FHDetailShareInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"coverImage": @"cover_image",
                           @"isVideo": @"is_video",
                           @"shareUrl": @"share_url",
                           @"desc": @"description",
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

@implementation FHDetailContactImageTagModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"imageUrl":@"image_url"
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

@implementation FHRealtorTag
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
+(JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        NSDictionary *dict = @{
                               @"backgroundColor": @"background_color",
                               @"fontColor": @"font_color",
                               @"borderColor":@"border_color"
                               };
        return dict[keyName]?:keyName;
    }];
}
@end

@implementation FHClueAssociateInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
+(JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        NSDictionary *dict = @{
                               @"imInfo": @"im_info",
                               @"phoneInfo": @"phone_info",
                               @"reportFormInfo":@"report_form_info",
                               };
        return dict[keyName]?:keyName;
    }];
}
@end


@implementation FHDetailContactModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"realtorLogpb": @"realtor_log_pb",
                           @"businessLicense": @"business_license",
                           @"realtorName": @"realtor_name",
                           @"homePage": @"home_page",
                           @"realtorId": @"realtor_id",
                           @"agencyId": @"agency_id",
                           @"agencyName": @"agency_name",
                           @"avatarUrl": @"avatar_url",
                           @"showRealtorinfo": @"show_realtorinfo",
                           @"noticeDesc": @"notice_desc",
                           @"imOpenUrl" : @"chat_openurl",
                           @"imLabel" : @"chat_button_text",
                           @"callButtonText" : @"call_button_text",
                           @"realtorDetailUrl" : @"main_page_info",
                           @"imageTag": @"image_tag",
                           @"reportButtonText":@"report_button_text",
                           @"realtorType":@"realtor_type",
                           @"realtorCellShow":@"realtor_cell_show",
                           @"realtorTags":@"realtor_tags",
                           @"realtorEvaluate":@"realtor_evaluate",
                           @"realtorScoreDisplay":@"realtor_score_display",
                           @"realtorScoreDescription":@"realtor_score_description",
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


@implementation FHDisclaimerModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"richText": @"rich_text",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
@end
@implementation FHDetailPriceTrendValuesModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"timeStr": @"time_str",
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


@implementation FHDisclaimerModelDisclaimerRichTextModel
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
@end

@implementation FHDetailPriceTrendModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHDetailDataCertificateLabelsModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"fontColor": @"font_color",
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

@implementation FHDetailDataCertificateModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"bgColor": @"bg_color",
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

@implementation FHDetailDataNeighborhoodInfoSchoolInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"schoolType": @"school_type",
                           @"schoolId": @"school_id",
                           @"schoolName": @"school_name",
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

@implementation FHDetailDataNeighborhoodInfoSchoolItemModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"schoolTypeName": @"school_type_name",
                           @"schoolList": @"school_list",
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

@implementation FHDetailDataBaseExtraDialogsModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"subTitle": @"sub_title",
                           @"feedbackContent": @"feedback_content",
                           @"reportUrl":@"report_url",
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

@implementation FHDetailCommunityEntryActiveCountInfoModel
+(JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"numColor": @"num_color",
            @"textColor": @"text_color"
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

@implementation FHDetailCommunityEntryActiveInfoModel
+(JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"activeUserAvatar": @"active_user_avatar",
            @"suggestInfo": @"suggest_info",
            @"suggestInfoColor": @"suggest_info_color"
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

@implementation FHDetailCommunityEntryModel
+(JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"activeInfo": @"active_info",
            @"socialGroupSchema": @"social_group_schema",
            @"activeCountInfo": @"active_count_info",
            @"logPb": @"log_pb"
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

@implementation FHDetailGaodeImageModel
+(JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"latRatio": @"lat_ratio",
            @"lngRatio": @"lng_ratio",
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

@implementation FHVideoHouseVideoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"videoInfos": @"video_infos",
                           @"infoSubTitle": @"info_sub_title",
                           @"infoTitle": @"info_title",
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

@implementation FHVideoHouseVideoVideoInfosModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"vHeight": @"v_height",
                           @"imageHeight": @"image_height",
                           @"vWidth": @"v_width",
                           @"imageWidth": @"image_width",
                           @"coverImageUrl": @"cover_image_url",
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

@implementation FHDetailOldDataHouseImageDictListModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"houseImageTypeName": @"house_image_type_name",
                           @"houseImageType": @"house_image_type",
                           @"houseImageList": @"house_image_list",
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




@implementation FHDetailNewTopBanner

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"businessTag": @"business_tag",
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

@implementation FHDetailNewUserStatusModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"courtOpenSubStatus": @"court_open_sub_status",
    @"pricingSubStatus": @"pricing_sub_status",
    @"courtSubStatus": @"court_sub_status",
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
