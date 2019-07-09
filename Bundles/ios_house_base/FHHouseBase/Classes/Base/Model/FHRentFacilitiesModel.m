//
//  FHRentFacilitiesModel.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/7/3.
//

#import "FHRentFacilitiesModel.h"

@implementation FHRentFacilitiesModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"iconUrl": @"icon_url",
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
