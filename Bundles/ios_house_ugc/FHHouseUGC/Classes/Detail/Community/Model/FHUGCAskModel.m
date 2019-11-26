//
//  FHUGCAskModel.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/26.
//

#import "FHUGCAskModel.h"

@implementation FHUGCAskModel
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
