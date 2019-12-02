//GENERATED CODE , DON'T EDIT
#import "FHSugSubscribeModel.h"

@implementation FHSugListRealHouseTopInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"fakeTitle": @"fake_title",
                           @"houseTotal": @"house_total",
                           @"totalTitle": @"total_title",
                           @"enableFakeHouse": @"enable_fake_house",
                           @"trueHouseTotal": @"true_house_total",
                           @"openUrl": @"open_url",
                           @"fakeText":@"fake_text",
                           @"trueTitle": @"true_title",
                           @"fakeHouseTotal": @"fake_house_total",
                           @"fakeHouse": @"fake_house",
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

@implementation FHSugSubscribeDataDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHSugSubscribeModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHSugSubscribeDataDataSubscribeInfoModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"subscribeId": @"subscribe_id",
    @"isSubscribe": @"is_subscribe",
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

@implementation FHSugSubscribeDataDataItemsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"openUrl": @"open_url",
    @"subscribeId": @"subscribe_id",
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


