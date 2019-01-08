//
//  FHCitySearchModel.m
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import "FHCitySearchModel.h"

//for implementation
@implementation  FHCitySearchDataDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"cityId": @"city_id",
                           @"fullPinyin": @"full_pinyin",
                           @"simplePinyin": @"simple_pinyin",
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


@implementation  FHCitySearchModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHCitySearchDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
