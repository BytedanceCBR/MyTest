//
//  FHHouseRealtorDetailInfoModel.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/13.
//

#import "FHHouseRealtorDetailInfoModel.h"

@implementation FHHouseRealtorDetailInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"realtorName": @"realtor_name",
            @"avatarUrl": @"avatar_url",
            @"realtorId": @"realtor_id",
            @"agencyName": @"agency_name",
            @"agencyPosition": @"agency_position",
            @"enablePhone": @"enable_phone",
            @"imageTag": @"image_tag",
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

@implementation FHHouseRealtorDetailUserEvaluationModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"isShow": @"is_show",
            @"evaCount": @"eva_count",
            @"hasMore": @"has_more",
            @"commentInfo": @"comment_info",
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

@implementation FHHouseRealtorDetailrRgcModel

@end

@implementation FHHouseRealtorDetailModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHHouseRealtorDetailDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"associateInfo": @"realtor_home_page_associate_info",
            @"realtorTab":@"realtor_tab",
            @"certificationPage": @"certification_page",
            @"realtorTag": @"realtor_tag",
            @"certificationIcon": @"certification_icon",
            @"scoreInfo": @"score_info",
            @"chatOpenUrl": @"chat_open_url",
            @"realtorShop": @"realtor_shop",
            @"ugcTabList": @"ugc_tab_list",
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

@implementation FHHouseRealtorDetailScoreModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"realtorScore": @"realtor_score",
            @"realtorScoreRank": @"realtor_score_rank",
            @"cityName": @"city_name",
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

@implementation FHHouseRealtorDetailUserEvaluationItemModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"avatarUrl": @"avatar_url",
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
@implementation FHHouseRealtorDetailRgcTabModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"showName": @"show_name",
            @"tabName":@"tab_name",
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

@implementation FHHouseRealtorDetailShopModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"isShow": @"is_show",
            @"houseCount": @"house_count",
            @"houseImage": @"house_image",
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

@implementation FHHouseRealtorShopModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"associateInfo": @"realtor_shop_associate_info",
            @"certificationPage": @"certification_page",
            @"certificationIcon": @"certification_icon",
            @"topNeighborhood": @"top_neighborhood",
            @"chatOpenUrl": @"chat_open_url",
            @"houseImage": @"house_image",
            @"houseCount": @"house_count"
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

@implementation FHHouseRealtorShopDetailModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"isShow": @"is_show",
            @"houseCount": @"house_count",
            @"houseImage": @"house_image",
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

