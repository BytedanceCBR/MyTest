//
//  FHHouseRealtorUserCommentDataModel.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "FHHouseRealtorUserCommentDataModel.h"

@implementation FHHouseRealtorUserCommentDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
@implementation FHHouseRealtorUserCommentModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"hasMore": @"has_more",
            @"commentInfo": @"comment_info",
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

@implementation FHHouseRealtorUserCommentItemModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"avatarUrl": @"avatar_url",
            @"scoreCount": @"score_count",
            @"layoutStyle": @"layout_style",
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


