//
//  FHHouseBaseInfoModel.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/6/17.
//

#import "FHHouseBaseInfoModel.h"

@implementation FHHouseBaseInfoModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"isSingle": @"is_single",
                           @"openUrl": @"open_url",
                           
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
