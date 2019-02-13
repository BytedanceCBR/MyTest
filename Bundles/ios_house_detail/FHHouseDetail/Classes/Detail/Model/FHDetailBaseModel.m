//
//  FHDetailBaseModel.m
//  Pods
//
//  Created by 张静 on 2019/1/31.
//

#import "FHDetailBaseModel.h"

@implementation FHDetailBaseModel

@end

@implementation FHDetailPhotoHeaderModel

@end

@implementation FHDetailHouseDataItemsHouseImageModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"urlList": @"url_list",
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

@implementation FHDetailGrayLineModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineHeight = 6.0;
    }
    return self;
}

@end
