//
//  FHUGCTagAndRemarkModel.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/2/26.
//

#import "FHUGCTagAndRemarkModel.h"

@implementation FHUGCTagModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"tagId": @"id"
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

@implementation FHUGCRemarkModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"maxScore": @"max_score"
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

@implementation FHUGCTagAndRemarkDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUGCTagAndRemarkModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
