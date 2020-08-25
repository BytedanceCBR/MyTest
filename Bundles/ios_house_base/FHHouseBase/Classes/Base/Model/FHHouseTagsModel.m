//
//  FHHouseTagsModel.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/6/19.
//

#import "FHHouseTagsModel.h"

@implementation FHHouseTagsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"backgroundColor": @"background_color",
                           @"textColor": @"text_color",
                           @"borderColor": @"border_color"
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
