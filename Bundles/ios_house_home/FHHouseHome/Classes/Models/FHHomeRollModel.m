//GENERATED CODE , DON'T EDIT
#import "FHHomeRollModel.h"
@implementation FHHomeRollDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHHomeRollDataDataDetailModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"houseType": @"house_type",
                           @"openUrl": @"open_url",
                           @"guessSearchId": @"guess_search_id",
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

@implementation FHHomeRollModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHHomeRollDataDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

