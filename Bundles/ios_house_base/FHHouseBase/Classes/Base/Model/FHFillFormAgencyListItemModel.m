//
//  FHFillFormAgencyListItemModel.m
//  FHHouseBase
//
//  Created by 张静 on 2019/5/5.
//

#import "FHFillFormAgencyListItemModel.h"

@implementation FHFillFormAgencyListItemModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"agencyId": @"agency_id",
                           @"agencyName": @"agency_name",
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
