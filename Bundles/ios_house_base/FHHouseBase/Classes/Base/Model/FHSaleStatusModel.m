//
//  FHSaleStatusModel.m
//  FHHouseBase
//
//  Created by bytedance on 2020/7/2.
//

#import "FHSaleStatusModel.h"

@implementation FHSaleStatusModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
                           @"backgroundColor": @"background_color",
                           @"textColor": @"text_color",
                           };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
