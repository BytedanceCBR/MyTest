//
//  FHCityListModel.m
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import "FHCityListModel.h"

@implementation FHHistoryCityListModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"name": @"label",
                           @"cityId": @"cityId",
                           @"simplePinyin": @"simplePinyin",
                           @"pinyin": @"pinyin",
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

@implementation FHHistoryCityCacheModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
