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

