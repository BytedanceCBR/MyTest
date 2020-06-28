//
//  EncyclopediaTracerModel.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/26.
//

#import "EncyclopediaTracerModel.h"

@implementation EncyclopediaTracerModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"categoryName": @"category_name",
        @"enterFrom": @"enter_from",
        @"originFrom": @"origin_from",
        @"pageType": @"page_type",
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
