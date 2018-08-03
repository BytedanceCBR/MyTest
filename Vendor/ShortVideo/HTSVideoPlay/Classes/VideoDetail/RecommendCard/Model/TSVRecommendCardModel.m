//
//  TSVRecommendCardModel.m
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/15.
//

#import "TSVRecommendCardModel.h"
#import <RACEXTKeyPathCoding.h>

@implementation TSVRecommendCardModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    TSVRecommendCardModel *model;
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"user_cards" : @keypath(model, userCards),
                                                       @"has_more" : @keypath(model, hasMore),
                                                       }];
}

@end
