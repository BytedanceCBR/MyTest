//
//  TTVideoRecommendModel.m
//  Article
//
//  Created by 刘廷勇 on 16/4/27.
//
//

#import "TTVideoRecommendModel.h"

@implementation TTVideoRecommendModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"media_info.name"     : @"userName",
                           @"media_info.media_id" : @"mediaID"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end
