//
//  FHHouseFindRecommendModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import "FHHouseFindRecommendModel.h"


@implementation FHHouseFindRecommendDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"openUrl": @"open_url",
                           @"priceTitle": @"price_title",
                           @"districtTitle": @"district_title",
                           @"roomNumTitle" : @"room_num_title",
                           @"findHouseNumber" : @"find_house_number",
                           @"bottomOpenUrl": @"bottom_open_url",
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

@implementation FHHouseFindRecommendModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

