//
//  FHUGCVoteModel.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/12.
//

#import "FHUGCVoteModel.h"

@implementation FHUGCVoteModel
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
