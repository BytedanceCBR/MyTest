//
//  FHUGCUserVWhiteModel.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/12/10.
//

#import "FHUGCUserVWhiteModel.h"

@implementation FHUGCUserVWhiteModel
//+ (JSONKeyMapper*)keyMapper
//{
//    NSDictionary *dict = @{
//        @"imageUrl": @"image_url",
//    };
//    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
//        return dict[keyName]?:keyName;
//    }];
//}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
