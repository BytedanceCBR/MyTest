//
// Created by zhulijun on 2019-06-04.
//

#import "FHTopicListModel.h"


@implementation FHTopicListResponseItemModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
            @"communityId": @"community_id",
            @"title": @"title",
            @"subtitle": @"subtitle",
            @"des": @"des",
    };
    return [[JSONKeyMapper alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName] ?: keyName;
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end


@implementation FHTopicListResponseDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end


@implementation FHTopicListResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end