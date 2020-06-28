//
//  FHDetailBrokerEvaluationModel.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/15.
//

#import "FHDetailBrokerEvaluationModel.h"
@implementation FHDetailBrokerDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end


@implementation FHDetailBrokerContentModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"schema": @"realtor_content_list_schema"
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

@implementation FHDetailBrokerEvaluationModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabList": @"tab_list"
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
