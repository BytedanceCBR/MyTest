//
//  FHUGCShortVideoRealtorInfoModel.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/7/30.
//

#import "FHUGCShortVideoRealtorInfoModel.h"

@implementation FHUGCShortVideoRealtorInfo
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"realtorId": @"realtor_id",
                           @"realtorName": @"realtor_name",
                           @"agencyName": @"agency_name",
                           @"mainPageInfo": @"main_page_info",
                           @"firstBizType": @"first_biz_type",
                           @"associateInfo": @"associate_info",
                           @"avatarUrl": @"avatar_url",
                           @"realtorLogPb": @"realtor_log_pb",
                           @"certificationIcon": @"certification_icon",
                           @"certificationPage": @"certification_page",
                           @"chatOpenUrl": @"chat_openurl"
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
@implementation FHUGCShortVideoRealtor

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
@implementation FHUGCShortVideoRealtorInfoModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
