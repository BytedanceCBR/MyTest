//
//  FHBrowseHistoryHouseDataModel.m
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/7/13.
//

#import "FHBrowseHistoryHouseDataModel.h"


@implementation FHBrowseHistoryHouseDataModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
        @"hasMore": @"has_more",
        @"searchId": @"search_id",
        @"historyItems": @"history_items",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHBrowseHistoryHouseResultModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHBrowseHistoryRentDataModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *dict = @{
        @"hasMore": @"has_more",
        @"searchId": @"search_id",
        @"historyItems": @"history_items",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation FHBrowseHistoryContentModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
