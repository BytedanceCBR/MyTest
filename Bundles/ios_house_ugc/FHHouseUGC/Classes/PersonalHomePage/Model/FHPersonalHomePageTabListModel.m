//
//  FHPersonalHomePageTabListModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageTabListModel.h"

@implementation FHPersonalHomePageTabItemModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"showName": @"show_name",
            @"tabName":@"tab_name",
    };
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHPersonalHomePageTabListDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"ugcTabList": @"ugc_tab_list",
    };
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHPersonalHomePageTabListModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
