//
// Created by zhulijun on 2019-07-18.
//

#import "FHUGCCommunityListModel.h"
#import "FHUGCScialGroupModel.h"


@implementation FHUGCCommunityListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHUGCCommunityListDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"socialGroupList": @"social_group_list",
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