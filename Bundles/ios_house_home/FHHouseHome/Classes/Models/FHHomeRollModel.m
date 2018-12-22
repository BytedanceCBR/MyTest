//
//  FHHomeRollModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "FHHomeRollModel.h"

//for implementation
@implementation  FHHomeRollDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHHomeRollModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHHomeRollDataDataModel

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
