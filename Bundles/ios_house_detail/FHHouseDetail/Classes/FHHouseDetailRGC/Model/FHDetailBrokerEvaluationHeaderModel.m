//
//  FHDetailBrokerEvaluationHeaderModel.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/15.
//

#import "FHDetailBrokerEvaluationHeaderModel.h"

@implementation FHDetailBrokerEvaluationHeaderModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"showName": @"show_name"
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
