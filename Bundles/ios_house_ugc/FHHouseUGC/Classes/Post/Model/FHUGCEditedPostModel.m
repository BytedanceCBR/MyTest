//
//  FHUGCEditedPostModel.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/12/23.
//

#import "FHUGCEditedPostModel.h"

@implementation FHUGCEditedPostModelData
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"threadCell": @"thread_cell"
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

@implementation FHUGCEditedPostModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
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
