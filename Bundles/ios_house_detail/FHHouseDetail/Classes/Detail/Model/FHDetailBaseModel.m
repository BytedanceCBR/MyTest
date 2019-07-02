//
//  FHDetailBaseModel.m
//  Pods
//
//  Created by 张静 on 2019/1/31.
//

#import "FHDetailBaseModel.h"

@implementation FHDetailBaseModel

@end

@implementation FHDetailPhotoHeaderModel

@end

@implementation FHDetailHouseDataItemsHouseImageModel
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

@implementation FHDetailShareInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"coverImage": @"cover_image",
                           @"isVideo": @"is_video",
                           @"shareUrl": @"share_url",
                           @"desc": @"description",
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

@implementation FHDetailContactModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
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
                           @"reportButtonText":@"report_button_text"
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






