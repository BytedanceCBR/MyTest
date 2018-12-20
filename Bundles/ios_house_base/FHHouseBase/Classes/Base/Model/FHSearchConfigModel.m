//
//  FHSearchConfigModel.m
//  FHBMain
//
//  Created by 谷春晖 on 2018/11/14.
//

#import "FHSearchConfigModel.h"

@implementation  FHSearchConfigDataFilterOptionsOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isEmpty": @"is_empty",
                           @"dynamicFetchUrl": @"dynamic_fetch_url",
                           @"isDynamicFetch": @"is_dynamic_fetch",
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


@implementation  FHSearchConfigModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHSearchConfigDataFilterOptionsModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"supportMulti": @"support_multi",
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


@implementation  FHSearchConfigDataFilterModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"tabId": @"tab_id",
                           @"tabStyle": @"tab_style",
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


@implementation  FHSearchConfigDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHSearchConfigDataAbtestModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"abtestVersions": @"abtest_versions",
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


@implementation  FHSearchConfigDataAbtestParamsModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end



