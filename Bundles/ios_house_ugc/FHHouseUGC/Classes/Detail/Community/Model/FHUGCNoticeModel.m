//
//  FHUGCNoticeModel.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/10/8.
//

#import "FHUGCNoticeModel.h"
@implementation FHUGCNoticeModelData
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"announcement": @"announcement",
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

@implementation FHUGCNoticeModel
@end
