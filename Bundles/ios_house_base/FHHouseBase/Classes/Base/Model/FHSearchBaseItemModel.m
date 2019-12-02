//
//  FHSearchBaseItemModel.m
//  FHHouseBase
//
//  Created by 张静 on 2019/11/8.
//

#import "FHSearchBaseItemModel.h"

@implementation FHSearchBaseItemModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"cardType": @"card_type",
                           @"cellStyle": @"cell_style",
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
