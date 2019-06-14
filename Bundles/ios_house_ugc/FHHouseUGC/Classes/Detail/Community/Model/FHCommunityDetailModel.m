//
// Created by zhulijun on 2019-06-12.
//

#import "FHCommunityDetailModel.h"



@implementation FHCommunityDetailModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end


@implementation FHCommunityDetailDataModel
+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"followed": @"followed",
    };
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName] ?: keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end