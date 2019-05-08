//
//  FHNeighborListModel.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/12.
//

#import "FHNeighborListModel.h"

@implementation FHSameNeighborhoodHouseResponse
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHSameNeighborhoodHouseDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"hasMore": @"has_more",
                           @"searchId": @"search_id",
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

@implementation FHRelatedHouseResponse
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
